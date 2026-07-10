---
name: feedback-load-cost-incremental-default
description: "MotherDuck per-minute billing → incremental by default, full-refresh only on demand; never a scheduled full re-copy"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 0082d8de-9746-4211-b3d0-5fe0f7bdb4a3
---

MotherDuck bills per **compute-minute** and this is a cost-sensitive India SMB, so **cost is a
first-class design driver** — co-equal with correctness/reliability, not an afterthought. The
rule, now **[[ADR 0032]]** (`docs/adr/0032-load-cost-incremental-default-full-refresh-on-demand.md`,
warehouse-wide): **incremental by default, full-refresh ONLY on demand.** A scheduled full-refresh
of a marker-having table is prohibited (pure redundant compute); the only scheduled full-refresh
tables are tiny marker-less config/text lookups on the slowest cadence. Never re-load a `done`
grid chunk (the grid is a cost guard, not just reliability — the Zakya empty-grid re-walk was a
*dollar* incident).

**Why:** Siraj corrected me twice on this during the #121 grill — I defaulted to "full-refresh
masters (they're small)" then "cadenced monthly," both wrong. Don't reason like compute is free.

**How to apply:** treat any *scheduled* full-refresh as a red flag to challenge. Masters with a
change-marker (e.g. MARA via GREATEST(LAEDA,ERSDA)) → incremental; physical deletes (rare) are
caught by the reconcile count-gate + an on-demand `--refresh`. Verify each master actually has a
usable change-marker before assuming incremental (a HANA probe). Relates to [[project_sap_116b_partition_bootstrap]].
