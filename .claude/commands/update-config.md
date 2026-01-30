---
name: update-config
description: Update dotfiles config using the bare repo method. Use when you want to add, commit, or push changes to your dotfiles.
---

# Dotfiles Bare Repo Context

The user manages dotfiles using a **bare git repo** method:

- **Git database:** `~/.cfg` (bare repo, no working directory)
- **Working tree:** `$HOME` (files tracked directly in home directory)
- **Alias:** `config` = `git --git-dir=$HOME/.cfg --work-tree=$HOME`
- **Remote:** https://github.com/siraj-samsudeen/dotfiles

## Key Commands (use full git command since alias isn't available in Claude sessions)

```bash
# Check status
git --git-dir="$HOME/.cfg" --work-tree="$HOME" status

# Add a file
git --git-dir="$HOME/.cfg" --work-tree="$HOME" add <file>

# Commit
git --git-dir="$HOME/.cfg" --work-tree="$HOME" commit -m "message"

# Push
git --git-dir="$HOME/.cfg" --work-tree="$HOME" push
```

## Files Currently Tracked

- `.zshrc`, `.zshenv`, `.p10k.zsh` - shell config
- `.claude/CLAUDE.md` - global Claude instructions
- `.claude/settings.json` - Claude settings
- `.claude/skills/` - custom skills
- `.claude/commands/` - custom commands (like this one)
- `.claude/hooks/` - custom hooks

## Workflow

1. **Show current status** - what files have changed
2. **Ask user** what they want to do:
   - Add specific files
   - Add all changed tracked files
   - View diff of changes
3. **Commit** with a descriptive message
4. **Push** to GitHub

## Instructions

When the user invokes this command:

1. Run `git --git-dir="$HOME/.cfg" --work-tree="$HOME" status` to show current state
2. Ask what they want to update/add
3. Walk them through add → commit → push, confirming each step
