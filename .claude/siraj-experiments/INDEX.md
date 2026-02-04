# Siraj's Experiments

Explorations, research, and synthesis for workflow improvements.

## Active Explorations

| Folder | Name | Status | Date |
|--------|------|--------|------|
| `tdd-ralph-vertical-slices/` | TDD Ralph with Vertical Slices | Research complete, ready for planning | 2025-02-04 |

## Exploration Structure

Each exploration should have:

```
<experiment-name>/
├── EXPLORATION.md    # Research, sources, key ideas
├── SYNTHESIS.md      # Decisions made, final design (after planning)
├── CHANGELOG.md      # What changed during implementation (optional)
└── artifacts/        # Any supporting files (optional)
```

## Naming Conventions

- Folder names: `kebab-case`, short, descriptive
- Process names: Title Case for reference in conversations

## Persisting to Dotfiles

Use `/update-config` to commit explorations to the bare repo:

```bash
# After creating/updating an exploration
/update-config
# Then: add, commit, push the siraj-experiments folder
```
