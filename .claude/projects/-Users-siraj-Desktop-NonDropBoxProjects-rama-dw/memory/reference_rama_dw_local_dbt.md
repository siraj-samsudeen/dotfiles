---
name: reference_rama_dw_local_dbt
description: How to run the rama_dw dbt project locally + the gate-reverts-shared-seeds gotcha
metadata: 
  node_type: memory
  type: reference
  originSessionId: a9e00059-8b7a-4c37-b886-aa10d071cbe9
---

Run the rama_dw dbt project locally with the **`dbt_runner`** venv (dbt-core 1.11 + dbt-duckdb
adapter). Do NOT use `~/.local/bin/dbt` — that is **dbt-fusion**, which rejects the
`duckdb`/MotherDuck adapter (`unknown variant 'duckdb'`).

**Post-#172 (2026-06-18): the service dir was renamed `silver_runner/` → `dbt_runner/`, and the dbt
project moved to `dbt_runner/dbt/` (ADR 0023).** As of 2026-06-26 the `dbt_runner/.venv/bin/dbt`
console script runs **directly** (`dbt parse|compile|build`, dbt=1.11.11) — the earlier broken-shebang
workaround (`python -m dbt.cli.main`) is no longer needed; the venv was rebuilt.

Invocation (token: `rill/.env` holds it as lowercase `motherduck_token`, but profiles.yml needs env
`MOTHERDUCK_TOKEN` — must map it; works against a worktree project dir):
```
export MOTHERDUCK_TOKEN=$(grep -iE '^[[:space:]]*motherduck_token=' rill/.env | head -1 | sed -E 's/^[^=]*=//; s/"//g')
MAIN/dbt_runner/.venv/bin/dbt build \
  --project-dir <wt>/dbt_runner/dbt --profiles-dir <wt>/dbt_runner/dbt --no-version-check --select <sel>
```
Building `--select <models>` from a worktree writes straight to the prod MotherDuck catalog
(e.g. `silver_sap.inventory.*`) — fine for additive/new tables (idempotent table rebuild = what the
gate does); the hourly gate is **watermark-gated** (builds only when bronze advanced), so a brand-new
model may otherwise not materialise until the next bronze load. A 61M→47M-row SAP silver build is ~40s.

**Gotcha — the hourly `dbt_runner` gate (formerly `silver_runner`) runs from `main` and re-seeds
shared seeds.** It runs `dbt build` whenever bronze advances (bronze_zakya/gofrugal load
constantly), which re-seeds `silver_core.store_master` from **main's** CSV. So worktree changes to
shared `silver_core` seeds get **reverted within the hour**, and `relationships` FK tests against
`silver_core.store` only hold once the branch is **merged to main**. Verify such tests by re-seeding
+ testing in a tight window. See [[reference_rama_dw_env_and_run]], [[feedback_feather_discover_ui_server]].
