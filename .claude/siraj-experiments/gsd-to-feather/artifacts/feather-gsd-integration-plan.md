# Plan: Integrate Feather Quality Enforcement into GSD Fork

## Context

**Problem:** GSD orchestrates reliable AI execution at scale (research, planning, parallel execution, verification) but has no quality enforcement layer. Code can pass GSD verification with zero tests, no coverage, self-reviewed by the same agent that wrote it, and feedback captured as unstructured prose.

**Solution:** Bring Feather's 12 quality capabilities into the GSD framework structure — as agents, commands, workflows, templates, and references. The result is a single distributable framework (feather-gsd) that replaces both standalone Feather skills AND upstream GSD.

**Goals:**
1. feather-gsd becomes self-contained — no dependency on `~/.claude/skills/`
2. Distributable to team members and clients via GSD's existing install mechanism
3. All Feather features gated by config — existing GSD users see no change
4. Clean separation: upstream-worthy core vs fork-only extras

**Key files in the fork:** `/Users/siraj/Desktop/NonDropBoxProjects/feather-gsd/`

---

## Design Decisions

### D1: Artifacts live in GSD's `.planning/phases/` structure
Feather puts specs in `docs/specs/<feature>/`. GSD puts everything in `.planning/phases/XX-name/`. We use GSD's convention: `{phase}-SPEC.md`, `{phase}-GHERKIN.md` sit alongside `CONTEXT.md` and `RESEARCH.md`. Single source of truth.

### D2: `.feedback/` lives at project root
Feedback spans phases and persists across the project lifecycle. Like `.planning/`, it sits at project root. Not inside any phase directory.

### D3: Config is additive — all quality features default to off
No existing config needs migration. `loadConfig()` uses defaults for missing values. Users who never touch quality config see zero behavioral change.

### D4: TDD is a three-tier option
- `off` — no enforcement (GSD default)
- `basic` — GSD's existing `tdd="true"` prompt-based RED-GREEN cycle
- `full` — Feather's hook-based enforcement (blocks writes, coverage gates, read-only test contract)

### D5: Gherkin review is always a gate
Even in yolo mode, Gherkin scenarios are presented for user approval before implementation. The test contract is non-negotiable because it defines what "done" means.

### D6: PR-worthy vs fork-only separation
- **PR-worthy (upstream):** Config extension, executor TDD tiers, spec-aware planning, structured feedback, quality checkpoints, traceability chain
- **Fork-only (opinionated):** 100% coverage default, full-stack-only test strategy, HTML mockups via Playwright, design exploration with 2-3 approaches

---

## Implementation Phases

### Phase 1: Config Foundation
*Enables everything else. Zero behavioral change.*

**Modify:**
- `get-shit-done/templates/config.json` — Add `quality` section with all feature flags
- `get-shit-done/bin/gsd-tools.js` — `loadConfig()` parses quality config; `cmdConfigEnsureSection()` adds defaults; all `init` functions include `quality_*` fields in return JSON; add MODEL_PROFILES entries for new agents
- `get-shit-done/references/planning-config.md` — Document quality config options

**New config schema:**
```json
"quality": {
  "tdd_mode": "off",
  "specs": false,
  "two_stage_review": false,
  "feedback": false,
  "mockups": false,
  "design_exploration": false,
  "checkpoints": false,
  "coverage_threshold": 100
}
```

**Verify:** `gsd-tools.js state load` returns quality config. Existing projects unchanged.

---

### Phase 2: Settings & Setup Commands
*Users can configure quality features interactively.*

**New files:**
- `commands/gsd/setup-quality.md` — Interactive quality config (presets: minimal/standard/full)
- `commands/gsd/setup-tdd-hooks.md` — Install TDD enforcement hooks (only for `tdd_mode: "full"`)
- `get-shit-done/workflows/setup-quality.md` — Quality config workflow
- `get-shit-done/workflows/setup-tdd-hooks.md` — Hook installation (adapted from `feather:setup-tdd-guard`)

**Modify:**
- `get-shit-done/workflows/settings.md` — Add quality mode question to `/gsd:settings`
- `get-shit-done/workflows/new-project.md` — Offer quality setup during project init

**Verify:** `/gsd:settings` shows quality option. `/gsd:setup-quality --full` enables everything.

---

### Phase 3: EARS Specs + Design Exploration
*Lightweight specs replace/supplement REQUIREMENTS.md at phase level.*

**New files:**
- `get-shit-done/references/ears-spec-format.md` — EARS syntax reference (WHEN/WHILE/IF-THEN/Ubiquitous/WHERE patterns, ID conventions, example tables, anti-patterns)
- `get-shit-done/templates/spec.md` — EARS spec template using GSD frontmatter
- `commands/gsd/create-spec.md` — Create EARS spec for a phase
- `get-shit-done/workflows/create-spec.md` — Spec creation workflow (reads CONTEXT.md, outputs `{phase}-SPEC.md`)

**Modify:**
- `get-shit-done/workflows/discuss-phase.md`:
  - When `quality.design_exploration`: present 2-3 approaches with trade-offs before locking decisions
  - When `quality.specs`: suggest `/gsd:create-spec` after writing CONTEXT.md
  - When `quality.mockups`: offer `/gsd:mockup`

**Output:** `.planning/phases/XX-name/{phase}-SPEC.md`

**Verify:** `/gsd:create-spec 3` produces EARS spec in phase directory.

---

### Phase 4: Gherkin Derivation + Traceability
*Specs expand into test scenarios with IDs for tracing.*

**New files:**
- `agents/gsd-test-deriver.md` — Agent that expands EARS specs into Gherkin (adapted from `feather:derive-tests`)
- `get-shit-done/templates/gherkin.md` — Gherkin template with scenario IDs and seed data
- `commands/gsd/derive-tests.md` — Gherkin derivation command
- `get-shit-done/workflows/derive-tests.md` — Spawns gsd-test-deriver, presents for user review (gate)

**Modify:**
- `get-shit-done/workflows/plan-phase.md`:
  - New step after loading CONTEXT: check for SPEC.md and GHERKIN.md
  - If `quality.specs` and SPEC exists but GHERKIN missing: auto-spawn gsd-test-deriver
  - Pass spec + gherkin content to planner prompt

**Output:** `.planning/phases/XX-name/{phase}-GHERKIN.md`

**Verify:** `/gsd:derive-tests 3` expands SPEC into GHERKIN with proper IDs and user approval gate.

---

### Phase 5: Spec-Aware Planning
*Planner references spec IDs; tasks trace to requirements.*

**Modify:**
- `agents/gsd-planner.md`:
  - When `quality.specs`: tasks MUST include `spec_ref="XX-1"` attribute
  - Task `<action>` specifies which EARS criteria it implements
  - Task `<verify>` references Gherkin scenario IDs
  - Test files use Gherkin IDs in describe/it blocks
- `get-shit-done/workflows/plan-phase.md`:
  - When `quality.checkpoints`: add CP1 artifact verification (CONTEXT + SPEC + GHERKIN + PLAN must exist before proceeding)

**Enhanced task XML:**
```xml
<task type="auto" tdd="true" spec_ref="TL-1">
  <name>Task: Implement task creation</name>
  <files>src/features/tasks/create.ts, src/features/tasks/create.test.ts</files>
  <action>Implement TL-1 (Create Task). Test IDs: TL-1.1 through TL-1.5.</action>
  <verify>TL-1.1 through TL-1.5 pass. Coverage >= threshold for create.ts.</verify>
</task>
```

**Verify:** Plans generated with `quality.specs: true` reference spec IDs and Gherkin scenarios.

---

### Phase 6: TDD Enforcement Tiers
*Three-tier TDD from advisory to hook-enforced.*

**Modify:**
- `agents/gsd-executor.md`:
  - Replace `<tdd_execution>` with three-tier version:
    - `off`: advisory, write tests if convenient
    - `basic`: RED-GREEN-REFACTOR cycle (existing behavior)
    - `full`: read-only test contract (can't modify spec-derived tests), coverage gate after GREEN, hook awareness (tdd-guard blocks writes when tests fail), traceability (Gherkin IDs in test blocks)
  - Extract quality config in `<step name="load_project_state">`
- `get-shit-done/workflows/execute-phase.md`:
  - Pass `quality_*` config values to executor context
  - Include `quality-enforcement.md` reference in executor prompt
- `get-shit-done/references/quality-enforcement.md` — Master reference for all quality rules (TDD tiers, read-only contract, coverage gates, full-stack test strategy, traceability chain)

**Verify:** `tdd_mode: "basic"` follows RED-GREEN. `tdd_mode: "full"` blocks writes when tests fail.

---

### Phase 7: Two-Stage Review
*Separate spec compliance and code quality reviewers.*

**New files:**
- `agents/gsd-spec-reviewer.md` — Reviews implementation against EARS spec (adapted from feather:execute/spec-reviewer-prompt.md)
- `agents/gsd-code-reviewer.md` — Reviews code quality after spec compliance passes (adapted from feather:execute/code-quality-reviewer-prompt.md)
- `get-shit-done/references/spec-reviewer-prompt.md` — Reviewer prompt template
- `get-shit-done/references/code-quality-reviewer-prompt.md` — Reviewer prompt template

**Modify:**
- `agents/gsd-executor.md`:
  - Add `<two_stage_review>` section after `<self_check>`
  - When `quality.two_stage_review`: spawn spec-reviewer then code-reviewer after each task
  - Fix issues before committing; re-review until approved

**Model profiles for new agents:**
```
gsd-spec-reviewer:  { quality: 'sonnet', balanced: 'sonnet', budget: 'haiku' }
gsd-code-reviewer:  { quality: 'sonnet', balanced: 'sonnet', budget: 'haiku' }
gsd-test-deriver:   { quality: 'opus',   balanced: 'sonnet', budget: 'sonnet' }
```

**Verify:** With `two_stage_review: true`, executor spawns both reviewers after each task.

---

### Phase 8: Structured Feedback + Polish Queue
*Issues get tracked, prioritized, and worked through systematically.*

**New files:**
- `get-shit-done/templates/feedback-item.md` — Feedback file template (YAML frontmatter: id, type, priority P0-P3, phase, spec group, status)
- `get-shit-done/templates/feedback-index.md` — Dashboard template for `.feedback/INDEX.md`
- `commands/gsd/feedback.md` — Feedback management command (list/add/resolve/dashboard)
- `commands/gsd/polish.md` — Work through polish queue with TDD (no spec/gherkin ceremony)
- `get-shit-done/workflows/feedback.md` — Feedback CRUD workflow
- `get-shit-done/workflows/polish.md` — Polish execution workflow (RED-GREEN per item)

**Modify:**
- `get-shit-done/workflows/verify-work.md`:
  - When `quality.specs`: group verification by spec capability IDs
  - When `quality.feedback`: save all issues to `.feedback/open/` with proper templates
- `agents/gsd-executor.md`:
  - In summary creation: when `quality.feedback`, create feedback files for issues found

**Artifact structure:**
```
.feedback/
  INDEX.md            (auto-generated dashboard)
  open/               (BUG-001-*.md, UX-002-*.md)
  in-progress/
  resolved/
```

**Verify:** `/gsd:feedback list` shows dashboard. `/gsd:polish` works through queue.

---

### Phase 9: UI Mockups
*Quick visual validation before code.*

**New files:**
- `commands/gsd/mockup.md` — Create HTML mockup for a phase
- `get-shit-done/workflows/create-mockup.md` — Mockup workflow (text diagram first, then HTML via Playwright, save to `docs/mockups/`)

**Modify:**
- `get-shit-done/workflows/discuss-phase.md` — When `quality.mockups`: offer `/gsd:mockup` after discussion

**Verify:** `/gsd:mockup 3` renders mockup in Chrome.

---

### Phase 10: Quality Checkpoints
*Gates before and after implementation.*

**Modify:**
- `get-shit-done/workflows/plan-phase.md`:
  - CP1 (before impl): verify all required artifacts exist per config
    - Always: CONTEXT.md, PLAN.md(s)
    - When `quality.specs`: SPEC.md, GHERKIN.md
    - When `quality.mockups`: mockup file
  - Block execution if required artifacts missing
- `get-shit-done/workflows/execute-phase.md`:
  - CP2 (after impl): automated checks (tests, types, lint, build, coverage) + manual verification guide grouped by spec sections + feedback collection

**Verify:** With `quality.checkpoints: true`, plan-phase blocks on missing artifacts. Execute-phase runs full CP2.

---

## Summary: All Files

### Modified (14 existing files)
1. `get-shit-done/templates/config.json`
2. `get-shit-done/bin/gsd-tools.js`
3. `get-shit-done/references/planning-config.md`
4. `agents/gsd-executor.md`
5. `agents/gsd-planner.md`
6. `get-shit-done/workflows/discuss-phase.md`
7. `get-shit-done/workflows/plan-phase.md`
8. `get-shit-done/workflows/execute-phase.md`
9. `get-shit-done/workflows/execute-plan.md`
10. `get-shit-done/workflows/verify-work.md`
11. `get-shit-done/workflows/settings.md`
12. `get-shit-done/workflows/new-project.md`
13. `get-shit-done/references/tdd.md`
14. `CLAUDE.md`

### New (25 files)
**Agents (3):**
1. `agents/gsd-spec-reviewer.md`
2. `agents/gsd-code-reviewer.md`
3. `agents/gsd-test-deriver.md`

**Commands (7):**
4. `commands/gsd/setup-quality.md`
5. `commands/gsd/setup-tdd-hooks.md`
6. `commands/gsd/create-spec.md`
7. `commands/gsd/derive-tests.md`
8. `commands/gsd/mockup.md`
9. `commands/gsd/feedback.md`
10. `commands/gsd/polish.md`

**Workflows (7):**
11. `get-shit-done/workflows/setup-quality.md`
12. `get-shit-done/workflows/setup-tdd-hooks.md`
13. `get-shit-done/workflows/create-spec.md`
14. `get-shit-done/workflows/derive-tests.md`
15. `get-shit-done/workflows/create-mockup.md`
16. `get-shit-done/workflows/feedback.md`
17. `get-shit-done/workflows/polish.md`

**Templates (4):**
18. `get-shit-done/templates/spec.md`
19. `get-shit-done/templates/gherkin.md`
20. `get-shit-done/templates/feedback-item.md`
21. `get-shit-done/templates/feedback-index.md`

**References (4):**
22. `get-shit-done/references/quality-enforcement.md`
23. `get-shit-done/references/ears-spec-format.md`
24. `get-shit-done/references/spec-reviewer-prompt.md`
25. `get-shit-done/references/code-quality-reviewer-prompt.md`

---

## PR Strategy

**For upstream GSD PR (high acceptance probability):**
- Config extension with quality section (non-breaking, additive)
- Three-tier TDD in executor (extends existing `tdd="true"`)
- Structured feedback system (objectively better than prose UAT.md)
- Quality checkpoints (configurable gates)
- Traceability chain concept (spec ID in task XML)

**Fork-only (opinionated, may not fit upstream):**
- EARS spec format (upstream may prefer their own)
- 100% coverage default (upstream may want lower default)
- Full-stack-only test strategy (opinionated)
- HTML mockups via Playwright (requires MCP)
- Design exploration (changes discuss-phase philosophy)
- Two-stage review (adds execution time)

---

## Verification

After each phase, test that:
1. Existing GSD projects with no quality config work identically (regression)
2. New projects with `/gsd:setup-quality --full` get all features
3. Each quality feature can be toggled independently
4. The install mechanism distributes new commands/agents properly
