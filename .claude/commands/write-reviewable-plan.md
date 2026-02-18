---
description: Use when writing or reviewing implementation plans. Ensures plans are structured for easy human review with diff summaries, reviewer questions, and appendix-separated code.
argument-hint: [optional: path to existing plan file to audit]
---

# /write-reviewable-plan — Plan Writing & Review Guide

Write implementation plans optimized for human review. Plans should be scannable in 10 minutes with all code pushed to appendices.

## Two Modes

1. **Writing a new plan** — follow the Structure and Content Rules below
2. **Auditing an existing plan** — read the file at `$ARGUMENTS` and run the Verification Checklist

---

## Plan Structure

Every plan MUST follow this skeleton:

```
1. Decision Summary
2. Definitions
3. Phase 1 — [name]
     - Why
     - Behavioral Change (diff)
     - API Changes (diff)
     - Files Modified (bullet list only)
     - Risks
     - Open Questions
4. Phase 2 — [name] (same structure)
5. Phase N — [name] (same structure)
6. Appendix A — [reference material, philosophy, etc.]
7. Appendix B — Implementation Code
8. Appendix C — Alternatives Considered
```

### Section Details

**Decision Summary** — What you are asking the reviewer to approve:
- Numbered list of what the plan will do
- Non-goals (explicitly stated)
- Breaking changes (yes/no + what breaks)
- No code, no context, no justification — just scope

**Definitions** — Define repeated terms ONCE, reference thereafter:
- Any concept mentioned 3+ times gets a definition
- Use bold term = short definition format
- Example: `**Real Auth Path** = Scrypt hash + DB write + session creation via backend action.`
- After defining, never expand the term again — just use it

**Phase sections** — Each phase uses identical sub-sections:
- **Why**: Max 3 lines. Problem statement only.
- **Behavioral Change**: What changes from user perspective. Use `diff` block if replacing existing behavior, bullets if purely additive.
- **API Changes / New Artifacts**: Interface changes (use `diff` for replacements) or new files added (use bullets). Label "New Artifacts" when everything is new.
- **Files Modified**: Bullet list only. One line per file. No code.
- **Risks**: Short bullet list. Phase-specific only.
- **Open Questions**: Numbered list of decisions the reviewer needs to make. Turns review into a decision conversation, not passive reading.

**Appendix A** — Non-code reference material (philosophy docs, testing principles, etc.)

**Appendix B** — Full implementation code for agent execution. Label clearly: "For agent execution. Not for plan review."

**Appendix C** — Alternatives Considered. For each rejected approach:
- **What**: Name and 1-line description of the approach
- **Why considered**: What made it a plausible option
- **Why rejected**: Specific reasons it lost to the recommended approach (tradeoffs, constraints, risks)
- This appendix preserves architectural context and enables future re-evaluation if circumstances change

---

## Content Rules

### Match representation to the cognitive task

- **Diff blocks** → when something is replaced (before/after contrast)
- **Bullet lists** → when something is added (no "before" exists)
- **Tables** → when comparing options

Do NOT use diff blocks for purely additive phases — `+` lines with no `-` lines create false contrast that slows reading. Use "New Artifacts" heading with bullets instead of "API Changes" with diffs.

```diff
# GOOD — real before/after contrast
- signIn(): boolean toggle
+ signIn(): calls client.action("auth:signIn")

# BAD — no "before" side, diff adds friction
+ playwright.config.ts: starts Vite + Convex
+ e2e/auth.spec.ts: lifecycle test
```

### No code in main body

Code belongs in Appendix B. The main body uses only:
- Diff blocks (for replacements)
- Bullet lists (for additions, files modified)
- Short inline code for names (`signInError`, `formDataToParams()`)

### No repeated explanations

If you catch yourself writing the same concept twice, define it in Definitions and reference the term.

### One recommended approach, alternatives preserved

The main body presents only the recommended approach — no inline comparisons or option matrices. But rejected alternatives belong in **Appendix C — Alternatives Considered** with full detail: what each approach was, why it was plausible, and why it was rejected. This keeps the main body decisive while preserving architectural context for the reviewer to challenge the recommendation or revisit it later.

### Reviewer Questions are mandatory

Every phase MUST end with Open Questions. If there are no genuine questions, the phase is either trivial (fold it into another) or you haven't thought hard enough.

---

## Presenting a Plan for Review

After writing the plan, present it to the reviewer using this format:

### Step 1: Show the walkthrough summary

Present a structured overview with clickable file links to source code locations:

```
Phase 1: convex-test-provider
  - Why (plan.md#29)
  - Behavioral Change (plan.md#35)
  - API Changes (plan.md#43)
  - Files Modified — links to actual source files:
    - ConvexTestProvider.tsx:5-8 (link)
    - ConvexTestAuthProvider.tsx:18-49 (link)

Phase 2: Starter Pack
  - ...
```

Use markdown link syntax for clickable navigation:
- Files: `[filename.ts:42](path/to/filename.ts#L42)`
- Line ranges: `[filename.ts:42-51](path/to/filename.ts#L42-L51)`

### Step 2: Walk through chunk by chunk

- Go **one phase at a time** in plan order
- Present the phase, then WAIT for questions before moving to next
- Do NOT prompt for plan acceptance — wait for reviewer to say "review is finished"
- When there was more than one way to do something, explain the rationale
- For new libraries or unfamiliar APIs, explain line by line
- After answering questions and updating the plan, move to next phase automatically

### Step 3: Show walkthrough summary again at the end

Repeat the structured overview so the reviewer can see the full picture after the detailed walk-through.

---

## Verification Checklist

Run this after writing a plan (or when auditing with `$ARGUMENTS`):

### Structure
- [ ] Decision Summary present with numbered scope items?
- [ ] Non-goals explicitly listed?
- [ ] Breaking changes called out?
- [ ] Definitions section for terms used 3+ times?
- [ ] Every phase has all 6 sub-sections (Why, Behavioral Change, API Changes, Files, Risks, Open Questions)?
- [ ] No top-level summary sections that duplicate phase content (risks overview, dependency graph, review checklist)?
- [ ] Appendix A for reference material?
- [ ] Appendix B for implementation code?
- [ ] Appendix C for alternatives considered (with what/why considered/why rejected for each)?

### Content Quality
- [ ] No code blocks in main body (only diffs and inline code)?
- [ ] No repeated explanations (terms defined once in Definitions)?
- [ ] Diff blocks show behavioral change, not implementation?
- [ ] Files Modified is bullet list only (no code)?
- [ ] Every phase ends with Open Questions?
- [ ] Main body is under ~120 lines (excluding appendices)?
- [ ] Plan is scannable in 10 minutes?

### Anti-Patterns to Flag
| Anti-Pattern | Fix |
|---|---|
| Full code blocks in main body | Move to Appendix B, replace with diff summary |
| Same concept explained multiple times | Define once in Definitions, reference term |
| "Example Before / Example After" sections | Replace with single diff block |
| Phase without Open Questions | Add genuine decisions for reviewer |
| Top-level sections that duplicate phase content (risks overview, dependency graph, review checklist) | Remove — phase-level sections are the source of truth. Open Questions resolved inline serve as the decision record |
| Process steps elevated to major headings | Fold into a one-line checklist or remove |
| Alternatives discussed inline in main body | Move to Appendix C — main body stays decisive, appendix preserves the reasoning |
| No alternatives documented at all | Add Appendix C — reviewer needs to see what was rejected and why |
| Context section longer than 5 lines | Trim — reviewer needs scope, not backstory |
| Diff blocks with only `+` lines (no `-`) | Use bullet lists — diff implies contrast, additions don't have a "before" |

---

## Success Criteria

A plan passes this skill's standards when:
1. A reviewer can scan the main body in 10 minutes and know what's changing
2. Every phase ends with decisions the reviewer needs to make
3. No code reading is required to approve the plan
4. An agent can execute from Appendix B without ambiguity
