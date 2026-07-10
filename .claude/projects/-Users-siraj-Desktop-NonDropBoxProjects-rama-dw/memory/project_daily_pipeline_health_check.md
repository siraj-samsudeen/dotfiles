---
name: project_daily_pipeline_health_check
description: "Siraj's recurring daily concern — are the pipelines healthy, and is a problem the source's or ours? The triage method + planned pipeline-health skill (#206)"
metadata: 
  node_type: memory
  type: project
  originSessionId: 086ed6e0-d98f-4948-85b2-0a5328ed9044
---

Siraj checks **every morning** whether the pipelines ran: did we load all the data, was there a problem, is it the **source** (down/unreachable) or **us** (landed in bronze but bronze→silver→gold broke)? Tracked as the `pipeline-health` skill in **#206**.

**The `/pipeline-health` skill now EXISTS (live as of 2026-06-26)** — it reconciles the Postgres control plane (hot) against MotherDuck (data plane + legacy pre-cutover control tables) in one DuckDB process and answers the five load questions (loaded? dup? edge re-poll? errors captured? bronze→silver→gold complete?) per source for today + last 3 days, IST-bucketed. Prefer it over the manual triage below. NOTE post-#204 cutover: control freshness now lives in the Postgres control plane (`control.<ext>_grid` / `control.run`), NOT MotherDuck `bronze_*.control.*` (those froze at each extractor's cutover) — see [[reference_control_plane_query_model]].

**The triage method (top-down — symptom first, then cause):**
1. **Symptom** — read `gold.freshness` (#202, the front door): `is_stale` (business-date, authoritative) / `load_stale` (recency) / `max_business_date` / `loaded_at` per (table, source). All green → done.
2. **Source layer** — if stale, `bronze_*.control.run_events` (status: ok / zero_rows / zero_rows_final). zero_rows = source reachable but empty (closed store, usually legit). **Source-down is NOT diagnosable today** — run_events logs only HTTP-200; failures leave no durable event (gap #204).
3. **Transform layer** — compare `bronze._loaded_at` vs `silver._loaded_at` vs `gold.loaded_at` (bronze fresh + gold stale → DW transform problem); `dbt_control.run_results` for build/test failures.

Key facts: morning check is never partial (nightly load runs early-AM for prior day → expect complete *yesterday*; Zakya hourly intraday makes *today* legitimately partial). Compare at source level for the headline (don't alarm on one closed store). Gaps to consume as they land: #203 per-store attribution, #204 durable failure events. See [[project_sap_bronze_status_2026_06_15]] for the broader pipeline landscape.

**#205 DONE (2026-06-24):** the operational run-health "when did this run" column is now uniformly **`ran_at`** across every `control.run_events` (gofrugal, zakya, sap, ptp, stylehr) **and** `dbt_control.run_results` — so the #206 skill needs **no per-source CASE-ing** on that column (was `event_ts`/`ran_at`/`generated_at`). Convention enshrined in ADR 0027 + CONTEXT.md glossary. Note `*._dlt_loads.inserted_at` stays dlt-named (out of scope). See [[reference_rama_dw_deployment_topology]] for how the run_events writers deploy.

**#384 DONE (2026-07-03) — dbt-runner transform-health baseline is now GREEN.** The hourly `dbt-runner` cron had been logging `status='error'` on **every** run for weeks (a broken smoke alarm) — 4 data-tests made `dbt build` rc=1. Fixed at source: zakya_item_master dedup (one row per sku), deleted the obsolete `_control`-grid test, seed `plant_code`→varchar, repointed stylehr coverage at the disposition seed. So in triage step 3, `dbt_control.main.runs`/`run_results` showing `error` is now a *real* signal again, not noise. Also: the runner **self-heals** orphaned `status='running'` rows (a crash between the two-phase insert/update) — on start it marks any `running` older than **2h** as `error`. So a lingering `running` row in `dbt_control.main.runs` is expected to auto-clear; only treat `running` as "in flight" if <2h old. Key dbt gotcha this exposed: `severity: warn` rescues a test that **fails** (returns rows) but **not** one that **errors** (runtime) — an errored warn-test is still rc=1.
