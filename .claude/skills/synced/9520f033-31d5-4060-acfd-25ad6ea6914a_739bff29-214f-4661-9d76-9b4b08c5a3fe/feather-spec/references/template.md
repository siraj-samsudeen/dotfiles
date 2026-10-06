# Feather-Spec Template

```markdown
Feature: [name]

Workflow Context: (optional)
> [relevant workflow excerpt from discovery]
Pain points: [what's broken today]
Opportunity: [what we're solving]

Goal: [single sentence - why this exists]

Scope
In: [included capabilities]
Out: [explicitly excluded]

Dependencies
- Requires: [systems/features that must exist]
- Triggers: [side effects on other systems]
- Blocked by: [features that must be built first]

## XX-1: [Capability Name]

- WHEN [trigger] THE SYSTEM SHALL [response]
- IF [condition] THEN THE SYSTEM SHALL [response]

**Examples:**
| Input | Result |
|-------|--------|
| [concrete data] | [concrete outcome] |

## XX-2: [Capability Name]

- WHEN [trigger] THE SYSTEM SHALL [response]
- WHILE [state] THE SYSTEM SHALL [behavior]

**Examples:**
| Before | Action | After |
|--------|--------|-------|
| [state] | [user action] | [new state] |

## XX-3: [Capability Name]

- WHEN [trigger] THE SYSTEM SHALL [response]

THE SYSTEM SHALL [always-true constraint] (ubiquitous)

Business Validation (if any)

BV1: [rule]
BV2!: [critical rule] (critical: [reason])

Calculations (if any)

C1!: [formula with conditions] (critical: [reason])

Permissions

Standard ownership (user can only access own [resources])
— or expand to P1, P2 for complex cases (roles, sharing)

Input Validation

IV1: [constraint]
IV2: [constraint]

State Rules (if any)

S1: [when X happens, Y changes]

Data Model

T1: [table_name]
- [field] ([client-friendly type])
- [field] ([type])

Out of Scope

- [explicitly excluded capability]
- [explicitly excluded capability]
```

## Example Table Formats

**For creation (input → result):**
```markdown
| Input | Result |
|-------|--------|
| "Buy milk" | Task created, incomplete |
| "" | Error: "Title is required" |
```

**For state changes (before → action → after):**
```markdown
| Before | Action | After |
|--------|--------|-------|
| "Buy milk" (incomplete) | mark complete | "Buy milk" (complete) |
```

**For calculations (inputs → output):**
```markdown
| Subtotal | Coupon | Discount | Total |
|----------|--------|----------|-------|
| $100 | 20% off | $20 | $80 |
| $100 | 20% off, max $15 | $15 | $85 |
```

**For context-dependent actions:**
```markdown
| Context | Input | Result |
|---------|-------|--------|
| In project "Website Redesign" | "Update homepage" | Team-visible task |
```

## EARS Syntax Patterns

### Event-driven (WHEN)
User actions and system events.

```
WHEN user submits valid registration THE SYSTEM SHALL create account within 2s
WHEN user clicks save THE SYSTEM SHALL persist data and show confirmation
WHEN payment is received THE SYSTEM SHALL update order status to confirmed
```

### State-driven (WHILE)
Behavior that continues during a state.

```
WHILE session is active THE SYSTEM SHALL refresh token every 15min
WHILE offline THE SYSTEM SHALL queue changes for sync
WHILE cart has items THE SYSTEM SHALL display cart badge with count
```

### Unwanted behavior (IF/THEN)
Error handling and failure cases.

```
IF email already exists THEN THE SYSTEM SHALL display "Email already registered"
IF 3 failed login attempts THEN THE SYSTEM SHALL lock account for 30min
IF payment fails THEN THE SYSTEM SHALL retain cart and show retry option
```

### Ubiquitous (no keyword)
Always-true constraints. Mark with `(ubiquitous)`.

```
THE SYSTEM SHALL encrypt passwords using bcrypt (ubiquitous)
THE SYSTEM SHALL log all authentication attempts (ubiquitous)
```

### Optional (WHERE)
Feature flags and variations.

```
WHERE premium subscription is active THE SYSTEM SHALL allow unlimited exports
WHERE two-factor auth is enabled THE SYSTEM SHALL prompt for verification code
```

## Client-Friendly Types

| Technical | Client-Friendly |
|-----------|-----------------|
| uuid, pk | globally unique ID |
| decimal | number |
| integer | whole number |
| varchar, text | text |
| boolean | yes/no |
| timestamp, datetime | date/time |
| date | date |
| fk → table.id | reference to [table] |
| jsonb array | list of [type] |
| enum | one of: [values] |
