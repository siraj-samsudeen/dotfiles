---
name: github-issue-as-chronological-history
description: "When filing an issue retroactively, reconstruct the work as dated comments that read as if logged live"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: adf8a418-c94b-4f66-b9a3-99330d3fafe1
---

When filing a GitHub issue for work that has already happened, don't just write a single summary. Create the issue with the **plan** as the body, then post **dated comments** that reconstruct the actual chronology — build milestones, blockers, bugs found, fixes, results — as if each had been logged when it occurred.

**Why:** the user wants the issue thread to be a faithful track record. Issues, comments, and the bugs hit along the way should "flow as history as if we had done it as it happened," even when filed all at once afterward. A flat summary loses the story; the dated-comment sequence preserves it.

**How to apply:** issue body = goal + approach + success criteria. Then one comment per milestone/discovery, each led by an absolute date (`**2026-05-20 — ...**`), in the order events actually occurred. Post via `gh issue comment --body-file`. GitHub can't backdate comments, so the date prefix in the text carries the chronology. Builds on [[post-to-github-not-local]].
