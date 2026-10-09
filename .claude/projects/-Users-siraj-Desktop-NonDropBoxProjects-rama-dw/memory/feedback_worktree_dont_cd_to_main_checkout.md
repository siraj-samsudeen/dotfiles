---
name: feedback-worktree-dont-cd-to-main-checkout
description: "In a harness worktree, never cd to the main repo path for git — ops hit the shared main checkout and commits land on the wrong branch"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: e4d90a40-8d43-41ab-a38b-b8cc95a3b5a8
---

The harness boots you into a worktree (its own branch + HEAD). If your Bash commands `cd` to the
**main repo path** (`/Users/siraj/Desktop/NonDropBoxProjects/rama_dw`), every git op runs in the
**shared main checkout**, not your worktree — so your commits land on whatever branch main is on, and
another agent sharing that checkout can `git checkout` and move HEAD out from under you.

**Why:** this happened in #307 — I `cd`-ed to the main repo on every command; my plan/CONTEXT commits
landed on local `main` (not my worktree branch), local `main` diverged, and a second agent moved the
checkout. Recovery took a cherry-pick onto fresh `origin/main`.

**How to apply:** stay in the worktree cwd (the harness default) for all git work; reach main's
gitignored resources (`.venv`, `secrets/`) by **absolute path**, don't `cd` into main.
Before "commit/merge/push", run `git worktree list` + `git branch --contains <sha>` to confirm where
HEAD and your commits actually are. Never force-move `main` while another agent is active on the shared
checkout. 
**It is not only git — `cd` into main sends FILE EDITS there too.** #2686 (26-Aug-2026): a probe
needed main's gitignored `rill/.env`, so every Bash call opened with `cd <main>`. Three `docs/`
files were then created/appended **in the main checkout on branch `main`**, while `perl -pi` ran in
the worktree and silently no-op'd — the giveaway was `Can't open <newfile>: No such file`. Recovery:
`cp` the three files into the worktree, `git checkout --` the two modified ones in main, `rm` the
new one, leaving main's other untracked files (another agent's) alone.

**How to apply (extended):** never open a command with `cd <main>` just to read a gitignored
credential — read it by absolute path (`grep '^motherduck_token=' /abs/path/rama_dw/secrets/motherduck.env` — rill/.env is gone, #2627/#2817) and
stay in the worktree cwd. Note the shell's cwd **persists between Bash calls**, so one stray `cd`
silently redirects every later command. After any doc/code edit, `git status --short` in the
worktree: if it shows nothing, you wrote somewhere else.

Related: [[feedback_worktree_file_links_resolve_main_root]], [[project-reference-data-teable-307]].
