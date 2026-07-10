## 1. Narrate the Approach Before Acting

**Tell me what you're going to do, and why, before you do it.**

I buy into the *process*, not just the output. I need a mental model of how you're
getting to a result so I can course-correct early — before the work is done, not after.

- Before any non-trivial action (running a command, editing files, calling a tool),
  state in one or two lines: what you're about to do and the reasoning behind it.
- For multi-step work, lay out the brief plan first, then execute.
- This is about visibility, not permission — narrate and proceed; don't gate on
  approval unless the work is design-shaping or risky (see §6).
- The goal: I should never be surprised by *how* you arrived somewhere.

## 2. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 3. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 4. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 5. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

## 6. Gate on Design Input and Risk — Not on Every Plan

**Two kinds of work; only one needs my input before you proceed.**

- **Execution-type** (investigate → fix/build; the design is already settled by existing
  ADRs, conventions, or the request itself; consequences are recoverable): file the issue,
  write the plan, and carry it **straight through to implementation and close-out** — do
  NOT stop for plan approval.
- **Design-shaping** (new data models, naming, architecture, business rules — anywhere my
  domain input could genuinely change the answer): grill the open decisions and **wait for
  my input** before implementing.
- **Risky** (hard-to-reverse, destructive, or outward-facing): always confirm first,
  whichever type it is.

The test for stopping: *could my different vantage point change the answer, and does
getting it wrong matter?* If no to either, proceed. Classify per task — don't default to
stopping "to be safe" on work that doesn't need me.

(For a specific repo, the project CLAUDE.md's version of this gate is canonical for the
team; this section is my cross-project default.)

## 7. Single Source for Rules

**A rule lives in exactly ONE place; every other surface points to it.**

When a rule or convention could appear on multiple surfaces (this file, a project
CLAUDE.md, a skill, memory), define it fully in one canonical home — chosen by audience:
team-facing rules → the project repo; cross-project personal preferences → this file;
per-project agent context → that project's memory. Everywhere else gets a one-line
pointer naming the home, at most with a one-clause gist. When a rule changes, update the
home and grep for stale restatements — duplicated rules drift independently.