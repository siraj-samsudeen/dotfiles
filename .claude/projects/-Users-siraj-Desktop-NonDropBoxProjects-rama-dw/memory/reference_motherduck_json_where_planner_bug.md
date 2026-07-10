---
name: reference_motherduck_json_where_planner_bug
description: MotherDuck planner errors on JSON string-equality in WHERE over bronze landing _payload; keep filters as date-cast + push dims into GROUP BY/CASE
metadata: 
  node_type: memory
  type: reference
  originSessionId: c591cb73-3ed3-4ebe-a6a0-070d1e1fe168
---

Querying `bronze_zakya.landing.export_*._payload` (raw JSON), a `WHERE _payload->>'SomeKey' = 'literal'` string-equality filter triggers a spurious `Conversion Error: Failed to cast value to numerical: {whole payload}` — the planner pushes an unrelated numeric CAST below the filter and hits a non-castable row elsewhere in the table. The error line points at the string-equality predicate but is NOT about that predicate.

Workaround (the shape that reliably works): filter only with `WHERE CAST(_payload->>'Invoice Date' AS DATE) = DATE '...'`, and push every other dimension into `GROUP BY` / `CASE WHEN _payload->>'Mode'='UPI' THEN ...`, never into a `WHERE col = 'x'`. `TRY_CAST` in SELECT/ORDER BY does NOT rescue it; the trigger is the JSON string-equality WHERE clause itself. Seen repeatedly while reproducing the Zakya tenderwise report. See [[project_zakya_tenderwise_payment_dive]].
