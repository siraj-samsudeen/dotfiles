# Feather + GSD: A Complementary Analysis

**Purpose:** Show where Feather's quality enforcement layer can plug gaps in GSD's project orchestration system.

**TL;DR:** GSD is infrastructure (research, roadmaps, parallel execution, state). Feather is quality control (TDD enforcement, spec traceability, feedback tracking). They operate at different altitudes and don't compete — they complement.

---

## What Each Framework Is

**GSD** = A context engineering system for project-scale work. It orchestrates 11 specialized subagents across a milestone > phase > plan > task hierarchy. Its superpower is reliable AI execution at scale through goal-backward planning, wave-based parallelization, and stub detection.

**Feather** = A quality enforcement system for feature-level work. It chains lightweight skills across a design > spec > test > implement > verify loop. Its superpower is executable TDD discipline with human-in-the-loop control at every step.

---

## Where GSD is Clearly Stronger (Feather Should NOT Replace)

| Capability | GSD | Feather |
|---|---|---|
| Research | 4 parallel researchers with Context7, confidence levels, tool hierarchy | None |
| Goal-backward planning | Truths > Artifacts > Key Links > Wiring verification | None |
| Parallel execution | Wave-based plan dispatch, fresh 200k context per plan | Intentionally serial (one slice then STOP) |
| Stub detection | 3-level verification: Exists / Substantive / Wired | None |
| Context budget | Tracks degradation at 30/50/70% thresholds | None |
| Model allocation | Quality/balanced/budget profiles per agent role | None |
| Plan verification | Plan-checker verifies plans BEFORE execution | None |
| Deviation rules | Auto-fix bugs vs ASK for architectural changes | None |
| Cross-phase integration | Integration checker verifies phase connections | None |
| Roadmapping | Automated roadmap from requirements with 100% coverage validation | None |
| Atomic commits | Per-task commits with bisect-friendly format | Per-TDD-cycle commits |

These are GSD's core strengths. Feather has no equivalent and shouldn't try to build one.

---

## Where Feather Plugs GSD's Gaps (12 Concrete Holes)

### 1. TDD Enforcement — GSD's Biggest Blind Spot

**The gap:** GSD's executor writes code and commits. There is zero mechanism to ensure tests come first, or even exist. The verifier checks "does the goal work?" but not "is it tested?"

**What Feather brings:**
- `.claude/settings.json` hooks that physically block `Edit`/`Write` on non-test files when tests are failing
- Pre-commit hooks that reject commits below coverage thresholds
- The "iron law": no production code without a failing test first
- This is executable enforcement, not advice — the agent literally cannot write code before tests

**Why it matters:** GSD could pass full verification with zero test coverage. A phase could be "goal achieved" with completely untested code that breaks on the next change.

---

### 2. Test Coverage Gates — GSD Verifies Goals, Not Coverage

**The gap:** GSD's verifier asks "are truths observable?" and "are artifacts wired?" It never asks "is there test coverage?" You could pass GSD verification with zero tests.

**What Feather brings:**
- 100% coverage requirement (vitest config)
- Coverage included in pre-commit gate
- Verification checkpoint includes automated coverage check
- Philosophy: if code isn't tested, either add tests or remove the code

**Potential integration:** Add coverage verification to GSD's verifier as a 4th level beyond Exists/Substantive/Wired — **Tested**.

---

### 3. Read-Only Test Contract — GSD's Executor Writes Both Tests and Code

**The gap:** In GSD, the executor agent writes tests and implementation. This means the agent can adjust tests to match whatever it built — tests confirm the code, not the spec.

**What Feather brings:**
- Tests are derived from specs and become a READ-ONLY CONTRACT
- The implementer can read tests but CANNOT modify them
- Tests represent user intent (from spec), not implementation convenience
- If the code doesn't pass the tests, the code is wrong — not the tests

**Why it matters:** This is the single most powerful quality guarantee in either framework. Without it, tests become tautologies — "the code does what the code does."

---

### 4. Specification Format — GSD Requirements are Heavier

**The gap:** GSD uses REQUIREMENTS.md with requirement IDs — traditional format that works but is verbose. Requirements are written once during project init and referenced throughout.

**What Feather brings:**
- Feather-spec: one-pager with the "30-second rule" (client reads headings + examples, signs off)
- EARS syntax (WHEN/WHILE/IF-THEN/Ubiquitous/WHERE) — AI-native, unambiguous
- Grouped by user capability, not technical component
- Concrete example tables that serve triple duty: client sign-off, test data, disambiguation
- Example tables become Gherkin test data directly

**Why it matters:** Lighter specs = faster iteration. Example tables that become test data = less duplication. AI-native syntax = cleaner code generation.

---

### 5. Gherkin Test Derivation — GSD Skips the Test Planning Step

**The gap:** GSD goes: requirements > plan > execute. There's no intermediate step that expands requirements into detailed test scenarios with edge cases before code is written.

**What Feather brings:**
- `derive-tests` expands specs into Gherkin scenarios
- Automatic edge case defaults (empty input = ignore, escape = cancel, etc.)
- User approves scenarios before implementation begins
- Scenario IDs enable traceability (QT-1.1 maps to spec group QT-1)

**Why it matters:** Test scenarios reviewed before implementation = fewer surprises. Edge cases caught in planning = fewer bugs in execution.

---

### 6. End-to-End Traceability — GSD Traces Requirements to Phases, Not to Bugs

**The gap:** GSD maps: Requirement > Phase > Plan > Task > Commit. The chain stops at commits.

**What Feather brings:**
- Full chain: Spec Group (QT-1) > Gherkin Scenario (QT-1.1) > Test File > Feedback Item (BUG-001, source: QT-1, step 3)
- When a bug is found, "QT-3 step 2 failed" maps directly to a spec requirement, a Gherkin scenario, and a test file
- Root cause analysis is instant — no searching through code to figure out which requirement broke

**Why it matters:** Traceability that stops at commits only tells you what changed, not what requirement is violated. Extending to feedback/bugs closes the loop.

---

### 7. Structured Feedback Tracking — GSD Has No Feedback System

**The gap:** GSD's `verify-work` does UAT but captured feedback is prose in UAT.md. Issues found during verification have no structured tracking, prioritization, or lifecycle.

**What Feather brings:**
- `.feedback/` folder with structured markdown files
- Types: BUG-001, TWEAK-002, UX-003, FEATURE-004
- P0-P3 prioritization (fix now > before complete > if time > backlog)
- open/in-progress/resolved lifecycle folders
- Auto-generated INDEX.md dashboard
- Each feedback item traces to spec group and checkpoint step

**Why it matters:** Prose feedback in UAT.md gets stale. Structured feedback with priorities and lifecycle means nothing gets lost between sessions.

---

### 8. UI Mockups — GSD Has No Visual Preview

**The gap:** GSD's `discuss-phase` captures preferences and decisions as text in CONTEXT.md. For UI-heavy phases, there's no visual validation before code is written.

**What Feather brings:**
- Quick HTML mockups rendered in Chrome via Playwright
- Text diagram first (ASCII art), then HTML if approved
- Templates for common layouts (sidebar, cards, forms, todo lists)
- Validates direction in minutes, not hours
- Not pixel-perfect — just enough to confirm layout and flow

**Why it matters:** "Show me" beats "describe to me" for UI. A 5-minute mockup can prevent a 2-hour rewrite.

---

### 9. Polish Queue — GSD Has No Lightweight Bug Workflow

**The gap:** GSD has `add-todo` for ideas, but no workflow for bugs/UX tweaks discovered during development. These either get lost in chat or require creating a whole new phase.

**What Feather brings:**
- `create-issue` appends to `.slices/polish.md` instantly (BUG, UX, PERF, A11Y types)
- `polish` works through the queue with TDD discipline but skips spec/gherkin ceremony
- Commit conventions: fix:, improve:, perf:, a11y:
- Same test-first rigor, lighter process

**Why it matters:** Small bugs shouldn't need a full GSD phase. They need a quick capture mechanism and a lightweight fix workflow.

---

### 10. Full-Stack Test Strategy — GSD Doesn't Prescribe Test Approach

**The gap:** GSD leaves test strategy entirely to the planner/executor. The system has no opinion on what kind of tests to write.

**What Feather brings:**
- Default: one full-stack test per scenario (UI action > Database verification)
- Exception: unit tests only for hard-to-trigger edge cases
- Forbidden: separate backend/frontend test files, separate integration tests
- Mutation tests verify actual database state (not just UI rendering)

**Why it matters:** Unit tests can pass while the feature is broken (components isolated but not wired). GSD's key-link verification catches some wiring issues, but tests that exercise the full stack catch them earlier and more reliably.

---

### 11. Two-Stage Review — GSD's Executor is Self-Reviewing

**The gap:** GSD's executor writes code, self-checks, and commits. There's no independent review step — the same agent that built it evaluates it.

**What Feather brings:**
- `execute` dispatches a fresh subagent per task
- After implementation: spec compliance reviewer (does it match the spec?)
- Then: code quality reviewer (is it well-written?)
- If either finds issues: implementer fixes, re-review loop
- Two separate concerns, two independent reviewers

**Why it matters:** Self-review is inherently biased. The agent that wrote the code will rationalize its choices. Independent reviewers catch what the author misses.

---

### 12. Design Exploration — GSD Discusses, Feather Explores

**The gap:** GSD's `discuss-phase` captures decisions (locked/deferred/discretion). It's about alignment — getting user preferences recorded. It doesn't explore alternatives.

**What Feather brings:**
- `create-design` proposes 2-3 approaches with trade-offs
- Explores alternatives before settling on one
- Validates each section iteratively (200-300 words at a time)
- Asks questions one at a time (prefers multiple choice)

**Why it matters:** For complex features where the approach isn't obvious, exploration before alignment prevents premature commitment to suboptimal solutions.

---

## One Key Tension to Resolve

**GSD's parallelism vs Feather's serial control.**

GSD runs multiple plans in waves (parallel execution). Feather enforces one-slice-then-STOP (serial, human-in-the-loop).

These aren't contradictory — they operate at different granularities:
- Parallelism is at the **plan level** (multiple plans executing concurrently) — GSD's domain
- TDD enforcement is at the **task level** (within each plan, tests before code) — Feather's domain

The executor running Plan 01 and the executor running Plan 02 can work in parallel. Within each executor, TDD hooks ensure tests come before code. The Ralph loop (one slice then STOP) would apply to the overall phase, not to individual parallel plans.

---

## Proposed Hybrid Flow

```
GSD: new-project > research > requirements > roadmap
                                    |
GSD: discuss-phase + Feather: create-design + create-ui-mockup
                                    |
GSD: plan-phase + Feather: create-spec (EARS format within plans)
                                    |
           Feather: derive-tests (Gherkin from spec, user approves)
                                    |
           Feather: review-design (Checkpoint 1 quality gate)
                                    |
GSD: execute-phase (with Feather TDD hooks active in executor env)
     - Tests written first (read-only contract from Gherkin)
     - Implementation must pass tests
     - Coverage gates enforced per task
     - Two-stage review (spec compliance + code quality)
                                    |
GSD: verify-work + Feather: verify (Checkpoint 2)
     - GSD: goal-backward verification (truths/artifacts/wiring)
     - Feather: coverage gates + structured feedback to .feedback/
                                    |
           Feather: polish (bugs found during verification)
                                    |
GSD: complete-milestone
```

**GSD owns:** Project structure, research, orchestration, parallel execution, goal-backward verification, state management, atomic commits.

**Feather owns:** Spec format, test planning, TDD enforcement, coverage gates, feedback tracking, polish queue, UI mockups, quality checkpoints.

---

## Summary Table

| Dimension | GSD Today | With Feather |
|---|---|---|
| Test enforcement | None (trusts executor) | Hooks block code without tests |
| Coverage gates | Not checked | 100% required, pre-commit enforced |
| Test contract | Executor writes tests + code | Tests are read-only, derived from spec |
| Spec format | REQUIREMENTS.md (traditional) | EARS one-pager with example tables |
| Test planning | Skipped (executor decides) | Gherkin scenarios approved before impl |
| Traceability | Requirement > Phase > Commit | Spec > Gherkin > Test > Feedback |
| Feedback tracking | Prose in UAT.md | Structured .feedback/ with P0-P3 lifecycle |
| UI preview | Text in CONTEXT.md | HTML mockups in Chrome |
| Bug workflow | add-todo or new phase | Polish queue with lightweight TDD |
| Test strategy | Executor decides | Full-stack default (UI > DB) |
| Code review | Self-review by executor | Two-stage independent review |
| Design phase | Decision capture | Alternative exploration |
