---
name: Always keep source last_modified in silver
description: Source timestamp columns that answer "how fresh is our data?" must always be included in silver — they're business columns, not just ETL plumbing
type: feedback
---

Never drop source modification timestamps (e.g., `modify_by_date`, `ModifiedDate`, `Timestamp`) from silver transforms. These columns answer business questions like "when was the last data loaded?" and "what is the most recent invoice?" — they are not just ETL watermark columns.

**Why:** The user pointed out that dropping `modify_by_date` from silver would make it impossible to answer basic data freshness questions from the client. The watermark column serves double duty: ETL incremental extraction AND business-facing data freshness.

**How to apply:** When designing silver transforms (SQL or column_map), always include the source's modification/timestamp column renamed to `last_modified`. This applies to every table that has one — not just incremental tables. The only columns to drop from silver are true ETL metadata (`_etl_loaded_at`, `_etl_run_id`) that feather-etl adds automatically.
