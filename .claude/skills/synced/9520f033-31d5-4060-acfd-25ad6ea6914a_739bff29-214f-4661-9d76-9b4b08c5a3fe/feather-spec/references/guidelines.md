# Section Guidelines

## Workflow Context (Optional)

Include when discovery was done. Helps AI understand the "why."

```markdown
Workflow Context:
> "I log hours at end of day but often forget. Have to guess when invoicing."
Pain points: Forgetting to log, guessing hours
Opportunity: Reduce friction between working and logging
```

## Goal

One sentence. User benefit, not technical outcome.

- ❌ "Store task data in database"
- ✅ "Allow users to track personal tasks without losing items"

## Scope

**In:** Capabilities being built
**Out:** Explicitly excluded (prevents scope creep)

## Dependencies

- **Requires:** Must exist before this works
- **Triggers:** Side effects when this runs
- **Blocked by:** Build order dependencies

## Capability Groups (XX-1, XX-2, etc.)

Group by **user capability**, not technical component. Each group contains:
1. EARS criteria (the rules)
2. Example table (concrete data)

### Naming Groups

Use a short feature prefix + number:
- Todo management → TM-1, TM-2, TM-3
- Apply coupon → CP-1, CP-2, CP-3
- Quick task → QT-1, QT-2

Name from user perspective:
- ✅ "Task Creation", "Task Completion", "Task List"
- ❌ "TaskForm Component", "Status Toggle API"

### EARS Within Groups

Place criteria closest to the capability they describe:
- WHEN/IF/THEN → inside the relevant group
- WHILE → inside the group if specific, or after all groups if general
- Ubiquitous → after all groups (applies globally)

### Example Tables

Every capability group should have examples. Capture the user's actual words:

> User says: "I want to add 'Buy milk' and mark it done"

This becomes:
```markdown
**Examples:**
| Input | Result |
|-------|--------|
| "Buy milk" | Task "Buy milk", incomplete |
```

Choose the table format that fits:
- **Input → Result** for creation
- **Before → Action → After** for state changes
- **Multiple inputs → Output** for calculations

Skip example tables only for trivially obvious groups (e.g., a delete with no special behavior).

### Tips for Good Criteria

- Be specific: "within 2s", "every 15min", "after 3 attempts"
- One behavior per line
- Cover all user actions with WHEN
- Cover key failure modes with IF/THEN
- Don't state obvious (auth required, record must exist)

## Business Validation

Rules requiring business decisions. Mark critical with `!`.

**Don't include:**
- "Record must exist" - obvious
- "Must be authenticated" - covered by Permissions

Omit section if no business rules beyond acceptance criteria.

## Calculations

Explicit formulas. Mark financial/critical with `!`.

```
C1!: discount = (subtotal × percentage)
     capped at max_discount if specified
```

Omit section if no calculations.

## Permissions

**Simple case:** `Standard ownership (user can only access own [resources])`

**Complex case:** Expand to P1, P2 when:
- Role-based access (admin, member)
- Shared resources
- Public endpoints
- View vs edit differences

Don't state "must be authenticated" - assume auth by default.

## Input Validation

Format and constraint rules.

```
IV1: Title is required
IV2: Title maximum 500 characters
```

## State Rules

**Reactive behavior only:**
- "When cart changes, totals recalculate"
- "Deleting project deletes its tasks"
- "Order: pending → confirmed → shipped"

**Don't include:**
- Default values ("new tasks default to incomplete")
- UI behavior ("completed tasks stay in list")

Omit section if no reactive behavior.

## Data Model

Client-friendly types. Only fields this feature touches.

**Tables created/modified:** Full field list
**Related tables:** Only fields this feature reads/writes

For simple features, a one-liner works:
```
Task: title (text), completed (yes/no), user_id (reference to user)
```

For complex features, use the full vertical format with T1, T2, etc.

## Out of Scope

Repeat from Scope section with more detail. Useful for:
- Client clarity ("we explicitly won't do X")
- Preventing scope creep during implementation
- Future feature planning ("Phase 2")
