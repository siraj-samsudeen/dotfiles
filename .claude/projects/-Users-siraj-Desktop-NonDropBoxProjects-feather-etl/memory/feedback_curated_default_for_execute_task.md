---
name: feedback-curated-default-for-execute-task
description: openspec-siraj-execute-task defaults to Curated mode (Sonnet+Opus parallel); never silent-pick a winner even under auto-mode
metadata: 
  node_type: memory
  type: feedback
  originSessionId: dd462900-b339-4f99-8921-6a4ea51232c9
---

The default execution mode for `openspec-siraj-execute-task` is **Curated**: Sonnet and Opus run in parallel in isolated git worktrees against the same task, then the user picks a winner from the side-by-side comparison. Auto-mode (system reminder "Work without stopping for clarifying questions") does NOT override this — Curated stays the default, AND the gate to wait for the user's explicit pick stays in place.

**Why:** Empirical evidence from the 4-agent comparison documented at `~/Dropbox/Siraj/Projects/siraj-claude-vault/cross-project/principle-plan-polish-flips-agent-behavior.md` showed that parallel implementations surface plan gaps (and divergences) that single-agent runs hide. The cost (~2× wall time / tokens vs single-subagent) is worth the signal for production code that ships to main. Auto-picking a winner would strip the user out of the loop on the most consequential gate of the per-commit cycle.

**How to apply:** When invoking `openspec-siraj-execute-task` in Curated mode and both subagents complete, render the side-by-side comparison and wait for an explicit pick. Acceptable picks: "go with sonnet", "go with opus", "use sonnet's <file> and opus's <other-file>", or any explicit selection. Never auto-select even when one output is obviously better — the user owns the gate. Switch to Single-subagent or Inline mode only on explicit user instruction ("switch to single subagent with sonnet" / "go inline for this one").

Skill file at `~/.claude/skills/openspec-siraj-execute-task/SKILL.md` makes this explicit in its "Execution Modes" section and in the orchestrator (`openspec-siraj-flow`) anti-patterns table. This entry supersedes the prior `feedback_user_execute_default.md` rule (user-execute was the default before Curated mode was added during the 2026-05-25 session).

Related: [[add_feather_init_is_template]] (the verb being built under this skill — the per-commit Curated rhythm anchors here).
