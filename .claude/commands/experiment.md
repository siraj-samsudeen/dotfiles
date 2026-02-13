---
name: experiment
description: >
  Use when starting, capturing, or continuing an experiment in ~/.claude/siraj-experiments/.
  Modes: new (fresh experiment), capture (mid-session discovery worth tracking), continue (add findings to existing).
argument-hint: "[new|capture|continue]"
---

# Experiment Tracker

**Home:** `~/.claude/siraj-experiments/`
**Index:** `~/.claude/siraj-experiments/INDEX.md`

## Current Experiments

!`cat ~/.claude/siraj-experiments/INDEX.md 2>/dev/null || echo "No INDEX.md found"`

## Step 1: Determine Mode

If `$ARGUMENTS` is "new", "capture", or "continue", use that mode directly.
Otherwise, ask the user (via AskUserQuestion) which mode:

- **New** — fresh experiment from scratch
- **Capture** — mid-session discovery worth tracking
- **Continue** — resume an existing experiment

---

## Mode: New

```
Checklist:
- [ ] Get one-liner: "What are you curious about?"
- [ ] Get question/hypothesis (optional — user can skip)
- [ ] Derive kebab-case folder name (2-4 words), confirm with user
- [ ] Create <name>/EXPLORATION.md from template
- [ ] Add row to INDEX.md
- [ ] Commit to dotfiles
```

After creation, tell user: "Run `/experiment continue` when you have findings."

---

## Mode: Capture

For mid-session use when the user realizes the current conversation is worth tracking.

```
Checklist:
- [ ] Ask user to describe what they've been exploring (their voice, not AI-generated)
- [ ] Offer to enrich with conversation summary (separate "Session Context" subsection)
- [ ] Derive kebab-case folder name, confirm with user
- [ ] Create <name>/EXPLORATION.md with user's narrative as first log entry
- [ ] Add row to INDEX.md
- [ ] Commit to dotfiles
```

---

## Mode: Continue

The INDEX.md content is already loaded above. Present the active experiments via AskUserQuestion.

```
Checklist:
- [ ] Present active experiments from INDEX.md (already loaded above)
- [ ] Read selected experiment's EXPLORATION.md
- [ ] Show: Question, Status, most recent log entry, Next Steps
- [ ] Ask: "What's new? What did you explore or discover?"
- [ ] Append dated log entry to Log section
- [ ] Ask if status or next steps changed, update if so
- [ ] Update INDEX.md status if changed
- [ ] Commit to dotfiles
```

---

## EXPLORATION.md Template

```markdown
# <Experiment Name>

**Question:** <What are we trying to find out?>
**Status:** In Progress
**Started:** YYYY-MM-DD
**Last Updated:** YYYY-MM-DD

## Context

<Why this matters, what triggered it>

## Log

### YYYY-MM-DD — Started

<Initial notes, sources, ideas>

## Findings

<Populated as discoveries emerge>

## Next Steps

<What to explore next>
```

## INDEX.md Row Format

```markdown
| `<folder-name>/` | <Experiment Name> | <Status> | YYYY-MM-DD |
```

Update the row when status changes on Continue.

## Dotfiles Commit

```bash
git --git-dir="$HOME/.cfg" --work-tree="$HOME" add <files>
git --git-dir="$HOME/.cfg" --work-tree="$HOME" commit -m "<message>"
```

Do NOT push — user pushes manually.

## Agent Guidelines

- **Naming:** short kebab-case — `visible-tdd-agents` not `exploring-visible-tdd-agent-patterns`
- **Voice:** preserve the user's words in EXPLORATION.md — don't over-polish
- **Continue context:** show enough to jog memory, don't dump the entire file
- **Capture summaries:** factual and concise — key findings, not a transcript
- **Status values:** `In Progress` | `Research Complete` | `Complete` | `Paused`
