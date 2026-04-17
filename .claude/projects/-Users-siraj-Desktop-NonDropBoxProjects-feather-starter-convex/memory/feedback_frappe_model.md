---
name: Frappe as the model to follow
description: User wants to adopt Frappe patterns wholesale — only fix what's broken. Same for Glide. Don't reinvent.
type: feedback
---

Follow Frappe Framework patterns as the default model for Feather's DX architecture. Don't reinvent — take what they have, fix only what's actually broken for our context.

**Why:** Frappe is a working system powering an entire ecosystem (ERPNext). User is a big fan of their no-code → low-code → pro-code graduated complexity and single DocType handling everything.

**How to apply:** When designing any Feather feature (permissions, workflows, reports, extensibility), first check how Frappe does it. Adopt their pattern unless there's a concrete reason it doesn't work for React+Convex. Same approach for Glide's computed columns and Golden Triangle.

**User's key insight:** Operations + Analytics are two sides of the coin. Glide's Golden Triangle (Data + Layout + Actions) covers operations but misses analytics/reports. Feather's model should be: Data + Layout + Actions + Reports.
