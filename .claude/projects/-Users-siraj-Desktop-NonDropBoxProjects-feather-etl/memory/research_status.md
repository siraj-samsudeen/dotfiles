---
name: Research status and key decisions
description: Research phase complete with 6 agents. Key architectural decisions locked. 13 ideas deferred with triggers.
type: project
---

Research phase completed 2026-03-25. Six research agents synthesized into `docs/research.md`.

**Locked decisions:**
- pyodbc for extraction (mssql-python deferred until Arrow support)
- PyArrow for zero-copy data transfer
- Local DuckDB for staging + state + transforms
- MotherDuck via ATTACH as final destination
- APScheduler v3.x + SQLite job store for scheduling
- YAML config with human-readable schedule presets
- typer for CLI
- uv for project management
- Silver transforms are views; gold transforms are views in dev/test, materialized tables in prod (mode-dependent — see arch_mode_system.md)
- CHECKSUM_AGG + COUNT(*) for cold table change detection
- Timestamp watermark + overlap window + boundary dedup for hot tables
- Excel reader: DuckDB `excel` extension (`read_xlsx()`) for .xlsx, openpyxl fallback for .xls (resolved 2026-03-25)

**Open questions:**
- MotherDuck region (latency from India)
- Whether Icube ERP tables have ROWVERSION columns

**How to apply:** Reference `docs/research.md` for full context. Deferred ideas section has revisit triggers — check when scope expands.
