---
name: feedback_naming_self_evident_ai_legible
description: Name domain levels/columns for self-evidence + AI-legibility over industry jargon; record business-vocab aliases in ADR+CONTEXT
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 48334ae9-870f-49e8-8176-6f942a53fd15
---

When naming hierarchy levels, dimensions, or columns, Siraj prefers **self-evident, AI-legible names over industry-standard jargon**. In the #261 merch-hierarchy grill he rejected the retail-standard `Division/Department/Class/Subclass` (Oracle RMS — what retail veterans know) in favor of `Division → Subdivision → Category → Subcategory`.

**Why:** two reasons he stated explicitly — (1) new joiners (even from the industry) shouldn't have to *learn* the scheme; the morphology should place a node on sight (two `X`/`sub-X` pairs do this). (2) much downstream tooling will be AI-generated, so names should be ones models parse cleanly — `class`/`subclass` is *actively worse* because it's overloaded with the OOP meaning in training corpora.

**How to apply:** prefer generic, unambiguous, self-nesting words; treat "famous in the industry" as a weak argument if it loses to "instantly legible to everyone incl. machines". Separately: when the business/CEO has an EXISTING term for a level that appears across reports (e.g. "Main Category"/"MC" = our Subdivision), record that mapping as a first-class alias in BOTH an ADR and CONTEXT.md — not just the plan — because report-readers will search for their term. We own the canonical column name; the business term is the recorded alias. See [[feedback_ceo_requirements_not_design]], [[project_category_master_261]].
