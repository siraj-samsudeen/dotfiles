---
name: feedback_ceo_requirements_not_design
description: "CEO (rbchandran) GitHub issues are requirements, not design — take the business need, reshape the data model ourselves"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: ff4fdd42-87f2-41ab-8096-b9919e27dede
---

The CEO **rbchandran** files detailed, prescriptive GitHub issues (e.g. #104 epic with
named silver facts/dims/db layout, #131 treasury architecture). He is **not a data-warehouse
practitioner** — much of the design is relayed from ChatGPT. So treat his issues as the
authoritative source of **requirements** (the business towers, the ₹-quantified needs,
the questions to answer), and **own the design ourselves** — adopt his proposed schema
names / layouts only where they genuinely serve us.

**Why:** Taking his design verbatim imports DW anti-patterns (e.g. flattened `fact_sales_line`
at Silver, silver databases split by process) that conflict with our ADRs. The value is in
his demand signal, not his modelling.

**How to apply:** Mine his issues for *what the business needs to see*; map it onto our own
ADR-governed model (ADR 0001/0003, [[feedback_silver_no_flatten_header_line]]). Be discerning,
not dismissive — some of his asks are sound DW practice and worth adopting on merit (e.g.
#107 system-of-record matrix + cross-system mapping-key master, #106 conformed KPI dictionary).
Surface the gaps where his design and our ADRs diverge rather than silently following either.
