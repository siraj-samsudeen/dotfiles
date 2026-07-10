---
name: project_sap_116b_partition_bootstrap
metadata: 
  node_type: memory
  type: project
  originSessionId: 5de0abd2-208c-4a3d-91aa-e76a9da062d3
---

## 2026-06-29 — MERGED TO MAIN + finance silver LIVE + box reconciled (Siraj overrode the defer)
- **#121 spool cutover + #286 append-only finance silver are ON MAIN** (FF merge `a3ecade`; branch
  `issue-121-spool-rewrite` == main; resolved 2 conflicts: dbt_project sap.finance+ptp both kept,
  CONTEXT.md took main's #261 material-group glossary). Siraj explicitly chose merge-now + build-now
  (wanted current CEO numbers) over the earlier tonight-defer.
- **Finance silver BUILT & current**: `silver_sap.finance.acdoca` (135M) + `bseg` (106M) via dbt
  incremental dedup (`qualify row_number() over (PK order by _loaded_at desc)=1`); ALL not_null +
  composite-PK uniqueness tests PASS. Built Mac→MD (MD does the compute). **acdoca had to build
  SOLO** — 4-thread `dbt build` aborted it (MotherDuck concurrent-DDL → see repo gotcha
  `motherduck-concurrent-ddl-aborts-large-model-builds`). ⚠️ OPEN RISK: the hourly Railway gate runs
  `dbt build` 4-threaded → may re-hit this on the giants → **chip spawned** to make the gate robust.
- **Drain**: acdoca + bseg spool chunks landed clean (read-once/append; bseg 1 clean chunk =
  16m24s, read 3,592/s + append 2,044/s; acdoca read 2,719/s); overnight_giants self-stops 09:00.
- **Box ↔ main reconciled** (Siraj: "no divergence, nothing only in box"): `src/**` + ALL installed
  systemd `--user` units already byte-identical to main. Box-only/divergent drift CAPTURED to main
  at `sap_bronze/_box_capture_2026-06-29/` (inert, tagged) — see its README; commented on **#215**
  (box deploy/observe model) pointing there. Genuine keeps: `supervise.sh` (box-only, #215 Observe
  seed), box `pyproject.toml` (ahead of main: vendored control_plane+psycopg, #204/#221). Dropped
  the dead #82 Railway artifacts (Dockerfile/deploy.sh/railway.json — already removed from main by
  #214 ws2 `ea86ed8`, still linger on box → #215/#214 box-cleanup item).
- **#287** = repeatable CEO morning-load report; seed (`sap_bronze/reports/sap_morning_report.py` +
  `probes/issue_121/sap_load_status.py`) + the 2026-06-29 reference report committed; **report chip
  spawned** to perfect it + its skill (CEO wants: lead with freshness, plain English not SAP cols,
  order Sales→Purchase→Masters→Finance, dbt transform time + end-to-end latency mental model).
- New repo gotchas: concurrent-DDL (above) + `bronze-sap-loaded-at-timestamptz-is-plus-5-30-skewed`
  (real `_loaded_at` = shown − 5:30; affects ADR 0025 gold freshness).

- ✅ **#295 RESOLVED + CLOSED — finance off the hourly edge; bseg DISABLED; edge RE-ENABLED (2026-06-29).**
  bseg's hourly edge cliffed (low-res header_ride `_cursor` → merge dedup-set explosion, ~40k @ 15/s,
  held the fd-200 flock → blocked ALL edges). Fix on main (`6b20257`), deployed to box, 95 tests green:
  **bseg `enabled=False`** (disabled — redundant w/ acdoca = S/4 Universal Journal, no consumer; re-enable
  via append/spool, never merge, only if AP/AR open-item detail is needed); **acdoca/bkpf/reguh/regup
  `cadence='nightly_incremental'`** (GL not intraday → nightly SNAPSHOT; acdoca/bkpf history backfill
  continues). Hourly edge **RE-ENABLED** (`sap-drive-edge.timer` active) = 18 tables, zero finance,
  cliff-free (verified live: EDGE no finance, SNAPSHOT carries it, bseg in neither).
- ✅ **Config-vocabulary refactor (#295, `ecbb07f` + CONTEXT.md glossary `62a3944`)** — self-evident,
  collision-free names (pure rename, 0 behaviour change, 95 tests green, box==main): pattern
  `self_timestamped`/`header_ride`/`full_reload`/`period_keyed`; cadence (property `cadence`, override
  `cadence_override`) `hourly`/`nightly_incremental`/`weekly_full_reload`/`nightly_recent_periods`
  (tuple `CADENCES`); fields `incremental_expr`/`incremental_col`/`trailing_window`/`enabled`. The
  dlt-side `write_disposition="replace"` + `partition_axis="period"` were deliberately NOT renamed.
  GOTCHA (cost a wasted pass): macOS/BSD `sed` has NO `\b` — use `perl -i -pe` for word-boundary renames.
  pgrep self-match also bit: verify procs with `ps -eo pid,cmd | grep "[s]ap_bronze"`, not `pgrep -f`.

## What shipped (#116(b) + local cold-pull)
- **Partition grid** (`control.partition_grid`): MATNR-range entity bootstrap (NTILE, row-balanced
  ~400K/bucket — NOT plant; matdoc plant skew 4M:1) + period axis. Modes `--init-partition-grid` /
  `--partition-backfill`. Commits `3cc0955` plan, `29c0f82` impl+tests.
- **MD-independent cold pull** (the #240 outage response): `--local-pull` (`7ebc6a5`) full-dumps SAP →
  per-table local DuckDB on the box (`~/sap_local/<t>.duckdb`, replace, no cursor/merge/grid);
  `pull_local.sh` driver (args+MAXJOBS, `212b7d2`/`3664062`); `--since` cap via `full_dump_sql`;
  `ensure_database` 5x retry (`51cce95`). ~31k rows/s at 3 threads vs ~7-9k single.

## #251 local→MD upload: DONE (2026-06-27, merged `ba035ae`)
- **marc/mvke/rseg/mbewh uploaded to MD via `--local-upload`** (new mode) + `--local-verify` (3-way
  LOCAL/MD/HANA) + `deploy/upload_local.sh` driver. **3-way verified MD==local exactly**: marc
  27,843,929 · mvke 15,800,750 · rseg 3,189,678 · mbewh 29,582,892 (mbewh ≥202501 cap; full HANA 90M).
  HANA-local deltas are post-dump growth the edge catches. **mbew left untouched** (99.96% complete;
  SAP owner's edge fills its 50.9k gap). #251 CLOSED.
- **The load mechanism that worked = app-level row-range Arrow chunking** (~500k-row LIMIT/OFFSET
  slices, one pipe.run each, replace→append, single-threaded stable scan). Forced by the slow box→MD
  uplink + MD per-request deadline — see [[reference_md_load_chunking_from_box]] for the full why.
- Watermark **seeds** (marc/mvke/rseg `--since 20260626`; mbewh max-banked-period) ran after; bounded
  post-dump pulls, NON-URGENT (edge off until the rewrite re-enables; #121 owns watermark/schedule).
- **ALL SAP schedules still DISABLED** (giant-drain timer/stop + hourly `run.sh incremental` cron
  `#DISABLED`, crontab backed up `~/crontab.backup.*`). PTP crons untouched. Re-enable only AFTER the rewrite.
- marc/mvke/rseg/mbewh `_cursor`=NULL on banked rows (header_ride/period) → reconcile gate skips them;
  `--local-verify` covers them instead ([[project_control_plane_204_status]], #110/#116 caveat).

## #121 DESIGN RESET (2026-06-28) — merge model SUPERSEDED by 50k-spool/append-only/local-first
Go-live night proved the merge-based driver structurally wrong for our constraints. New design
(issue comment #121, the contract for the fresh session) = **G1 uniform 50k atomic micro-batch
end-to-end** (read/normalize/write/commit/advance all 50k; a failure loses seconds → retry →
quarantine+move-on; NO multi-million all-or-nothing merge scope). **G2 decouple read from write —
reading SAP is the scarce night-only resource, must NEVER block on MD/PG**: two loops, reader
(SAP→local spool disk) + uploader (spool→MD); MD down for hours → keep reading. **G3 local-first
state, PG=mirror not mid-run dependency**: cursor+progress on local disk (source of truth); PG-down-
mid-run → continue + reconcile later; PG-down-at-START (no cursor) = the ONE hard-stop, flag+halt;
**heartbeat first-class, per-batch (~every 50k/~minute), phase+counts+rate to local disk+log — NEVER
infer state from CPU/process proxies again** (we got that wrong repeatedly). Architecture: backfill
comes OFF dlt merge → Arrow 50k batches → **append-only MD landing** (NOT merge) + dedup-on-read,
unifying SAP with gofrugal/zakya bronze ([[reference_control_plane_query_model]] qualify-max pattern);
revises ADR 0028 (PG hard-dep → mirror).
SURVIVES: Decimal cursors, EDGE→SNAPSHOT→BOOTSTRAP order, EDGE_CUTOFF, #221 cutover (PG demoted).
OBSOLETE (merge artifacts): _quarantine_pending, day-res windowed-edge, mara→replace, banked-table
merge fix. SUBSUMED by G3: fail-soft PG phases + RestartSec=330. Old issue-121-unified-driver branch
kept as record; rewrite branches fresh. Box keeps draining untouched (progressing slowly) until
replaced — no rollback.

### PROBES DONE — all 6 assumptions TESTED on the box (2026-06-28, committed 82cdc36, branch issue-121-spool-rewrite)
`sap_bronze/probes/issue_121/` (p1..p5 + CLAIMS.md ledger); decision = **ADR 0034 (PROPOSED, awaiting
go-ahead)**; tested-claims posted to #121 (comment 4824003281). Hypotheses CONFIRMED with real
HANA/MD/PG, NOT proxies: **(1)** dict→dlt = 457 rows/s, the sink is dlt's per-row **normalize+load
(2,222 + 606/s), NOT HANA**; raw HANA fetch=4,575/s (10× the dict total); **Arrow=14,799/s = 32× dict**
(beats the code's "~20x"). Build Arrow from hdbcli tuples **in Python with a PINNED per-table schema**
— lossless (199/199 cols), moots the old hdbcli Decimal-drift blocker; never `from_pylist`-infer
(gave DECIMAL(4,2) vs dlt's (38,9)). **(2)** 50k append=~11s atomic over the flaky uplink; merge=18.5s
& couples the whole chunk (the overnight stall was merge SCOPE, not 50k size). **(3)** append-only +
dedup-on-read correct for composite keys w/ update-wins. **(4)** local-first cursor works on the
EXISTING `control_plane` WAL (Wal.append/read_new/shipper.ship) + real Railway PG — add a `cursor`
record + `sap_cursor` mirror; PG has NO sap_cursor yet (zakya_cursor exists). **(5)** reader fills
spool with uploader off (MD=0); blip costs 1 batch, no loss/dup; per-batch heartbeat in BOTH phases.
NEXT: implement the spool reader/uploader + cursor-WAL extension once Siraj approves ADR 0034. The old
giant-drive (PID was 368678) still runs nightly until replaced.

### IMPLEMENTED + TESTED (2026-06-28, branch issue-121-spool-rewrite, REBASED onto issue-121-unified-driver)
Siraj approved ("implement"). **CRITICAL: my branch was wrongly based on main; REBASED onto
issue-121-unified-driver (071d784) which is EXACTLY what the box runs (box is scp-deployed, NOT git;
acdoca cursor_expr=GREATEST(TIMESTAMP,LAST_CHANGE_DATETIME) Decimal, windows encoded by
extract._window_param → 14-digit int).** Built `sap_bronze/spool.py`: arrow_batches (pinned-schema
from cursor.description, lowercased to match dlt bronze, lineage), write_chunk (50k parquet, atomic
publish), drain (append-only INSERT BY NAME, per-file schema routing, leaves failures in spool),
clear_uploaded, backfill_window (grid window via _window_param). Driver `run_spool_backfill` +
`--spool-backfill` flag in __main__ — MIRRORS run_backfill (same pending_chunks/mark_chunk/backfill_summary
grid plumbing) swapping merge→spool; coexists with --drive/--backfill (additive, nightly UNCHANGED).
Verified on box: p6 lossless vs dict (DDIC DECIMAL(23,2) stable, not from_pylist's (4,2) drift); p7
e2e write_chunk→drain into real schema, reader writes 0 to MD (G2), (23,2)→(38,9) coercion preserves
sum(tsl); p8 real acdoca window [20250201,20250202) idempotent (re-run dedups); 22 unit tests; data-free
--spool-backfill --max-chunks 0 smoke. **Box live __main__.py RESTORED to unified-driver — my additions
NOT deployed.** Commits: 243cbe4 docs, 13239cf engine, 616e1aa backfill_window, 5a78a7e driver.
**NOT pushed. CUTOVER GATED (the data-touching step, must run at NIGHT — read-window):** (1) first real
--spool-backfill night run filling pending chunks (acdoca 47 / bseg 54 pending per grid); pending
chunks are fresh (not-yet-loaded) so append adds NO dups even pre-silver-dedup; (2) swap --drive's
bootstrap step run_backfill→run_spool_backfill; (3) confirm silver dedup-on-read ready for giants
(ADR 0002) before re-runs. Cursor-WAL (Claim 4b) DEFERRED: giants get G3 from grid(loaded@start)+spool
(durable local)+append-only idempotency+WAL events; PG-down-at-start=hard-stop already (can't read grid).

### LIVE VALIDATION 2026-06-28 (Sunday daytime — Siraj OK'd reading; box idle): SPOOL PROVEN END-TO-END
Ran real `--spool-backfill --max-chunks 1 --only acdoca` on the box. Chunk [20250819,20250824)=1,430,341
rows (grid uses ~5-DAY windows, not months). **READ: ~3,100 rows/s, CONTINUOUS per-50k heartbeats the
whole way, NO stall** (vs merge path's 5.5h silent stall — the core fix works). 29 spool files written.
**Two bugs found+fixed (commit d36f605)**: (1) drain failed on real dlt-managed acdoca — NOT NULL on
_dlt_id/_dlt_load_id (p7's CTAS dropped constraints, hid it); fix synthesises them on insert
(_dlt_load_id=run load_id, _dlt_id=gen_random_uuid, per-table col cache); (2) run_spool_backfill marked
chunk done despite 0 rows landed (backfill_window swallowed drain fails); fix: backfill_window returns
`undrained`, mark done only when undrained==0. **Re-drained the retained 29 files into REAL acdoca: all
1,430,341 landed, 0 dup composite keys, 0 failures, NO HANA re-read (read-once/drain-many resilience
proven).** Test rows tagged `_dlt_load_id='spool-revalidate-20250819'` (deletable; legit history so left
in place — chunk now genuinely done). **KEY FINDING — upload is BANDWIDTH-bound ~1,850 rows/s (~27-40s
per 6MB 50k parquet over the ~222KB/s box→MD uplink), SAME as the merge path** — spool's win is the
fast/observable READ + resilience, NOT upload speed. Current backfill_window is READ-then-DRAIN
SEQUENTIAL per chunk (~19min/1.4M); true read/upload OVERLAP (concurrent loops, G2) would cut wall-time
~1.6×→ deferred optimization. **OPEN DECISION (gated): append to dlt-managed bronze tables (works,
synthesised _dlt cols, low mixing risk — edge merge coexists) vs SEPARATE append-only LANDING table
(cleaner per ADR/gofrugal-zakya, needs silver union+dedup).** Backfill is multi-night
(~150M pending rows / 1,850/s ≈ 2-3 nights) but resumable+observable now.

### CUTOVER WIRED + LIVE (2026-06-28, commit 0dcaf33, pushed): Siraj chose SAME-TABLE append
run_drive BOOTSTRAP step dispatches on env `DRIVE_BOOTSTRAP` (default 'merge'=legacy run_bootstrap;
'spool'=new run_spool_bootstrap → date-giants via 50k spool until drive deadline, newest-first,
resumable; fat partition mbew/marc/mvke/mbewh still merge). run_spool_backfill gained `deadline` param.
**BOX .env.run now has `DRIVE_BOOTSTRAP=spool` + `SPOOL_DIR=/home/rmail/sap_bronze/spool`; run.sh sources
.env.run, so TONIGHT'S 21:00 sap-drive-nightly drains giants via the SPOOL** (monitor by34rc4nm watches;
fail-soft: blip pauses drain, grid resumes; EDGE/SNAPSHOT untouched). **REVERT = set DRIVE_BOOTSTRAP=merge
in .env.run.** Box __main__.py + spool.py = my deployed version (NOT unified-driver anymore — this IS the
cutover). 100 unit tests green. Hourly EDGE ticks use my __main__ but edge path UNCHANGED (safe).
FOLLOW-UPS (deferred, non-blocking): (1) read/upload OVERLAP (concurrent reader+uploader loops) → ~1.6×
wall-time; (2) spool-ify the fat partition axis (mbew etc. still merge); (3) cursor-WAL Claim 4b for the
edge; (4) landing-table option if dlt-mixing ever bites; (5) the 1.43M test rows tagged
spool-revalidate-20250819 in acdoca (legit history, deletable). NOT-merged-to-main: branch awaits PR.

### #121 PIVOT (2026-06-28): giants DEPRIORITIZED; UNIFORM edge-backwards incremental is the priority
Siraj corrected the focus: giant FULL history is NOT priority (I'd spent the session on the spool G3
backfill — useful but lowest tier). Agreed design (traced from #121 06-27 01:07 design + the **5 APPROVED
decisions** in the 06-27 10:23 status): every STAMPED table incremental (txn hourly, masters daily/windowed);
only marker-less → periodic full-refresh (tiny=WEEKLY). **DIVERGENCE found: commit ff6441c reversed the
approved "mara DAILY incremental" → 1.37M nightly FULL-REFRESH** (premise "no grid to window on" is wrong —
windowed-edge needs no grid). **#121-A DONE+DEPLOYED+pushed (commit f51d691, branch issue-121-spool-rewrite):**
mara → native_ts GREATEST(LAEDA,ERSDA), mode=daily, **daily_windowed=True** (new Table flag); driver SNAPSHOT
routes daily_windowed→run_windowed_edge (daily trailing re-merge), marker-less masters (schema=master+replace:
makt+31 dims)→WEEKLY (Sunday-gate `now.weekday()==6`), not nightly. mbew already oracle-gated (not nightly).
mara smoke verified LIVE: 122,970 changed materials re-merged in 51s ~2,400/s (vs cliff 61/s), delta+0
(updates not reload), NOT 1.37M. 100 tests pass. Applied via snapshot run today + 21:00 nightly. The giant
drive I'd launched = STOPPED (lease/CPU freed). **#121-B PENDING (full uniformization, NEXT):** marc/mvke
have partition_axis=entity → EXCLUDED from snapshot loader → their intended daily-merge NEVER runs (stale
after bootstrap) — fix; makt ride-mara vs ML; mbew #254 change-feed; audit every `replace`; no full-refresh
of any marker-having table (ADR 0034). Corrective record = #121 comment 4825122486.

## #121 unified driver — BUILT + GO-LIVE (2026-06-27, branch issue-121-unified-driver) [SUPERSEDED ↑]
Commits 1f6237f (config modes+Decimal cursors) · 685e0c4 (Decimal backfill windowing) · 3057931
(driver) · 42f63f9 (windowed-edge). One **`--drive`** entry point: **EDGE → SNAPSHOT → BOOTSTRAP**
(strict, priority-resume; edge always first), budgeted+resumable. Replaces `--scheduled`+`giant_drain.sh`;
keeps primitives. `--steps snapshot,bootstrap`, `--budget-minutes`, `--gate`, `--edge-trail-days`.
- **Decimal cursors (ADR 0033)**: acdoca `GREATEST(TIMESTAMP,LAST_CHANGE_DATETIME)` (was BUDAT — a
  back-datable posting date that dropped ~424k rows, PROVEN on the box); bkpf/bseg `LAST_CHANGE_DATETIME`;
  vbrk/vbrp `CHANGED_ON`; vbak `UPD_TMSTMP`. All `initial=0` (int) + `settle=False` (full-count gate).
- **Day-res giants lips/vbfa/ekpo/eket CLIFF on dlt-incremental even for 1 day** (confirmed on box,
  EXIT=124) → they EDGE by **windowed trailing re-merge** (`run_windowed_edge`, `backfill_resource`
  over [now-trail,now], default 2d, no cliff: lips 62k/44s). High-res giants (acdoca/bkpf/bseg/vbrp
  Decimal, matdoc/ekbe `CPUDT‖CPUTM`) edge by efficient dlt-incremental. `driver.is_day_res_giant`.
- **EDGE_CUTOFF must track ≈now** (config 20260601 was stale → a ~27d/~10M un-chunked first edge). It
  is the *cold floor only*; after first edge the dlt watermark self-advances. Go-live set
  `BACKFILL_EDGE_CUTOFF=20260627` in box `.env.run` + extended the grid to today (`--init-backfill
  --history-start 20260601 --edge-cutoff 20260627`). The GRID chunks all history; the edge stays thin.
- **#221 PG control plane DEPLOYED**: `CONTROL_PG_DSN`=public proxy `reseau.proxy.rlwy.net:49512`
  (from Railway Postgres `DATABASE_PUBLIC_URL`) in box `.env.run` + Mac `.env.local` (gitignored; NOT
  in git). **Cutover DONE**: `backfill_grid` MD→PG (358 chunks, idempotent ON CONFLICT, per-table
  verified — acdoca 57/50, bseg 54/53) — the Zakya no-re-walk lesson. partition_grid self-heals via
  the data-plane oracle (`driver.needs_bootstrap`). `psycopg`+`pytest` `uv pip install`ed on box.
- **Box validated**: 91 offline tests; `--monitor` reads PG; Decimal edge loads (vbrk/vbak/bkpf);
  windowed-edge (lips); full `--drive` EDGE+SNAPSHOT run.
- **Schedule (NEW --user timers, drafted `deploy/systemd/sap-drive-*`)**: hourly EDGE 09:00–20:00;
  nightly EDGE+SNAPSHOT+BOOTSTRAP 21:00 (budget 510m → ~05:30); 06:00 catch-up+gate. Old
  giant-drain/incremental units stay OFF. Giant history (acdoca 51 / bseg 54 pending) drains overnight.
- **BANKED-TABLE MERGE BUG + FIX (the first full --drive surfaced it, 2026-06-27)**: the #251 tables
  (rseg/marc/mvke/mbewh) were loaded via *replace* → missing dlt's `_dlt_id/_dlt_load_id/_cursor`, so
  the merge-edge `ALTER ADD … NOT NULL`s them → DuckDB "Adding columns with constraints not yet
  supported". dlt's merge also writes through a `<schema>_staging` table; a STALE staging table gets
  the same fatal ALTER. **FIX (no HANA re-pull, data preserved): pre-add the 3 cols as nullable VARCHAR
  to the MAIN table + DROP the stale `<schema>_staging.<tbl>` so dlt CREATEs it fresh** (CREATE-with-
  constraints is legal; only ALTER-ADD-with-constraint fails). **APPLIED to all 4 on MD** (verified
  via MCP: 3 cols present, marc/mvke/mbewh staging dropped). **rseg VALIDATED** (17,339 merged,
  3,189,678→3,193,010). marc/mvke/mbewh merge un-validated only because the box network degraded
  (Tailscale relay-fallback, MD DEADLINE_EXCEEDED) — the fix is proven on rseg, will work when run.
  Also surfaced a CASCADE: rseg's stranded pending package re-failed ekpo/eket (same purchase pipeline)
  → fixed by the new `_quarantine_pending` (commit 612df15, drop_pending_packages on failure in
  run_load/run_windowed_edge/bootstrap). LESSON: smoke the actual banked tables (replace→merge), not
  just the new logic.
- **mara COLD-EDGE CLIFF (go-live night, 2026-06-27)**: the driver seeds the day-res GIANTS
  (windowed-edge / EDGE_CUTOFF floor) but NOT the large day-res MASTER `mara` (cursor
  GREATEST(LAEDA,ERSDA), day-res, 1.37M). Its cold first edge from '00000000' in the SNAPSHOT step
  hit the dedup cliff (**61 rows/s** — ~6h for mara, starving the night). Fix tonight: stop nightly →
  backup mara (bronze_sap.pre_drive_backup.mara) → clear master pending pkg → `--incremental --only
  mara,kna1,lfa1,aufk --refresh --no-gate` (REPLACE-bootstrap, no dedup → no cliff, seeds the
  watermark) → restart nightly (mara edge now a small delta). **CODE FOLLOW-UP**: bootstrap-via-replace
  any day-res incremental table on its cold first load (no stored watermark), or seed it — else a
  fresh deploy re-cliffs on mara. kna1/lfa1/aufk (~11k) don't cliff (small) but seeded for cleanliness.
- **FLAKY-INTERNET CRASH LOOP + fail-soft fix (go-live night, commit 071d784)**: the box's office
  internet intermittently times out box->PG (Railway public proxy) + box->MD. A box->PG blip raised an
  uncaught `psycopg.OperationalError` in `_ensure_fat_bootstrapped` -> `control.partition_summary` ->
  crashed `--drive` -> left a FRESH control-plane lease -> systemd's 30s restart collided
  ("another live run holds the lease") -> crash-looped until the 300s lease lapsed, re-ran
  edge+snapshot, re-crashed. Zero drain progress. The control_plane LIB ops (run.event/lease/ship)
  buffer to the WAL + survive blips; the DIRECT psycopg queries in run_drive did not. FIX: wrap the 3
  direct-PG phases (_ensure_fat_bootstrapped, run_bootstrap, _drive_gate) in try/except -> log + PAUSE
  (grid resumes next run), never crash; + bump nightly unit `RestartSec` 30->330 (> lease TTL) so a
  true crash can't tight-loop. **FOLLOW-UP**: per-chunk reconnect-retry inside run_bootstrap so the
  drain continues THROUGH blips instead of pausing the whole phase on the first one (build on STABLE
  infra). The box LAN (HANA) is fine; only box->cloud (PG/MD) is flaky.
- **OVERNIGHT OUTCOME (2026-06-28 ~05:30) + the OVERSIZED-CHUNK problem is now PROVEN, not cosmetic**:
  the nightly stayed `active` (0 crashes/restarts, fail-soft held) and drained **8 grid chunks** in
  ~11h (grid 247->255 done, 113->105 pending; pending = bseg 54 / acdoca 50 / bkpf 1). At ~8 chunks/
  night the giant tail is **~13 nights**. **ROOT DRAG — CORRECTED (verified on box parquet 2026-06-28):
  the UPLOAD JOBS ARE ALREADY 50k ROWS** (`NORMALIZE__DATA_WRITER__FILE_MAX_ITEMS=50000`, dict-extract
  path honors it — acdoca job=50,000 rows/~6MB, matdoc=50,000/~4.5MB). So "write in 50k" is DONE;
  shrinking the upload further does nothing. What's multi-million is the **GRID CHUNK = the all-or-
  nothing merge/finalization SCOPE** (acdoca [Jun15-27]=3.78M = ~76 × 50k jobs that must ALL land
  before the chunk's merge runs + watermark advances; drain splits by `max_days=4`, acdoca ~344k/day
  → ~1.4M/window). The stall: a few of the ~76 jobs hit `DEADLINE_EXCEEDED`/`time-based lease expired`
  = connection STALLS on the flaky uplink (NOT size-vs-deadline — a stall kills a 6MB or 2MB upload
  alike), retry for hours, and the all-or-nothing finalize waits on them (matdoc retried 02:00, acdoca
  05:04-05:21, ~5h; both packages DID eventually reach `loaded/`). dlt ALREADY parallelizes load jobs
  (LOAD__WORKERS≈20) + per-job retry WITHOUT blocking siblings, and extract↔load are disk-decoupled
  (MD slowness never blocks the HANA read; reads are LAN-reliable, ~0 read retries). The gap: a chunk
  won't finalize till ALL jobs land + chunks run SERIALLY → one fully-stuck chunk blocks the next.
  **FIX (two, gated on Siraj — proposed not implemented; do NOT auto-apply, design change):
  (1) count-based GRID split to ~300-500k/chunk** — shrinks the all-or-nothing SET + the merge, so a
  chunk finalizes in minutes + a stall costs only ~400k replay (NOT the upload size — that's already
  50k). **(2) per-chunk wait-budget + advance** (the continue-through-blips follow-up): if a chunk
  can't finalize in N min, leave it pending + move on + retry later → flaky night defers instead of
  stalling. NET: drain healthy + self-limiting (budget/retry-cap/quarantine), just slow; no overnight
  intervention — restart would re-feed the same chunk into the same wall.
- **RESUME (when box network is STABLE — it was relay-degraded at session end)**: box `~/sap_bronze`
  has all #121 code incl. quarantine; `.env.run` has `BACKFILL_EDGE_CUTOFF=20260627` + `CONTROL_PG_DSN`
  + `CONTROL_WAL_DIR`. (1) re-run ekpo/eket (cascade victims; package cleared); (2) confirm
  marc/mvke/mbewh merge (will work); (3) **enable the new --user timers** `deploy/systemd/sap-drive-{edge,nightly,catchup}.{service,timer}` (NOT enabled yet — do NOT enable on a flaky network; the
  nightly drains acdoca 50+/bseg 53+ pending chunks overnight); (4) smoke (b) priority-resume + (c)
  death-detection. First full `--drive` already loaded ~20 tables OK (edge current). Deferred docs:
  table-config CSV in docs/sources + #121 plan-doc consolidation (issue_121_tiered_hot_cold_cadence.md
  is the older binary HOT/COLD design, superseded by the 4-way modes — reconcile per Siraj).

## Gotcha
MotherDuck MCP session gets poisoned (`Catalog '_control' has been deleted`, even `SHOW DATABASES`)
when a sibling drops an attached DB (#245). Fresh per-process connections (the box) are fine —
monitor MD from the box, not the MCP, during such.
