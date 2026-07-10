---
name: feedback-no-askuserquestion-when-reading
description: "Don't use AskUserQuestion when the user is reading through proposed content — the modal hides the text behind it"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 477ba4e9-6c3b-4e97-8709-2861f46c46ad
---

When walking the user through proposed issues/drafts/findings one at a time, do NOT use the `AskUserQuestion` tool — its modal UI blocks the user's view of the proposed text above it.

**Why:** User said directly: "dont use askUSerQ - i need to read it and this tool blocks the view". They want to read the proposal *while* deciding on it; the dialog covers it.

**How to apply:** When the response contains content the user needs to review (proposed issue bodies, draft PRs, plan steps, mockup options), end the message with a plain-text prompt asking for the decision and wait for a normal reply. Reserve `AskUserQuestion` for short pure-choice questions where the options stand on their own without referenced content above them.
