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
gitignored resources (`.venv`, `rill/.env`, `secrets/`) by **absolute path**, don't `cd` into main.
Before "commit/merge/push", run `git worktree list` + `git branch --contains <sha>` to confirm where
HEAD and your commits actually are. Never force-move `main` while another agent is active on the shared
checkout. Related: [[feedback_worktree_file_links_resolve_main_root]], [[project-reference-data-teable-307]].
