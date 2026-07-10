---
name: project_matdoc_248_stock_fix
description: "#248 matdoc 4x stock fix — repair-table + silver dedup (PR #282); the merge-key LESSON is promoted to docs/agents/gotchas/dlt-merge-key-change-on-a-live-table-double-loads.md (2026-07-10)"
metadata: 
  node_type: memory
  type: project
  originSessionId: e3dd6b8a-509f-425b-b8b1-cbf6ccd6f11c
---

**#248 silver stock_on_hand 4× inflated — root cause matdoc's 3-tuple merge key. RESOLVED (history) via a repair-table + silver dedup (PR #282); ongoing-trickle fast-follow = chip task_af4cbf88.**

ROOT CAUSE (diagnosed 2026-06-28, HANA-verified): NSDM splits each material-doc line into a main
posting `RECORD_TYPE='MDOC'` and a counter-posting `'MDOC_CP'` that SHARE `(MBLNR,MJAHR,ZEILE)` but
cancel (STO receipt +55 / in-transit −55). matdoc's merge key was the 3-tuple `(MBLNR,MJAHR,ZEILE)` →
the merge collapsed the pair and **dropped 2.73M MDOC_CP (−) rows** → `sum(stock_qty)` saw only the +
side → 4× over-count. HANA: BWART=101 has 8.59M rows / 5.87M distinct line keys; 2,726,249 lines carry
both S and H. `(MBLNR,MJAHR,ZEILE,RECORD_TYPE)` is unique across all 64.4M rows; RECORD_TYPE is already
in the keep-list. **Silver is correct** (`sap_stock_movements` passes through, `sap_stock_on_hand` sums)
— it's 100% a bronze key bug.

**LESSON (general): dlt merge is NOT idempotent across a primary-key CHANGE on a live table → DUPS.**
I tried swapping the live key to the 4-tuple + a recovery merge; it inserted the slice TWICE
(369,820=185,532×2) when MD was mid-recovery. Reverted by deleting `_run_id='matdoc-cp-recover-*'`;
matdoc is back fully unique. **NEVER change a dlt merge_key on an existing merge table** — land it via a
fresh table. (Probe `sap_bronze/probes/issue_121/matdoc_recover_cp.py` is the diagnostic record — do NOT
re-run as a live merge.) Box matdoc key REVERTED to 3-tuple (commit 2a2509b); edge safe.

**THE FIX (DEPLOYED 2026-06-28, PR #282, live-verified).** NOT the full re-load (~9.6h, too slow) and
NOT a live key swap (dups). A **repair-table**: loaded the ~5.46M rows of SHARED line-keys — both MDOC
and MDOC_CP sides (HANA `(MBLNR,MJAHR,ZEILE) GROUP BY HAVING COUNT(DISTINCT RECORD_TYPE)>1`) — into a
new additive table `bronze_sap.inventory.matdoc_repair` (5,463,118 rows, unique by 4-tuple,
MDOC_CP=2,731,559); the live matdoc edge is untouched. silver `sap_stock_movements` now UNIONs
matdoc ∪ matdoc_repair and **dedups-on-read** by (material_doc,doc_year,doc_item,record_type);
record_type surfaced; uniqueness test → 4-tuple. Verified: deduped grain 64,443,230 vs HANA 64,443,972
(−742 = recent postings the edge reconciles); Σstock_qty 155,441,485→38,148,579 (4.07× fix); live
`sum(on_hand_qty)`=38,148,579; `dbt build` PASS=25. Unblocks the Article-Enquiry cutover (#158); also
explains part of #244 negatives (~5.9% own-stock). Probes: `sap_bronze/probes/issue_121/`
(matdoc_repair_load, verify_repair, matdoc_composition/linekey/shared-lines diagnostics).

**FAST-FOLLOW (chip task_af4cbf88):** the hourly edge still 3-tuple-MERGES new matdoc → shared lines
created after the snapshot re-collapse slowly. Clean close = matdoc → append-only + the same silver
dedup (ADR-0002 / #278 direction). The repair table fixes all history; the engine change closes the
trickle. See [[feedback_load_cost_incremental_default]], [[project_sap_silver_inventory]].
