---
name: openspec-siraj-review-change
description: Review an OpenSpec change folder for cross-document consistency and right-sized verbosity-vs-guardrails. Launches two parallel Sonnet subagents — one auditing for contradictions / stale references / scenario-to-commit mapping integrity, one auditing for over-shooting (dead weight, spec restatement in design.md, tautological scenarios, over-prescriptive tasks) and under-shooting (unanchored vague terms, missing state-after-commit lines, decisions stated in proposal but not anchored in design). Use after substantial rewrites of an OpenSpec change, before committing the change folder, or whenever the user says "review this", "ready to commit", "check the change", or pauses on an OpenSpec change folder. Defaults to the most recently modified change folder if no name is given.
---

# Review an OpenSpec change folder

This skill runs a two-subagent review of an OpenSpec change folder before commit. It's the formalisation of a pattern we've found valuable: an independent consistency check plus an independent verbosity/guardrails check, with results synthesised back to the user.

## When to invoke

**Explicit user request** — "review the change", "ready to commit", "check the artifacts", "/openspec-siraj-review-change", or any phrasing where the user wants a pre-commit sanity pass.

**Proactive suggestion** — when the user has just finished a substantial rewrite of an OpenSpec change folder and signals they're winding down ("let's commit", "I think we're done", "looks good"), suggest invoking this skill before they commit. Phrase the suggestion: *"Before you commit, want me to run the two-subagent review to catch any contradictions or over/under-shooting?"* Take a no gracefully.

**Do NOT auto-invoke** on every file edit. The skill takes 30-60 seconds and the cost is wasted if the change is still mid-author.

## Step 1: Discover the change folder

If the user named a change (e.g., "review add-user-auth"), use that. Otherwise:

```bash
ls -td openspec/changes/*/ 2>/dev/null | head -5
```

Pick the most-recently-modified change folder. Confirm with the user if there are multiple recent candidates.

## Step 2: Locate the artifacts

The four core artifacts in every OpenSpec change folder:

- `openspec/changes/<name>/proposal.md`
- `openspec/changes/<name>/specs/<capability>/spec.md` (may be multiple specs across capabilities — review all)
- `openspec/changes/<name>/design.md` (may be absent for trivial changes — OK to skip)
- `openspec/changes/<name>/tasks.md`

If any of the four is missing, note it and continue with what's present.

## Step 3: Locate referenced docs (conditional)

The skill should adapt to what the project actually uses. Discover (don't assume):

- **OpenSpec config**: `openspec/config.yaml` — always include if present. Its `context:` block names the project's load-bearing references.
- **CLAUDE.md** (or `AGENTS.md`, `GEMINI.md`): the repo-wide agent instructions. Always include if present.
- **PRD**: many projects don't have one. Look for `docs/prd/PRD-*.md`, `docs/PRD-*.md`, `docs/prd.md`, or any reference to a PRD path in `openspec/config.yaml`'s `context:` block. Include only if found.
- **Testing conventions**: `docs/testing.md` or any equivalent referenced from `openspec/config.yaml`. Include if found.
- **Spec conventions**: `docs/spec-conventions.md` or equivalent. Include if found.
- **Vault principles**: if `openspec/config.yaml` references a vault path (e.g., `~/Dropbox/.../cross-project/principles/`), the relevant principle files are referenceable but **do not pull their full contents into subagent prompts** — just name the principles by filename so subagents can read them if needed.

## Step 4: Distill a "what the design should be" brief

Before launching subagents, read the artifacts and `openspec/config.yaml` and CLAUDE.md, and write a one-paragraph background brief that captures:

- What the change is doing (one sentence)
- The locked design choices (key behaviors, constraints, rejected alternatives)
- Numbering / naming conventions the project uses
- **The decision format convention** the project uses (e.g., "Format A — Question / Alternatives with pros and cons / Recommendation" — if referenced in `openspec/config.yaml`'s `rules.design`). Pass this to Subagent 2 so it can audit Format A compliance.
- Any project-specific patterns (e.g., "first verb in rewrite — sets convention for others")
- **Renamed entities** to watch for. Note any names that have changed during the change folder's life (skills, commands, flags, doc paths). Pass these to Subagent 1 as explicit search-for-stale-refs targets.

This brief is your input to both subagents so they ground their review in the agreed design, not just the artifact text.

## Step 5: Launch both subagents in parallel

Use the `Agent` tool with `subagent_type: general-purpose` and `model: sonnet`. Both calls go in **one message** for parallel execution.

### Subagent 1 — Consistency review

```
You are doing a consistency review across <N> OpenSpec artifacts plus <M> supporting docs. Your job is to find contradictions, stale references, terminology drift, broken cross-references, and scenario-to-commit mapping integrity — NOT to suggest stylistic improvements.

Read these files in order:
<list of absolute file paths>

Background (what the design SHOULD be, per the user's locked decisions):
<the brief from Step 4>

What to flag:

1. **Contradictions** — anything that says one thing in one file and the opposite in another.
2. **Stale references** — mentions of things that were dropped (renamed flags, removed scenarios, deleted requirements, abandoned approaches). **Pay special attention to renames** — when an entity (skill name, command, doc path, flag, file rename) has been renamed during the change's life, references to the old name in proposal.md / spec.md / design.md / tasks.md / `openspec/config.yaml` must ALL be updated. The background brief should name renamed entities; grep for the old name in every file to find stragglers.
3. **Cross-reference breakage** — "see decision N" when the decision doesn't exist; "scenario Nx" when Nx was renumbered or removed.
4. **Terminology drift** — same concept named differently across files.
5. **PRD ↔ change consistency** (if a PRD is in scope) — anything in the PRD that contradicts the change artifacts, and vice versa.
6. **Numbering integrity** — scenarios numbered sequentially within each requirement, no gaps; task numbering consistent.
7. **Scenario → commit mapping integrity** — tasks.md SHOULD have a "Scenario → commit mapping" section. Verify:
   - Every spec scenario appears in exactly one commit per the mapping.
   - No scenario is mapped to multiple commits or unmapped.
   - The task list bodies match the mapping section.
   - Multi-scenario commits have a stated rationale (same code path, observability dependency, etc.).
   - Infrastructure-only commits (no spec scenario) are flagged as such.

What NOT to flag: style preferences, verbosity opinions, suggested improvements.

For each finding, output one bullet:
- File:line (or section heading)
- What it says
- What it should say (or what it conflicts with)
- Severity: HIGH (real contradiction), MEDIUM (stale reference), LOW (cosmetic)

Cap response at 500 words. If no issues, say so explicitly. Do NOT write or edit files.
```

### Subagent 2 — Improvements review

```
You are reviewing <N> OpenSpec artifacts for the right level of detail. Dual audience:

- **Human reviewer** — reads to approve. Should not be overwhelmed by verbosity, padding, or restated obvious things.
- **Implementing agent (or junior developer)** — reads to build. Should have enough guardrails to implement correctly without re-deriving decisions or guessing intent.

Read these four files:
<list of absolute file paths>

Background:
<the brief from Step 4>

Each file's job:
- **proposal.md** — why and what at a glance; what we considered and rejected
- **spec.md** — requirements and scenarios; source of behavioral truth
- **design.md** — real technical decisions (architectural, why-X-over-Y) NOT spec restatement
- **tasks.md** — vertical scenario commits, test-first. Each task is a state achieved, not a line-by-line script.

What to look for:

**Over-shooting:**
- Sentences that pad without adding signal
- Paragraphs that restate something already said earlier (cross-doc duplication)
- Decisions in design.md that are spec restatement
- Tautological scenarios in spec.md
- Tasks that over-prescribe (field names, function signatures, file-line edits)
- Redundant rationale across multiple sections

**Under-shooting:**
- Decisions stated in proposal but not anchored in design where they'd guide implementation
- Tasks lacking a "state after this commit" description
- Scenarios too abstract for the implementer to know what to assert
- Missing references between spec/design/tasks where needed
- Edge cases mentioned in proposal that no scenario captures

**Design.md structure and discipline** (the background brief names the project's locked decision format, e.g., Format A):
- Does every numbered decision use the locked format consistently? Flag decisions that omit the alternatives section, skip the recommendation reasoning, or collapse into a one-line statement when they should be in the format.
- Is each decision a real technical choice NOT dictated by the spec? Flag "decisions" that restate spec requirements as decisions, or that re-derive principles already in the vault — these belong in proposal.md's "Does NOT do" section or are simply redundant.
- Is there a `## Smaller choices` section for low-impact decisions accepted without full walkthrough? If many small decisions are dispersed inline among the big ones, the big decisions get diluted — flag for consolidation into a Smaller choices panel.

**Scenario → commit mapping quality** (if tasks.md has a mapping section):
- Are multi-scenario commits genuinely grouped under one of the stated rules (same code path or observability dependency), or just thematically related?
- Are any commits over-split (two branches of one `if/else` separated into different commits)?
- Does each commit pass the test: "Can I sit down and use this in a real project right now, and it does one more useful thing than before?"
- Does every commit have a "state after this commit" sentence?

For each finding, output one bullet:
- File and section/line
- "Over-shoots" or "Under-shoots" or "Mapping issue"
- What's wrong, in one sentence
- Proposed fix, in one sentence

Cap response at 700 words. Lead with the 3-5 highest-leverage findings; group additional as "minor."

Do NOT write or edit files. Don't flag everything you could nitpick — only ones where applying the fix would meaningfully improve the doc for either audience.
```

## Step 6: Synthesise findings

Once both subagents return, present a unified summary to the user. Categorise every finding into one of three buckets:

- **Apply** — high-confidence mechanical fixes (contradictions, stale references, missing "state after" lines, broken cross-refs). State which file each fix touches.
- **Surface for decision** — judgment calls (drop a requirement? restructure a commit?). Each gets a one-sentence summary plus your recommendation.
- **Dismiss with reason** — findings you'd not act on, with a one-line reason (e.g., "false alarm — the spec wording is correct in context").

Then ask the user which to apply. Do **not** auto-apply anything during the review — the user is the gate.

## Step 7: After the user decides

Apply approved fixes. Do not re-run the subagent review unless the user explicitly asks — repeated subagent rounds during one editing session usually surface diminishing returns. The expected pattern is: review → apply → commit. If a second round is warranted (e.g., the apply phase touched many files), the user will say so.

## What this skill does not do

- Does not verify implementation against artifacts — that's `openspec-verify-change`'s job (post-implementation).
- Does not edit any files itself — pure review.
- Does not commit anything — the user commits.
- Does not auto-fire on file edits — only on explicit invocation or proactive suggestion at natural breakpoints.

## Cost

~30-60 seconds elapsed (two Sonnet subagents in parallel). ~50-70k tokens combined across both subagents. One-time cost per pre-commit checkpoint, not per edit.

## Related skills

- `openspec-verify-change` — verifies implementation matches artifacts (post-implementation).
- `openspec-archive-change` — finalises a change after implementation is complete.
- `verify-plan` — analogous review pattern for plan files (uses three parallel agents).
