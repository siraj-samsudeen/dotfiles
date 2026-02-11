---
name: update-dotfiles
description: Update dotfiles config using the bare repo method. Use when you want to add, commit, or push changes to your dotfiles.
---

# Dotfiles Bare Repo Context

The user manages dotfiles using a **bare git repo** method:

- **Git database:** `~/.cfg` (bare repo, no working directory)
- **Working tree:** `$HOME` (files tracked directly in home directory)
- **Alias:** `dotfiles` = `git --git-dir=$HOME/.cfg --work-tree=$HOME`
- **Ignore file:** `~/.cfg-ignore` (allowlist approach — ignores everything, un-ignores tracked files)
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
5. **Discover new configs** - offer to scan for untracked dotfiles worth tracking

## Instructions

When the user invokes this command:

1. Run `git --git-dir="$HOME/.cfg" --work-tree="$HOME" status` to show current state
2. Ask what they want to update/add
3. Walk them through add → commit → push, confirming each step
4. **After push**, ask: "Want me to scan for new dotfiles you might want to track?"
   - If yes, run: `comm -23 <(ls -1dA ~/.[!.]* 2>/dev/null | xargs -I{} basename {} | sort -u) <(git --git-dir="$HOME/.cfg" --work-tree="$HOME" ls-files | sed "s|/.*||" | sort -u)`
   - Filter out obvious noise (caches, histories, temp files, runtime dirs)
   - Show only configs that look intentional (e.g. `.iex.exs`, `.npmrc`, `.psqlrc`, `.condarc`)
   - If any look worth tracking, offer to add them and update `~/.cfg-ignore` with a `!` entry
