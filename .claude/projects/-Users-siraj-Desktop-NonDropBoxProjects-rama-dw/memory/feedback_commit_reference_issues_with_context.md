---
name: commit-reference-issues-with-context
description: "In commit messages, give each issue reference its own line explaining how the commit relates to that issue"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: adf8a418-c94b-4f66-b9a3-99330d3fafe1
---

When a commit references GitHub issues, don't write a bare `Refs #1, #4, #26` list. Give **each** issue its own line with a sentence explaining how this specific commit relates to that specific issue.

**Why:** the user navigates from the issue to the cross-linked commit. A bare reference tells them nothing; a context line tells them what the commit contributed to *that* issue. This applies even to closed issues — the user still wants the thread to explain the connection.

**How to apply:** in the commit message footer, instead of `Refs #26, #1, #4`, write:
```
Refs #26 - <how the commit relates to #26>
Refs #1 - <how the commit relates to #1>
```
One sentence per issue, concrete about what changed and why it touches that issue. See [[push-after-commit]] — push right after so the cross-links appear on the issues.
