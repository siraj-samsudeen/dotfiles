# Superpowers to Feather Transition

> **Question:** What was wrong with Superpowers and how should it be replaced?
> **Status:** Complete
> **Started:** 2026-02-10
> **Last Updated:** 2026-02-10

---

## Context

Superpowers (v4.1.1) by Jesse Vincent was a Claude Code plugin providing 14 skills for AI-native development — planning, TDD, code review, debugging, git workflows. Adopted early in the Claude Code journey via `superpowers-marketplace` (MIT license, https://github.com/obra/superpowers).

The 14 skills covered brainstorming, parallel agents, plan execution, branch finishing, code review (send/receive), subagent-driven development, systematic debugging, TDD, git worktrees, verification, plan writing, and skill writing.

---

## Log

Performed process analysis on projects built with Superpowers (notably `todo_convex`). Found four systemic failures:

1. **Plans embedded 2600+ lines of code** — design docs became implementation-heavy, specifying exact React components instead of behavior. Defeated the purpose of planning.
2. **TDD claimed but not practiced** — the TDD skill existed but projects had no backend test infrastructure. Only shallow component rendering tests.
3. **Tests passed but features broken** — "tests pass" became the verification criteria instead of "feature works for the user."
4. **Verification was superficial** — checked "did tasks complete" not "does the feature work end-to-end."

Root causes: design docs specified code not behavior, no backend test setup (Convex testing missing), component tests didn't verify features, plans specified implementation not outcomes.

---

## Findings

### The Fix: Feather Skills

Created a custom skill set addressing each root cause:
- **EARS syntax** for requirements (Event, Action, Response, State)
- **User-level abstraction** — specs describe what users experience, not what code does
- **Single source of truth** — the spec IS the plan
- **TDD guard hooks** — pre-commit hooks that block commits without tests
- **Verification against spec** — check "does feature work" not "did tasks complete"

### Mapping: Superpowers → Feather

| Superpowers Skill | Feather Replacement | Notes |
|-------------------|-------------------|-------|
| brainstorming | — | No direct equivalent yet |
| dispatching-parallel-agents | — | Claude Code handles natively now |
| executing-plans | `feather:execute` | Executes against spec, not code-heavy plan |
| finishing-a-development-branch | `feather:finish` | Branch cleanup with verification |
| receiving-code-review | `receive-review` | Standalone skill |
| requesting-code-review | `request-review` | Standalone skill |
| subagent-driven-development | `feather:work-slice` | Slice-based development |
| systematic-debugging | `debug-issue` | Standalone skill |
| test-driven-development | `feather:write-tests` + `feather:setup-tdd-guard` | Split into writing and enforcement |
| using-git-worktrees | `feather:isolate-work` | Git worktree management |
| using-superpowers | `feather:help` + `feather:workflow` | Help and workflow overview |
| verification-before-completion | `feather:verify` | Verifies against spec, not task list |
| writing-plans | `feather:create-plan` + `feather:create-spec` | Split into planning and spec |
| writing-skills | — | Covered by CLAUDE.md instructions |

### Verdict

Superpowers' main value was establishing that skills/workflows matter. But it was too code-heavy in planning and didn't enforce TDD — it only described it. Feather shifts from "plan the code" to "specify the behavior" and adds automated guardrails.

---

## Artifacts

All 14 original Superpowers skills preserved in `superpowers-skills-snapshot/` with full content.

---

## Next Steps

None — transition complete. Superpowers removed, Feather active.
