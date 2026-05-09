---
name: obsidian
description: "Write to or read from the Obsidian knowledge vault. Use when: saving lessons/corrections, recording decisions, creating session notes, or checking existing principles before making decisions."
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
---

<objective>
Interact with the Obsidian knowledge vault at ~/Dropbox/Siraj/Projects/siraj-claude-vault/. This vault stores cross-project wisdom, session logs, plans, and decisions that persist across Claude Code sessions.
</objective>

<vault_structure>
~/Dropbox/Siraj/Projects/siraj-claude-vault/
├── cross-project/              # Read these FIRST — they shape all decisions
│   ├── philosophy-testing.md       # Real infra, E2E first, TDD, coverage exclusions
│   ├── philosophy-ai-collaboration.md  # Dual-agent verification, batch questions
│   ├── philosophy-architecture.md  # Simplicity, concrete before abstract, mode over config
│   ├── philosophy-design.md        # Tableau standard, Frappe model, audit trail
│   ├── philosophy-process.md       # Immutable reviews, vertical slices, four-lens review
│   ├── context-domain.md           # ERP domain, Indian SMB, Excel-first, Feather brand
│   ├── lessons-hard-won.md         # Mistakes that became principles
│   └── vault-sync-conventions.md   # How artifacts are routed into the vault
├── projects/<name>/            # Per-project artifacts
│   ├── _dashboard.md               # Project hub with links to all artifacts
│   ├── sessions/                   # Session logs (date + description)
│   ├── decisions/                  # Architecture decisions (slug, no date)
│   ├── plans/                      # Plan documents (date + description)
│   ├── research/                   # Research findings
│   ├── memories/                   # Synced from .claude/projects/*/memory/
│   ├── reviews/                    # Code reviews, audits
│   └── feedback/                   # User corrections, working preferences
├── daily-log/                  # Daily Claude Code activity summaries
├── templates/                  # Templater templates for each artifact type
└── attachments/
</vault_structure>

<when_to_write>
- User corrects a mistake that reveals a reusable principle → cross-project/ or lessons-hard-won.md
- Session produces a decision worth preserving → projects/<name>/decisions/
- A plan is created → projects/<name>/plans/ with a proper descriptive name (never random slugs)
- Multi-step diagnostic that the user explicitly asks to preserve, OR a recurrence cost that clearly outweighs writing cost → projects/<name>/sessions/ or cross-project/gotchas/. Otherwise, daily-log bullets are the record — do not auto-spawn a companion file. See <session_log_style>.
- End of productive day → daily-log/YYYY-MM-DD ddd.md — summary only, see <daily_log_vs_session_log>
</when_to_write>

<daily_log_vs_session_log>
**Default: daily-log bullets only.** As few bullets as carry causal
meaning (often 2–3) — symptom-style title in the user's voice, then
the practical causal steps. Skip the discovery-arc bullet unless the
discovery itself is the interesting bit.

A session/gotcha file is by **exception**, not default. Only write one if:

- the user explicitly asks for one, OR
- the diagnostic playbook is genuinely multi-step *and* the recurrence
  cost clearly dwarfs the writing cost.

Companion files alongside trivial fixes are "death to detail" — bulk
drowns the signal. If two bullets in the daily log already capture
symptom + fix, the daily log IS the record. Don't spawn a gotcha file
to re-explain.

**Title style:** state the symptom in plain English, the way the user
would grep for it next time. Not a retrospective principle or
abstraction.

- ✅ "VSCode shows empty Explorer when opened from terminal"
- ✅ "Claude Code Terminal was printing too much when using Tool calls"
- ❌ "macOS TCC blocks Desktop access" / "Verbose flag default"
</daily_log_vs_session_log>

<daily_log_style>
**Format per topic** — apply X-to-solve-Y-got-Z; drop any part that
doesn't carry meaning:

> "In project <name>, I did <X> — to solve <Y>. Got <Z>."

Or as a richer narrative:

> "<What I did and why>, <result>. <Detail in [[session log]] if it exists>."

**Structure rules:**

- One H2 per real focus area. Resist sub-arcs and re-tellings of the same story.
- Multi-line content → bullets, not paragraphs.
- ~3 indicative bullets per topic; "plus smaller things" or "and similar fixes"
  beats exhaustive lists.
- Principles → wikilink them, plus 1–2 lines on why the principle came about
  and what main thing it solves. Don't punt with "worth promoting if it recurs."
- Detail (commit SHAs, version numbers, file paths, error messages,
  reproduction steps, debugging arcs) → wikilink to the session log; do not
  restate in the daily log.
- Peripheral / unrelated items: **ASK THE USER** before logging. Do not
  default to a "Loose ends" or "TODO" section in the daily log.
- Voice: first-person where natural ("I trialled X yesterday…"); neutral
  observation otherwise. Avoid "load-bearing for future-me" and similar
  self-referential framing.
</daily_log_style>

<session_log_style>
**Purpose:** capture for future-me (or a fresh agent) when the
recurrence cost genuinely dwarfs the writing cost. If two bullets in
the daily log already carry symptom + fix, do not write a session log.

**Keep it short.** Default ~20–30 lines, one section. Write only the
sections that have unique content — often that's two: **symptom** and
**fix**. If you find yourself adding "Why the symptoms are misleading,"
"What to check first," "Watchouts," and a fix-variants table to the
same file, stop and ask the user. Most of those sections are noise, not
signal — that's the "death to detail" failure mode.

**Available sections, by need:**

- What broke (exact symptom — error message, behaviour)
- What did fix it
- (Only if non-obvious): what didn't fix it; mental model behind the fix; watchouts

Errno semantics, kernel-layer breakdowns, and "worked yesterday because…"
patterns feel insightful but rarely save time on recurrence — cut them
unless the user explicitly wants the depth.
</session_log_style>

<daily_log_anti_patterns>
| ❌ Don't | ✅ Do |
|---|---|
| Encyclopedic paragraphs in daily log | Bullets with one-line context; detail → session log |
| Commit SHAs, version numbers, line counts in daily log | Git is the audit trail; daily log captures what and why |
| Agent narrating its own debugging arc ("caught nine issues") | What the human did and what the human got |
| "Load-bearing for future-me" framing | Neutral observation; first-person where natural |
| Narrative arcs re-telling the same story (v1.0.0 → v1.0.1 → ...) | One tight summary per topic |
| "Loose ends" / "TODO" sections by default | Ask the user first; don't default to a scratchpad section |
| Punted principles ("worth promoting if it recurs") | Articulate now or wikilink the principle file |
| Restating session-log detail in daily log | Wikilink to the session log |
| Mention every change exhaustively | "Plus smaller things…" / "and similar" — indicative not exhaustive |
| Mix peripheral work into main topic | Either ask user, or it doesn't go in the daily log |
| Auto-spawn a gotcha/session file alongside a trivial daily-log entry | Daily-log bullets in the user's voice are usually the whole record. Ask before writing a companion file. |
| Title the entry with a principle or abstraction ("TCC blocks Desktop") | Title with the symptom in plain English ("VSCode shows empty Explorer when opened from terminal") |
| Default to a fixed bullet count | Bullet count = causal steps that matter; often 2, sometimes 4 |
</daily_log_anti_patterns>

<when_to_read>
- Before making architecture or testing decisions, check cross-project/philosophy-*.md
- When starting work on a project, skim projects/<name>/_dashboard.md for context
- When the user asks "have we decided this before?" or "what's our stance on X?"
</when_to_read>

<writing_conventions>
Every file needs YAML frontmatter:

```yaml
---
type: session | plan | decision | memory | research | review | daily-log
project: <project-slug> or cross-project
date: YYYY-MM-DD
status: active | completed | superseded  # for decisions/plans
tags:
  - Projects/<name>    # matches existing Obsidian tag convention
  - Type/<artifact>    # Session, Plan, Decision, Memory, Research, Review
---
```

Naming:
- Plans/sessions/research/reviews: `YYYY-MM-DD <descriptive-slug>.md`
- Decisions/memories: `<descriptive-slug>.md` (no date — timeless until superseded)
- Dashboards: `_dashboard.md`
- Daily logs: `YYYY-MM-DD ddd.md`

Routing:
- Cross-project principles → cross-project/
- Project-specific artifacts → projects/<name>/<type>/
- New projects: create the subfolder structure (sessions, decisions, plans, research, memories, reviews, feedback)
</writing_conventions>

<process>
1. Determine intent: reading existing knowledge or writing new content
2. If reading: search vault with Grep or read specific philosophy files
3. If writing: choose the right location and artifact type, apply frontmatter template, write the file
4. If updating daily log: append to today's entry or create if it doesn't exist
</process>
