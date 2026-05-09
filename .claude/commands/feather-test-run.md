---
description: Run a 3-mode parallel test of the feather-* skills end-to-end. Spawns three Sonnet sub-agents (walk-through / assumption / paste-driven), each role-playing both sides of a brainstorm + spec session against the same scenario. Produces artifacts on disk, then synthesizes findings — what worked, what's tweakable, mode-specific observations.
argument-hint: [optional: scenario description, e.g. "a recipe sharing app for home cooks"]
allowed-tools: [Read, Edit, Write, Bash(mkdir:*), Bash(ls:*), Bash(date:*), Bash(grep:*), TodoWrite, Agent]
---

<objective>
Exercise the feather-* skill pipeline across all three brainstorm entry modes
in parallel. Each mode uses a different persona, but all three test the same
scenario so the artifacts are comparable. The output is:

- Three sets of generated artifacts (`brainstorm.md` / `spec.md` / `design.md` /
  `tasks.md` / mockups) in isolated directories
- Three structured reports — what worked, what didn't, mode-specific findings
- A synthesis that surfaces convergent issues (multi-agent agreement = strong
  signal) vs single-agent observations

This command gives the skill author a reproducible way to test changes before
committing them. Run it after any non-trivial heal of feather-brainstorm or
feather-spec.
</objective>

<context>
Skill files (the agents will read these): !`ls -1 ~/.claude/feather-flow/skills/ 2>/dev/null || echo "feather-flow plugin not installed"`
Latest skill commit: !`cd /Users/siraj/Desktop/NonDropBoxProjects/feather-flow 2>/dev/null && git log --oneline -1 || echo "source repo not present"`
Today's date: !`date -u +%Y-%m-%d`
</context>

<workflow>

## 1. Resolve the scenario

If the user provided arguments, use that as the scenario.
If no arguments, use this default:

> **Default scenario:** a small-team project management system. A 4-to-6-person
> team currently tracks work in spreadsheets or chat threads; pain is status
> rot, missed handoffs, and wasted standup time. They want a lightweight
> workspace where assignments are first-class.

Pick a short feature-name slug for paths: `team-projects` (default) or derive
from the user's argument (kebab-case, ≤30 chars).

## 2. Set up isolated test directories

```bash
TEST_DIR=$HOME/Desktop/NonDropBoxProjects/feather-skill-test-$(date -u +%Y-%m-%d)
mkdir -p "$TEST_DIR/walk-through/docs/features/<feature-name>"
mkdir -p "$TEST_DIR/assumption/docs/features/<feature-name>"
mkdir -p "$TEST_DIR/paste-driven/docs/features/<feature-name>"
```

If today's directory already exists, append a counter (`-2`, `-3`) so
multiple runs in one day don't collide.

## 3. Generate a sample PRD for the paste-driven mode

The paste-driven mode needs source material the user (the simulated persona)
will paste. Generate a realistic PRD for the scenario — gritty, written in
the user's voice, ~300 words, captures pain points and rough requirements.
Match the shape of the example below (which is for the default PM scenario):

```markdown
# Project Tracker for Linden Studio

**Author:** Maya R. (founder)
**Date:** 2026-04-22
**Status:** rough draft

## What is this?
We're a four-person creative studio (3 designers + me on PM). We juggle 6–10
client projects at any given time. Right now we're using a Notion database
that everyone hates — slow, search is bad, status updates rot.

We need our own thing. Lightweight, fast, lets us see "what's everyone
working on this week" at a glance.

## Who uses it
- Maya (me) — sees the whole portfolio, assigns work
- Theo, Anya, Ben — designers; each owns 2-4 projects

## What it should do
[Per project / Per person / Studio-wide breakdown of features]

## Behavior
[Who can do what; defaults; click behaviors]

## Out of scope (for now)
[What's deliberately excluded]

## Open questions
[The user's own unresolved items]

## Technical notes
[Any tech preferences the user mentions]
```

Adapt to the scenario. Write it to `$TEST_DIR/paste-driven/source-prd.md`.

## 4. Spawn three parallel Sonnet sub-agents

Use the Agent tool with `subagent_type: general-purpose`, `model: sonnet`,
`run_in_background: true` for all three. Use the prompts in section 5–7
below verbatim, substituting the scenario / persona / paths as needed.

Three personas (one per mode) — these are characters who use the system
the agents are testing. Each persona has different prior knowledge, comfort
level, and information-density to give the skill realistic variety:

- **Walk-through (mode 1)** — technical user with a clear current workflow
  and pains. Will describe the spreadsheet/Notion/Slack flow in detail when
  asked. Default name: Asha.
- **Assumption (mode 2)** — non-technical user with vague intent. Doesn't
  have a clear picture; reacts to whatever the agent proposes. Default name:
  Sara.
- **Paste-driven (mode 3)** — user with a pre-written rough PRD. Pastes it
  upfront, answers gap questions tersely. Default name: Maya. Uses the
  source PRD generated in step 3.

Adapt the persona names to the scenario if a different domain (e.g., a
restaurant booking app might use Owner / Customer / Staff personas).

## 5. Sub-agent prompt template — Walk-through (mode 1)

[Self-contained prompt; the spawned agent has no context from this
conversation. Edit the bracketed placeholders before launching.]

```
You are testing the healed feather-* skills end-to-end by roleplaying both
sides of a brainstorm + spec session, then producing the artifacts on disk
for human review.

## Your assignment

**Mode: 1 — Walk through your current workflow.** When the brainstorm skill
offers the mode menu, you (as the user) pick option 1.

**Persona:** [persona — name, role, current-state pains, comfort with
software vocabulary; mode-1 specific: will describe current workflow in
detail when asked].

## What to do

1. Read the skill files (full content — these are the rules):
   - ~/.claude/feather-flow/skills/feather-flow/SKILL.md
   - ~/.claude/feather-flow/skills/feather-brainstorm/SKILL.md
   - ~/.claude/feather-flow/skills/feather-spec/SKILL.md

2. Run the brainstorm phase as a self-roleplay. You play BOTH the agent
   running feather-brainstorm step-by-step AND the user (persona above)
   responding. Walk through the full skill: shape & scope check → mode
   menu (persona picks 1) → walk-through discovery → horizon expansion
   → visual companion if layouts come up (write HTML mockup files; you
   don't need a real browser, just create files and have persona pick
   one) → mockup curation → write project-level docs/brainstorm.md →
   commit prompt (just say "committed") → handoff.

3. Run the spec phase. Continue self-roleplay using feather-spec. For
   each feature in the brainstorm.md Features section, produce:
   - features/<feature-name>/spec.md (15-section template)
   - features/<feature-name>/design.md (only if there are tech decisions)
   - features/<feature-name>/decisions/*.md (per-feature ADRs if any)
   - features/<feature-name>/screens/<screen>-NN.html (mockup sidecars
     when a layout was contested; otherwise none)
   - features/<feature-name>/tasks.md

4. Stop after spec. Do NOT run feather-execute-task. Do not write code.

## Where to write

Project root: [TEST_DIR]/walk-through/

Standard structure:
  docs/
    brainstorm.md  ROADMAP.md  STATE.md
    features/<feature-name>/
      spec.md  design.md  decisions/  screens/  tasks.md

## Report

After producing all artifacts, write a final report (under 1000 words):

1. Friction encountered — places the skill was unclear, contradictory,
   or made the persona confused. Cite section names from SKILL.md.
2. What worked — places the skill structure genuinely guided to a
   better artifact.
3. Mode-specific observations — was walk-through Phase 1 actually
   useful? Did the primary discovery question pull the right content?
   Did Broadening Stance fire?
4. Self-assessment — did brainstorm.md read as project-level discovery
   (not transcript)? Did spec.md fit ~85 lines / 1-2 pages?
5. List of artifacts produced with paths.
6. Any sections of the new spec template that felt forced or empty.

Be honest about failures. The point is to find weaknesses, not perform.
```

## 6. Sub-agent prompt template — Assumption (mode 2)

```
[Same overall structure as mode 1, with these adaptations:]

**Mode: 2 — Let AI propose something.** Persona picks option 2.

**Persona:** [non-technical user, vague intent, reacts to proposals].

**Critical for mode 2 testing:** persona should push back on at least
2-3 items in the proposed assumption-mode picture. The whole point is
the iteration loop — silent "all ok" doesn't test anything.

## Mode-specific report items

- Did the assumption-mode picture fit the one-screen rule (~25 lines,
  per-section ≤7)?
- Did the closing instruction give phrase-based reply options
  ('all ok' / change-list / 'show alternatives for #N')?
- Did the iteration loop work — could persona mark '✏️ #5 should be X'
  and the agent updated the picture?
- Did Broadening Stance fire — were 1-2 horizon-expanding alternatives
  surfaced even on persona's clear-enough input?
- Did Alternatives Considered in brainstorm.md actually populate
  (since iteration happened)?

[Standard 6-point report structure as mode 1.]

Where to write: [TEST_DIR]/assumption/
```

## 7. Sub-agent prompt template — Paste-driven (mode 3)

```
[Same overall structure as mode 1, with these adaptations:]

**Mode: 3 — I have a clear idea (paste-driven).** Persona picks option 3
and pastes the source PRD provided below.

**Persona:** [user with pre-written PRD; answers tersely; mode-3 specific:
expects agent to read source quietly, ask only about gaps].

**Source PRD path:** [TEST_DIR]/paste-driven/source-prd.md
Read it before starting; use as Maya's pasted material.

**Critical for mode 3:** the agent should NOT re-discover information
already in the PRD. Re-asking is the failure mode to catch.

## Mode-specific report items

- Did mode 3 have a clear paste-driven flow (Phase 1b ingestion)?
- Did the agent re-discover information already in the PRD? Name any
  redundant questions.
- Gap question count — should be ≤5. List the gap questions actually
  asked.
- Verbatim preservation — did persona's voice (their terms, phrases)
  survive into brainstorm.md In-the-user's-own-words section?
- Did agent honor the discovery-only stance — no committed-answer
  leakage from the PRD's behavior section into brainstorm; instead
  forwarded into spec.md?

[Standard 6-point report structure as mode 1.]

Where to write: [TEST_DIR]/paste-driven/
```

## 8. Wait for all three to complete

The Agent tool will notify you when each sub-agent finishes. Address
each notification briefly; do not block on one before the others are
done. All three should finish within 15-25 minutes total.

## 9. Synthesize and surface

Once all three reports are in:

1. Read each agent's final report
2. Read the headline artifacts produced by each (brainstorm.md +
   spec.md from each mode — six files)
3. Identify CONVERGENT findings (mentioned by 2+ agents — strong
   signal) vs single-agent observations (weaker signal)
4. Build a priority table: HIGH (convergent + skill-impacting) /
   MEDIUM (convergent or single-agent + clear fix) / LOW (style/polish)
5. Surface the artifacts to the user — show paths, quote key excerpts
   so they can apply their own judgment
6. Recommend the highest-leverage skill changes from the test

The user will then drive which fixes to apply (this command produces
findings, not fixes).

## 10. Cleanup

Do NOT delete the test artifacts. The user may want to re-read them
later. Each timestamped directory is its own self-contained record.

If the user wants to clean up old test runs:
```bash
ls $HOME/Desktop/NonDropBoxProjects/feather-skill-test-* | head
```

</workflow>

<usage_notes>

**When to run:** after any non-trivial heal of feather-brainstorm or
feather-spec — e.g., new template sections, restructured phases, changed
file naming, new behaviors. Skip for purely cosmetic/typo fixes.

**Test variance:** different runs may produce different artifacts even
with identical skills (LLM stochasticity). Convergent findings (mentioned
across modes / runs) carry more weight than one-off observations.

**Cost:** ~3× the cost of a single feather-flow run. Each sub-agent
makes 15–30 tool calls and writes ~10–15 artifacts.

**Limitations of this test:**
- The sub-agents play both sides of the conversation — they don't have
  the friction a real user would hit (typing limits, attention drift,
  emotional reactions)
- Visual companion runs without a real browser (sub-agents can't open
  HTML files visually, so layout choices are reasoned from file content)
- Reports are sub-agents' self-assessment — bias toward what they could
  see. The skill author should still spot-check artifacts directly.

</usage_notes>
