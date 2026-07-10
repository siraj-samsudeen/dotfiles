---
name: reference_dbt_run_results_md_table
description: dbt transform timing lives in MotherDuck dbt_control.main.run_results (execution_time_s); dbt runs on Railway not the box
metadata: 
  node_type: memory
  type: reference
  originSessionId: c086743e-a70a-4a8e-b8c3-8afa8debaaa6
---

dbt run timing is persisted to the **MotherDuck table `dbt_control.main.run_results`** by an
`on-run-end` macro (`dbt_runner/dbt/macros/log_run_results.sql`), NOT just `target/run_results.json`.
Columns: `run_id, ran_at (TIMESTAMPTZ), node (unique_id), name, resource_type, target_relation,
status, rows_affected, failures, execution_time_s (DOUBLE, wall-seconds per node), message`.

- **Per-area attribution:** `resource_type='model' AND target_relation LIKE 'silver_sap.sales.%'`
  (also `.inventory.`, `.finance.`, `.master.`; PTP = `silver_ptp.procurement.%`; `gold.%`). Filter
  on `resource_type`, NOT target_relation alone — a **test**'s target_relation is always
  `my_db.dbt_test__audit.*` regardless of layer (#70 gotcha; see [[reference_dbt_run_results_tests_my_db]]).
- **No per-run wall-clock column:** every row of one run shares the same `ran_at` (set to `now()` at
  on-run-end). Use `SUM(execution_time_s)` per area as the cost proxy; true wall-clock < sum due to
  ~4-worker parallelism — note that caveat when quoting a transform duration.
- **Where dbt runs:** the **Railway `dbt_runner` service**, gate-triggered by
  `dbt_runner/run_silver_if_new.py` when any bronze feed's `max(_loaded_at)` advances — NOT on the
  on-prem box. But the table is in MotherDuck, so a box-side report reads it over the same `md:` conn.
