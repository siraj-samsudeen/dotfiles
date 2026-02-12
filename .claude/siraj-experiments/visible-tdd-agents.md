# Visible TDD Agents: Watching Subagent Work in Real-Time

**Purpose:** Find a way to observe Claude Code subagents doing TDD work — see every test failure, every fix attempt, the full red-green-refactor loop — instead of getting back an opaque final result.

**Status:** Two approaches selected for hands-on testing

**Date:** 2026-02-12

---

## The Question

When dispatching TDD-based code writing to subagents (via the Task tool), their work is invisible. You give them a task, they disappear into a black box, and you get a summary back. You can't see:

- Which tests failed and why
- What the agent tried first
- How it reacted to failures
- The red-green-refactor loop playing out
- Mistakes caught by TDD guard and recovery strategies

The whole point of TDD is the feedback loop. If you can't observe it, you lose the learning signal and can't course-correct.

---

## Research: What Claude Code Offers Today

### Task Tool Subagents (current approach)

| Mode | Visibility | Problem |
|---|---|---|
| **Foreground** (`run_in_background: false`) | Tool calls stream to terminal | Main agent is blocked waiting — can't do anything else |
| **Background** (`run_in_background: true`) | None until completion | No live streaming. Known bug where output files can be empty (0 bytes). Only get final result via `TaskOutput` |

Neither gives intermediate TDD cycle visibility.

**Docs:** [Create custom subagents](https://docs.anthropic.com/en/docs/claude-code/sub-agents)

### Agent Teams (experimental)

A fundamentally different model. Instead of subagents that report back to a parent, Agent Teams are **independent Claude Code sessions** that coordinate via a shared task list and messaging system.

Key capabilities:
- **In-process mode**: All teammates in one terminal. **Shift+Up/Down** to cycle between them and see live output
- **Split-pane mode**: Each teammate gets its own tmux/iTerm2 pane. See everyone simultaneously
- **Delegate mode** (Shift+Tab): Restricts the lead to coordination-only — won't start implementing itself
- **Plan approval**: Can require teammates to plan before implementing
- **Shared task list**: Tasks with dependencies, self-claiming, file locking for race conditions
- **Direct messaging**: Talk to any teammate directly, not just through the lead
- **Quality hooks**: `TeammateIdle` and `TaskCompleted` hooks for enforcement

**Docs:** [Orchestrate teams of Claude Code sessions](https://docs.anthropic.com/en/docs/claude-code/agent-teams)

### Other Options Explored

| Approach | Verdict |
|---|---|
| **Tailing background agent output files** | Unreliable — output can be empty, no real-time streaming even when it works |
| **Hooks for notifications** | `PostToolUse` hooks can notify on events, but only event-based — not continuous visibility |
| **Git worktrees + parallel sessions** | Official docs recommend this for parallel work. Manual but proven. Docs: [Run parallel sessions with git worktrees](https://docs.anthropic.com/en/docs/claude-code/common-workflows) |

### Related: Guard Against Recursive Launch (v2.1.39)

Claude Code 2.1.39 added a guard against launching Claude Code inside itself — relevant because the two-terminal approach intentionally runs separate instances (not nested), which is fine. The guard only blocks a `claude` command *inside* an existing Claude Code Bash tool call.

**Docs:** [Changelog](https://docs.anthropic.com/en/docs/claude-code/changelog)

---

## Decision: Two Approaches to Try

### Approach 1: Agent Teams with Split Panes

**Why try it:** Best integrated solution. Real-time visibility with coordination built in. Delegate mode keeps the lead from doing implementation work. Split panes let you watch multiple TDD loops simultaneously.

**Enable:**
```json
// settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "teammateMode": "tmux"
}
```

**Usage:**
```
Create an agent team. Spawn one developer teammate.
Have them implement the login feature using strict TDD against tests in src/auth/__tests__/.
Require plan approval before they start implementing.
```

Then use **Shift+Tab** for delegate mode so the lead only coordinates.

**Known Limitations:**
- **No session resumption**: `/resume` and `/rewind` don't restore in-process teammates. After resuming, the lead tries to message dead teammates. Must spawn new ones
- **Task status can lag**: Teammates sometimes forget to mark tasks done, blocking dependent tasks
- **One team per session**: Must clean up before starting another
- **No nested teams**: Teammates can't spawn their own teams
- **Lead is fixed**: Can't promote a teammate or transfer leadership
- **Permissions locked at spawn**: All teammates inherit the lead's permission mode
- **Shutdown is slow**: Teammates finish current tool call before stopping
- **Lead goes rogue**: Sometimes starts implementing instead of delegating (use delegate mode to prevent)
- **File conflicts**: Two teammates editing the same file = overwrites. Must partition files
- **Split panes need tmux or iTerm2**: Won't work in VS Code terminal, Windows Terminal, or Ghostty
- **Token cost**: Each teammate has its own full context window. Scales linearly with team size

**Biggest risk for TDD:** File conflict between test files and implementation files — TDD has tight coupling between them. Mitigate by having only one teammate do TDD per module.

---

### Approach 2: Two Separate Terminals

**Why try it:** Zero experimental flags, full visibility, each session resumable independently, no coordination overhead. You are the orchestrator.

**Setup:**
```bash
# tmux split (recommended)
tmux split-window -h
# Left pane: orchestrator session (design, planning, review)
# Right pane: worker session (TDD implementation)
```

**Workflow:**
```
Terminal 1 (orchestrator)     Terminal 2 (worker)
─────────────────────────     ─────────────────────
Write spec / tests       →
                               Run TDD loop (you watch live)
                               RED → GREEN → REFACTOR
                               ...see every mistake, every fix...
Review the output        ←     Done
Give next task           →
                               Run TDD loop again
```

**Worker launch options:**

Interactive (can steer mid-task):
```bash
claude
# Then paste: "Implement X using strict TDD. Tests are in path/to/tests.
# Run tests first, see failures, write minimal code, repeat until green."
```

Headless (fire and watch):
```bash
claude -p "Implement X using strict TDD against tests in path/to/tests.
Run tests first, see failures, write minimal code, repeat until green."
```

**Tradeoffs:**

| Pro | Con |
|---|---|
| Full TDD loop visibility | Manual orchestration — you dispatch tasks |
| No experimental features | No programmatic task handoff between sessions |
| Each session resumable independently | You copy/paste tasks between terminals |
| Context isolation by default | No shared task list or messaging |
| Zero extra token overhead | Requires terminal management |
| No file conflict risk (one writer at a time) | Can't parallelize across modules easily |

---

## Evaluation Criteria

After trying both, compare on:

1. **TDD visibility** — Can you see every red/green/refactor cycle in real-time?
2. **Context efficiency** — Does the worker session stay lean or bloat?
3. **Handoff friction** — How painful is passing tasks from orchestrator to worker?
4. **Recovery** — What happens when context fills up mid-TDD? Can you resume?
5. **Token cost** — How much more do you burn vs the current opaque subagent approach?
6. **Flow state** — Does the approach let you stay in flow or does coordination overhead break it?

---

## Open Questions

- [ ] Does the worker session pick up TDD guard hooks from the project? (Should — it reads project settings)
- [ ] Can the orchestrator session read files modified by the worker in real-time? (Should — same filesystem)
- [ ] What happens if both sessions try to git commit simultaneously? (Likely lock conflict — serialize commits)
- [ ] In Agent Teams, can you use `TeammateIdle` hook to auto-trigger test runs?
- [ ] Would a shared file like `.tdd-status.json` help the orchestrator track progress without watching?
- [ ] For Agent Teams, is delegate mode reliable enough to prevent the lead from coding?
