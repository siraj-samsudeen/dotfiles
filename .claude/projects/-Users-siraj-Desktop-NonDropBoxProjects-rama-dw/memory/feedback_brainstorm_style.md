---
name: feedback-brainstorm-style
description: User wants question-by-question brainstorming with visuals, not bundled design drafts. Each option must be explained with context. Visual companion is pre-approved.
type: feedback
originSessionId: a63bfde6-ef29-41f0-963c-ae8c21711e0c
---
When brainstorming designs with this user, do NOT try to "stop the question-drip" or batch multiple decisions into one response to move faster. The user explicitly wants:

1. **One option/question at a time, properly contextualized.** Before asking a question, explain what's being decided and why it matters. Never drop them into an unfamiliar sub-topic ("how should we handle the backups?") without first establishing the domain context.
2. **Visuals for visual questions.** Use the browser-based visual companion for UI/layout/mockup tradeoffs — not just text bullets.
3. **Grilling is welcomed.** The user wants to be pushed on each choice, understand every option, and pick the right one deliberately. Do not rush to "enough direction to draft a design."

**Why:** User said explicitly (2026-04-19, curation viewer brainstorm): "no ask me questions and grill me and show me the visuals. it is very important that i understand every option and select the right option." Earlier in the same session they asked "Why are we starting somewhere deep into the woods, like backup tables? I don't even understand what these backup tables are. When you ask for options, can you set the context?"

**How to apply:**
- Before any design question, do a short context paragraph ("what this thing is, why it matters, what's at stake in the choice").
- Prefer visuals (mockups, diagrams, split views) when the answer is visual.
- Resist the urge to bundle decisions or move to spec-writing faster. Spec-writing happens after *every* gray-area question has been individually ground through.
- If the user seems frustrated it is almost always because context was skipped — back up, re-establish the domain, then re-ask.
- **The browser-based visual companion is pre-approved** — don't ask consent each session ("can we set some pref so that i dont have to say yes each time", 2026-04-19). Still decide per-question whether content is truly visual; just skip the permission prompt. (Merged from feedback_visual_companion_auto_accept, 2026-07-10.)

Aligns with [[feedback_grill_batch_all_questions]] (one question at a time, re-affirmed 2026-06-24) and [[feedback_show_examples_before_decision_question]].
