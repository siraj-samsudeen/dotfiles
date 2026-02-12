# Feather: Lightweight TDD Workflow with Vertical Slices

> **Goal:** A development workflow that takes vague requests → ordered vertical slices → TDD-enforced execution with session handoffs

**Why "Feather":** Lightweight artifacts (feather-spec, feather-mockup), quick iteration, not heavyweight ceremonies.

## Summary

Create seven new skills (all prefixed with `feather:`) that integrate Ralph-style "one task per loop" execution with strict TDD enforcement and GSD-style state persistence:

| Skill | Purpose | Session |
|-------|---------|---------|
| `/feather:slice-project` | Vague idea → one or more slices | Session 1 |
| `/feather:add-slice` | Add more slices to existing project | Any time |
| `/feather:work-slice` | Execute ONE slice with TDD, then STOP | Session 2+ |
| `/feather:pause-slice` | Stop mid-TDD cycle with handoff file | Mid-session |
| `/feather:resume-slice` | Restore context, show position, route | After break |
| `/feather:note-issue` | Capture bug/UX tweak to polish queue | During use |
| `/feather:polish` | Work through polish queue with TDD | Any time |

## File Structure

```
~/.claude/skills/
├── feather:slice-project/
│   └── SKILL.md           # Initialize project (one or more slices)
├── feather:add-slice/
│   └── SKILL.md           # Add slices to existing project
├── feather:work-slice/
│   └── SKILL.md           # TDD execution for one slice
├── feather:pause-slice/
│   └── SKILL.md           # Mid-cycle handoff
├── feather:resume-slice/
│   └── SKILL.md           # Session restoration
├── feather:note-issue/
│   └── SKILL.md           # Capture bugs/UX to polish queue
├── feather:polish/
│   └── SKILL.md           # Work through polish queue with TDD
└── dev-workflow/
    └── SKILL.md           # Update to integrate feather: skills
```

**Project-level files created by /feather:slice-project:**
```
project/
├── .slices/
│   ├── STATE.md           # Session state (human-readable)
│   ├── slices.json        # Machine-readable slice status
│   ├── SLICES.md          # Overview table
│   └── polish.md          # Bug/UX polish queue
├── docs/
│   ├── DOMAIN.md          # Data model tree
│   └── specs/<slice-id>/  # Per-slice specs (created by /feather:work-slice)
└── src/                   # Implementation
```

---

## Skill 1: `/feather:slice-project`

**File:** `~/.claude/skills/feather:slice-project/SKILL.md`

**Purpose:** Transform vague request into ordered vertical slices with dependencies.

**Input:** "I want to build a project management system like Basecamp"

**Output:**
1. `docs/DOMAIN.md` - Data model tree
2. `.slices/slices.json` - Machine-readable slice list
3. `.slices/SLICES.md` - Human-readable overview
4. `.slices/STATE.md` - Session state
5. Add `.slices/CONTINUE.md` to `.gitignore` (transient, local-only)

**Process:**
1. **Don't ask questions upfront** - take vague prompt and generate best-guess slices immediately
2. Present ordered slice list for critique:
   ```
   Based on "build a project management system like Basecamp", here are suggested slices:

   | # | Slice | Description | Depends On |
   |---|-------|-------------|------------|
   | 1 | AUTH-1 | Username/password login | — |
   | 2 | PROJ-1 | Create/list projects | AUTH-1 |
   | 3 | TODO-1 | Basic todo list in project | PROJ-1 |
   | 4 | MEMBER-1 | Invite members to project | PROJ-1, AUTH-1 |
   ...

   Pick one to start, or tell me what to change.
   ```
3. **Offer feather-mockups for UI slices:**
   ```
   Slices with UI: TODO-1, PROJ-1, MEMBER-1

   Want to see feather-mockups before deciding? (quick visual, not final design)
   ```
   - Uses existing `create-mockup` skill (rename to `feather-mockup`)
   - Mockups saved to `docs/mockups/<slice-id>.html`
   - "Feather" = lightweight, quick, iterative - not heavyweight design docs
4. **Refine only when user asks** - questions come after they've seen the proposal
5. User can:
   - Pick one slice to start (single-slice mode)
   - Approve all and start with first
   - Ask to add/remove/reorder slices
   - Request mockups for specific slices
6. Write slices.json with:
   - `id`: Short code (AUTH-1, TODO-1)
   - `name`: One-line description
   - `order`: Execution sequence
   - `depends_on`: Array of prerequisite slice IDs
   - `passes`: false (initially)
6. Write SLICES.md overview table
7. Initialize STATE.md with position at slice 0

**slices.json schema:**
```json
{
  "project": "Project Name",
  "created": "2025-02-04",
  "slices": [
    {
      "id": "AUTH-1",
      "name": "Username/password authentication",
      "order": 1,
      "depends_on": [],
      "passes": false,
      "spec_path": null
    }
  ]
}
```

**Setup requirements** (verified before slicing):
- `setup-tdd-guard` active (PreToolUse hook)
- Pre-commit hook for 100% coverage (or husky/lint-staged)
- Vitest with coverage thresholds configured

**Key constraint:** Does NOT start implementation. Outputs structured plan for Ralph loop.

---

## Skill 2: `/feather:add-slice`

**File:** `~/.claude/skills/feather:add-slice/SKILL.md`

**Purpose:** Add more slices to an existing project after initial setup.

**When to use:**
- Started with one slice, want to add more
- New feature idea during development
- Breaking a large slice into smaller ones

**Process:**
1. Read existing `.slices/slices.json`
2. Explore new slice intent via questions
3. Determine dependencies (can depend on existing slices)
4. Add to slices.json with next available order number
5. Update SLICES.md overview

**Example:**
```
User: "Add a slice for email notifications"

→ Reads slices.json (has AUTH-1, TODO-1)
→ Creates NOTIFY-1 with depends_on: ["AUTH-1"]
→ Appends to slices.json
→ Updates SLICES.md
```

**Flexibility:** User can also ask to reorder or modify existing slices here.

---

## Skill 3: `/feather:work-slice`

**File:** `~/.claude/skills/feather:work-slice/SKILL.md`

**Purpose:** Execute ONE slice with strict TDD, update status, then STOP.

**Process:**
1. Read `.slices/slices.json` → pick first slice where `passes: false`
2. Read `.slices/STATE.md` → understand context
3. **For this slice ONLY:**
   - Use `feather-spec` (existing `create-spec`) → `docs/specs/<slice-id>/spec.md`
   - Use `derive-tests-from-spec` → Gherkin scenarios
   - **TDD Loop** (with tdd-guard hook enforced):
     - Write test (RED) → **VERIFY FAILS** → show output
     - Write code (GREEN) → **VERIFY PASSES** → show output
     - Commit with "RED: <test>" / "GREEN: <impl>" messages
   - Use `verify-feature` → 100% coverage gate

### Test Philosophy (DHH style - full stack by default)

**Default: One test, full stack (UI → database)**
```typescript
// GOOD: CRUD test covers everything
it("creates todo and persists to database", async () => {
  await user.type(input, "Buy milk");
  await user.click(submitButton);

  // UI verification
  expect(screen.getByText("Buy milk")).toBeInTheDocument();

  // Database verification (REQUIRED)
  const todos = await t.run(async (ctx) => ctx.db.query("todos").collect());
  expect(todos[0].text).toBe("Buy milk");
});
```

**Exception: Unit tests for edge cases hard to set up in e2e**
```typescript
// GOOD: Edge case that's hard to trigger through UI
it("handles 500 character limit", () => {
  expect(validateTitle("x".repeat(501))).toBe(false);
});
```

**FORBIDDEN:**
```typescript
// BAD: Separate backend test (redundant - integration already covers it)
describe("todos.create", () => { ... });

// BAD: Separate frontend test (tests mock, not real behavior)
describe("TodoForm", () => { vi.mock("convex/react"); ... });

// BAD: Separate integration test (this IS the integration test)
describe("TodoList integration", () => { ... });
```

**Rule:** If a slice is CRUD, write CRUD tests (UI → DB). Don't split into layers.

### Test Checklist (agent ticks, human verifies)

Before marking slice complete, agent must present this checklist:

```markdown
## Test Checklist for [SLICE-ID]

- [ ] Tests are full-stack (UI action → database verification)
- [ ] Database state verified in assertions (not just UI)
- [ ] No `vi.mock("convex/react")` except for loading/error states
- [ ] No separate backend test files (convex/*.test.ts)
- [ ] No separate frontend-only tests (mocked hooks)
- [ ] Unit tests only for edge cases hard to trigger through UI

**Test files created:**
- `src/components/TodoList.integration.test.tsx` (12 tests)

**Patterns used:**
- ConvexTestProvider for real backend execution
- t.run() for database verification
```

Human reviews checklist before approving. Agent can lie about ticking boxes - human catches it.

**Future enhancement:** Extend tdd-guard to automatically detect forbidden patterns (vi.mock, separate backend files) and block. For now, human verification.
4. Update slices.json: `passes = true` for this slice
5. **Delete CONTINUE.md** if exists (cleanup after successful completion)
6. Update STATE.md with:
   - Current position
   - Decisions made
   - Next slice to work
7. **STOP** with message: "✓ AUTH-1 complete. Next: AUTH-2. Run /feather:work-slice to continue."

### Executable Guardrails (not philosophy)

**Why this works when superpowers failed:**
- Superpowers: "Evidence before claims" → agent circumvents with words
- This: **hooks literally block tools/commands** → can't circumvent

| Guardrail | Enforcement | What It Blocks |
|-----------|-------------|----------------|
| `tdd-guard` hook | PreToolUse hook | Edit/Write on non-test files when tests failing |
| Pre-commit hook | Git pre-commit | `git commit` if any check fails |
| Vitest threshold | Coverage config | Tests fail if coverage drops below 100% |

**No philosophy. No red flags. No rationalization lists.** Just hooks that block tools.

**Pre-commit hook setup** (add to project):
```bash
# .git/hooks/pre-commit (or use husky/lint-staged)
#!/bin/sh
set -e

# All guardrails block commit
npm run test:coverage          # Tests + 100% coverage
npx tsc --noEmit               # TypeScript diagnostics (type errors)
npm run lint                   # Lint errors (user's eslintrc)
```

**Lint rules:** User manages via existing `.eslintrc`. Disable noisy rules (import order, etc.) in eslintrc, not in slice system. Only meaningful lint rules should be enabled.

### Key Constraints

- ONE slice per invocation (prevents context rot)
- TDD hook must be active (setup-tdd-guard)
- Must stop after slice completion (human-in-the-loop)
- **100% coverage required** - no exceptions

**Integration with existing skills:**
- Invokes: `create-spec`, `derive-tests-from-spec`, `write-tests`, `verify-feature`
- Requires: `setup-tdd-guard` active in project

---

## Skill 4: `/feather:pause-slice`

**File:** `~/.claude/skills/feather:pause-slice/SKILL.md`

**Purpose:** Create handoff file when stopping mid-TDD cycle (before slice completes).

**When to use:**
- Context window filling up
- Need to stop before slice is complete
- Switching to other work temporarily

**Process:**
1. Detect current slice from `.slices/slices.json`
2. Determine TDD cycle position:
   - `spec` - Spec created but tests not derived
   - `gherkin` - Tests derived, not implemented
   - `red` - In RED phase, some tests failing
   - `green` - In GREEN phase, implementing
   - `verify` - Running verification
3. Capture state to `.slices/CONTINUE.md`:

```markdown
---
slice_id: AUTH-1
phase: red
last_updated: 2025-02-04T14:30:00Z
---

# Continue AUTH-1

## Current Position
- **Slice:** AUTH-1 (Username/password auth)
- **TDD Phase:** RED - tests written, 3/5 failing
- **Last Test:** `should reject invalid password`

## Work Completed
- [x] Spec created: docs/specs/auth-1/spec.md
- [x] Gherkin derived: 5 scenarios
- [x] Tests written: 5 tests
- [ ] Implementation: 2/5 passing

## Uncommitted Changes
- src/auth/login.test.ts (new)
- src/auth/login.ts (in progress)

## Decisions Made
- Using bcrypt for password hashing
- JWT for session tokens

## Next Action
Continue GREEN phase: implement `validatePassword()` to pass test 3
```

4. **DO NOT commit** - CONTINUE.md is local-only (gitignored)

5. Display confirmation:
   ```
   ✓ Paused AUTH-1 at RED phase (3/5 tests failing)

   Handoff: .slices/CONTINUE.md

   To resume: /feather:resume-slice
   ```

**Key constraint:** Does NOT update slices.json (slice not complete).

---

## Skill 5: `/feather:resume-slice`

**File:** `~/.claude/skills/feather:resume-slice/SKILL.md`

**Purpose:** Restore context after session break, show status, route to next action.

**Process:**
1. **Check for graceful handoff:** `.slices/CONTINUE.md`
   - If exists → show slice position, route to `/feather:work-slice` to continue

2. **Detect incomplete work (recovery mode - no CONTINUE.md):**
   ```bash
   # Check for uncommitted changes
   git status --porcelain

   # Check for failing tests
   npm test 2>&1 | grep -E "FAIL|PASS"

   # Check for spec without passing slice
   ls docs/specs/*/spec.md  # specs exist?
   cat .slices/slices.json  # which slices still have passes: false?
   ```

   **Recovery heuristics:**
   - Uncommitted test files → likely in RED or GREEN phase
   - Failing tests → in GREEN phase (implementing)
   - Spec exists but slice not passing → in TDD loop
   - All tests pass but slice marked `passes: false` → in VERIFY phase

3. Read `.slices/slices.json` → get slice statuses
4. Read `.slices/STATE.md` → get last position, decisions, blockers
5. Display status:
   ```
   Slice Project: [Project Name]

   Progress: 2/6 slices complete

   | Slice | Status | Coverage |
   |-------|--------|----------|
   | AUTH-1 | ✓ Complete | 100% |
   | AUTH-2 | ✓ Complete | 100% |
   | TODO-1 | → Next | — |
   | PROJ-1 | Pending | — |

   Last session: [date]
   Decisions: [summary]

   ⚠️ Recovery: Found uncommitted changes in src/auth/
      3 failing tests detected
      Likely in GREEN phase for AUTH-1

   Next: /feather:work-slice to continue with TODO-1
   ```
6. Route to appropriate action:
   - CONTINUE.md exists? → Show position, offer: "Continue from here?" or "Discard and start fresh?"
   - Recovery detected? → Show findings, ask to continue or reset
   - All slices complete? → "Project complete! Run /finish-branch"
   - Slices remaining? → "Run /feather:work-slice to continue"
   - Blocker noted? → Show blocker, ask for resolution

**Discard option:** If user chooses to discard CONTINUE.md, delete it and start slice fresh.

### Slice Flexibility (iterative requirements)

User can always say:
- **"Redo AUTH-1"** → Mark slice as `passes: false`, re-enter TDD loop
- **"Move TODO-1 before PROJ-1"** → Reorder in slices.json (warn about dependency issues)
- **"Remove MEMBER-1"** → Delete from slices.json
- **"Split TODO-1 into two slices"** → Create TODO-1a, TODO-1b

Requirements are iterative. The slice list is always editable, not locked after creation.

---

## Skill 6: `/feather:note-issue`

**File:** `~/.claude/skills/feather:note-issue/SKILL.md`

**Purpose:** Quickly capture bugs and UX tweaks discovered during use.

**When to use:**
- Found a minor bug while testing
- Noticed a UX improvement after seeing final output
- Too small for a full slice, but needs tracking

**Process:**
1. User describes issue: "The save button is hard to see" or "Login fails with special characters"
2. Append to `.slices/feather:polish.md`:
   ```markdown
   ## Polish Queue

   - [ ] **UX** Save button contrast too low (discovered during TODO-1)
   - [ ] **BUG** Login fails with special chars in password (discovered during AUTH-1)
   - [ ] **UX** Add loading spinner on form submit
   ```
3. Confirm: "Added to polish queue (3 items). Run /feather:polish when ready."

**Key constraint:** Just captures, doesn't fix. Quick and lightweight.

---

## Skill 7: `/feather:polish`

**File:** `~/.claude/skills/feather:polish/SKILL.md`

**Purpose:** Work through the polish queue with TDD (but skip spec/gherkin ceremony).

**Process:**
1. Read `.slices/feather:polish.md`
2. Show queue:
   ```
   Polish Queue (3 items):
   1. [UX] Save button contrast too low
   2. [BUG] Login fails with special chars
   3. [UX] Add loading spinner

   Pick one to fix, or "all" to work through sequentially.
   ```
3. For each item:
   - Write test (RED) → tdd-guard still enforced
   - Fix (GREEN)
   - Commit: "fix: save button contrast" or "fix: login special chars"
   - Mark as done in polish.md
4. **Still requires TDD** - no code without test, but skips spec/gherkin

**Key constraint:** Lighter than full slice, but TDD is still mandatory.

---

## Skill 8: Update `dev-workflow`

**File:** `~/.claude/skills/dev-workflow/SKILL.md`

**Changes:** Add "Slice Mode" as alternative flow for multi-feature projects.

**New section:**
```markdown
## Slice Mode (Multi-Feature Projects)

For larger projects with multiple features, use slice-based workflow:

┌─────────────────────────────────────────────────────────────────────┐
│  SESSION 1: SLICE PROJECT                                            │
│  Skill: /feather:slice-project                                               │
│  Output: slices.json, STATE.md, DOMAIN.md                           │
├─────────────────────────────────────────────────────────────────────┤
│  SESSION 2+: WORK ONE SLICE                                          │
│  Skill: /feather:work-slice (or /feather:resume-slice first)                        │
│  Per-slice: spec → gherkin → TDD → verify → STOP                    │
├─────────────────────────────────────────────────────────────────────┤
│  MID-SLICE: PAUSE                                                    │
│  Skill: /feather:pause-slice                                                 │
│  Creates: CONTINUE.md with TDD cycle position                        │
├─────────────────────────────────────────────────────────────────────┤
│  AFTER BREAK: RESUME                                                 │
│  Skill: /feather:resume-slice                                                │
│  Shows: position, progress, next action                              │
│  Detects: CONTINUE.md for mid-cycle resume                           │
└─────────────────────────────────────────────────────────────────────┘

When to use:
- Multiple features/phases (more than one /create-design cycle)
- Projects that span multiple sessions
- Need to "spec ahead" while implementing current slice
```

---

## Implementation Order

1. **Create `/feather:slice-project`** - Foundation (supports single slice mode)
2. **Create `/feather:add-slice`** - Add slices incrementally
3. **Create `/feather:work-slice`** - Core execution with TDD
4. **Create `/feather:pause-slice`** - Mid-cycle handoffs
5. **Create `/feather:resume-slice`** - Session restoration (handles CONTINUE.md)
6. **Create `/feather:note-issue`** - Capture bugs/UX to queue
7. **Create `/feather:polish`** - Work through polish queue
8. **Update `/dev-workflow`** - Integrate slice mode
9. **Test end-to-end** with single-slice flow first

---

## Verification Plan

After implementation, test with:

1. **Run `/feather:slice-project`** with: "Build a todo app with auth"
   - Verify: DOMAIN.md, slices.json, SLICES.md, STATE.md created
   - Verify: At least 3 slices identified with dependencies

2. **Run `/feather:work-slice`**
   - Verify: Picks first incomplete slice
   - Verify: Creates spec, derives tests
   - Verify: TDD loop enforced (blocked without tests)
   - Verify: Updates slices.json (passes = true)
   - Verify: STOPS after one slice

3. **Test `/feather:pause-slice` mid-cycle**
   - Start `/feather:work-slice`, stop after writing some tests
   - Run `/feather:pause-slice`
   - Verify: CONTINUE.md created with TDD phase
   - Verify: Uncommitted changes listed
   - Verify: slices.json NOT updated (slice incomplete)

4. **Test graceful resume with `/feather:resume-slice`**
   - Run `/feather:pause-slice` → creates CONTINUE.md
   - Simulate context reset (`/clear`)
   - Run `/feather:resume-slice`
   - Verify: Detects CONTINUE.md
   - Verify: Shows exact TDD phase position
   - Verify: Routes to /feather:work-slice

5. **Test recovery mode (abrupt cutoff)**
   - Start `/feather:work-slice`, write some tests, DON'T run `/feather:pause-slice`
   - Simulate context reset (`/clear`)
   - Run `/feather:resume-slice`
   - Verify: No CONTINUE.md found
   - Verify: Detects uncommitted changes via `git status`
   - Verify: Runs tests to determine phase (failing = GREEN phase)
   - Verify: Shows recovery findings with warning
   - Verify: Asks whether to continue or reset

---

## Key Design Decisions (from exploration)

| Decision | Rationale |
|----------|-----------|
| `.slices/` folder | Keeps slice state separate from `docs/specs/` content |
| Both JSON + MD state | Machine-readable for routing, human-readable for context |
| ONE slice per session | Prevents context rot (from GSD/Anthropic research) |
| Reuse existing skills | `create-spec`, `derive-tests`, `verify-feature` already work |
| tdd-guard integration | Hook-based enforcement is the differentiator |
| Stop after completion | Maintains human-in-the-loop control |
| **Show first, refine later** | Don't ask questions upfront - generate slices, let user critique |
| **Slices are always editable** | Requirements are iterative - redo, reorder, remove anytime |

---

## Ideas Synthesis

### From Superpowers (NOT adopted)
- ~~Verification discipline~~ - "Evidence before claims" → **agent circumvents with words**
- ~~Rationalization blockers~~ - Explicit lists → **agent ignores them**
- **Learning:** Philosophy doesn't work. Executable enforcement does.

### From Ralph/GSD (adopted)
- **One task per loop** - Prevents context rot
- **prd.json pattern** - Machine-readable status with `passes: true/false`
- **STATE.md pattern** - Human-readable session state
- **Pause/resume flow** - Clean handoffs between sessions

### Your Unique Additions (the actual differentiators)
- **tdd-guard hook** - **EXECUTABLE** - blocks Edit/Write tools, can't circumvent
- **100% coverage threshold** - **EXECUTABLE** - build fails, can't mark complete
- **RED before GREEN** - Hook enforces this, not words
- **Feather-* naming** - Lightweight artifacts (feather-spec, feather-mockup) = quick, iterative, not heavyweight

---

## Files to Create

| File | Lines (est.) | Purpose |
|------|--------------|---------|
| `feather:slice-project/SKILL.md` | ~150 | Project init (single or multi slice) |
| `feather:add-slice/SKILL.md` | ~80 | Add slices incrementally |
| `feather:work-slice/SKILL.md` | ~150 | TDD slice execution |
| `feather:pause-slice/SKILL.md` | ~100 | Mid-cycle handoffs |
| `feather:resume-slice/SKILL.md` | ~120 | Session restoration |
| `feather:note-issue/SKILL.md` | ~50 | Capture bugs/UX to queue |
| `feather:polish/SKILL.md` | ~80 | Work through polish queue |
| Update `dev-workflow/SKILL.md` | +50 | Add feather: workflow section |

**Total:** ~780 lines across 8 files
