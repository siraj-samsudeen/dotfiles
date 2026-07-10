---
name: feedback-worktree-useless-for-untracked-cleanup
description: "Don't use EnterWorktree to clean up files that are untracked in the user's main checkout — the worktree branched from origin/main has none of them, so deletes/edits there are paper exercises."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: d281ad9d-f25a-4c50-8477-1340c0f9e797
---

When a cleanup task involves deleting or editing files that are **untracked** in the user's main checkout (showing as `??` in `git status`, not `M`), do NOT solve the harness's "background-session can't edit shared checkout" constraint by calling `EnterWorktree`. A fresh worktree branches from `origin/main` and shares only the `.git` object DB, not the working directory — so all the untracked target files are absent from the worktree.

**Why:** Hit this 2026-05-13 on rama_dw cleanup-handoff. Entered a worktree to do MD edits + file deletes for a handoff list of 8 PBI JSONs and `docs/powerbi_inventory.md` — all untracked in main. Worktree was empty of every target file. Even copying them in + committing + deleting on the worktree branch would not propagate back to main's working tree, because the originals were never under git's control there. Total dead end.

**How to apply:** Before calling `EnterWorktree` in a background session, run `git status --short` and check whether the files you're about to touch are `M` (tracked, modified — worktree works) or `??` (untracked — worktree is useless). For untracked-file cleanup, the only real options are:
1. Print exact shell commands for the user to run in their main checkout
2. Ask the user to re-invoke as a foreground session (which can edit the shared checkout directly)

Either is fine; pick by task size. Both [[feedback_post_to_github_not_local]]-style "do the durable thing, not the paper-trail thing" applies — don't run a worktree just to look like you did work.
