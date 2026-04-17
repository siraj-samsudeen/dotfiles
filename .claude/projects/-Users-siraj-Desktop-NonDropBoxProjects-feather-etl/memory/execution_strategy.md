---
name: Parallelization strategy for V4-V18
description: User-designed 4-wave dependency DAG for remaining slices with file conflict analysis. Updated 2026-03-28 with progress.
type: project
---

Designed 2026-03-27 by user. Slices 1-3 are VERIFIED prerequisites.

**Progress as of 2026-03-28:**
- V4 (column_map + silver-direct): **DONE** — implemented as part of mode feature, not as a separate slice
- Mode feature (dev/prod/test toggle): **MERGED** — covers V4 scope plus mode-driven target derivation, gold materialization control, test row limits
- V7 (SQL Server source): Plan created (PENDING, not yet approved). Successfully tested pyodbc connection to Icube ERP — 650 tables discovered, 61+70 rows extracted in smoke test. Plan at `docs/plans/2026-03-27-slice7-sqlserver-source.md`
- V8 (silver/gold transforms): Plan created (COMPLETE, not yet approved). Transform engine implemented (discover, parse, order, execute). Detailed sqlmesh → feather porting analysis done for all 12 models. Plan at `docs/plans/2026-03-27-slice8-transforms.md`

**Remaining waves (adjusted):**

**Wave 1 (ready now):**
- V5: --table, --tier, history (cli.py, state.py) — Small, completely isolated
- V6: JSON + Excel sources (sources/ new files, registry.py) — Medium, completely isolated
- V7: SQL Server source — plan exists, needs approval
- V8: Transform engine — plan exists, needs approval (porting the 12 sqlmesh models)
- V12: append strategy (destination, pipeline.py, config.py) — Small

**Wave 2 (independent, heavier setup):**
- V9: DQ checks — new module + state table
- V10: schema drift — touches source + pipeline + destination + state
- V11: SMTP alerting — new module (alert bus for V9/V10)
- V14: retry + backoff — pipeline + state
- V16: boundary dedup — extends V3's incremental

**Wave 3 (hard dependencies):**
- V13: MotherDuck sync — blocked by V8 (needs gold tables)
- V15: scheduling — blocked by V5 (needs --tier)

**Wave 4 (final polish):**
- V17: init wizard — blocked by V6 + V7 + V8
- V18: --json output — blocked by all (touches all CLI)

**How to apply:** V7 and V8 are MVP-critical. Execute them next (they're the user's stated MVP: "Connect to SQL Server, do the transforms, land in local DuckDB"). Other wave 1 items can run in parallel.
