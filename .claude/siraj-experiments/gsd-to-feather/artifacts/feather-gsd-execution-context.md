# Feather-GSD Integration: Execution Context

This file provides context for executing the integration plan. Start here when resuming work.

## Key Files

| File | Purpose |
|------|---------|
| `feather-gsd-comparison.md` | Comparison document for GSD creator — shows what Feather brings |
| `feather-gsd-integration-plan.md` | 10-phase implementation plan with all files listed |
| This file | Execution context and critical references |

## Repositories & Paths

- **GSD fork (target):** `/Users/siraj/Desktop/NonDropBoxProjects/feather-gsd/`
- **Feather skills (source):** `/Users/siraj/.claude/skills/` (to be deleted after integration)
- **Experiments:** `/Users/siraj/.claude/siraj-experiments/`

## GSD Fork Structure

```
feather-gsd/
  agents/                    # Agent definitions (markdown prompts)
    gsd-executor.md          # Most impacted — TDD tiers, two-stage review
    gsd-planner.md           # Spec-aware planning
    gsd-verifier.md          # Coverage verification
    gsd-*.md                 # 8 other existing agents
  commands/gsd/              # Slash commands (YAML+markdown)
  get-shit-done/
    bin/gsd-tools.js         # CLI utility — config loading, state mgmt
    workflows/               # Orchestration workflows
    templates/               # Document templates (config.json, plan.md, etc.)
    references/              # Philosophy & pattern docs
  hooks/                     # Claude Code hooks (dist/ has built versions)
```

## Feather Skills to Adapt (Source Material)

These skills contain the logic to port into GSD's structure:

| Skill | Adapt Into | Key File |
|-------|-----------|----------|
| `feather:setup-tdd-guard` | `workflows/setup-tdd-hooks.md` | `~/.claude/skills/feather:setup-tdd-guard/SKILL.md` |
| `feather:create-spec` | `workflows/create-spec.md` + `references/ears-spec-format.md` | `~/.claude/skills/feather:create-spec/SKILL.md` |
| `feather:derive-tests` | `agents/gsd-test-deriver.md` + `workflows/derive-tests.md` | `~/.claude/skills/feather:derive-tests/SKILL.md` |
| `feather:write-tests` | `references/quality-enforcement.md` (TDD section) | `~/.claude/skills/feather:write-tests/SKILL.md` |
| `feather:execute` | `agents/gsd-spec-reviewer.md` + `agents/gsd-code-reviewer.md` | `~/.claude/skills/feather:execute/` (has 3 prompt files) |
| `feather:verify` | `workflows/verify-work.md` modifications + feedback templates | `~/.claude/skills/feather:verify/SKILL.md` |
| `feather:create-ui-mockup` | `workflows/create-mockup.md` | `~/.claude/skills/feather:create-ui-mockup/SKILL.md` |
| `feather:polish` | `workflows/polish.md` | `~/.claude/skills/feather:polish/SKILL.md` |
| `feather:create-issue` | `workflows/feedback.md` (add action) | `~/.claude/skills/feather:create-issue/SKILL.md` |

## Critical GSD Files to Read Before Each Phase

### Phase 1 (Config Foundation)
- `get-shit-done/templates/config.json` — current config schema
- `get-shit-done/bin/gsd-tools.js` — `loadConfig()` (~line 157), `cmdConfigEnsureSection()` (~line 571), init functions (~line 3620+)

### Phase 2 (Settings)
- `get-shit-done/workflows/settings.md` — current settings workflow

### Phase 3 (EARS Specs)
- `get-shit-done/workflows/discuss-phase.md` — where to inject design exploration
- `~/.claude/skills/feather:create-spec/SKILL.md` — source EARS format

### Phase 4 (Gherkin)
- `~/.claude/skills/feather:derive-tests/SKILL.md` — source Gherkin derivation logic
- `get-shit-done/workflows/plan-phase.md` — where to inject derivation

### Phase 5 (Planner)
- `agents/gsd-planner.md` — current planner, find `<task_breakdown>` section

### Phase 6 (TDD Tiers)
- `agents/gsd-executor.md` — current executor, find `<tdd_execution>` section (~line 227)
- `~/.claude/skills/feather:setup-tdd-guard/SKILL.md` — hook configuration details
- `get-shit-done/workflows/execute-phase.md` — executor spawning

### Phase 7 (Two-Stage Review)
- `~/.claude/skills/feather:execute/spec-reviewer-prompt.md` — source spec reviewer
- `~/.claude/skills/feather:execute/code-quality-reviewer-prompt.md` — source code reviewer

### Phase 8 (Feedback)
- `~/.claude/skills/feather:verify/SKILL.md` — feedback file format
- `~/.claude/skills/feather:polish/SKILL.md` — polish workflow
- `get-shit-done/workflows/verify-work.md` — where to inject feedback saving

### Phase 9 (Mockups)
- `~/.claude/skills/feather:create-ui-mockup/SKILL.md` — mockup process

### Phase 10 (Checkpoints)
- `get-shit-done/workflows/plan-phase.md` — CP1 insertion point
- `get-shit-done/workflows/execute-phase.md` — CP2 insertion point

## User's Goals (from conversation)

1. **feather-gsd = single distributable framework** replacing both Feather skills and upstream GSD
2. **Delete all local skills after** — `~/.claude/skills/feather:*` goes away
3. **Share with team/clients** via GSD's install mechanism
4. **PR to GSD creator** — upstream-worthy parts as PR, opinionated parts stay in fork
5. **TDD mode is configurable** — off/basic/full (user's explicit request)

## Implementation Order

Execute phases 1-10 sequentially. Each phase is independently useful and verifiable. Start with Phase 1 (config foundation) since everything else depends on it.
