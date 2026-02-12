# Siraj's Experiments

Explorations, research, and synthesis for workflow improvements.

## Experiments

| Folder | Name | Status | Started |
|--------|------|--------|---------|
| `dotfiles-audit/` | Dotfiles Audit & Cleanup | Complete | 2026-02-11 |
| `superpowers-to-feather/` | Superpowers to Feather Transition | Complete | 2026-02-10 |
| `feather-evolution/` | Feather Workflow Evolution | Complete | 2025-02-04 |
| `gsd-to-feather/` | GSD to Feather Integration | Research Complete | 2026-02-10 |
| `visible-tdd-agents/` | Visible TDD Agents | In Progress | 2026-02-12 |

## Related Systems

- **`~/.claude/skills/study-idea/`** — Queue-based system for studying URLs, concepts, and tools. Has its own `QUEUE.md` and `SKILL.md`. Moved from experiments to skills.
- **`study-idea-reports/`** — Study reports produced by the study-idea skill (and pre-system analyses migrated here).

## Experiment Structure

Each experiment lives in a kebab-case folder with an `EXPLORATION.md`:

```
<experiment-name>/
├── EXPLORATION.md    # Question, Status, Context, Log, Findings, Next Steps
└── artifacts/        # Original documents, supporting files (optional)
```

## Persisting to Dotfiles

```bash
# Use the dotfiles alias to commit changes
dotfiles add ~/.claude/siraj-experiments/<folder>
dotfiles commit -m "experiments: <description>"
dotfiles push
```
