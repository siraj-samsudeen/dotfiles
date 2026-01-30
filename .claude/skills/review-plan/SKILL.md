---
name: review-plan
description: Review implementation plans against designs or specs. Use when user says "review the plan", "check the plan", "is this plan ready to execute?", or before starting implementation.
---

# Review Plan

Reviews implementation plans to verify they correctly implement the design.

## Core Principle

> "The plan is not the design. The plan is HOW we build the design."

Implementation plan review asks: "If we execute this plan exactly, will we have built what the design specifies?"

This is different from:
- **Design review** → "Is this the right system?" (architecture, data model)
- **Code review** → "Is this implementation correct?" (logic, style)

## What to Review

### 1. Design Coverage

| Check | Question |
|-------|----------|
| **Feature coverage** | Does the plan cover every feature in the design? |
| **Data model coverage** | Are all tables/schemas/indexes created? |
| **API coverage** | Are all endpoints/functions implemented? |
| **Edge cases** | Does the plan address edge cases from the design? |

**How to check**: Create a checklist from the design, verify each item has a corresponding task.

### 2. Task Quality

| Check | Question |
|-------|----------|
| **Atomicity** | Can each task be completed independently and verified? |
| **Clarity** | Is it clear what "done" means for each task? |
| **Size** | Are tasks small enough to complete in one session? |
| **Testability** | Can each task be tested before moving on? |

**Red flags**:
- Task says "implement the system" (too big)
- Task has no clear completion criteria
- Task depends on decisions not yet made

### 3. Dependencies & Sequence

| Check | Question |
|-------|----------|
| **Dependency correctness** | Are task dependencies accurate? |
| **Sequence logic** | Does the order make sense? (schema before queries) |
| **Parallel opportunities** | Are independent tasks identified for parallel work? |
| **Blocking identification** | Are potential blockers called out? |

**Dependency types** ([Atlassian](https://www.atlassian.com/agile/project-management/project-management-dependencies)):
- **Finish-to-start**: Task B can't start until Task A finishes
- **Start-to-start**: Tasks can start together
- **Finish-to-finish**: Tasks must finish together

### 4. Completeness

| Check | Question |
|-------|----------|
| **Setup tasks** | Environment, dependencies, configuration? |
| **Migration tasks** | Data migration, schema updates? |
| **Testing tasks** | Unit tests, integration tests? |
| **Cleanup tasks** | Remove scaffolding, dead code? |
| **Documentation tasks** | API docs, README updates? |

### 5. Feasibility

| Check | Question |
|-------|----------|
| **Technical feasibility** | Can each task actually be implemented as described? |
| **Information completeness** | Does each task have enough detail to execute? |
| **Assumption identification** | Are assumptions explicit, not hidden? |

## What to Skip

Leave these for code review:
- Code style concerns
- Implementation alternatives ("you could also do X")
- Performance micro-optimizations
- Specific function signatures

**Rule**: If it's about HOW to write the code, it's code review. If it's about WHAT to build, it's plan review.

## Review Process

### Quick Review

Single pass checking:
1. Does every design feature have a task?
2. Are dependencies explicitly stated?
3. Are tasks atomic enough?

### Deep Review

User says: "deep review", "thorough review"

Launch **two agents in parallel**:

1. **Agent A (Coverage)**: Map design → plan, find gaps
2. **Agent B (Quality)**: Check atomicity, dependencies, sequence

Synthesize findings, deduplicate.

## Output Format

```markdown
## Implementation Plan Review

### Gaps (design items missing from plan)

| Design Item | Location in Design | Status |
|-------------|-------------------|--------|
| [Feature/requirement] | [Section/line] | Missing / Partial / Covered |

### Task Issues

| Task | Issue | Recommendation |
|------|-------|----------------|
| [Task name] | [Problem] | [Fix] |

### Dependency Issues

| Issue | Impact | Fix |
|-------|--------|-----|
| [Dependency problem] | [What breaks] | [Correction] |

### Ready to Execute

- [Tasks that are well-defined and ready]

---

**Verdict**: [Ready to execute / Needs revisions first]
```

## Common Issues to Catch

**Coverage gaps**:
- "Activity logging not covered" → add tasks for each action type
- "Search only covers titles, design says title + description" → expand task

**Task quality**:
- "Task 7 is too large - 'implement all CRUD operations'" → break down
- "Task 3 has no completion criteria" → add verification step

**Dependency errors**:
- "Task 5 uses helper from Task 8" → reorder or split
- "Schema change in Task 2 but Task 1 runs queries" → wrong sequence

**Missing tasks**:
- "No task for database indexes" → add index creation
- "No cleanup of starter code" → add removal task

## Relationship to Other Reviews

```
┌─────────────────┐     ┌──────────────────────┐     ┌─────────────────┐
│  review-design  │ ──▶ │ review-implementation│ ──▶ │  code-reviewer  │
│                 │     │        -plan         │     │                 │
│ "Right system?" │     │ "Right plan?"        │     │ "Right code?"   │
└─────────────────┘     └──────────────────────┘     └─────────────────┘
     BEFORE                   BEFORE                      AFTER
    planning               implementation             implementation
```

**After this review passes**, use `superpowers:code-reviewer` during implementation to verify code matches the plan.

## Sources

- [Atomic Planning](https://adamhannigan81.medium.com/breaking-down-technical-tasks-with-atomic-planning-6045218b0c86)
- [Task Dependencies](https://www.atlassian.com/agile/project-management/project-management-dependencies)
- [Gap Analysis](https://www.cascade.app/blog/gap-analysis)
