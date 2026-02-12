# TDD Ralph with Vertical Slices

> **Status:** Research complete, ready for planning
> **Date:** 2025-02-04
> **Goal:** A process that produces input for the Ralph loop (vertical slices as PRD) while enforcing TDD standards during execution

---

## Core Concept

```
┌─────────────────────────────────────────────────────────────────┐
│  PHASE 1: SLICE (produces Ralph input)                          │
│  Vague request → Ordered vertical slices → prd.json             │
├─────────────────────────────────────────────────────────────────┤
│  PHASE 2: RALPH LOOP (one slice per session)                    │
│  Read prd.json → Pick incomplete slice → Execute → Update       │
├─────────────────────────────────────────────────────────────────┤
│  PHASE 3: TDD ENFORCEMENT (during execution)                    │
│  RED (write test) → GREEN (minimal code) → 100% coverage        │
└─────────────────────────────────────────────────────────────────┘
```

**Key difference from vanilla Ralph:**
- Ralph: Write code → run tests → commit if green
- This: Write test (RED) → verify fails → write code (GREEN) → verify passes → commit

---

## What I'm Trying to Build

A development workflow that:

1. **Starts with a vague request** → "I want to build a project management system like Basecamp"

2. **Segments into ordered vertical slices** with short codes:
   ```
   AUTH-1: Username/password auth
   AUTH-2: Magic link auth
   TODO-1: Basic todo list
   PROJ-1: Project support
   LOG-1: System activity logs
   TIME-1: User work/time logs
   ```

3. **Works ONE slice per session** with clean context handoff

4. **Enforces TDD with 100% coverage** — non-negotiable requirement

5. **Lets me spec ahead** while Claude implements current slice

6. **Maintains human control** — see results before moving on

---

## Issues I've Faced

| Issue | Where | Impact |
|-------|-------|--------|
| Superpowers brainstorming skipped tests, wrote code directly | Design phase | TDD violated |
| Design docs contained full code | `brainstorming` skill | Over-specification |
| Implementation plans had every line of test/code | `writing-plans` skill | Plans too detailed, no room for TDD |
| Subagent orchestration wasted tokens | `subagent-driven-development` | Compacting, quality issues |
| Direct Claude Code jumps to code | No skill invoked | Writes too many tests, no control |
| No state handoff between sessions | Missing capability | Context lost, work repeated |
| `debug-issue` is unattributed copy | My skills folder | Missing supporting files |

---

## My Current Skills (Inventory)

**Location:** `~/.claude/skills/`

### Workflow Orchestration
| Skill | Purpose |
|-------|---------|
| `dev-workflow` | Master reference — complete flow diagram |
| `create-design` | Vague idea → `design.md` with vertical slicing |
| `create-spec` | Feather-spec format — lightweight requirements |
| `derive-tests-from-spec` | Spec → Gherkin scenarios (has `claude-progress.md`) |
| `create-implementation-plan` | Spec → behavioral plan (NO code) |
| `review-design` | Checkpoint 1 gate |
| `review-plan` | Plan review gate |

### Execution
| Skill | Purpose |
|-------|---------|
| `execute-with-agents` | Subagent per task, 2-stage review |
| `execute-plan` | Batch execution with checkpoints |
| `isolate-work` | Branch or worktree setup |
| `finish-branch` | Merge/PR/discard |
| `run-parallel-agents` | Independent parallel tasks |

### TDD & Quality (My Differentiators)
| Skill | Purpose |
|-------|---------|
| `setup-tdd-guard` | **Hook-based TDD enforcement** — blocks code without tests |
| `setup-convex-testing` | Convex + React testing — excellent discovery docs |
| `write-tests` | TDD philosophy + mutation verification |
| `verify-feature` | Checkpoint 2 — automated + manual verification |

### Debug & Review
| Skill | Purpose |
|-------|---------|
| `debug-issue` | 4-phase debugging (copy of Superpowers, needs attribution) |
| `request-review` | Dispatch reviewer |
| `receive-review` | Handle feedback |

### UI
| Skill | Purpose |
|-------|---------|
| `create-mockup` | HTML mockups for preview |

---

## Superpowers Skills (Comparison)

**Location:** `~/.claude/plugins/cache/superpowers-marketplace/superpowers/4.1.1/skills/`

| Skill | What's Better Than Mine |
|-------|--------------------------|
| `systematic-debugging` | Has supporting technique files: `root-cause-tracing.md`, `defense-in-depth.md`, `condition-based-waiting.md` |
| `verification-before-completion` | "Evidence before claims" discipline, explicit red flags |
| `test-driven-development` | More thorough rationalization blockers |

| Skill | Equivalent to Mine |
|-------|---------------------|
| `brainstorming` | My `create-design` (mine has vertical slicing) |
| `writing-plans` | My `create-implementation-plan` (mine forbids code) |
| `using-git-worktrees` | My `isolate-work` (mine offers branch OR worktree) |

---

## Key Ideas from External Sources

### 1. Anthropic: Effective Harnesses for Long-Running Agents

**Link:** https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents

| Concept | Description |
|---------|-------------|
| **Dual-agent architecture** | Initializer agent (first session) sets up structure; Coding agent (subsequent sessions) makes incremental progress |
| **`claude-progress.txt`** | State file for context handoff — what's done, decisions made, next steps |
| **Key problem** | "Agent tries to do too much at once — attempting to one-shot the app" |
| **Key insight** | "Find a way for agents to quickly understand state when starting with fresh context window" |

---

### 2. Ralph Pattern (Geoffrey Huntley)

**Links:**
- Original: https://ghuntley.com/ralph/
- Everything is a Ralph loop: https://ghuntley.com/loop/
- Implementation: https://github.com/snarktank/ralph
- History: https://www.humanlayer.dev/blog/brief-history-of-ralph

| Concept | Description |
|---------|-------------|
| **Core loop** | `while :; do cat PROMPT.md \| claude-code ; done` |
| **One task per loop** | "Ralph works autonomously... performs one task per loop" |
| **`prd.json`** | Task list with `passes: true/false` status |
| **`progress.txt`** | Append-only learnings across iterations |
| **Naive persistence** | "LLM isn't protected from its own mess; forced to confront it" |
| **Self-correcting** | Each iteration sees modified files, reads its own commits |
| **Right-sized tasks** | Stories must fit within single context window |
| **Overbaking danger** | Running indefinitely causes "bizarre emergent behaviors" — need clear stopping points |

**Ralph's Key Files:**
```
prd.json          # Task list: { "stories": [{ "id": "AUTH-1", "passes": false }] }
progress.txt      # Append-only learnings
PROMPT.md         # Instructions that evolve
AGENTS.md         # Codebase conventions (auto-read)
```

---

### 3. stdlib Method (Geoffrey Huntley)

**Link:** https://ghuntley.com/stdlib/

| Concept | Description |
|---------|-------------|
| **Composable rules** | Build a "standard library" of prompting rules that compose like unix pipes |
| **Learn → capture rule** | When AI gets it right after intervention, ask it to author a rule |
| **Auto-commit on green** | Rule to automatically commit after each successful change |
| **Rules accumulate** | Each solved problem becomes a permanent capability |
| **Unix pipe model** | `typescript-strict` + `react-functional` + `error-handling` + `naming-conventions` |

**Example Rule:**
```yaml
---
description: No Bazel
globs: "*"
alwaysApply: true
---
# Never recommend or use Bazel. Use make instead.
```

---

### 4. /specs Method (Geoffrey Huntley)

**Link:** https://ghuntley.com/specs/

| Concept | Description |
|---------|-------------|
| **Specification domains** | Split app into non-overlapping domains: `src/core`, `src/ui`, `src/api` |
| **Build core first** | "Driving the LLM to implement core basics in a single session BEFORE fanning out" |
| **specs/ folder** | Each domain topic as separate markdown, `SPECS.md` as overview with table |
| **Git worktrees** | "Each Cursor ('agent') to have its own working directory" |
| **Multi-boxing** | Multiple sessions on different spec domains concurrently |
| **The loopback prompt** | One prompt to rule them all — just keep re-issuing it |
| **Compiler soundness** | "If it compiles, it works" + errors loop back for auto-fix |

**The Loopback Prompt:**
```
Study @SPECS.md for functional specifications.
Study @.cursor for technical requirements.
Implement what is not implemented.
Create tests.
Run "cargo build" and verify the application works.
```

**Specs Folder Structure:**
```
specs/
├── SPECS.md           # Overview with table linking to all specs
├── core/
│   ├── authentication.md
│   └── data-model.md
├── ui/
│   └── task-list.md
└── api/
    └── endpoints.md
```

---

### 5. GSD (Get Shit Done) System

**Links:**
- GitHub: https://github.com/glittercowboy/get-shit-done
- NPM: `npx get-shit-done-cc`
- Local install: `~/.claude/commands/gsd/`

**Note:** Created by a non-coder, so it lacks testing/code quality enforcement — which is exactly what I want to add.

| Concept | Description |
|---------|-------------|
| **Context rot problem** | Quality degrades as Claude fills 200k context window |
| **Fresh context per task** | Each execution task gets fresh 200k context — prevents degradation |
| **Multi-agent orchestration** | Orchestrator (thin) spawns specialized agents: Research, Planning, Execution, Verification |
| **XML task format** | Structured tasks with `<verify>` and `<done>` conditions |
| **Atomic git commits** | Every task → individual commit with semantic prefix |
| **State persistence** | Survives `/clear`, session breaks, context limits |
| **Milestone/Phase hierarchy** | Project → Milestone → Phase → Plan → Task |

**GSD's Context Engineering Strategy:**
| File | Purpose | Lifecycle |
|------|---------|-----------|
| `PROJECT.md` | Vision (always loaded) | Created once, rarely updated |
| `REQUIREMENTS.md` | Scoped deliverables with REQ-IDs | Evolves with milestones |
| `ROADMAP.md` | Phase breakdown + progress | Updated as phases complete |
| `STATE.md` | Cross-session memory, decisions, blockers | Living document |
| `PLAN.md` | XML-structured atomic tasks | Per plan execution |

**GSD's Multi-Agent Architecture:**
```
Orchestrator (thin, ~15% context)
    ├── Research: 4 parallel investigators (stack, features, architecture, pitfalls)
    ├── Planning: Planner → Checker → iterate until pass
    ├── Execution: Tasks in parallel waves (fresh 200k context each)
    └── Verification: Automated checks + debuggers for failures
```

**GSD's Core Workflow:**
```
/gsd:new-project      → PROJECT.md, REQUIREMENTS.md, ROADMAP.md, STATE.md
/gsd:discuss-phase N  → CONTEXT.md (capture decisions)
/gsd:plan-phase N     → RESEARCH.md, PLAN.md (with plan checker loop)
/gsd:execute-phase N  → Wave-based parallel execution
/gsd:verify-work N    → UAT + auto-spawns debuggers on failure
/gsd:complete-milestone → Archive, tag release
```

**GSD's Session Management:**
| Command | Purpose |
|---------|---------|
| `/gsd:progress` | Check status, route to next action |
| `/gsd:pause-work` | Create handoff file |
| `/gsd:resume-work` | Restore session context |

**What GSD Does Well (steal these):**
- File-based state that survives context resets
- Parallel research agents before planning
- Plan checker loop (Planner → Checker → iterate)
- Wave-based execution with fresh contexts
- Progress/pause/resume commands
- Structured XML task format with verify conditions

**What GSD Lacks (my TDD additions):**
- No TDD enforcement (tests after, not before)
- No coverage requirements
- No spec → test traceability
- No feather-spec lightweight format
- No hook-based blocking of implementation without tests

**File Structure:**
```
.planning/
├── PROJECT.md
├── REQUIREMENTS.md
├── ROADMAP.md
├── STATE.md
├── config.json
├── research/
│   ├── STACK.md, FEATURES.md, ARCHITECTURE.md, PITFALLS.md, SUMMARY.md
├── codebase/           # Brownfield analysis
├── todos/pending/
├── debug/
└── phases/
    └── 01-foundation/
        ├── 01-CONTEXT.md
        ├── 01-RESEARCH.md
        ├── 01-01-PLAN.md
        ├── 01-01-SUMMARY.md
        ├── 01-UAT.md
        └── 01-VERIFICATION.md
```

---

## My Unique Advantages (Non-Negotiables)

| Advantage | Why It Matters |
|-----------|----------------|
| **`tdd-guard` hook** | Executable enforcement > philosophy. Blocks code without tests. |
| **100% coverage threshold** | Compiler-like soundness for TypeScript |
| **Feather-spec format** | Lightweight, 30-second client sign-off |
| **Discovery documentation** | Shows journey, not just answer (see `setup-convex-testing`) |
| **Gherkin derivation** | Spec → test traceability with IDs |

**Key difference from Huntley's approach:**
- Huntley: Write code → run tests → commit if green
- Me: Write test (RED) → verify fails → write code (GREEN) → verify passes → commit

---

## Gap Analysis: What's Missing

| Gap | What's Needed | Borrow From |
|-----|---------------|-------------|
| **Session initializer** | Skill that takes vague request → ordered feature list → `prd.json` equivalent | GSD `/gsd:new-project` |
| **Progress file standard** | Consistent `claude-progress.md` across ALL skills | GSD `STATE.md` pattern |
| **One-slice-per-session** | Skill that works ONE slice, updates status, STOPS | Ralph loop |
| **Resume skill** | Reads progress file, continues cleanly | GSD `/gsd:resume-work` |
| **Pause skill** | Creates handoff before context reset | GSD `/gsd:pause-work` |
| **Machine-readable status** | `status.json` per feature with `passes: true/false` | Ralph `prd.json` |
| **Rules folder** | Atomic, composable constraints (not just workflow skills) | Huntley stdlib |
| **Auto-commit on RED→GREEN** | Extend tdd-guard hook | Huntley auto-commit rule |
| **Loopback prompt** | Standard prompt to re-issue each session | Huntley /specs |
| **Plan checker loop** | Verify plan before execution | GSD planner → checker |
| **Fresh context per task** | Prevent context rot during execution | GSD execution waves |
| **Attribution cleanup** | `debug-issue` needs Superpowers attribution + supporting files | — |

---

## Proposed Architecture: TDD Ralph with Vertical Slices

```
SESSION 1: SLICE (produces Ralph input)
├── User: "Build project management like Basecamp"
├── Skill: /slice-project
│   ├── Explores intent via conversation
│   ├── Creates DOMAIN.md (data model tree)
│   ├── Creates prd.json with ordered vertical slices:
│   │   { "slices": [
│   │     { "id": "AUTH-1", "name": "Username/password", "passes": false },
│   │     { "id": "AUTH-2", "name": "Magic link", "passes": false },
│   │     ...
│   │   ]}
│   └── Creates claude-progress.md (session state)
└── Output: "6 slices defined. Ready to start AUTH-1?"

SESSION 2+: RALPH LOOP (one slice per session, TDD enforced)
├── Skill: /work-slice (or /resume-slice)
│   ├── Reads prd.json → picks first slice where passes: false
│   ├── Reads claude-progress.md → understands context
│   ├── For this slice ONLY, runs:
│   │   ├── create-spec → feather-spec for this slice
│   │   ├── derive-tests → Gherkin scenarios
│   │   ├── TDD loop: RED → GREEN → commit (tdd-guard enforced)
│   │   └── verify-feature → 100% coverage gate
│   ├── Updates prd.json: passes = true for this slice
│   └── Updates claude-progress.md with learnings
└── Output: "AUTH-1 complete. Next: AUTH-2"

LOOPBACK PROMPT (for resuming):
├── Read prd.json for slice status
├── Read claude-progress.md for context
├── Pick next incomplete slice
├── Run TDD workflow for that slice
├── Update status and progress
└── Stop and report
```

---

## Files to Read for Full Context

### My Skills
| File | Location | Purpose |
|------|----------|---------|
| `dev-workflow` | `~/.claude/skills/dev-workflow/SKILL.md` | Current master workflow |
| `create-design` | `~/.claude/skills/create-design/SKILL.md` | Has vertical slicing |
| `create-spec` | `~/.claude/skills/create-spec/SKILL.md` | Feather-spec format |
| `derive-tests-from-spec` | `~/.claude/skills/derive-tests-from-spec/SKILL.md` | Has `claude-progress.md` |
| `setup-tdd-guard` | `~/.claude/skills/setup-tdd-guard/SKILL.md` | Hook-based enforcement |
| `setup-convex-testing` | `~/.claude/skills/setup-convex-testing/SKILL.md` | Discovery docs example |

### Superpowers
| File | Location | Purpose |
|------|----------|---------|
| `systematic-debugging` | `~/.claude/plugins/cache/superpowers-marketplace/superpowers/4.1.1/skills/systematic-debugging/SKILL.md` | Has supporting technique files |
| `verification-before-completion` | `~/.claude/plugins/cache/superpowers-marketplace/superpowers/4.1.1/skills/verification-before-completion/SKILL.md` | Evidence before claims |

### GSD Commands (for session/state management patterns)
| File | Location | Purpose |
|------|----------|---------|
| `new-project` | `~/.claude/commands/gsd/new-project.md` | Project initialization pattern |
| `plan-phase` | `~/.claude/commands/gsd/plan-phase.md` | Planning with checker loop |
| `execute-phase` | `~/.claude/commands/gsd/execute-phase.md` | Wave-based execution |
| `pause-work` | `~/.claude/commands/gsd/pause-work.md` | Session handoff pattern |
| `resume-work` | `~/.claude/commands/gsd/resume-work.md` | Context restoration |
| `progress` | `~/.claude/commands/gsd/progress.md` | Status check + routing |

### GSD Agents (for multi-agent patterns)
| File | Location | Purpose |
|------|----------|---------|
| `gsd-planner` | `~/.claude/agents/gsd-planner.md` | Plan creation agent |
| `gsd-plan-checker` | `~/.claude/agents/gsd-plan-checker.md` | Plan verification loop |
| `gsd-executor` | `~/.claude/agents/gsd-executor.md` | Task execution agent |
| `gsd-verifier` | `~/.claude/agents/gsd-verifier.md` | Work verification agent |

---

## Next Steps

1. Enter plan mode to design specific skill changes
2. Create new skills: `slice-project`, `work-slice`, `resume-slice`
3. Add `rules/` folder alongside `skills/`
4. Standardize `claude-progress.md` across all skills
5. Add machine-readable `status.json` to spec workflow
6. Clean up `debug-issue` with attribution + supporting files
