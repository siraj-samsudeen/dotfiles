---
name: project_matdoc_248_stock_fix
description: "#248→#2739 matdoc saga CLOSED — bronze matdoc alone holds the 4-tuple grain; repair table dropped; merge-key lesson REFINED (finer key + backfill heals in place)"
metadata: 
  node_type: memory
  type: project
  originSessionId: 9d8e0026-b80f-461b-b585-ec9719a6a5f6
  modified: 2026-08-28T03:41:02.336Z
---

**The matdoc grain saga is CLOSED (#2739, PR #2743, merged 2026-08-27). Bronze
`bronze_sap.inventory.matdoc` alone holds the true 4-tuple grain `(MBLNR,MJAHR,ZEILE,RECORD_TYPE)`
for all history; `matdoc_repair` was proven byte-identical-redundant (0 missing keys, 0 dedup wins,
0 value diffs) and DROPPED after a live re-verify. Silver `stock_movements` reads matdoc alone.**

Background (#248, 2026-06-28): NSDM splits each material-doc line into MDOC (+) and MDOC_CP (−)
sharing the 3-tuple; the old 3-tuple merge key collapsed the pairs → stock 4× over-counted for
STO-heavy stores. Interim fix was `matdoc_repair` + silver UNION-dedup. The permanent fix landed in
two silent steps nobody connected until #2739: commit `d6e185a7` (14-Jul) switched the live key to
the 4-tuple, and the #121 `matdoc_recover_cp` run merged the missing MDOC_CP history in. From then
on the repair table contributed ZERO rows to silver — #2739's "multi-night HANA re-pull" premise was
a stale doc row (`sap_load_config.csv` had never been regenerated; its generator had been broken
since the #295 rename — both fixed).

**MERGE-KEY LESSON, REFINED (supersedes the absolute "never change a live dlt merge_key"):**
- Moving a live merge table to a **FINER** key while **supplying the rows the old key collapsed** is
  safe and heals in place — delete+insert on the finer key only ever adds the missing sibling.
- What corrupts: a **COARSER** key, a finer key **without** the backfill, or (the original #248
  burn) running the key swap **concurrently with a mid-flight recovery merge** — that raced and
  double-inserted.
- Recorded beside the object in `sap_bronze/src/sap_bronze/config.py` (the matdoc Table entry).

Leftover: `bronze_sap.inventory.matdoc_pre248` (63.7M rows, the 14-Jul pre-swap backup) — chip
task_42f42468 running in its own session to verify + drop.

See [[project_stock_freeze_2628_2744]] for what the #2739 full refresh collaterally fixed.
