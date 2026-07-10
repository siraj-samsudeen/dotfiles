---
name: feedback_implementation_closeout_loop
description: "Definition of done = code + commit + deploy + update the tracking issue — don't stop at code"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 15843b3a-71fa-449e-817c-ca06df5864ca
---

When implementing a slice, "done" means the **full close-out loop**, not just working code:
**implement → commit → deploy → update the issue.** Don't leave it at code and wait to be asked
for the rest.

**Why:** the user wants each slice fully landed and visible — running where it's supposed to run,
and its status reflected on the tracker — not a pile of uncommitted/undeployed local work.

**How to apply (esp. SAP bronze cycles #83–#86):**
- **Commit** with per-issue context lines ([[feedback_commit_reference_issues_with_context]]).
- **Deploy** to the on-prem box ([[reference_sap_bronze_deploy_box]]) — `ssh_box.py put` (runs from
  src/, no reinstall); verify it imports/runs; wire/refresh the schedule.
- **Update the issue** — a dated status comment + tick the acceptance criteria
  ([[feedback_github_issue_as_history]]); push if the commit closes it ([[feedback_push_after_commit]]).
