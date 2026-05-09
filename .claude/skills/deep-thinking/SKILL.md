---
name: deep-thinking
description: Use when the user is stuck on a non-trivial decision or problem and wants clarity — invoking /deep-thinking, or saying things like "I'm stuck on X", "help me think through Y", "I can't decide between A and B", "why does Z keep happening?", "what should I focus on?". Detects which of five thinking lenses (5 Whys, First Principles, Pareto, One Thing, Occam's Razor) actually fit the question, runs the applicable ones as parallel sub-agents (or inline if only one fits), and synthesizes their independent verdicts into a single recommendation. Skips lenses that don't add signal.
---

# deep-thinking

## Overview

Five thinking frameworks, applied selectively to one question, then synthesized into a single recommendation.

The skill's job is to **detect which lenses fit** and **skip the ones that don't**. Forcing all five on every question creates ritual, not insight.

The five lenses:

- **5 Whys** — drill to root cause by asking why repeatedly
- **First Principles** — strip assumptions, rebuild from base truths
- **Pareto (80/20)** — find the vital few that drive most results
- **One Thing** — find the single action that makes others easier or unnecessary
- **Occam's Razor** — pick the explanation with fewest unsupported assumptions

## When to use

- User invokes `/deep-thinking <topic>` directly.
- User is stuck on a non-trivial decision or problem and wants clarity.
- User says "I'm stuck on X", "help me think through Y", "I can't decide between A and B", "why does this keep happening?", "what should I focus on?"
- A question is multi-faceted enough that one perspective isn't sufficient.

## When NOT to use

- Trivial factual questions ("what does this regex do?") — just answer.
- Tasks where execution is the bottleneck, not thinking ("write the code for X") — just do it.
- The user has already decided and just wants implementation help.
- Single, narrow technical questions with one obvious framing.

## Process

### 1. Restate the question

If invoked with arguments, use them. If blank, use the open question in the current conversation. State it back in one sentence so the framing is locked.

### 2. Clarify, but only if necessary

Ask **at most one** clarifying question, and only when scope is genuinely ambiguous (e.g., "Are you asking why this keeps happening, or what to do about it?"). Skip the question if the framing is already clear — bloating simple invocations with interrogation defeats the skill.

### 3. Detect which lenses fit

Score each lens against the question using this guide:

| Lens | Fits when the question is... | Skip when... |
|---|---|---|
| **5 Whys** | "Why does this keep happening?" — recurring problem, debugging a persistent issue, root-cause hunt | The question is forward-looking ("what should I build?"), not diagnostic |
| **First Principles** | "Why are we doing it this way?" — assumptions/conventions feel suspect, greenfield design, challenging defaults | The problem is mechanical and existing conventions are clearly correct |
| **Pareto** | "What matters most?" — too many options, prioritization, scope-cutting | Only one or two factors exist — there's no long tail to trim |
| **One Thing** | "Where do I even start?" — paralysis, sequencing, multiple competing initiatives | The next step is already obvious |
| **Occam's Razor** | "Which explanation is right?" — competing hypotheses, debugging, picking among root causes | Only one explanation is on the table, or the question isn't about *why* |

State the result of selection in 1–2 sentences: which lenses you picked, which you skipped, and the reason. Offer the user a chance to override before running.

### 4. Run the applicable lenses

- **0 lenses fit** → tell the user this question doesn't need deep-thinking, recommend a more direct approach, and stop.
- **1 lens fits** → apply it inline (no sub-agent overhead). Use the framework's process and output format from the appendix. Skip the synthesis stage and present the lens result directly.
- **2+ lenses fit** → spawn one parallel sub-agent per lens. Each sub-agent is a `general-purpose` Agent with a self-contained prompt (it sees no conversation history). **Send all sub-agent calls in a single message** so they run concurrently. Then synthesize.

### 5. Synthesize (only when 2+ lenses ran)

Once all sub-agents return, present in this order:

1. **One-line verdict per lens** — what each lens concluded, so the user can see the raw signal at a glance.
2. **Convergence** — where the lenses agree. Usually the most load-bearing signal.
3. **Tension** — where lenses disagree, and what the disagreement reveals about the question. (Disagreement is often more useful than agreement — it surfaces hidden trade-offs.)
4. **The recommendation** — a single concrete next action.
5. **What can wait** — what becomes lower-priority once the recommendation lands.

Append the full per-lens reports below the synthesis for the user to dig into if desired.

## Sub-agent prompt template

When spawning a sub-agent, give it everything needed to act cold — it sees no conversation history. Use this shape:

```
You are applying the [LENS NAME] framework to a single question.

Question: <user's question, verbatim, plus any clarifications>

Context: <2–4 lines of relevant background from the conversation, if any>

Objective: [copy from appendix]

Process: [copy from appendix]

Return your output in EXACTLY this format:
[copy from appendix]

Do not include preamble, meta-commentary, or hedging. Return only the structured output.
```

## Lens reference (appendix)

Sub-agents are briefed from this appendix — keep it embedded so no external lookups are needed.

### 5 Whys

**Objective:** Drill to root cause by asking "why" repeatedly until you hit an actionable root, not a symptom.

**Process:** State the problem → ask why → ask why of that answer → continue until root cause is reached (usually 3–5 iterations) → identify intervention at the root.

**Output format:**
```
**Problem:** ...
**Why 1:** ...
**Why 2:** ...
**Why 3:** ...
(continue as needed, stop when root reached)
**Root Cause:** ...
**Intervention:** ...
```

### First Principles

**Objective:** Strip away assumptions, conventions, and analogies; rebuild from irreducible truths.

**Process:** State the belief → list all assumptions (even obvious ones) → challenge each → identify base truths that cannot be reduced further → rebuild from only fundamentals.

**Output format:**
```
**Current Assumptions:**
- Assumption: [challenged: true/false/partially]
**Fundamental Truths:**
- Truth: [why irreducible]
**Rebuilt Understanding:** ...
**New Possibilities:** ...
```

### Pareto (80/20)

**Objective:** Identify the ~20% of factors that drive ~80% of the outcome.

**Process:** List all factors → estimate impact of each → rank → find the cutoff where the vital few account for most impact → recommend focus and what to defer.

**Output format:**
```
**Vital Few (focus here):**
- Factor: [why it matters, specific action]
**Trivial Many (deprioritize):**
- (deferred items)
**Bottom Line:** [single sentence on where to focus]
```

### One Thing

**Objective:** Find the single action that makes everything else easier or unnecessary.

**Process:** Clarify the goal → list candidate actions → for each, identify downstream effect → find the domino that knocks down others → define the next concrete action.

**Output format:**
```
**Goal:** ...
**Candidate Actions:**
- Action: [downstream effect]
**The One Thing:** ...
**Why This One:** ...
**Next Action:** ...
```

### Occam's Razor

**Objective:** Pick the explanation with the fewest unsupported assumptions while still fitting all the facts.

**Process:** List candidate explanations → enumerate assumptions per explanation → mark each assumption as supported/unsupported → eliminate explanations needing unsupported assumptions → pick the simplest that still explains everything.

**Output format:**
```
**Candidate Explanations:**
1. [Explanation]: assumptions [A, B, C]
**Evidence Check:**
- Assumption A: supported/unsupported
**Simplest Valid Explanation:** ...
**Why This Wins:** ...
```

## Common mistakes

- **Running all five lenses by default.** Ritual, not insight. Pick what fits.
- **Asking three clarifying questions.** One max. If the question is too vague for one to fix, recommend reframing and stop.
- **Sequential lens application instead of parallel sub-agents.** When 2+ lenses run, sequential application contaminates later lenses with earlier conclusions. Parallel sub-agents preserve independence — that's the point.
- **Synthesizing without surfacing tension.** Lens disagreement is often more useful than agreement — it reveals hidden trade-offs. Don't paper over it.
- **Recommending more than one "next action."** The skill ends in a single concrete step. Multiple recommendations means the synthesis didn't finish.
- **Spawning a sub-agent when only one lens fits.** Sub-agent overhead is wasteful for a single perspective. Apply inline instead.
