---
name: Silver-direct via YAML for simple tables, SQL for joins
description: Most silver transforms are column renames — use YAML column_map to land directly in silver. Only use SQL transforms for JOINs/UNIONs that YAML can't express. Implemented 2026-03-28 via mode feature.
type: decision
---

Two mechanisms for silver, chosen per table:

1. **YAML column_map** (simple rename) → prod mode extracts only mapped columns, renames via PyArrow, loads directly to `silver.*`. No bronze, no SQL file. Used for most tables (~4 of 6 MVP tables).
2. **SQL transform file** (JOINs, UNIONs) → data goes to bronze first, SQL file creates silver view. Used for item_master (joins inventory_group) and similar.

**Status:** Implemented 2026-03-28 as part of the mode feature (dev/prod/test toggle). In prod mode, `column_map` drives column selection and renaming. In dev mode, column_map is ignored and all columns go to bronze.

**Why:** The user challenged why silver needs SQL files when YAML can express column renames. For 4 of 6 MVP tables, YAML is sufficient and cleaner. SQL transforms only needed for the 2 tables requiring JOINs.

**How to apply:** Default to YAML column_map for new tables. Only create a SQL transform file when the silver logic requires JOINs, UNIONs, CASE expressions, or aggregations.

Decided 2026-03-28. Aligns with PRD's silver-direct pattern.
