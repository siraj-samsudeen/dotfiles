---
name: feedback_worktree_sync_reverts_uncommitted
description: "In Claude-desktop cowork worktrees, uncommitted edits get reverted to HEAD within seconds — commit atomically"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 063d2b68-d48d-4a5f-907c-c334ecebb778
---

In the harness-managed auto-handle worktrees (e.g. `.claude/worktrees/quizzical-villani-8b9fdc`),
the Claude **desktop cowork session sync** (feature flags `coworkBranchSession` /
`coworkRemoteSessionSpaces`) periodically resets the working tree to `HEAD`, **silently discarding
uncommitted changes within seconds**. Edit tool reports success, `pytest` even passes, then a later
`grep`/`git status` shows the file back to original and the tree "clean". HEAD and reflog are
untouched — only unstaged working-tree edits vanish. No visible `git reset` process; it is the app,
not a shell command.

**Why:** the sync treats committed state as canonical and drops dirty working-tree edits.

**How to apply:** don't leave edits sitting uncommitted. Apply file changes **and `git add` +
`git commit` in a single Bash invocation** (write the files with a python/sed script, then commit in
the same call) so there is no window for the revert. Committed changes survive the sync. Verified
this session (#345): separate Edit calls were wiped repeatedly; a bundled patch-then-commit stuck.
Relates to [[feedback_worktree_dont_cd_to_main_checkout]].
