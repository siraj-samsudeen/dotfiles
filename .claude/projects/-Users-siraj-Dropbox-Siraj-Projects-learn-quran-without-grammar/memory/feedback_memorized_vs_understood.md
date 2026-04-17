---
name: Memorized vs understood vocabulary
description: LQWG's two axes of "known" are called "memorized" and "understood" — not "recitation fluency" / "meaning comprehension"
type: feedback
originSessionId: d4bcc610-7a4d-412e-b7d8-02a30bfee327
---
**Rule:** In the LQWG project, the two independent axes of "known" are always named **"memorized"** (can recite in Arabic from rote) and **"understood"** (knows what the words mean). Use these terms in prose, schema docs, UI labels, mockups, and any user-facing or design-facing text. Do NOT use the academic pair "recitation fluency / meaning comprehension" — that's the jargon the brainstorms leaked and Siraj corrected.

**Why:** LQWG's core ethos is no-grammar-jargon, plain-English-about-meaning (see `.claude/rules/lesson-content.md`). The project name itself encodes this. Using academic vocabulary in design docs is the same class of error as using "singular / plural / Form X" in a lesson — it slowly degrades the project voice. Correcting early prevents the habit from spreading through code (entity names, field names, screen labels).

**How to apply:**
- Prose: "memorized but not yet understood" · "first thing Hanzala memorized was Juz' 30" · "understanding the words he already says"
- Schema: `studentRecitation` (table capturing memorized surahs) can stay as-is — it's a technical table name. But *describe* it as "memorization claims" in docs and UI.
- UI labels: "My Memorization" page ✓ · "What I understand" could be the inverse screen name if/when we surface an understood-inventory view · dashboard coverage bar = "memorized / understood"
- FSRS / card grading tracks **understood**. `studentRecitation` / "My Memorization" tracks **memorized**. Never conflate.
