---
name: openspec-siraj-flow-is-canonical
description: openspec-siraj-flow skill is the canonical home for all OpenSpec spec/tasks/numbering/title/cross-ref conventions; openspec/config.yaml and openspec/conventions.md were deleted as redundant
metadata: 
  node_type: memory
  type: feedback
  originSessionId: dd462900-b339-4f99-8921-6a4ea51232c9
---

The canonical home for all openspec-siraj convention content is the **`openspec-siraj-flow` SKILL** at `~/.claude/skills/openspec-siraj-flow/SKILL.md`. It carries the full pipeline diagram, the artifact-tree convention, requirement/scenario numbering, scenario title shape, cross-file reference scheme, renumbering protocol, and the `tasks.md` six-section commit-block shape. Per-commit plan shape lives in `openspec-siraj-create-plan/SKILL.md` (canonical).

**Why this changed (2026-05-25 session):**
- Conventions used to live in three places — `openspec/conventions.md`, `openspec/config.yaml`'s `rules:` block, and scattered inside individual SKILL.md files. Three homes = guaranteed drift, and that drift was empirically demonstrated (the plan-file shape conflict between create-plan SKILL.md and conventions.md).
- Skills are cross-project; project-local files force every new OpenSpec project to either copy the conventions or drift independently.
- Folding the universal parts into skills means new OpenSpec projects work zero-config: install the siraj skills, conventions inherit automatically.

**What got deleted in feather-etl:**
- `openspec/conventions.md` — fully redundant after fold.
- `openspec/config.yaml` — `schema: spec-driven` is the openspec CLI default; `openspec validate` and `openspec new change` work without the file. The `rules:` block was duplicated content from conventions.md.

**How to apply:**
- Before drafting any OpenSpec artifact (spec.md, tasks.md, plan files), the canonical shape lives in `openspec-siraj-flow` (or `openspec-siraj-create-plan` for per-commit plans). Sub-skills like `openspec-siraj-create-design` carry only their own procedure + a "Where this fits" pointer back to the orchestrator.
- When the user gives new feedback that should apply across all future OpenSpec work, the right home is the relevant skill's SKILL.md — NOT project-local files, NOT chat memory.
- Cross-project principles still belong in `~/Dropbox/Siraj/Projects/siraj-claude-vault/cross-project/principles/`.

**Caveat about `openspec update`:** the openspec CLI will recreate `openspec/config.yaml` and the `opsx/` command folder on each `openspec update` run. Delete the regenerated config.yaml and rename `opsx/` → `openspec-siraj/` afterward. Tracked as a known regeneration chore.

Supersedes the previous `openspec_config_is_canonical.md` entry (2026-05-18), which is now stale.
