---
name: feedback_show_examples_before_decision_question
description: "When asking Siraj to decide between options, show concrete worked examples first so he can form a mental model"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 2ccf3111-77fc-466e-a145-e5782301dc3f
---

When posing a decision question (A/B/C), **show a few concrete worked examples first** — real
numbers from the actual data, a small table contrasting how each option plays out — *then* ask.
Siraj decides from a mental model, not from abstract option descriptions.

**Why:** "Whenever you ask a question like this, I think you need to show me a few examples so that
I have a clear mental model and the examples would help me to decide one way or the other, and then
ask a question." (2026-07-08, during the #458 P&L-budget phasing grill — I asked A/B/C on monthly
phasing abstractly; he asked for examples. A KAT store table showing RB's ₹368 L May budget vs our
₹335 L phased estimate, and rent staying flat ₹6 L/month vs sales-curved, made the trade-off obvious.)

**How to apply:** In the grill/AskUserQuestion flow, before the question, build a compact example
grid from the real files/warehouse: pick one concrete entity, show 2-3 rows that behave differently,
and let the divergence between options be *visible* in numbers. Pairs with [[feedback_grill_question_format]]
(one keystroke) and [[feedback_grill_batch_all_questions]] (one at a time). Especially important for
modeling trade-offs where the naive option looks fine until you see a number that breaks it.
