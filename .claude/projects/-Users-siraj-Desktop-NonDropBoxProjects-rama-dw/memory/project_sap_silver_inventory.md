---
name: project_sap_silver_inventory
description: "silver_sap.inventory stock models (#243) — on-hand + EOD balance from matdoc; NSDM stock_qty, go-live opening, negatives"
metadata: 
  node_type: memory
  type: project
  originSessionId: 7ee2986e-303c-48bd-bd38-4447ec57f0ca
---

`silver_sap.inventory` exists as of #243 (merged to main 2026-06-26, built + 24 tests PASS): three
dbt models in `dbt_runner/dbt/models/sap/inventory/` deriving SAP stock from `matdoc` movements (ADR
0015 — MARD is all-zero in our S/4 and was dropped, stock lives in movements).

- **`stock_movements`** — source-faithful matdoc line grain (PK mblnr/mjahr/zeile).
- **`stock_on_hand`** — current on-hand = `SUM(stock_qty)` by `item_code_sap × store_code`. 2.71M cells.
- **`stock_balance_daily`** — SPARSE end-of-day running balance per item×store×posting_date (47.4M rows;
  not a dense snapshot ≈1.5B, not a re-scanning view); "balance as of date D" = latest row ≤ D.

Key facts a fresh agent needs (verified by probe, don't re-derive):
- **On-hand uses NSDM `stock_qty`, NOT a hand-rolled SHKZG×MENGE.** matdoc carries pre-signed
  `stock_qty`/`consumption_qty`/`lbkum` (S/4 NSDM). `stock_qty == signed(menge)` by `shkzg` (S=+/H=−)
  in 99.99% of rows AND it zeroes the ~998 rows that don't touch owned stock — it IS SAP's stock-impact
  determination. `consumption_qty` is SEPARATE (an issue sets both); never sum it into on-hand.
- **No opening-balance join needed.** SAP go-live was Jan-2025: 658,490 `561` initial-stock movements
  in 2025-01 vs 1 in 2025-02. matdoc `budat` floor is 20250101 = real go-live, so cumsum is the
  absolute on-hand. MBEWH not required for quantity.
- **Grain is MATNR×WERKS, LGORT is not a dimension** (ADR 0015 / CONTEXT.md: SL01=all stores,
  ST01=all warehouses). LGORT carried on `stock_movements` only.
- **~5.91% of (item,store) cells are negative** — all own-stock (`sobkz=''`; special stock clean).
  Drivers: cross-plant transit (`641`, posts consumption_qty with stock_qty=0, umwrk≠werks) +
  materials onboarded after the go-live 561 load. Surfaced faithfully, NOT filtered. Reconciliation =
  **#244** (open, needs a physical count).

Consumer: this is the **silver** layer of the frozen `.62` SAPSTOCKDOWNLOAD/SAPSTOCKB replacement
(#158); the **gold** stock fact still to build there. See [[project_sap_bronze_status_2026_06_15]],
[[feedback_silver_no_flatten_header_line]], [[reference_rama_dw_local_dbt]].
