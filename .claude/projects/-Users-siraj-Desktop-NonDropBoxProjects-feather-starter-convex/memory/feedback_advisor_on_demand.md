---
name: On-demand advisor research
description: User wants thorough-evaluator research for specific decisions mid-conversation, not as the default mode
type: feedback
---

Default advisor mode is minimal_decisive (from opinionated vendor_philosophy). But when the user asks for deeper analysis on a specific decision — "research this", "show me pros/cons", "compare options" — escalate to thorough-evaluator behavior for that decision only: spawn advisor-researcher agent, present comparison table with pros/cons and rationale.

**Why:** User is opinionated by default (fast decisions on known territory) but wants full research when facing genuinely unfamiliar or high-stakes decisions. The two modes aren't contradictory — they apply to different decision types.

**How to apply:** During /gsd:discuss-phase or any decision point, if the user signals they want deeper analysis, spawn gsd-advisor-researcher for that specific gray area regardless of the ADVISOR_MODE setting. Resume minimal_decisive for remaining decisions.
