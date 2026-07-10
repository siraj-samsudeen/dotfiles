---
name: curation requires per-table decisions, not mechanical review defaults
description: When user asks to run feather-curation on newly discovered tables, analyze each table's schema and take a proper classification decision — do not bulk-default to decision=review.
type: feedback
originSessionId: 28857891-4592-41d5-b034-5906f8d2f4dd
---
When the user asks to run the feather-curation skill against newly discovered tables, the expected output is a *proper classification decision per table* (decision, table_type, strategy, alias, timestamp, grain, scd, etc. as appropriate), not a bulk insertion of `decision: "review"` entries.

**Why:** The user explicitly corrected this in the rama_dw project after I merged 710 MySQL tables as raw `review` defaults. Their exact words: "I completely disagree. In fact, I don't want you to do this mechanically. Go through each one and then take a proper decision. That's the job that I have assigned to you." The `decision: "review"` default in the skill is for cases where the agent genuinely cannot classify (ambiguous tables) — not a convenient fallback to avoid analysis.

**How to apply:** When running feather-curation on new tables:
1. Read each table's columns (names + types) from the schema JSON.
2. Apply the classification rubric in the skill (type decision tree, decision-strategy matrix).
3. Take a decision — `include` with strategy/PK/timestamp/alias, or `exclude` with reason, or `review` only when the table is genuinely ambiguous (all-nvarchar, unclear purpose, possible pipeline output).
4. Populate `classification_notes` for any tentative decisions so the user can spot-check.
5. Do not dump hundreds of unclassified tables at once — classify them. The user takes it personally when I shortcut the job.

This overrides the skill's "do not auto-classify without user confirmation" anti-pattern when the user has explicitly asked for classifications.
