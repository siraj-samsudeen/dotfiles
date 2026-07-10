---
name: feedback_worktree_file_links_resolve_main_root
description: "Clickable file links to worktree-only files error (\"couldn't read this file\") — UI resolves relative hrefs against the MAIN project root, not the worktree"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 5ce1b284-9a38-4cb2-a88b-6b2335138942
---

When working in a `git worktree` (e.g. `.claude/worktrees/issue-215-…/`), a markdown link with a
bare repo-relative href like `docs/plans/issue_215_….md` renders as **"Couldn't read this file —
it may have been deleted or moved"** when clicked. The UI resolves the relative href against the
**main project root** (`/Users/siraj/Desktop/NonDropBoxProjects/rama_dw/`), but the file only exists
on the worktree's branch — so the main root has no such path until the branch merges to main.

**Why:** file-link hrefs are always resolved from the main checkout root, regardless of which
worktree authored the file. A file that's committed only on a feature branch in a separate worktree
dir is invisible at the main-root path.

**How to apply:** when referencing a file that currently lives **only in a worktree** (uncommitted
to main / on a feature branch), write the link with the **full worktree-relative path** —
`.claude/worktrees/<handle>/docs/plans/foo.md` — not the bare `docs/plans/foo.md`. Once the branch
merges to main, the bare path works. When unsure, the full worktree path always resolves. Related:
[[feedback_worktree_useless_for_untracked_cleanup]].
