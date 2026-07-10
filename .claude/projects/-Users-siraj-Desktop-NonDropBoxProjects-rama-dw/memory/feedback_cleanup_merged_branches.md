---
name: feedback-cleanup-merged-branches
description: "After a feature branch merges, always delete the remote branch and the local branch/worktree"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 160f61dc-474f-4312-8c6c-bbbb654be8f8
---

When a feature branch has merged, **always clean it up** — don't leave it lingering. Default behaviour, no need to ask:

- **Remote feature branch:** `git push origin --delete <branch>` once the PR is merged.
- **Local branch:** delete it too (it'll be merged to `origin/main`, not necessarily to the worktree's base branch, so `git branch -d` may refuse with an advice hint — confirm `git merge-base --is-ancestor <branch> origin/main` then `git branch -D`).
- **Dedicated feature worktree:** remove it as well (`git worktree remove`) once merged.

**Why:** the repo accumulates dozens of stale `claude/*` and `issue-N-*` branches/worktrees across parallel agent sessions; merged ones are pure noise that make it hard to see what's actually in flight.

**How to apply:**
- To delete a local branch that's checked out in the current worktree, first move the worktree off it (`git checkout <base>`), then `-D`.
- **Don't remove the live session's own worktree out from under yourself** — that breaks the running shell. The harness reclaims the session worktree on exit; only proactively remove *other* merged feature worktrees.
- Only touch branches/worktrees that are merged and yours — don't delete another active session's in-flight branch. See [[reference-rama-dw-local-dbt]] and the parallel-agents worktree convention.
