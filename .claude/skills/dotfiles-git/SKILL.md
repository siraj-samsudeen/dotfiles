---
name: dotfiles-git
description: Use BEFORE any git operation on Siraj's dotfiles bare repo at $HOME/.cfg — staging, committing, checking status, or adding a new file to track. Also use when a file under $HOME refuses to show in git status, refuses to stage, or "pathspec did not match any files" appears. Covers three gotchas (silent-untracked status, allowlist .cfg-ignore, absolute-path requirement) + a debugging checklist + the canonical add-new-path sequence. Every agent hits these once. Save them the second occurrence.
---

# Working with the dotfiles bare repo

This skill covers the non-obvious mechanics of Siraj's dotfiles bare repo
at `$HOME/.cfg`. Trigger it whenever you're about to run `git` against
that repo, or when a dotfiles-related operation behaves unexpectedly.

## Basics (same as cross-project/context-environment.md)

- Bare repo: `$HOME/.cfg`
- Work-tree: `$HOME`
- No `.git/` directory exists — the repo is driven via explicit flags:

```bash
git --git-dir=$HOME/.cfg --work-tree=$HOME <subcommand>
```

The `dotfiles` shell alias exists in `~/.zshrc` but is NOT available in
non-interactive shells (tool calls). Always use the full command above.

## Three gotchas every agent hits

Each one can burn 5+ minutes of diagnosis. Read them once, save the repeat.

### Gotcha 1 — `git status` is silent about untracked files

The bare repo has `status.showUntrackedFiles = no` configured. Plain
`git status` shows only *tracked* file changes. A brand-new file you just
created will NOT appear — not even with `-u` in some cases, because the
pair (silent-untracked + allowlist `.cfg-ignore`) hides it.

**"Nothing to commit" does NOT mean "nothing new on disk."**

### Gotcha 2 — `.cfg-ignore` is an allowlist, not a blocklist

`~/.cfg-ignore` line 5 is a single `*` (ignore *everything*). Every
other pattern is a `!` un-ignore for a specific path. A new file is
invisible to the repo unless an existing `!` rule covers its path, OR
you add a new `!` rule for it.

Already-un-ignored trees (memorise these; they cover 95% of cases):

- Shell: `.zshrc`, `.zshenv`, `.p10k.zsh`
- Git: `.gitconfig`, `.gitignore`, `.cfg-ignore`
- Tool configs: `.config/**`, `.psqlrc`, `.duckdbrc`, `.odbc.ini`,
  `RectangleConfig.json`
- Claude Code: `.claude/CLAUDE.md`, `.claude/settings.json`,
  `.claude/agents/**`, `.claude/commands/**`, `.claude/hooks/**`,
  `.claude/skills/**`, `.claude/skill-audit/**`,
  `.claude/siraj-experiments/**`, `.claude/projects/*/memory/**`
- Editors: `Library/Application Support/{Code,Cursor}/User/{settings,keybindings}.json`

Anything outside those needs a new `!<path>` line in `~/.cfg-ignore`
BEFORE `git add` will recognise it.

### Gotcha 3 — relative paths to `git add` break when CWD ≠ `$HOME`

The work-tree is `$HOME`, but the shell's CWD is usually a project
directory. Running `git ... add .claude/skills/foo/SKILL.md` from
`~/Desktop/.../some-project/` fails with `pathspec did not match any
files` — git resolves the path relative to the project, not to `$HOME`.

Always pass absolute paths (or `cd $HOME` first):

```bash
git --git-dir=$HOME/.cfg --work-tree=$HOME add "$HOME/.claude/skills/foo/SKILL.md"
```

## Debugging checklist — "my file won't commit / isn't showing up"

Run these in order; each one rules out one of the three gotchas.

**Step 1 — which `.cfg-ignore` rule is deciding?**

```bash
git --git-dir=$HOME/.cfg --work-tree=$HOME check-ignore -v "$HOME/<path>"
```

If the matching line is `5:*` with no later negation, no `!` rule has
un-ignored this path yet — add one to `~/.cfg-ignore`.

**Step 2 — is the file already staged from a prior session?**

```bash
git --git-dir=$HOME/.cfg --work-tree=$HOME ls-files --stage -- "$HOME/<path>"
```

The index can accumulate silently because untracked status is hidden. A
file you thought was fresh may have been `add`-ed in a past session. If
this prints an entry, the file is already staged — you just need to
commit it.

**Step 3 — full untracked listing, bypassing the silent-untracked config:**

```bash
git --git-dir=$HOME/.cfg --work-tree=$HOME status -u --ignored
```

This shows everything: tracked modifications, untracked files, and what
`.cfg-ignore` is hiding. Useful when you've lost track of the repo state.

**Step 4 — before committing, confirm exactly what's staged:**

```bash
git --git-dir=$HOME/.cfg --work-tree=$HOME diff --cached --name-only
```

Use `--name-only`, NOT `--stat` — the `--stat` summary line has shipped
unintended files in the past. See `cross-project/lessons-hard-won.md`
"Git Pathspec Globs Don't Unstage in Dotfiles Bare Repo" for the incident.

## Canonical "add a new path to track" sequence

Whenever you create a new file under `$HOME` that you want committed:

```bash
# 1. Verify current ignore status — is a `!` rule already in place?
git --git-dir=$HOME/.cfg --work-tree=$HOME check-ignore -v "$HOME/path/to/new-file"

# 2. If line 5 (`*`) is the deciding rule, add a !-entry to ~/.cfg-ignore
#    (edit ~/.cfg-ignore, append e.g. `!path/to/new-file` or `!path/to/**`)

# 3. Re-check — should now print nothing, or a later negating rule
git --git-dir=$HOME/.cfg --work-tree=$HOME check-ignore -v "$HOME/path/to/new-file"

# 4. Stage the new file AND the modified .cfg-ignore in the same commit
git --git-dir=$HOME/.cfg --work-tree=$HOME add "$HOME/path/to/new-file" "$HOME/.cfg-ignore"

# 5. Confirm the staged set is exactly what you intend
git --git-dir=$HOME/.cfg --work-tree=$HOME diff --cached --name-only

# 6. Commit with narrow scope — never `-a`; the index can contain unrelated stale entries
git --git-dir=$HOME/.cfg --work-tree=$HOME commit -m "<concise scope>: <what+why>"

# 7. Push to origin — always push after committing (commit + push are one unit here)
git --git-dir=$HOME/.cfg --work-tree=$HOME push
```

When committing multiple logical groups in a row, push once at the end
of the batch (single `push` ships all the new commits).

## Always push after committing

Unlike most repos, the dotfiles bare repo is treated as a
commit+push unit. After any commit (or a batch of related commits),
run `git --git-dir=$HOME/.cfg --work-tree=$HOME push`. Origin is the
source of truth across machines, and unpushed dotfile commits silently
diverge across laptops.

The only exception: explicit user instruction to hold off pushing.

## What this skill must NOT do

- Do not `git add -A` or `git commit -a` — both stage unrelated pending
  changes the index has accumulated silently.
- Do not delete or amend history without explicit user approval.
- Do not modify `.cfg-ignore` beyond adding `!` rules for paths the
  current task needs — leave the rest of the file alone.
- Do not force-push (`--force`, `--force-with-lease`) without explicit
  user approval.

## Commit-message style

Look at `git log --oneline -5` first; match the prevailing style.
Current pattern in this repo is conventional-commits-ish:

- `feat(skills): add ... skill`
- `chore: slim global CLAUDE.md to vault pointer only`
- `feat: track Claude Code project memory files in dotfiles`

Short first line (≤70 chars), body explains what + why, trailer for
co-authorship when Claude generated the work.

## Related

- Environment overview: `cross-project/context-environment.md` in the
  Obsidian vault (basic command, points back at this skill for details).
- Related lesson: `cross-project/lessons-hard-won.md` — "Git Pathspec
  Globs Don't Unstage in Dotfiles Bare Repo." Read once if you are doing
  anything non-trivial with staging/unstaging ranges.
