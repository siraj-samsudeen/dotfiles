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
- Significant session completed → projects/<name>/sessions/ or cross-project/ if multi-project
- End of productive day → daily-log/YYYY-MM-DD ddd.md
</when_to_write>

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
