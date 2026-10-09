---
name: project_ptp_bronze_curation_537
description: "PTP bronze is now a curated 36-table merge-only allow-list, NOT a full mirror (ADR-537 supersedes ADR 0039"
metadata: 
  node_type: memory
  type: project
  originSessionId: f8438068-2573-47a7-baef-39ed7e4079ec
---

#537 (PR #544, branch `issue-537-ptp-bronze-curation`) re-curated PTP bronze from a **full
base-table mirror** into an explicit **36-table `config.KEEP_TABLES` allow-list**, merge-only.
**Do NOT re-expand to a full mirror** — ADR-537 supersedes ADR 0039 #2/#3 (its
database-consolidation-diff justification was never intended; the replace-only tail was
destructive-on-failure in MotherDuck — a lease-expired `replace` wiped ~60 tables 2026-07-08).

**Why / key facts:**
- `ptp_extract` `discovery.py` now keeps a table iff it's in `KEEP_TABLES` and present in that
  instance; `source.py` is **merge-only** (`write_disposition="merge"` always; `--refresh` = full-read
  merge, never `replace`). A keyless kept table raises at discovery (extends ADR 0034 → no destructive replace).
- Dropped 51 tables: 3 no-consumer SAP mirrors (`sap_data`/`sap_results`/`complete_sap_data`), 20 junk,
  28 empty/tiny stubs. Physical `DROP TABLE` is **post-deploy** (`ptp_extract/scripts/drop_decommissioned_ptp_tables.py`, dry-run default) — the #517 chip runs it after the Railway deploy so tonight's old cron doesn't reload them.
- `silver_ptp` conform (#386) pruned in lockstep: 65 → 34 models (the 5 gold-feeding + timeline sources survive). See [[project_ptp_conform_386.md]].
- **2 SAP-mirror catches kept under protest** (`sap_payments` → #260 timeline; `sap_data_stn` → Stationery Dive) — merge cleanly, no gold/silver home yet. Repoints filed as follow-ups.
- **Only TN (`bronze_ptp`) has consumers**; KL/KN feed only the conform union. `report_server` P2P dashboards are csv_upload/baked (no live warehouse dep).

**UPDATE 2026-07-10 — #544 merged; #517 COMPLETE and closed; the drop is DONE.** 103 decommissioned
tables physically dropped; bronze now = the allow-list exactly (`bronze_ptp` 34, `_kerala` 30,
`_kannammal` 15). Three further curation defects surfaced only against the live source:
- `KEEP_TABLES` now holds **exact, case-sensitive SOURCE names** — `Users`, `PurchaseOrders`,
  `LorryReceipts` are CamelCase in the source. Matching on the dlt-normalized name is many-to-one and
  silently merged the dead `SirEntries` into the live `sir_entries`; an all-snake list silently
  dropped the CamelCase ones. **Identity is declared, never inferred** (#575). New
  `config.SHADOW_TABLES = {"SirEntries"}` (remove once the source drops it, #583).
- Anything comparing config against **bronze** must normalize first — `drop_decommissioned_ptp_tables.py`
  would otherwise drop the live `users`/`purchase_orders`/`lorry_receipts`.
- kannammal declares **no PK** on 6 kept tables → `_pick_key` falls back to an `id` column (#564).
- `docking_transactions.created` is nullable → `on_cursor_value_missing="include"` (#552).

**How to apply:** for any PTP bronze work, treat `config.KEEP_TABLES` as the source of truth (exact
source names); add a table + backfill on demand only when a named consumer needs it. Decision grid:
`docs/plans/issue_537_ptp_curation_grid.html`. **`po_table` + `stock_balance_summary` carry SAP field
names (`matkl`/`werks`/`po_item`) — they are SAP mirrors to repoint & drop, like `sap_payments` /
`sap_data_stn` (#548/#549); tracked in #584.** Bronze also accumulates hard-deleted rows forever —
see [[reference_merge_only_never_removes_hard_deletes]]. See [[project_ptp_railway_517]],
[[reference_rama_dw_deployment_topology]], [[project_stylehr_railway_413]].
