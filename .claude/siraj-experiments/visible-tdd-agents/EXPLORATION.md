# Visible TDD Agents

> **Question:** How can you observe Claude Code subagents doing TDD work in real-time?
> **Status:** In Progress
> **Started:** 2026-02-12
> **Last Updated:** 2026-02-12

---

## Context

When dispatching TDD-based code writing to subagents (via the Task tool), their work is invisible. You give them a task, they disappear into a black box, and you get a summary back. You can't see which tests failed, what the agent tried first, how it reacted to failures, or the red-green-refactor loop playing out. The whole point of TDD is the feedback loop — if you can't observe it, you lose the learning signal and can't course-correct.

---

## Log

### Research: What Claude Code Offers Today

Surveyed all available approaches for subagent visibility:

| Mode | Visibility | Problem |
|---|---|---|
| **Foreground Task tool** | Tool calls stream to terminal | Main agent blocked — can't do anything else |
| **Background Task tool** | None until completion | No live streaming. Known bug: output files can be empty |
| **Agent Teams** (experimental) | Full — split panes, shift+up/down | Best integrated solution but experimental |
| **Tailing output files** | Unreliable | Empty output, no real-time streaming |
| **PostToolUse hooks** | Event-based notifications | Not continuous visibility |
| **Git worktrees + parallel sessions** | Full — separate terminals | Manual but proven. Official docs recommend this |

### Two Approaches Selected for Testing

**Approach 1: Agent Teams with Split Panes** — Best integrated solution. Enable `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`, use tmux split panes, delegate mode (Shift+Tab) keeps lead from implementing. Known limitations: no session resumption, task status lag, one team per session, no nested teams, split panes need tmux/iTerm2.

Biggest TDD risk: file conflict between test and implementation files (tight coupling). Mitigate by one teammate per module.

**Approach 2: Two Separate Terminals** — Zero experimental flags, full visibility, each session resumable independently. Left pane = orchestrator (design, planning, review), right pane = worker (TDD implementation). You are the orchestrator. Tradeoff: manual dispatch vs full control and no file conflict risk.

---

## Findings

Evaluation criteria defined but not yet tested:

1. **TDD visibility** — Can you see every red/green/refactor cycle in real-time?
2. **Context efficiency** — Does the worker session stay lean or bloat?
3. **Handoff friction** — How painful is passing tasks between sessions?
4. **Recovery** — What happens when context fills up mid-TDD?
5. **Token cost** — How much more vs the current opaque approach?
6. **Flow state** — Does coordination overhead break your flow?

---

## Open Questions

- Does the worker session pick up TDD guard hooks from the project?
- Can the orchestrator read files modified by the worker in real-time?
- What happens if both sessions try to git commit simultaneously?
- In Agent Teams, can `TeammateIdle` hook auto-trigger test runs?
- Would a shared `.tdd-status.json` help orchestrator track progress without watching?
- Is Agent Teams delegate mode reliable enough to prevent the lead from coding?

---

## Next Steps

1. Try Approach 1 (Agent Teams) on a small feature with existing test infrastructure
2. Try Approach 2 (Two Terminals) on the same feature for comparison
3. Document results against the 6 evaluation criteria
4. Pick the winner and codify it as a Feather skill or workflow pattern
