---
name: feather-etl project context
description: Lightweight ETL tool replacing dlt+sqlmesh+dagster stack for SQL Server to MotherDuck pipelines
type: project
---

feather-etl is a single-package Python ETL tool built for a specific use case: extracting from SQL Server ERP (read-only, no CDC), transforming with plain SQL in DuckDB, loading to MotherDuck.

**Why:** Current stack (dlt + sqlmesh + Dagster) is overkill — each tool has broad functionality but only ~5% is used.

**How to apply:** All design decisions should favor simplicity and minimal dependencies.

**MVP definition (stated 2026-03-27):** "Connect to SQL Server, do the transforms from afans-reporting-dev, land data in local DuckDB." This means V7 (SQL Server source) and V8 (silver/gold transforms) are the MVP-critical slices — file-based sources (V1-V3) were scaffolding to build the extraction pipeline, but the real value is SQL Server + transforms.

**Progress as of 2026-03-28:**
- Slices 1-3 (foundation, change detection, incremental): VERIFIED
- Mode feature (dev/prod/test): MERGED — column_map, target derivation, gold materialization
- V7 SQL Server: Plan created, smoke-tested with real Icube ERP (pyodbc works)
- V8 Transform engine: Plan created, engine implemented, 12 sqlmesh models analyzed for porting
- Test suite: 269 tests, 97.7% coverage

**First client:** Afans (Indian distribution company, ERP: Icube on SQL Server). Cost-sensitive — no unnecessary full loads or cloud compute. ~20-25 tables, largest ~700K rows.

**Downstream:** MotherDuck (warehouse) + Rill Data (dashboards). These stay.
