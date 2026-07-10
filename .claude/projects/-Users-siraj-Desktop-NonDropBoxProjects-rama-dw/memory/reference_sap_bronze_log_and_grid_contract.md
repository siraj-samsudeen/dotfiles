---
name: reference_sap_bronze_log_and_grid_contract
description: sap_bronze box log line formats + control-grid completeness queries for parsing morning-load timing/coverage
metadata: 
  node_type: memory
  type: reference
  originSessionId: c086743e-a70a-4a8e-b8c3-8afa8debaaa6
---

Parsing contract for the SAP morning report (#287). All log lines are `[HH:MM:SS] …` where the
timestamp is **UTC** (emitted via `datetime.now(timezone.utc)` in `src/sap_bronze/__main__.py log()`)
— box-local IST = UTC+5:30. (Distinct from `_loaded_at`, which is +5:30 **skewed**, see
[[bronze-sap-loaded-at-timestamptz-is-plus-5-30-skewed]] — that's a data column, not a log time.)

- **`drive.log` per-table:** start `[{schema} {i}/{n}] {table} ({pattern}, {cols} cols) ...`;
  success `[{schema} {i}/{n}] {table}: rows={N}`; fail `… attempt {a}/3 failed: {exc}`. `schema` =
  business area. Run close: `[drive] done run={id} edge_fail=.. snap_fail=.. bf_fail=.. budget_hit=..`.
- **`giant_drain.log` (bootstrap):** `[drive bootstrap] {t} [{YYYYMMDD},{YYYYMMDD}) done rows={N}` /
  `… partial/failed …` / `… budget-stopped …`; summary `[drive bootstrap] grid {t}: done={d} pending={p}`.
- **`spool-backfill.log`:** read hb `[hb] {t} read: {rows} rows, {s}s, {rate}/s`; write hb
  `[hb] {t} spool: {rows} rows, {s}s`; append `[hb] {t} upload: {files} files, {s}s`. Read then write
  (not concurrent within a chunk).
- **Reconcile (masters):** `[drive snapshot] {t}: MD={n} HANA={n} …` lines.
- **Completeness % (giants):** `control.sap_backfill_grid (table_name, chunk_start, status …)` →
  `control.backfill_summary(conn)` returns `(table, done, pending)`. Fat masters (marc/mvke/mbew/mbewh)
  use `control.sap_partition_grid` → `control.partition_summary(conn, table)` returns `(done, pending)`.
- **Giants (`backfill=True`):** acdoca, bkpf, bseg, vbrp, matdoc, ekbe, ekpo, eket, lips, vbfa.
- **`config.Table`** (`src/sap_bronze/config.py`): `.name .sap .schema(area) .pattern .keys .backfill
  .partition_axis …`. Iterate `config.TABLES` to get the area→table map.
