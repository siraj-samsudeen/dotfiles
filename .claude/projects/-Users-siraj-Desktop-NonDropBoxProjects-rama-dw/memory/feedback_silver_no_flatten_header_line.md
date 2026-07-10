---
name: feedback_silver_no_flatten_header_line
description: "At Silver, keep SAP header and line-item as separate models — do NOT flatten header+item to line grain"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: ff4fdd42-87f2-41ab-8096-b9919e27dede
---

At the Silver layer we do **not** flatten header+item into a single line-grain fact.
Keep the header and the line items as separate Silver models that mirror the source's
own structure (e.g. SAP `vbrk`→billing_header + `vbrp`→billing_lines). Flattening,
joining, and conforming into a single consumer-facing fact is a **Gold** concern.

**Why:** Silver's consumer is the source-system owner doing DQ/recon (ADR 0001); a
header/line split keeps the debugging surface faithful to SAP and avoids baking join
decisions into Silver.

**Silver granularity follows source ACCESS shape** (the real principle): `silver_gofrugal`
looks flattened not by choice but because the GoFrugal **API only returns a pre-joined,
item-wise report** — we never see GoFrugal's own header/line tables, so there's nothing
to preserve. SAP is the inverse: we read the actual ERP tables (`vbrk`/`vbrp`), so Silver
preserves header+line. Do NOT use `silver_gofrugal` as the structural template for SAP.
→ capture in a new ADR (proposed 0016: "Silver granularity follows source access shape").

**How to apply:** When modelling SAP silver, produce per-document header + line models,
not one flattened `fact_*_line`. The CEO's `fact_sales_line`-style names in #104 are
**Gold** targets, not Silver. See [[project_sap_bronze_status_2026_06_15]] and
[[feedback_ceo_requirements_not_design]].
