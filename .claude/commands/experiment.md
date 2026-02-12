---
name: experiment
description: >
  Capture, create, or continue experiments in siraj-experiments/.
  Use when starting a new experiment, capturing a mid-session discovery worth tracking,
  or resuming previous work on an existing experiment.
---

# Experiment Tracker

Manages the experiment lifecycle in `~/.claude/siraj-experiments/`.

## Experiment Home

All experiments live at: `~/.claude/siraj-experiments/`
Index file: `~/.claude/siraj-experiments/INDEX.md`

## Step 1: Determine Mode

Ask the user which mode they want:

| Mode | When to use |
|------|-------------|
| **New** | Starting a fresh experiment from scratch |
| **Capture** | Mid-session — realized the current conversation is worth tracking |
| **Continue** | Picking up an existing experiment |

Use AskUserQuestion with these three options.

---

## Mode: New

### Step 1: Seed the experiment

Ask: **"What are you curious about?"** — get a one-liner that becomes the experiment name.

Then ask: **"What's the question or hypothesis?"** — this becomes the `Question` field. User can skip this if they're still forming the question.

### Step 2: Create the experiment

1. Derive a `kebab-case` folder name from the one-liner (short, descriptive, 2-4 words)
2. Confirm the folder name with the user before creating
3. Create `~/.claude/siraj-experiments/<name>/EXPLORATION.md` using the template below
4. Update INDEX.md (add a new row to the Active Explorations table)

### Step 3: Commit to dotfiles

Auto-commit using the bare repo:

```bash
git --git-dir="$HOME/.cfg" --work-tree="$HOME" add ~/.claude/siraj-experiments/<name>/EXPLORATION.md ~/.claude/siraj-experiments/INDEX.md
git --git-dir="$HOME/.cfg" --work-tree="$HOME" commit -m "Add experiment: <name>"
```

### Step 4: Prompt next action

Tell the user: "Experiment created. Start exploring — when you have findings, run `/experiment` again and choose Continue."

---

## Mode: Capture (mid-session)

This mode is for when the user is already in a conversation and realizes it's worth tracking.

### Step 1: Get the user's narrative

Ask: **"Describe what you've been exploring — what's the key question and what have you found so far?"**

Let the user write their own narrative. This is their voice, not AI-generated.

### Step 2: Offer to enrich

After the user provides their narrative, say:

"I can also summarize the relevant parts of our conversation to add context. Want me to add that to the EXPLORATION.md?"

If yes, write a concise summary of the conversation's key findings, decisions, and open questions. Add it as a separate subsection under the first log entry titled "Session Context".

### Step 3: Create the experiment

Same as New mode steps 2-4:
1. Derive folder name, confirm with user
2. Create EXPLORATION.md with the user's narrative as the first log entry
3. Update INDEX.md
4. Auto-commit to dotfiles

---

## Mode: Continue

### Step 1: List experiments

Read `~/.claude/siraj-experiments/INDEX.md` and present the active experiments table.

Ask the user to pick one (use AskUserQuestion with experiment names as options).

### Step 2: Show current state

Read the experiment's EXPLORATION.md and display:
- The Question
- Current Status
- The most recent log entry (last dated section)
- The current Next Steps section

### Step 3: Append new entry

Ask: **"What's new? What did you explore or discover?"**

Then append a new dated log entry to the Log section of EXPLORATION.md:

```markdown
### YYYY-MM-DD — <Entry title>
<User's notes>
```

Also ask if the status or next steps have changed, and update those sections if so.

### Step 4: Commit to dotfiles

```bash
git --git-dir="$HOME/.cfg" --work-tree="$HOME" add ~/.claude/siraj-experiments/<name>/EXPLORATION.md ~/.claude/siraj-experiments/INDEX.md
git --git-dir="$HOME/.cfg" --work-tree="$HOME" commit -m "Update experiment: <name> — <entry title>"
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

---

## INDEX.md Row Format

Add new experiments to the Active Explorations table:

```markdown
| `<folder-name>/` | <Experiment Name> | <Status> | YYYY-MM-DD |
```

When updating status on Continue, also update the row in INDEX.md.

---

## Dotfiles Commit Pattern

Always use the bare repo method:

```bash
# Add files
git --git-dir="$HOME/.cfg" --work-tree="$HOME" add <files>

# Commit
git --git-dir="$HOME/.cfg" --work-tree="$HOME" commit -m "<message>"
```

Do NOT push automatically — the user pushes manually when ready.

---

## Tips for the Agent

- Keep experiment names short: `visible-tdd-agents` not `exploring-visible-tdd-agent-patterns-for-subagent-work`
- The user's voice matters in EXPLORATION.md — don't over-polish their narrative
- On Continue, show enough context that the user remembers where they left off, but don't dump the entire file
- When capturing mid-session, the conversation summary should be factual and concise — key findings, not a transcript
- If the user says "this is worth tracking" or "let me capture this" mid-conversation, that's a signal to use Capture mode
- Status values: `In Progress`, `Research Complete`, `Complete`, `Paused`
- Date format: YYYY-MM-DD
