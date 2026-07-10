---
name: reference_sap_plant_master_t001w
description: SAP plant master = bronze_sap.master.t001w (58 plants); classify via name1-prefix/vlfkz; region/entity via vkorg NOT regio
metadata: 
  node_type: memory
  type: reference
  originSessionId: cc12c3c5-6b8b-4dd0-bb12-5f49080dd224
---

`bronze_sap.master.t001w` IS loaded = the SAP plant master (58 plants, with `name1`, `regio`, `vkorg`, `vlfkz`). It is the canonical store/location spine group-wide (ADR 0032, [[project_store_dimension_249]]).

Classification: `plant_type` from the `name1` format-prefix (`ST_/SM_/HM_/FS_/SC_/ML_/CC_`=store, `GH_`=gold, `DC_`=dc, `HO_`=head_office, `KA_`=kannammal) + `vlfkz` (A vs B) + an overrides seed (1006/1008→store, 9106→dc, 9152=legal_entity). **`entity`/`region` derive from `vkorg` (sales org: 1100=JCT/TN, 1150=RCT/KL, 2100=Kannammal), NOT `regio` (physical state)** — border stores 1509 (Tenkasi) and 1514 (Marthandam) are physically TN but KL-operated. 9000-series = warehouses.

Cross-source: GoFrugal + p2p (`bronze_ptp.main.plants`, has names+shortnames) carry the SAP code natively; **Zakya carries only `branch_name`** → recovered via `plant_alias`. Neither p2p nor inventory `matdoc` alone is complete (p2p misses live store 1517; matdoc misses gold 1201–03) — t001w is the spine.
