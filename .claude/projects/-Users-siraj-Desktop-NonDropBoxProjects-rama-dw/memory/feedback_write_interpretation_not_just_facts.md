---
name: feedback_write_interpretation_not_just_facts
description: "In issues/comments/docs, include plain-language interpretation of what findings mean, not just raw facts"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: c829a610-e67f-43c2-9fdc-645b15dbe26e
---

When writing GitHub issues, comments, or docs, always include a plain-language **interpretation** of what a finding means for a human reader — not just the raw facts/numbers.

**Why:** The user explicitly said interpretation content (e.g. "the root redirects to /GoFrugalERPAdapter/ — this is a GoFrugal ERP server, jcterp = a customer instance; it's a web app, not a bare REST API") is helpful and should always be included.

**How to apply:** After stating a fact, add a sentence explaining what it *is*, what it implies, and what to expect because of it. A raw HTTP 200 or a redirect target is a fact; "this server is a full ERP web app, so expect HTML on most paths and JSON only on the restAdapter servlet" is the interpretation that earns its place.

Put interpretation content **in the issue body** (as its own section), not in a separate comment — the body is the canonical description. Comments are for dated chronology/findings.
