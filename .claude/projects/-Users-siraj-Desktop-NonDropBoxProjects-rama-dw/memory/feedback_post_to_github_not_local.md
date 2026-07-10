---
name: feedback-post-to-github-not-local
description: "When drafting GitHub issues / PR descriptions, post directly to GitHub via gh — don't maintain markdown drafts in the local repo"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 163eab0a-8362-4548-90a6-6d1e8480a688
---

When asked to draft GitHub issues, sub-issues, or PR descriptions, **post them directly to GitHub via `gh issue create` / `gh pr create`** instead of writing a markdown file in the repo for "review first."

**Why:** User said "Rather than writing these issue drafts here in MD, you should post them in the right issue in GitHub and not maintain anything locally." Local drafts become stale shadow copies — once the GitHub issue exists, that's the source of truth, and a local `docs/issue-drafts.md` is just clutter that diverges. The "draft locally first, then post" workflow doubles the work and creates drift.

**How to apply:**
- When the task is "draft N issues" → write the bodies to `$CLAUDE_JOB_DIR` (ephemeral) and post via `gh issue create --body-file`.
- Capture the issue numbers from the URL output and thread cross-references with a follow-up `gh issue edit` if needed.
- Don't commit issue/PR drafts to the repo as documentation.
- Exception: if the user explicitly asks for a local file (e.g., "save the draft to docs/"), do that — but default to posting.
- Same principle applies to PR descriptions: write to a tempfile, pass via `gh pr create --body-file`.

Related: [[feedback-propose-defaults-dont-gate]] (same conversation — both about not creating friction the user didn't ask for).
