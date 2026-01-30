---
name: dev-workflow
description: Master reference for the development workflow. Shows the complete flow, which skill to invoke at each step, checkpoints, and feedback tracking. Use when starting a new feature or when unsure which skill comes next.
---

# Dev Workflow

The complete development workflow with skills, checkpoints, and feedback tracking.

**Use this skill:** When starting a new feature, or when unsure which skill comes next.

## The Complete Flow

```
┌─────────────────────────────────────────────────────────────────────┐
│                         DEV WORKFLOW                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. REQUIREMENTS                                                    │
│     Skill: create-design → create-spec                              │
│     Output: design.md, spec.md                                      │
│                                                                     │
│  2. DESIGN                                                          │
│     Skill: create-mockup                                            │
│     Output: UI mockups, user journey, UX touches                    │
│                                                                     │
│  3. ◆ CHECKPOINT 1                                                  │
│     Skill: review-design                                            │
│     Gate: 5 artifacts present? Architecture sound?                  │
│     Feedback: Saved to .feedback/ if deferred                       │
│                                                                     │
│  4. TEST DERIVATION                                                 │
│     Skill: derive-tests-from-spec                                   │
│     Output: Gherkin scenarios grouped by spec IDs                   │
│                                                                     │
│  5. ◆ GHERKIN REVIEW                                                │
│     (Built into derive-tests-from-spec)                             │
│     Gate: User approves scenarios before implementation             │
│                                                                     │
│  6. PLANNING                                                        │
│     Skill: create-implementation-plan                               │
│     Output: implementation-plan.md (behavioral tasks, NO code)      │
│                                                                     │
│  7. ISOLATION                                                       │
│     Skill: isolate-work                                             │
│     Output: Feature branch or worktree                              │
│                                                                     │
│  8. IMPLEMENTATION                                                  │
│     Skill: execute-with-agents                                      │
│     Constraint: Test is READ-ONLY CONTRACT                          │
│                                                                     │
│  9. ◆ CHECKPOINT 2                                                  │
│     Skill: verify-feature                                           │
│     Gate: Automated + manual verification                           │
│     Feedback: All issues saved to .feedback/                        │
│                                                                     │
│  10. COMPLETION                                                     │
│      Skill: finish-branch                                           │
│      Options: Merge / PR / Keep / Discard                           │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Quick Reference: Which Skill When?

| Step | Trigger | Skill | Output |
|------|---------|-------|--------|
| Start feature | "Let's build X" | `create-design` | design.md |
| Write requirements | After design | `create-spec` | spec.md |
| Create UI design | Need visual | `create-mockup` | mockup |
| Review before coding | Have design docs | `review-design` | approval |
| Expand to tests | After CP1 passes | `derive-tests-from-spec` | Gherkin |
| Plan implementation | After Gherkin approved | `create-implementation-plan` | implementation-plan.md |
| Start coding | Before first commit | `isolate-work` | branch |
| Execute plan | Have approved plan | `execute-with-agents` | code |
| Verify feature | Implementation done | `verify-feature` | approval |
| Finish up | All checks pass | `finish-branch` | merged |

## The Three Checkpoints

### Checkpoint 1: Before Implementation
**Skill:** `review-design`

| Artifact | Required |
|----------|----------|
| UI Mockup | ✓ (or N/A) |
| User Journey | ✓ |
| UX Touches | ✓ |
| Acceptance Criteria | ✓ |
| Data Model | ✓ (or N/A) |

**User says:** "Approved" → proceed | "Add X" → update or save to .feedback/

### Checkpoint: Gherkin Review
**Skill:** `derive-tests-from-spec` (built-in)

**User reviews:** Generated scenarios match intent?

**User says:** "Approved" → proceed | "Add/Remove/Change scenario"

### Checkpoint 2: After Implementation
**Skill:** `verify-feature`

| Check | Type |
|-------|------|
| Tests pass | Automated |
| Types/lint pass | Automated |
| Manual steps work | User performs |

**User provides:** Failed steps, issues found → saved to .feedback/

## Feedback Tracking

All feedback saved to `.feedback/` folder:

```
.feedback/
├── INDEX.md              # Dashboard (auto-generated)
├── open/                 # Unresolved
│   ├── BUG-001-xxx.md
│   ├── DESIGN-002-xxx.md
│   └── UX-003-xxx.md
├── in-progress/          # Being worked on
└── resolved/             # Done (keep for reference)
```

### Feedback Sources

| Source | When | Skill |
|--------|------|-------|
| `checkpoint-1` | Design review | `review-design` |
| `gherkin-review` | Scenario review | `derive-tests-from-spec` |
| `checkpoint-2` | After implementation | `verify-feature` |
| `user-testing` | After release | Manual |

### Traceability

```
Spec Group  →  Gherkin Scenarios  →  Manual Steps  →  Feedback
   QT-1          QT-1 scenarios       QT-1: Steps 1-5   "QT-1 step 3 failed"
   QT-2          QT-2 scenarios       QT-2: Steps 6-9   "QT-2 step 8 failed"
```

## Workflow Modes

### Default Mode (Simple Features)
- 2 checkpoints: CP1 (review-design) + CP2 (verify-feature)
- 2-step test pipeline
- Agents run autonomously between checkpoints

### Intensive Mode (Complex Features)
- Checkpoint after each phase
- 4-agent test pipeline
- More human review points

**Trigger:** User says "intensive review" or feature is high-risk

## Anti-Patterns

| Don't | Do |
|-------|-----|
| Skip create-design | Always clarify intent first |
| Put code in plans | Plans are behavioral, not code |
| Let implementer modify tests | Test is READ-ONLY CONTRACT |
| Claim done without CP2 | Always run verify-feature |
| Lose feedback | Always save to .feedback/ |

## Starting a New Feature

```
User: "Let's add quick task"

Claude: "I'm using dev-workflow to guide this feature.
         Starting with create-design to understand requirements."

→ invoke: create-design              → design.md
→ invoke: create-spec                → spec.md
→ invoke: create-mockup (if UI)
→ invoke: review-design (CP1)
→ invoke: derive-tests-from-spec
→ [Gherkin Review]
→ invoke: create-implementation-plan → implementation-plan.md
→ invoke: isolate-work
→ invoke: execute-with-agents
→ invoke: verify-feature (CP2)
→ invoke: finish-branch
```

## Relationship to Other Skills

```
dev-workflow (THIS - the map)
     │
     ├── create-design              → design.md
     ├── create-spec                → spec.md
     ├── create-mockup              → mockup
     ├── review-design              → (CP1)
     ├── derive-tests-from-spec     → Gherkin
     ├── create-implementation-plan → implementation-plan.md
     ├── isolate-work               → branch
     ├── execute-with-agents        → code
     ├── verify-feature             → (CP2)
     └── finish-branch              → merged
```

This skill is the **reference**. Invoke the specific skill for each step.
