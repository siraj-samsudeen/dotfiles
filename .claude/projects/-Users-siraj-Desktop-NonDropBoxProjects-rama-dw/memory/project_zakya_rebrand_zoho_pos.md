---
name: project-zakya-rebrand-zoho-pos
description: "Zakya was rebranded to Zoho POS — same product, same data. Legacy `api.zakya.in/inventory/v1` and new `www.zohoapis.in/pos/v1` coexist."
metadata: 
  node_type: memory
  type: project
  originSessionId: 6221ee22-2492-46c2-9a7a-7a5e51c9d933
---

Confirmed via in-app banner at `pos.zoho.in/<tenant>/index.do` on 2026-05-20: *"Zakya is now Zoho POS. The same trusted application, with a fresh new identity. Your data, settings, and overall experience remain the same."*

Two API surfaces:
- Legacy: `https://api.zakya.in/inventory/v1/...` — used by current Java prod jobs, verified working
- New: `https://www.zohoapis.in/pos/v1/...` — same backend (rebrand), not yet equivalence-verified

**Why:** Resolves the long-running confusion where one plan said "Zoho POS" and the existing Java said "Zakya" — they're the same product. Org `60035853406`, OAuth scope `ZakyaAPI.FullAccess.all` still works.

**How to apply:** Don't assume `/pos/v1` and `/inventory/v1` are different products. When reading old code, JSON configs, or docs that mention Zakya — mentally substitute Zoho POS. When writing new code, prefer `/inventory/v1` (the legacy path is proven; new path needs equivalence verification first). Full findings in `zakya_api_probe/FINDINGS.md`.

Related: [[project-pbi-sales-allstores-categorywise]] mentions Zakya as data source — same product.
