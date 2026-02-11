---
name: gsd:create-spec
description: Create EARS spec for a phase
allowed-tools:
  - Read
  - Write
  - Bash
  - AskUserQuestion
---

<objective>
Create an EARS specification for a phase by reading CONTEXT.md and REQUIREMENTS.md, then producing {phase}-SPEC.md in the phase directory.

Requires `quality.specs: true` in config. If not enabled, suggest `/gsd:setup-quality`.
</objective>

<execution_context>
@/Users/siraj/.claude/get-shit-done/workflows/create-spec.md
@/Users/siraj/.claude/get-shit-done/references/ears-spec-format.md
@/Users/siraj/.claude/get-shit-done/templates/spec.md
</execution_context>

<process>
**Follow the create-spec workflow** from `@/Users/siraj/.claude/get-shit-done/workflows/create-spec.md`.

Usage: `/gsd:create-spec {phase_number}`

Example: `/gsd:create-spec 3`
</process>
