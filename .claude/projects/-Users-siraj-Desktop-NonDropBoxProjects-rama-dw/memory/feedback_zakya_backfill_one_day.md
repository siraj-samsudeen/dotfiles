---
name: zakya-backfill-one-day-at-a-time
description: "Zakya /export backfills run one day per call, never multi-day ranges"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: adf8a418-c94b-4f66-b9a3-99330d3fafe1
---

When backfilling Zakya `/export` history, fetch and load **one day at a time** (`from_date == to_date`), never a multi-day range.

**Why:** the user prefers it for failure isolation and predictability. One `/export` is ~360 MB / ~17 min at a steady ~0.36 MB/s throughput ceiling. A multi-day range risks non-linear server-side generation cost, a long hang, and — if it fails — losing many days of work at once. One day = a standalone, resumable ~17-min unit.

**How to apply:** for any Zakya backfill spanning a week or month, loop date-by-date. This matches the existing build — the dlt pipeline name is date-derived (`zakya_sales_poc_<date>`) and the `Sales_dlt` resource is `write_disposition="append"`, so each day is already an independent unit. Quota is not a constraint (25,000 credits/window; ~30 calls for a month). See [[push-after-commit]] for the related commit/push habit.
