---
name: Use generators for new entities
description: Every new entity should be scaffolded via gen:feature first, then customized. Generator output is the starting point for agent customization.
type: feedback
---

Use the Plop generators (from Phase 03.2) to scaffold every new entity before writing custom code. Run gen:feature with a YAML definition, then customize the generated output for domain-specific logic.

**Why:** Each new feature validates the generators. The generator output is the starting point — agents customize from there rather than writing from scratch. This was proven through Phases 4-6 (projects, subtasks, work logs, activity logs) which all used this pattern successfully.

**How to apply:** When building any new feature, include a "Run generator" step as Task 1, followed by customization tasks. The YAML definition captures the entity's data model; customization adds domain-specific mutations, visibility rules, and UI tweaks.

**Generator-vs-customize decision:** For each custom feature, evaluate whether to:
- **A) Add to generator templates first** — if the behavior is reusable across future entities (e.g., ownership enforcement, completion counts). Update templates/feature/*.hbs, then regenerate.
- **B) Customize generated output directly** — if domain-specific to this entity only (e.g., smart time parsing for work logs, subtask promotion).
The executor agent should make this call per-feature.
