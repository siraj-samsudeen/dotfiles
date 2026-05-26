---
name: feedback-pilot-commits-first
description: "For bulk rewrites or refactors that span many sibling sections (tasks.md commits, spec requirements, etc.), apply to only the first 1-2 items first so the user can validate the shape before scaling"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: dc520ce9-5b79-403b-945f-fc3abc490139
---

When applying a new shape across many sibling sections of a file (e.g., rewriting every commit block in tasks.md, every requirement in spec.md, every test in a suite), **always apply to just commits 1 and 2 first** — or the equivalent first two items — then pause and wait for the user to read them in the editor and confirm.

**Why:** Lets the user validate the shape on a small sample (fast turnaround, low cost to revise) before paying the full rewrite cost. Catches "this works in the abstract but feels wrong in concrete form" early. Also surfaces edge cases that only show up in real data (e.g., a commit with no spec scenarios, a section that doesn't fit the template).

**How to apply:** When a user says "rewrite tasks.md in this shape" or "apply this format across the spec," do not produce the full rewrite in one go. Instead:
1. Apply the new shape to items 1 and 2 only.
2. Leave items 3+ unchanged (mixed state is fine for a review pass).
3. Pause and ask for explicit go-ahead before scaling.

**Related:** [[feedback-one-block-at-a-time]] (long reviews/critiques presented ≤1-page at a time) is the same principle for review output; this is the implementation-side counterpart.
