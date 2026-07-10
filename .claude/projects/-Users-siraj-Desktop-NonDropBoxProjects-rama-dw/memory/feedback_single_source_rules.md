---
name: feedback_single_source_rules
description: A rule lives in exactly ONE place; every other surface points to it — never restate the same rule in CLAUDE.md + skill + memory
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 33edc05f-159b-461f-a86b-7f2b5fd6e204
---

When a working rule or convention needs to exist in more than one surface (global CLAUDE.md,
a skill file, a memory), **define it fully in exactly one canonical home and make every other
surface a one-line pointer** — never restate the full rule in multiple places.

**Why:** During the 2026-07-10 approval-gate rework, Siraj found the same gate rule fully
restated in three places (global CLAUDE.md §6, the /file-issue skill, and two memories) and
asked: "they all talk about the same thing — why do we need that in three places?" Duplicates
drift independently and each copy has to be hunted down when the rule changes (exactly what that
session had to do).

**How to apply:** Pick the canonical home by audience (per the repo's knowledge-routing rule:
team-facing → repo; personal working style → global CLAUDE.md; per-user context → memory). All
other surfaces get a pointer naming the home ("defined once in global CLAUDE.md §6") plus at most
a one-clause gist where a cold reader needs orientation. When updating a rule, update the home
and verify the pointers still make sense — grep for restatements and collapse them. Caveat to
flag when relevant: a project-repo surface pointing at Siraj's *personal* global file dangles for
teammates' agents; if the team grows, lift the rule into the project repo and re-point.
Related: [[feedback_persist_handgathered_ops_knowledge]].
