---
name: project_control_plane_204_status
metadata: 
  node_type: memory
  type: project
  originSessionId: 875b9d3f-02ad-4683-a38a-e811fee8986c
---

The #204 epic replaced MotherDuck-based extractor control with a **shared Postgres control plane** (run lifecycle + event log + liveness lease + budget telemetry; the data plane stays MotherDuck). As of 2026-06-25, **GoFrugal and Zakya are both LIVE on it**; SAP is next. **UPDATE 2026-08-27 — SAP IS LIVE TOO; #221 shipped after all.** Verified first-hand off-box (`CONTROL_PG_DSN`, public proxy `reseau.proxy.rlwy.net`): `pg.control.run` has `extractor='sap'`, **896 runs**, hourly ticks all `ok`. Extractors present: zakya 1342 / sap 896 / gofrugal 190 / petpooja 23. **So `bronze_sap.control.*` going silent 26-27 Jun is the CUTOVER, not decay** - those MD tables are the decommissioned legacy surface. Do NOT read that silence as a monitoring gap or emit a "no control-plane visibility into SAP" red: it is a FALSE red (I nearly caused one). Point SAP checks at `pg.control.run`/`event`. **Two real defects found instead (#2775):** (1) daily-loading Sweep 2b allow-lists `source_error/sink_error/rate_limited/parked`, but DB extractors emit a fused `error` - so 84 SAP errors + 7 gofrugal `timeout` are INVISIBLE; filter `NOT IN ('ok','zero_rows','zero_rows_final')` instead. (2) `n_ok`/`n_err` are NULL on `control.run` `ok` rows - `status` is the trustworthy column.

**Architecture (ADRs 0028 control-plane / 0029 ingestion-shapes+grid / 0030 region):** a `control_plane` library — WAL (local crash redo-log, fsync, replayed next run) → ships to Postgres; a **lease** (steal-only-if-expired + a decoupled renewer thread → never false-kills a long run) is the deterministic death-detector; Postgres is a **HARD dependency** (no `CONTROL_PG_DSN` → refuse to run, never load blind). Per-source grain tables live in the shared `control` schema (e.g. `control.gofrugal_grid`, `control.zakya_{grid,cursor,quarantine}`). `control.event.extra` is a nullable **JSONB metrics bag** for source-specific fields (Zakya's n_requests/gen_ms/rate_remaining) that don't warrant shared columns.

**Status-vocab blend (status.py):** API extractors (gofrugal, zakya) split the legs — `source_error`/`sink_error`; DB extractors (sap, ptp, stylehr) use a single fused `error`. Standard run lifecycle (running/ok/partial/failed/died) + `stop_reason` (clean/budget_api/budget_export/budget_time/error/died) across all five.

**Packaging (Path 1):** `control_plane` is **vendored** into each Railway service's `src/` (`control_plane/vendor-sync.sh`, byte-identical guarded by `tests/test_vendored.py`) — Railway builds each service from its subdir, so it can't import a repo-root package. Temporary until published to the public **feather-etl** package (serves both rama_dw + ThankU_DW; ThankU runs its own PG, same code). Box extractors get the lib via their deploy rsync.

**Railway PG:** service `Postgres` (id `adc4fb8f-6a12-4407-a58a-07877bba4a01`), us-west (co-located with the extractors, ADR 0030). Railway extractors use the private DSN via ref-var `CONTROL_PG_DSN = ${{ Postgres.DATABASE_URL }}`; the box + Mac probes use the public TCP proxy `reseau.proxy.rlwy.net:49512`. **DSN/password live in Railway vars — never in the repo.** Schema auto-creates on first run. Nightly DuckDB-postgres-scanner sync → MotherDuck `control_archive` is planned (#225). See [[reference_rama_dw_deployment_topology]] and [[reference_control_plane_query_model]].

**CUTOVER GOTCHA — reconcile the completeness grid, don't start it empty (#238, 2026-06-26).** Schema auto-create ≠ data migration: the gofrugal (#219) and zakya (#222) cutovers created `control.<ext>_grid` **empty**, so the backfill saw no done-state, **re-walked all of history** (regressing #112), burned every tick's walltime (`stop_reason=budget_time`), re-appended duplicate `landing.*` loads, and **stalled Zakya's export-lane edge** (sales_returns/customer_payments — which have no incremental tick — went ~2 days stale; RB flagged it in #232). Fix = `zakya_extract/scripts/reconcile_grid_from_motherduck.py`: one-time idempotent upsert of the frozen MotherDuck `bronze_*.control.grid` → Postgres grid (zakya 139→2236 cells, gofrugal 624→21648). No tick-code change — seeding the state restored the #112 frontier; next tick stopped `clean`, edge healed to T-1.

**CUTOVER RULE GENERALIZED — reconcile EVERY stateful `control.*` table, not just the grid (#245 audit, 2026-06-26).** #238 fixed only the grid; #245 audited all control tables MD↔PG for the two migrated extractors. Findings: (1) **zakya cursor cold-started** (`control.zakya_cursor` born empty) but it was SAFE — seed = `now−2h` (`__main__.py:1158`); first post-cutover tick (12:20 IST) seeded to 10:16 IST, *earlier* than the frozen 12:02 IST watermark, so the 2h lookback covered the window → a **re-pull, not a gap** (65,135/65,636 = 99.2% of re-pulled invoices already existed pre-cutover, silver-absorbed). No targeted re-pull needed. (2) **zakya quarantine NOT carried** (3 MD rows lost) but it's write-only/inert (no `quarantine_read`; parking uses the grid's `attempts`) → documented, not reconciled. (3) `run_events`→`event` starts empty by design (telemetry, not state). (4) Legacy `_control` DB = **dead duplicate** of `bronze_gofrugal.control` (grid 20640/20640 cells + 114/114 run_ids carried via `gofrugal_extract/migrate_control_to_bronze.py`) → **`DROP DATABASE _control` DONE 2026-06-26** (gofrugal pre-cutover history fully in `bronze_gofrugal.control`; dead probe scripts in `gofrugal_api_probe/scripts/` still reference bare `_control.*` and will now error — not run in prod). **The remaining migrations (#221/#223/#224) MUST reconcile ALL stateful tables at cutover** — flagged on each issue. SAP #221 is the real exposure: 3 stateful tables beyond run_events — `backfill_grid`(358, empty→17M-row re-walk), `date_quarantine`(EKKO ledger), `reconcile`(88). ptp/stylehr are run_events-only (clean cutover). Full-history pipeline-health is split across planes (pre-cutover MD heterogeneous run_events ∪ post-cutover PG unified event) → fold a normalized MD history view into #225. Runbook precondition in `docs/agents/deployment.md` → "Control plane (Postgres)".

**Rollout:** gofrugal ✅ · zakya ✅ · **SAP ✅ LIVE (verified 2026-08-27; the 27-Jun 'not deployed' note below is SUPERSEDED)** · petpooja ✅ → ptp #223 → stylehr #224 → control_archive #225 → swap vendoring for the feather-etl dependency.

**SAP #221 state (2026-06-27, branch `issue-221-sap-control-plane` @ commit `87e89ec` — LOCAL to that worktree, NOT pushed; next session: push the feature branch first if it's a fresh checkout — feature branch, no deploy).** Code-authoring slice done + validated locally (full sap_bronze suite **57 green incl. a real Docker-PG integration test** for the new grid/reconcile module). Mirrors the zakya template, DB-extractor side (single fused `ok`/`error` event status, no source/sink split). What landed: `control.py`→psycopg `control.sap_backfill_grid` + `control.sap_reconcile`; `run_events` folds into the generic `control.event` (one row per table load: entity=table, source_attempts=retries, load_ms=duration, extra={schema,pattern,load_id}; one per backfill chunk); `__main__.py` wraps the **loading** modes in `ControlPlane("sap").run()` (lease+WAL+death-detect), read-only/seed modes (reconcile/init-backfill/monitor/uniqueness-gate) run outside; `CONTROL_PG_DSN` hard-dep for loaders; `--monitor` repointed to PG. Vendored `control_plane` into `sap_bronze/src` (vendor-sync + test_vendored extended; box gets it via `ssh_box.py put src/`, `PYTHONPATH=src`, WAL at `~/sap_bronze/control_wal`). Plan: `docs/plans/issue_221_sap_control_plane.md`. **GATED deploy steps (await approval):** (1) box `.env.run` += `CONTROL_PG_DSN` (public proxy); (2) **migrate backfill-grid PROGRESS** MD→PG before first `--scheduled` (the `done` chunks = weeks of expensive HANA reads; re-seeding fresh would idempotent-merge ~17M-row history again — the real #245 exposure; write a one-shot DuckDB postgres-scanner copy `bronze_sap.control.backfill_grid`→`control.sap_backfill_grid`, then `--init-backfill` tops up new pending via ON CONFLICT DO NOTHING); (3) box deploy + live kill→`died` / long-lease-not-reclaimed / resume validation; (4) push + merge. **NOTE the #245 memo's "3 stateful tables": only 2 are loader-resume-state (backfill_grid, reconcile — migrated). `date_quarantine` lives in the separate box script `sap_bronze/deploy/quarantine_dates.sh`, is `CREATE OR REPLACE` nightly from source (audit snapshot + `purchase.ekko_clean` view, MotherDuck), NOT resume-state → self-heals, out of #221 scope, no cutover migration needed.**

**dbt JOINS the control plane — #2640 phase 1 SHIPPED + VERIFIED 2026-08-28.** dbt_runner
dual-writes every tick: MotherDuck (`dbt_control.main.runs`/`run_results`, UNCHANGED, still
AUTHORITATIVE — read MD, not PG, until phase 2) + Railway PG `control.run`/`control.event`
`extractor='dbt'`. PRs #2803/#2804/#2813/#2815/#2840; evidence comment on #2640. Verified in prod:
tick 12:31 exact 1548/1548; 5h window 5/5 runs, 4782/4782 nodes green. Phase 2 = repoint readers
(replica_sync.py hot tick + loading_sweep) TOGETHER, gated on `dbt_runner/parity_check.py` rc 0
**over a window CONTAINING any disputed rows** — a green run over a window that aged past the
dispute proves nothing (that false pass happened). Phase 3 = stop the MD write; **#2835 (manual
dbt runs have no run-level row anywhere) must be settled first**.

**29-Aug close-out: #2840 merged 28-Aug evening; 24h unattended parity 24/24 runs,
26348/26348 nodes (reading on #2640). One gap found+fixed: a transiently-missed run_finish sat
'running' in PG forever while its nodes self-healed — run rows had no sweep. #2862 (merged+deployed
29-Aug 13:03) re-projects all window run rows each tick, so BOTH grains now converge. Phase 1
DONE; #2640 stays open for phases 2–3. Worktree practical-lovelace-7c48c7 / branch
issue-2640-dbt-control-dual-write cleanable once its session ends.

Final projection design (#2840, after a falsified first attempt): **wide 24h lookback + key-diff
on (run_id, seq) + whole-partition select + batched insert** (`store.apply_events_batch`,
executemany — 28k rows 4.4s vs ~2h per-row over the proxy). A forward watermark was WRONG: manual
dbt runs land BEHIND it (0/136 healed). Three prod-only defects found by live verification, none
reproducible locally: JSONB timestamps compare as TEXT in the reader's timezone; manual runs
dropped by a process-lifetime window; per-row inserts. `control.run.extra` JSONB added (mirrors
event.extra) for dbt's action/bronze_watermark/dbt_rc/detail; status kept VERBATIM
(running/ok/error/skipped/blocked). dbt_runner is the 4th vendored control_plane copy.

**⛔ NEVER deploy dbt-runner between :30 and :52 IST — you kill the tick that is running.** Cost 2
ticks on 28-Aug-2026. Cron is `0 * * * *` in **UTC**, so ticks fire at **:30 IST, not :00**, and a
build takes ~19 min. The tell is `status='running'` + `finished_at IS NULL` + **ZERO**
`run_results` rows (on-run-end writes all nodes in ONE statement at the END). Self-heals after 2h
(#384), no corruption — but during verification it is self-reinforcing: each fix you deploy
destroys the tick that would have proved the previous one. **Batch fixes, deploy once, in the
:55–:28 window.** Full writeup in the repo:
`docs/agents/gotchas/redeploying-a-railway-cron-service-kills-its-in-flight-run.md`.

**Next-agent notes:** gofrugal/zakya code are the migration templates. The Zakya `--scheduled` run overshoots its 3000s walltime budget (~2h actual — gates *starting* dates, not in-flight exports; pre-existing, lease makes the overlap safe). Trigger a one-off Railway cron run by temp-setting the cron near-future (runs in the active deployment, no new deployment row), then restore.

**DIRECTION CHANGE (Siraj, 28/29-Aug-2026 — #2845/#2851; supersedes parts of the architecture
block above).** (1) The **global per-extractor lease RETIRES** — ruled "a bad interim solution
for immature code"; replacement = idempotent work units + atomic partition-grid claims with
per-claim expiry/heartbeat (death detection moves from lease to claim expiry). Keep the lease
only until claims land per extractor. (2) The **hard-PG dependency is per-source policy, not
law** — deferred-sync (run through a PG outage on the WAL + a local lock, ship later) is
viable anywhere a volume is attached; measure actual PG-unreachable aborts before building.
(3) "MotherDuck single-writer" is an EXPIRED premise (multi-writer supported) — never cite it.
(4) **#225's nightly control_archive is superseded** by leg 1 of #2634 (slot CDC, 1–5 min).
(5) **#2851**: control-plane PG stays on Railway; Featherbase PG moved to its own new Railway
service; Supabase retires. ADR 0028 gets a dated operator-ruling block via #2845 — until then,
cite ADR 0028 only WITH these rulings. See [[project_data_circulation_2634]].
