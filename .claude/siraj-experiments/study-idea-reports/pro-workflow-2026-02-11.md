# Study Report: pro-workflow

**Source:** https://github.com/rohitg00/pro-workflow
**Date Studied:** 2026-02-11
**Author:** Rohit Ghumare
**Version:** 1.2.0
**License:** MIT

---

## What Is It?

A Claude Code plugin that packages 8 battle-tested AI coding workflow patterns into a reusable system with persistent SQLite-backed memory, specialized subagents, structured commands, and context modes.

Philosophy: "80% of code written by AI, 20% reviewing and correcting it" — optimize for that ratio.

---

## Architecture Overview

```
pro-workflow/
├── skills/          # Main SKILL.md with 8 workflow patterns
├── agents/          # Planner, Reviewer, Scout (confidence-gated)
├── commands/        # wrap-up, replay, handoff, commit, insights, learn
├── hooks/           # Post-commit auto-learning
├── contexts/        # dev, review, research mode switching
├── src/
│   ├── db/          # SQLite init with FTS5 for learnings + sessions
│   └── search/      # BM25 full-text search, keyword extraction
├── scripts/         # Hook execution scripts
└── .claude-plugin/  # Plugin manifest for marketplace
```

**Key dependency:** `better-sqlite3` for persistent learnings database at `~/.pro-workflow/data.db`

---

## Core Ideas Extracted

### Idea 1: Persistent Learning Memory (SQLite + FTS5)

**What:** Every mistake/correction/insight gets captured in a SQLite database with full-text search, then surfaced automatically when doing similar tasks.

**How:** Two tables — `learnings` (category, rule, mistake, correction, times_applied) and `sessions` (project, edit_count, corrections_count). FTS5 virtual table with BM25 ranking. Triggers keep the FTS index in sync. 10 categories: Navigation, Editing, Testing, Git, Quality, Context, Architecture, Performance, Claude-Code, Prompting.

**Why it matters:** Without persistent memory, Claude makes the same mistakes across sessions. This creates a compounding knowledge base — the more you use it, the fewer corrections needed.

**Key pattern:** *Structured capture + contextual retrieval*. Don't just store learnings as text — categorize them, track application frequency, and use relevance-ranked search to surface them at the right moment.

### Idea 2: Confidence-Gated Exploration (Scout Agent)

**What:** Before implementing anything complex, a Scout agent scores task readiness (0-100) across 5 dimensions and only proceeds when confidence is high enough.

**How:** 5 dimensions scored 0-20 each: Scope clarity, Pattern familiarity, Dependency awareness, Edge case coverage, Test strategy. Score >= 70 = GO, < 70 = HOLD (gather more context, re-score). After 2 rounds still < 70 = escalate to user. Integrates past learnings — reduces confidence when similar correction patterns exist.

**Why it matters:** Prevents the "jump in and hack until it works" anti-pattern. Forces systematic assessment before burning tokens on implementation.

**Key pattern:** *Quantified readiness gates*. Instead of vague "think before you act", assign numerical scores to concrete dimensions. Creates a decision framework that's both rigorous and auditable.

### Idea 3: Session Handoff Documents

**What:** Structured documents that capture full work state for seamless continuation across Claude sessions.

**How:** Gathers git status, recent commits, modified files, session learnings. Three modes: Standard (overview), Full (with diffs), Compact (just resume command). Saves to `~/.pro-workflow/handoffs/` with branch-based naming. Includes ready-to-paste resume command.

**Why it matters:** Context loss between sessions is the #1 productivity killer with AI coding. A structured handoff is dramatically better than "read the git log."

**Key pattern:** *Machine-readable session state*. Not just notes for humans — a document structured so the next AI session can immediately orient itself and continue.

### Idea 4: Correction Heatmap & Adaptive Quality Gates

**What:** Tracks which categories of mistakes recur most, visualizes as a heatmap, and automatically tightens quality checks in problem areas.

**How:** SQLite queries aggregate correction frequency by category and project. Areas with high correction rates trigger stricter review (e.g., if Testing corrections are frequent, the reviewer agent pays extra attention to test coverage). The `/insights heatmap` command visualizes distribution.

**Why it matters:** Generic quality gates waste time checking things that are fine while missing the areas where you actually struggle. Adaptive gates focus effort where it matters.

**Key pattern:** *Feedback-driven severity weighting*. Use correction history to dynamically adjust review intensity per category.

### Idea 5: Context Modes (Dev / Review / Research)

**What:** Switchable behavioral modes that change Claude's priorities, tool usage, and output style depending on the current activity.

**How:** Three markdown files define each mode's mindset, priorities, behavior, and triggers. Dev mode: "code first, explain after, iterate quickly." Review mode: "security > performance > style, provide solutions not just problems." Research mode: "explore broadly, don't change code yet, propose plan before acting."

**Why it matters:** A single behavioral profile for all activities leads to suboptimal results — Claude shouldn't be cautious when you're in rapid iteration mode, and shouldn't be fast-and-loose when reviewing security.

**Key pattern:** *Named behavioral profiles*. Rather than tuning behavior per-prompt, define named modes that bundle multiple behavioral adjustments and switch between them explicitly.

---

## Mapping to Existing Skills

| New Idea | Existing Skill/Gap | Integration Type | Effort | Impact |
|---|---|---|---|---|
| Persistent Learning Memory | **Gap** — no persistent memory across sessions. GSD has state files but no searchable DB. Feather has no learning capture. | New skill | High | High |
| Confidence-Gated Exploration | **Partial** — GSD has `discuss-phase` and `list-phase-assumptions`, feather has `review-design`. But none score readiness quantitatively. | Enhance existing | Med | Med |
| Session Handoff | **Partial** — GSD has `pause-work`/`resume-work`, feather has `pause-slice`/`resume-slice`. Both focus on TDD state, not full session state with learnings. | Enhance existing | Low | High |
| Correction Heatmap | **Gap** — no analytics on mistakes or correction patterns. GSD/feather track task completion but not error patterns. | New skill | Med | Med |
| Context Modes | **Gap** — CLAUDE.md has one behavioral profile. No explicit mode switching. | New skill or CLAUDE.md pattern | Low | Med |

---

## What's Already Covered (No Action Needed)

- **Planner agent** — GSD has `plan-phase` + `gsd-planner` subagent, feather has `create-plan`. Already well-served.
- **Reviewer agent** — You have `request-review` + `receive-review` skills. Already covered.
- **Commit workflow** — GSD has commit patterns, and Claude Code's built-in `/commit` works. Not a gap.
- **Wrap-up ritual** — GSD `pause-work` and feather `pause-slice` partially cover this. Low incremental value.
- **Split memory** (CLAUDE.md/AGENTS.md/SOUL.md) — Nice pattern but mostly organizational. Low impact to formalize.

---

## Critical Assessment

**Strengths of pro-workflow:**
- The SQLite learning database is genuinely novel and high-impact
- Confidence scoring before implementation is disciplined
- The correction heatmap creates a real feedback loop

**Weaknesses / Things I'd do differently:**
- The plugin relies on `better-sqlite3` (native Node addon) — heavy dependency for what's essentially a skill system. A simpler JSON-file or markdown-based approach might integrate better with Claude Code's native tools.
- Some commands overlap with what Claude Code provides natively (`/commit`, `/compact`, `/context`)
- The "8 patterns" framing mixes genuinely novel ideas (learning DB, confidence gates) with standard practices (use plan mode, manage tokens) that don't need a plugin
- Context modes are interesting but could be done with a single CLAUDE.md section rather than a whole system

---

## Top 3 Integration Opportunities

### 1. Learning Capture & Replay (High Impact, High Effort)
Build a `/learn` and `/replay` skill that captures mistakes and corrections into a persistent store (JSON files in `~/.claude/learnings/` — no SQLite dependency), with keyword-based retrieval. This compounds over time and is the most unique value from pro-workflow.

### 2. Session Handoff Enhancement (High Impact, Low Effort)
Enhance GSD's `pause-work` or feather's `pause-slice` to generate a richer handoff document — not just TDD state but git state, modified files with context, key decisions, and a ready-to-paste resume prompt. Small change, big payoff.

### 3. Readiness Scoring Gate (Med Impact, Med Effort)
Add a `/ready-check` skill that scores task readiness (0-100) across dimensions before implementation begins. Integrates naturally before `feather:create-plan` or `gsd:plan-phase`. Prevents wasted effort on underspecified tasks.

---

## Recommended First Build

**Session Handoff Enhancement** — it's the lowest effort with highest immediate impact. Your existing `pause-work`/`pause-slice` skills already do part of this. Enriching them with pro-workflow's handoff patterns (git state, file inventory, resume command, recent learnings) would be a quick win that improves every session transition.
