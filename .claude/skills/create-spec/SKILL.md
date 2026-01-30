---
name: create-spec
description: Lightweight, user-perspective requirements specification. Client sign-off document - skimmable in 30 seconds. Use when writing feature specifications. Outputs spec.md.
---

# Create Spec

A minimal requirements framework: light enough for clients to skim, precise enough to drive implementation. **Outputs: `docs/specs/<feature>/spec.md`**

**Core principle:** If a client can't sign off on it in 30 seconds, it's too heavy.

## What Feather-Spec IS

- User-perspective requirements (what they'd express)
- Grouped by capability (QT-1, QT-2, etc.)
- EARS syntax for precision
- Sign-off document before implementation

## What Feather-Spec is NOT

- Edge cases (those come from derive-tests-from-spec)
- Gherkin scenarios (those come later)
- Technical implementation details
- Exhaustive test cases

## Process Overview

```
1. Discover    →  Trace workflow, identify pain points
2. Decompose   →  Extract features from workflow
3. Specify     →  Write feather-spec (THIS SKILL)
4. Review      →  review-design checks architecture
5. Derive      →  derive-tests-from-spec expands to all cases
```

## Spec Structure

```markdown
# Feature: [Name]

## Overview
[One sentence: what this feature does and why]

## [GROUP-1]: [Capability Name]

- WHEN [trigger], THE SYSTEM SHALL [response]
- WHEN [trigger], THE SYSTEM SHALL [response]

## [GROUP-2]: [Capability Name]

- WHEN [trigger], THE SYSTEM SHALL [response]
- WHILE [state], THE SYSTEM SHALL [behavior]

## [GROUP-3]: [Capability Name]

- WHEN [trigger], THE SYSTEM SHALL [response]

## Data Model (if applicable)

[Entity]: [field] ([type]), [field] ([type])

## Out of Scope

- [Explicitly excluded capability]
```

## Example: Quick Task Feature

```markdown
# Feature: Quick Task

## Overview
Rapidly create tasks from any view without opening a form dialog.

## QT-1: Quick Task Creation

- WHEN I type and press Enter, THE SYSTEM SHALL create a task

## QT-2: Quick Task Visibility

- WHEN I create a quick task, THE SYSTEM SHALL make it private to me
- WHEN I assign to a teammate, THE SYSTEM SHALL make it visible to them

## QT-3: Project Task

- WHEN I create a task in a project, THE SYSTEM SHALL make it visible to the team

## Data Model

Task: title (text), projectId (optional reference), visibility (private/shared)

## Out of Scope

- Due dates (Phase 2)
- Priority levels (Phase 2)
```

**4 requirement groups. Client skims in 30 seconds. Signs off.**

## EARS Syntax Reference

| Pattern | Keyword | Template | Use For |
|---------|---------|----------|---------|
| Event-driven | WHEN | WHEN [trigger] THE SYSTEM SHALL [response] | User actions |
| State-driven | WHILE | WHILE [state] THE SYSTEM SHALL [behavior] | During states |
| Unwanted | IF/THEN | IF [condition] THEN THE SYSTEM SHALL [response] | Key error handling |
| Ubiquitous | (none) | THE SYSTEM SHALL [constraint] | Always-true rules |

## Grouping Guidelines

**Group by user capability**, not by technical component:

```markdown
GOOD (user perspective):
  QT-1: Quick Task Creation
  QT-2: Quick Task Visibility
  QT-3: Project Task

BAD (technical perspective):
  QT-1: InlineTaskForm Component
  QT-2: Visibility Calculation
  QT-3: API Integration
```

**Use short IDs** that carry through the process:
- Spec: QT-1, QT-2, QT-3
- Gherkin: Feature groups match QT-1, QT-2, QT-3
- Manual verification: Sections match QT-1, QT-2, QT-3
- Traceability: QT-2 failed at step 5

## What to Include vs. Exclude

| Include | Exclude |
|---------|---------|
| What user would express | Technical edge cases |
| Happy path requirements | Empty input validation |
| Key business rules | Implementation details |
| Main error cases user cares about | Obscure error handling |

**The filter:** "Would a real user sitting next to me say this?"

- "I want to quickly add tasks" → YES → Include
- "Empty input should do nothing" → NO → derive-tests-from-spec adds this

## Key Principles

1. **Light** - Client can read entire spec in 30 seconds
2. **User perspective** - Business language, not technical
3. **Grouped** - Capabilities have IDs that trace through
4. **No redundancy** - Single source of truth
5. **Omit obvious** - Don't state "must be authenticated"

## Anti-Patterns

| Don't | Do |
|-------|-----|
| Include every edge case | Only user-expressed requirements |
| Write Gherkin scenarios | EARS only (Gherkin comes later) |
| Technical jargon | Business terms |
| Long detailed spec | 4-6 groups, 1-3 items each |
| "System shall validate input" | Omit obvious validation |

## Validation Checklist

Before requesting sign-off:

- [ ] Can client skim in 30 seconds?
- [ ] All groups named from user perspective?
- [ ] No edge cases that user wouldn't express?
- [ ] No Gherkin scenarios (those come later)?
- [ ] IDs are short and traceable (QT-1, QT-2)?

## What Happens Next

```
create-spec (you are here)
     ↓
review-design (Checkpoint 1: verify all artifacts)
     ↓
derive-tests-from-spec (expands to Gherkin + edge cases)
     ↓
Review Gherkin (checkpoint before implementation)
     ↓
Implementation
```

Edge cases, Gherkin scenarios, and detailed test cases are generated by `derive-tests-from-spec` - not written in the spec.
