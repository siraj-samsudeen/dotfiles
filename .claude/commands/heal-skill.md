---
description: Diagnose and fix a skill that didn't work correctly in the current session
argument-hint: [optional: path to skill file]
---

# /heal-skill — Skill Self-Repair

Analyze the current conversation to find where a skill misbehaved, diagnose the root cause, and propose targeted fixes.

## When to Use

After running a skill that:
- Skipped steps it should have followed
- Followed the description instead of the body (CSO trap)
- Stopped too early or went too far
- Produced wrong output format
- Missed context it should have loaded
- Behaved differently than intended

## Process

### 1. Identify the skill

If `$ARGUMENTS` is provided, read that file. Otherwise, analyze the conversation to detect which skill was running. Look for:
- `/command-name` invocations
- Skill descriptions that appeared in system context
- Workflow patterns that match known skills

Ask the user to confirm: **"It looks like [skill-name] didn't work as expected. Is that right?"**

### 2. Gather evidence

From the conversation, extract:

**What was expected** — what the skill file says should happen (read the actual skill file)

**What actually happened** — trace Claude's actual behavior step by step:
- Which steps were followed?
- Which steps were skipped or altered?
- Where did behavior diverge from the skill's instructions?

**The gap** — specific delta between expected and actual behavior

Present this as a before/after comparison:
```
Expected (from skill):     Actually happened:
1. Ask for intent          1. Asked for intent ✓
2. Configure frontmatter   2. Skipped — jumped to writing ✗
3. Write body              3. Wrote body (partial) ~
4. Quality checklist       4. Skipped entirely ✗
5. Create files            5. Created files ✓
```

### 3. Diagnose root cause

Common failure modes to check:

| Symptom | Likely Cause |
|---------|-------------|
| Steps skipped | Description summarizes workflow (CSO trap) — Claude shortcuts |
| Wrong workflow chosen | Description too vague, triggers on wrong queries |
| Stopped too early | No success criteria defined |
| Output format wrong | No template or example provided |
| Context not loaded | File references too deep or ambiguous |
| Inconsistent behavior | Conflicting instructions between sections |
| Over-executed | No clear stopping point or "wait for user" gate |

Ask: **"Does this diagnosis match what you saw?"**

### 4. Propose fixes

For each root cause, show the specific edit:

```
## Fix 1: CSO Trap in description

File: ~/.claude/skills/my-skill/SKILL.md, line 3

Before:
  description: Dispatches subagent per task with code review between tasks

After:
  description: Use when executing implementation plans with independent tasks

Why: The old description leaked workflow details, causing Claude to
follow the description as a shortcut instead of reading the full skill.
```

Show all proposed fixes as diffs. Include the "why" for each — the user needs to understand the fix, not just apply it.

### 5. Apply with approval

Ask: **Which fixes should I apply?**
- **All fixes** — apply everything
- **Pick and choose** — list fixes by number, let user select
- **None** — just keep the diagnosis, fix manually

After applying fixes, suggest: **"Want to test the skill again to verify the fix?"**

## Principles

- **Evidence first** — always trace actual behavior from the conversation before diagnosing
- **One root cause at a time** — don't propose 10 fixes at once. Find the primary failure, fix it, re-test
- **The skill is the bug** — if Claude didn't follow the skill, the skill's instructions weren't clear enough. Don't blame the model, fix the instructions
- **Show your work** — every fix needs a "why" that the user can evaluate

<!-- Origin: Heal loop concept (self-repair after failed execution) adapted from https://github.com/glittercowboy/taches-cc-resources -->
<!-- Diagnosis patterns from writing-skills CSO trap research and debug-issue skill -->
