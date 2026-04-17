---
name: Audit trail over immutability for document lifecycle
description: User (ex-KPMG) rejects Frappe/SAP Submit/Cancel/Amend model as unnecessary ceremony. Wants auditability via change tracking, not immutability. Period-close events instead of per-document submit.
type: project
---

Frappe's Submit/Cancel/Amend lifecycle (inherited from SAP) is explicitly REJECTED for Feather.

**Why:** User worked at KPMG, deeply understands audit requirements. The real need is auditability, not immutability. Frappe confuses the two — forcing users to cancel+amend+resubmit when a simple edit with audit trail would suffice. Indian clients especially struggle with this ceremony.

**The problem with Submit/Cancel/Amend:**
- Creates unnecessary ceremony (can't print/share until submitted, can't edit after submit)
- Leads to credit note/debit note chains for simple corrections
- Documents are often temporary/iterative until truly finalized
- The "submit" gate blocks normal workflow (sharing, printing, sending)

**User's proposed alternative — "Audit Trail + Period Close":**
- Documents are freely editable by default (no submit gate)
- Every change is tracked with full audit trail (who, what, when, before/after)
- A "period close" event (daily/monthly/quarterly) locks documents for that period
- After period close: changes require explicit override with reason, visible to auditors
- No cancel-and-recreate ceremony — just edit with tracked changes

**How to apply:** Instead of `lifecycle: submittable`, implement:
- `audit: tracked` — every field change logged with before/after values
- `period_close: monthly` — periodic event that locks records
- Status flow handles the business workflow (draft→sent→paid), NOT the auditability concern
- Auditability is orthogonal to status — it's a cross-cutting concern handled by the audit trail
