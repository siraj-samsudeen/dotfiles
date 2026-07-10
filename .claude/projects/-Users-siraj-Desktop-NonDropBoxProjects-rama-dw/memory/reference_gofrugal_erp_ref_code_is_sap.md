---
name: reference_gofrugal_erp_ref_code_is_sap
description: "In GoFrugal sales_item_wise, erp_ref_code is the SAP item code (keep it) — item_code is GoFrugal's internal code"
metadata: 
  node_type: memory
  type: reference
  originSessionId: f483cd10-b16a-4ad6-9ecf-f4caae6fb48a
---

In the GoFrugal `sales_item_wise` feed, `erp_ref_code` (e.g. `10317558001`) is the **SAP item code** — the cross-system join key to SAP. Always keep it. Distinct from `item_code` (e.g. `978107`), which is GoFrugal's internal item id. Both are 1:1 with the item (7108 distinct on 2026-05-27 outlet 1001). See [[project_gofrugal_bronze_curated_not_full]].
