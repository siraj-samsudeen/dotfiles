---
name: feather-flow
description: >
  The Feather Flow pipeline. Entry point for end-to-end capability
  delivery — from a vague requirement to a merged PR. Orchestrates
  three sub-skills: feather-brainstorm, feather-spec, feather-execute-task.
  Use this skill to understand the full pipeline and when to invoke
  each sub-skill. Each sub-skill can also be invoked directly when
  the user is starting mid-pipeline.
---

# Feather Flow

End-to-end capability delivery. One pipeline, three skills.

```
vague requirement / pain point
        │
        ▼
feather-brainstorm          ← expand horizons, capture in user's words
        │                      Output: capabilities/<name>/brainstorm.md
        ▼
feather-spec                ← author all spec artifacts from brainstorm
        │                      Output: capability.md, design.md,
        │                              screens/, components/, tasks.md
        ▼
feather-execute-task        ← build one task at a time, gate at every step
        │                      Output: working code, per-task plan files
        ▼
       PR                   ← drafted by feather-execute-task, opened by user
```

---

## The Three Skills

### feather-brainstorm

**When:** User has a vague requirement, a specific feature idea,
or a mid-implementation pivot.

**What it does:**
- Optional discovery phase: traces the current workflow in the user's words
- Horizon expansion: surfaces screens, options, risks, scope boundary
- Produces brainstorm.md — a discussion log, not a reframing

**Entry points:**
- Vague: "I want a todo app" → starts with workflow walk-through
- Specific: "I want an xlsx upload screen with drag-and-drop" → skips discovery
- Pivot: "We need to change how the viewer works" → captures what changed first

**Output:** `capabilities/<name>/brainstorm.md`

---

### feather-spec

**When:** User has a brainstorm.md and is ready to write the spec,
OR user is jumping in mid-pipeline with a clear capability in mind.

**What it does:**
- Authors capability.md, design.md, screen specs, component specs, tasks.md
- Applies EARS patterns, stable IDs, checklists, scenario rules
- Follows the full framework reference

**Key rules:**
- One screen per spec file
- Specs are user-perspective — no implementation details
- Tasks are developer-perspective — no behavioral requirements
- Tasks always lead with "prove the engine first"
- Tests follow three layers: integration → unit (gaps only) → E2E

**Output:** Full capability folder structure

---

### feather-execute-task

**When:** User has a tasks.md and is ready to build.

**What it does:**
- One task per cycle: mini-plan → execute → verify → tick → ask
- Two modes: user-execute (default) and agent-execute (opt-in)
- Records plan and verification per task
- Drafts PR description when all tasks complete

**Key rules:**
- User owns the loop — agent never auto-continues
- Mini-plan before every task, even small ones
- Verification runs actual commands, not memory
- Scope creep is surfaced immediately, never silently absorbed

**Output:** Working code, `capabilities/<name>/plans/` files, PR draft

---

## Artifact Map

```
capabilities/
  └── <name>/
        ├── brainstorm.md    ← feather-brainstorm output (optional)
        ├── capability.md    ← feather-spec output (operating rules)
        ├── design.md        ← feather-spec output (rationale, always present)
        ├── tasks.md         ← feather-spec output (developer task list)
        ├── plans/           ← feather-execute-task output (per-task records)
        │     └── T2.1-build-upload-screen.md
        ├── screens/
        │     └── <screen>.md   ← feather-spec output
        └── components/
              └── <component>.md ← feather-spec output

decisions/
  └── <ADR>.md              ← system-wide decisions (authored separately)
```

---

## Starting Mid-Pipeline

The user does not have to start at the beginning.

| User has | Start here |
|---|---|
| Vague idea or pain point | feather-brainstorm |
| Clear capability in mind | feather-spec (skip brainstorm) |
| brainstorm.md already written | feather-spec |
| capability.md + tasks.md already written | feather-execute-task |
| Some tasks complete, resuming | feather-execute-task (find first unchecked task) |

---

## Handoff Points

**brainstorm → spec:**
User confirms brainstorm.md is complete.
Agent invokes feather-spec, reads brainstorm.md as primary input.
brainstorm.md stays as a permanent sibling — it is the source of
the user's original words and intent.

**spec → execute:**
User confirms tasks.md is complete and capability is ready to build.
Agent invokes feather-execute-task.
Screen specs and capability.md are read at mini-plan time, not upfront.

**execute → PR:**
All tasks ticked. Agent offers to draft PR description.
User opens the PR.

---

## Minimal Mode

A simple capability (one screen, no integrations, no non-obvious
decisions) may skip brainstorm.md and collapse to a single
capability.md with tasks folded in at the bottom.

Promote out of minimal mode when any of these become true:
- Second screen added
- Non-obvious decision arises
- Any integration introduced
- Open question worth recording

---

## Quick Reference

| Question | Answer |
|---|---|
| Where does a vague idea start? | feather-brainstorm |
| Where does the user's language live? | brainstorm.md — never paraphrased |
| Where do operating rules live? | capability.md |
| Where does rationale live? | design.md |
| Where do system-wide decisions live? | decisions/ ADRs |
| What is the first task in tasks.md? | Prove the engine — hardcoded UI, full pipeline |
| What is the test order? | Integration → unit (gaps only) → E2E |
| Who opens the PR? | The user. Always. |
| Who owns the execution loop? | The user. Agent serves the step. |
