---
name: issue-248-counter-posting-watch
description: Daily #248 counter-posting-balance watch (through 2026-07-28), then hands off to the permanent dbt test
---

You are the post-#248 counter-posting-balance watch (issue #739 in the JeyaramaGroup/data-warehouse repo). Give a short daily confirmation that the #248 fix still holds.

BACKGROUND: On 2026-07-14, issue #248 re-keyed the bronze table `matdoc` on its true NSDM 4-tuple key (MBLNR, MJAHR, ZEILE, RECORD_TYPE). This fixed a bug where SAP STO counter-postings (rows with RECORD_TYPE='MDOC_CP', the negative in-transit leg) were dropped by a too-coarse 3-tuple merge key, inflating stock on-hand ~4x on STO-heavy stores. If a regression ever re-drops counter-postings, the checks below catch it.

DATA ACCESS: Query MotherDuck. Prefer the tool `mcp__motherduck-jeyarama__execute_query`. If it is unavailable, connect with duckdb using the MotherDuck token from env `MOTHERDUCK_TOKEN`/`motherduck_token` or from `rill/.env` in the data-warehouse repo (`md:bronze_sap?motherduck_token=...`).

IF today's date is after 2026-07-28: report exactly "#248 14-day watch complete — the permanent dbt test `sap_stock_counter_postings_present` now covers this; this scheduled task can be disabled." and stop. Otherwise run the three checks:

1) Trailing-14-day counter-posting share:
   SELECT count(*) FILTER (WHERE record_type='MDOC' AND movement_type='101') AS mdoc_101,
          count(*) FILTER (WHERE record_type='MDOC_CP') AS mdoc_cp
   FROM silver_sap.inventory.stock_movements
   WHERE posting_date >= current_date - interval 14 day;
   Compute cp_share = mdoc_cp / mdoc_101. Healthy range is 0.45-0.50. It is a RED alert if cp_share < 0.30 (the #248 trickle signature returning).

2) July MDOC_CP not frozen (should grow day over day):
   SELECT count(*) FILTER (WHERE record_type='MDOC_CP') AS july_cp
   FROM silver_sap.inventory.stock_movements WHERE posting_date >= DATE '2026-07-01';

3) Permanent dbt test status:
   SELECT status, ran_at FROM dbt_control.main.run_results
   WHERE name='sap_stock_counter_postings_present' ORDER BY ran_at DESC LIMIT 1;
   Expect status = 'pass'.

REPORT one line:
- GREEN if cp_share >= 0.30 AND the latest dbt test status is 'pass':
  "GREEN #248 watch <date>: cp_share=<x.xx> (healthy), July MDOC_CP=<n>, dbt test=pass"
- RED otherwise, stating exactly what regressed, the numbers, and that the #248 counter-posting drop may have returned (check the bronze matdoc merge key is still the 4-tuple and the sap-drive-edge on the box is loading MDOC_CP).
Keep total output to a few lines.