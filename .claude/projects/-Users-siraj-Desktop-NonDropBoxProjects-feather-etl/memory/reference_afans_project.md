---
name: Reference project for transforms
description: afans-reporting-dev contains the 12 silver/gold SQL models that feather-etl V8 must replicate
type: reference
---

The existing production pipeline lives at `~/Desktop/NonDropBoxProjects/afans-reporting-dev/`. It uses dlt + sqlmesh + Dagster — feather-etl replaces all three.

**Transform templates for V8:**
- `sqlmesh/models/silver/` — 10 models: employee_master, pos_return_detail, pos_transaction_detail, customer_master, sales_invoice_detail, pos_detail, item_master, pos_return_master, pos_transaction_master, sales_invoice_master
- `sqlmesh/models/gold/` — 2 models: pos_transactions, sales_invoice

**Other relevant paths:**
- `dlt_pipelines/` — current extraction scripts (icube.py, sales_invoice.py)
- `sqlmesh/config.yaml` — current transform config (connection strings, scheduling)
- `discovery.duckdb` (442MB) — full extracted dataset for reference

When building V8 (transforms), read these SQL models to understand the actual transform logic feather-etl needs to support (joins, CTEs, column renames, type casts).
