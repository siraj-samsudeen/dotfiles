---
name: gsd:derive-tests
description: Expand EARS spec into Gherkin scenarios for user review
allowed-tools:
  - Read
  - Write
  - Bash
  - AskUserQuestion
  - Task
---

<objective>
Derive Gherkin test scenarios from an EARS spec. Spawns gsd-test-deriver agent, presents scenarios for user approval (gate), saves {phase}-GHERKIN.md.

Requires `quality.specs: true` and a {phase}-SPEC.md to exist.
</objective>

<execution_context>
@/Users/siraj/.claude/get-shit-done/workflows/derive-tests.md
</execution_context>

<process>
**Follow the derive-tests workflow** from `@/Users/siraj/.claude/get-shit-done/workflows/derive-tests.md`.

Usage: `/gsd:derive-tests {phase_number}`

Example: `/gsd:derive-tests 3`
</process>
