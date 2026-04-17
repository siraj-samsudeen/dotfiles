---
name: User's Domain Focus
description: User builds ERP-like transactional systems (order management, POS, leave management, payroll) — NOT complex SaaS with Stripe/integrations. Master data from Excel, transaction-heavy, data-heavy, approval workflows, analytics.
type: user
---

User primarily builds **ERP-like transactional systems and operational tools**, not complex SaaS products:

**Internal/operational:**
- Order management, POS, inventory
- Leave management, payroll calculations
- Budget tracking, financial reporting
- Master data imported from Excel spreadsheets

**Customer-facing operational:**
- Help desk / ticketing systems (like Freshservice, Zendesk)
- Learning management systems (LMS)

**Characteristics:**
- Transaction-heavy and data-heavy
- Analytics/reporting around the transactions
- Approval workflows (leave requests, purchase orders, ticket escalations)
- Ticket lifecycle / SLA management (help desk)
- Content + progress tracking (LMS: courses, modules, completion)
- NOT complex external integrations (Stripe, etc. are out of scope)
- Starting point is often an Excel file with master data

**Common patterns across ALL these systems:**
- Entities with status lifecycles (tickets: open→in_progress→resolved; courses: draft→published)
- Assignment/routing (tickets to agents, tasks to employees, courses to learners)
- SLA/deadline tracking (response time, resolution time, due dates)
- Categorization/tagging (ticket categories, course topics, product categories)
- Role-based views (agent dashboard vs customer portal; instructor vs student)
- Audit trails / activity logs
- Reports and dashboards

**Excel is a first-class concern:**
- User does data consulting — receives many Excels that need to become systems
- #1 pain point: tools (especially Grist) don't handle Excel changes gracefully (column renames, additions, deletions, reorder)
- Wants: import Excel → system created → modify Excel → re-import → graceful migration with no data loss
- This "Schema Reconciliation" workflow is potentially THE biggest DX differentiator

**Implication for Feather DX:** The framework should optimize for: (1) Excel → schema → CRUD → status workflows → reports, (2) graceful schema evolution when Excel changes, (3) the "Integrations" dimension is low priority; "Status Flow" (with SLA/deadlines), "Derived Data/Aggregations", and "Access Control" (role-based views) are the highest priorities.
