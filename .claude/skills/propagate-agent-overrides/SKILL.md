---
name: propagate-agent-overrides
description: Use when the user wants to adopt Siraj's cross-project agent overrides (vendored superpowers skills + spec template + CLAUDE.md workflow preferences) into the current repo. Run from the target project's root. Safe to re-run — the skill diffs and asks before overwriting.
---

# Propagating cross-project agent overrides into a project

## Purpose

Adopt (or re-sync) a consistent set of agent-config artifacts into the
current project:

- Vendored patched superpowers skills (`brainstorming`, `writing-plans`)
- Vendored slash commands (e.g. `research_codebase`)
- The cross-project spec template
- The `Standing workflow preferences for superpowers skills` section in the
  project's `CLAUDE.md`
- A `.gitignore` entry for `.claude/worktrees/`

All sources live in the user's vault at
`~/Dropbox/Siraj/Projects/siraj-claude-vault/cross-project/agent-overrides/`.

## Preconditions

1. Run from a git repository root (`git rev-parse --show-toplevel` equals
   the current working directory). If not, refuse and tell the user.
2. The masters dir
   `~/Dropbox/Siraj/Projects/siraj-claude-vault/cross-project/agent-overrides/`
   must exist and be readable. If missing, refuse and tell the user the
   vault is unavailable.
3. Do NOT auto-commit, do NOT push. The skill ends at staging-ready state.

## What gets copied, and where

| Source (under masters dir) | Target (relative to repo root) |
|---|---|
| `skills/brainstorming/SKILL.md` | `.claude/skills/brainstorming/SKILL.md` |
| `skills/brainstorming/NOTES.md` | `.claude/skills/brainstorming/NOTES.md` |
| `skills/writing-plans/SKILL.md` | `.claude/skills/writing-plans/SKILL.md` |
| `skills/writing-plans/NOTES.md` | `.claude/skills/writing-plans/NOTES.md` |
| `commands/*.md` | `.claude/commands/*.md` (one-for-one) |
| `spec-template.md` | `docs/conventions/spec-template.md` |
| `CLAUDE-md-snippet.md` | merged into `CLAUDE.md` (see merge rules) |

Plus: ensure `.gitignore` contains `.claude/worktrees/`.

Also write (if not already present): `.claude/skills/README.md` with the
team-facing provenance text — ask the user if they want the standard
content (offer to show it) or skip.

## Procedure

Work through these steps in order. Use TodoWrite to track them.

### Step 1 — Announce and verify preconditions

Announce: *"Using `propagate-agent-overrides` skill to sync cross-project
agent overrides into this project."*

Verify preconditions. If any fails, stop and report.

### Step 2 — Survey current state

For each target path above, check:

- Does the file exist?
- If yes, is its content identical to the master? (Use `diff` or `Read`
  both, compare.)

Produce a short table summarizing the state:

```
Path                                            State
.claude/skills/brainstorming/SKILL.md           MISSING | IDENTICAL | DIFFERS
.claude/skills/brainstorming/NOTES.md           ...
.claude/skills/writing-plans/SKILL.md           ...
.claude/skills/writing-plans/NOTES.md           ...
.claude/commands/<each master command>          MISSING | IDENTICAL | DIFFERS
docs/conventions/spec-template.md               ...
CLAUDE.md snippet                               ABSENT | PRESENT-IDENTICAL | PRESENT-DIFFERS
.gitignore .claude/worktrees/ entry             ABSENT | PRESENT
```

For commands, iterate over every `*.md` file in the masters' `commands/`
directory and add one row per file to the survey. This keeps the skill
future-proof as more commands are added to the masters.

Show this table to the user.

### Step 3 — Handle CLAUDE.md snippet merge

This is the trickiest step. The CLAUDE.md snippet begins with
`# Standing workflow preferences for superpowers skills`.

- **ABSENT**: plan to append the snippet. Precede with `\n---\n\n` if the
  existing CLAUDE.md does not already end with a `---` separator.
- **PRESENT-IDENTICAL**: no action; skip.
- **PRESENT-DIFFERS**: show the user the diff between existing and master.
  Ask how to resolve:
  1. Replace existing with master.
  2. Keep existing (skip this project's snippet).
  3. Let the user hand-merge — show both versions, stop here for this file
     only, continue with the other files.

Never silently overwrite a differing CLAUDE.md section.

### Step 4 — Plan file writes

Based on the survey, build a plan of the writes that will happen:

- Missing files → create with master content.
- Differing files → overwrite with master content (skills, commands, and
  spec-template are expected to be kept in sync with masters, so this is
  safe; they are not meant to be project-customized).
- CLAUDE.md → append/replace/skip per Step 3.
- `.gitignore` → add line if missing.

Show the user the plan as a bulleted list. Ask them to approve before any
writes. If they ask for changes, adjust and re-present.

### Step 5 — Write the files

On approval, write each file in the plan. Use the Write tool for full-file
overwrites (skills, spec-template, new NOTES.md) and Edit for `.gitignore`
and CLAUDE.md surgical insertion.

If `.claude/skills/README.md` does not exist, ask the user whether to
create it with the standard team-facing provenance text. If yes, offer the
content below as a default, let them adjust:

> (standard `.claude/skills/README.md` text explaining what's vendored and
> how to re-sync — see feather-etl's copy for the canonical version.)

### Step 6 — Final summary

- Run `git status --short` (via Bash) to show what changed.
- Suggest the commit message:
  `chore(agents): adopt cross-project agent overrides`
- Remind the user to review `git diff --cached` before committing.
- Do NOT run `git add`, `git commit`, or `git push`. The user drives the
  commit.

## Edge cases

- **Non-Python project**: the spec template is still useful; copy it. But
  if the project has no `docs/` directory, ask whether to create one or
  pick a different location (e.g., `conventions/spec-template.md` at root).
- **Project with its own CLAUDE.md workflow preferences block that is
  clearly intentional and different** — respect it. Offer option 2 (skip)
  or 3 (hand-merge).
- **Project using a different branch-naming convention** — the snippet
  hard-codes `feature/<slug>`. If the project uses `feat/`, `siraj/feat-`,
  or ticket prefixes, flag that mismatch. The user may want to hand-edit
  the snippet after the propagation.
- **No `.gitignore` at all** — create one with just the `.claude/worktrees/`
  entry, and flag to the user that the project had no gitignore.

## What the skill must NEVER do

- Commit or push.
- Delete any file.
- Modify any file outside the target paths listed above.
- Skip the user-review gate in Step 4.
- Fetch from the internet or re-download masters (they live on disk).

## Source of truth

- Masters: `~/Dropbox/Siraj/Projects/siraj-claude-vault/cross-project/agent-overrides/`
- Skill: `~/.claude/skills/propagate-agent-overrides/SKILL.md` (this file)
- Canonical example of a fully-propagated project:
  `~/Desktop/NonDropBoxProjects/feather-etl/`
