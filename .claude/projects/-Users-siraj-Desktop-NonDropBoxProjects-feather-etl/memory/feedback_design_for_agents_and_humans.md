---
name: Design for both agents and humans, always
description: Every feature, flag, and output must serve human TTY users AND non-interactive agents equally well — never design a path that only works in one mode
type: feedback
originSessionId: 69d38b66-036e-4660-aa52-d9d4771eeced
---
Every user-facing feature — CLI commands, prompts, errors, outputs — must work equally well for humans at a terminal AND for agents (including Claude Code, CI, scripts, wrappers) running the tool non-interactively. Designs that assume interactivity as the only path are incomplete.

**Why:** The user explicitly surfaced this during the feather-etl multi-source `discover` design (2026-04-14). Agents parse stdout and exit codes; they cannot answer interactive prompts. A feature that only works when a human types `y` at a prompt is broken for the agent workflow. Conversely, features that only work via flags (no interactive affordance) punish humans. Both audiences are first-class. This project will increasingly be run by agents (Claude Code wrappers, GSD autonomous workflows), so this is not a nice-to-have.

**How to apply — in every design and coding decision:**

1. **TTY detection is cheap — use it.** `sys.stdin.isatty()` in Python. When interactive, prompt freely. When non-interactive, never prompt; exit with guidance instead.

2. **Every interactive prompt needs a companion flag.** If you add `[Y/n]`, also add `--yes` (and/or `--no-...` for the negative case). The flag must be honored in both TTY and non-TTY contexts so scripts work consistently.

3. **Use distinct exit codes that encode intent:**
   - `0` — success
   - `1` — configuration or programmer error
   - `2` — data failure (a source failed, a test failed, something the caller may retry)
   - `3` — decision required (the command needs a human/agent choice before it can proceed; rerun with a flag)
   This lets wrappers branch on exit code without parsing output.

4. **Every message an agent might read must be parseable or self-documenting.** Either emit machine-readable output (JSON summary) or include the exact flag/command the agent should run next in the message body. "Rerun with `--yes`" is the agent-friendly hint; "try again" is not.

5. **Never conflate "needs decision" with "failed".** Humans can distinguish from context; agents cannot. If a command wants input, it is not a failure — it is an intermediate state.

6. **Document the non-TTY path in the design spec, not as an afterthought.** Every feature's design section should explicitly cover: what happens on TTY, what happens on non-TTY, which flags pre-answer which prompts, what exit codes are used.

**Reusable pattern — exit code 3 for "needs decision":** when a command detects an ambiguous situation (rename inference, destructive confirmation, conflicting state), exit `3` with the proposal and the flags that resolve it. This is cheaper and more reliable than a `--json` protocol for human-wrapped-by-agent workflows.

**Anti-patterns to reject:**
- Prompts without escape-hatch flags
- "Are you sure?" with no `--yes` bypass
- Non-interactive runs that silently pick a default instead of signaling ambiguity
- Outputs that require visual formatting to be understood
- Error messages that say "see logs" instead of stating the fix

This principle applies to config files, CLI arguments, error messages, warnings, deprecation paths, interactive wizards (`feather init`), and any future feature.
