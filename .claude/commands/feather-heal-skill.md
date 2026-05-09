---
description: Heal feather-* skills (or any user-installed skill) by applying classified feedback with per-item approval, principle extraction, and a verification re-run.
argument-hint: [optional: skill name to focus on, e.g. "feather-brainstorm"]
allowed-tools: [Read, Edit, Write, Bash(ls:*), Bash(grep:*), Bash(git:*), TodoWrite]
---

<objective>
Apply user-supplied feedback to one or more skills under `~/.claude/skills/`,
plus the principle vault under `~/Dropbox/Siraj/Projects/siraj-claude-vault/`,
and the user/project settings under `~/.claude/` or `.claude/`.

Distinguish between **skill bugs**, **cross-project principles**, **harness
config**, and **observation-only** items so each goes to the right home.
Approval per item. Verification re-run when the work is done.

Adapted from glittercowboy/heal-skill.md (see end). Differences: multi-skill
aware (feather pipeline = 4 cooperating skills); user-skills path
(~/.claude/skills/); explicit route-classification step; principle
extraction to Obsidian vault; verification re-run loop.
</objective>

<context>
Available feather skills: !`ls -1 ~/.claude/skills/ | grep -i feather || echo "no feather-* skills installed"`
Other user skills: !`ls -1 ~/.claude/skills/ | grep -v -i feather | head -20`
Vault location: ~/Dropbox/Siraj/Projects/siraj-claude-vault/cross-project/
</context>

<quick_start>
<workflow>
1. **Collect feedback** — ask the user for written feedback (paste or path)
2. **Read affected skills** — load every SKILL.md the feedback mentions
3. **Classify each item** — route to: skill-edit / principle / command / settings / memory / observation-only
4. **Present classification table** — get approval before drafting diffs
5. **Resolve design questions** — surface ambiguities that reshape multiple edits
6. **Per-item heal-skill diffs** — before/after, reason, per-item or batched approval
7. **Apply edits** — Edit tool, confirm each
8. **Extract principles** — write any new cross-project principles to the vault
9. **Verification re-run** — propose a 30-second re-run of the affected skill on a toy input to confirm behaviour changed
10. **Commit (optional)** — if user wants
</workflow>
</quick_start>

<process>

<step_1 name="collect_feedback">
If $ARGUMENTS names a specific skill, focus there. Otherwise ask which skill(s).

Ask the user:
> "Paste the feedback (rough form is fine), or point me at a file. I'll classify each item before drafting any edits."

Wait for input. Do not proceed without feedback in hand.
</step_1>

<step_2 name="read_affected_skills">
For every skill named (or implied) in the feedback, read the full SKILL.md:

```bash
ls -la ~/.claude/skills/<skill-name>/
```

For feather-* skills, the pipeline interconnects — feedback on one often touches another. If the feedback is about feather-brainstorm, also peek at feather-spec and feather-execute-task at the boundary they share.

Read references/, scripts/, and any companion files in the skill folder.
</step_2>

<step_3 name="classify_each_item">
Walk through every distinct piece of feedback. For each, decide where it goes:

| Route | When to use |
|---|---|
| **skill-edit** | The skill instructs the agent to do (or not do) the wrong thing; fix is in SKILL.md or its companions |
| **principle (vault)** | Cross-project pattern worth saving to `~/Dropbox/Siraj/Projects/siraj-claude-vault/cross-project/` |
| **command (commands/)** | The fix is reusable command behaviour, belongs in `~/.claude/commands/<name>.md` |
| **settings** | Hook, env var, or permission — belongs in `~/.claude/settings.json` or `.claude/settings.json` (use the update-config skill) |
| **memory** | Recurring correction — belongs in project MEMORY.md (only after the same item recurs across sessions) |
| **observation-only** | Worth noting but no action needed |

For items that origin in skill text vs. items that origin in agent overreach: note the difference. **Origin in skill** → fix is to remove/edit the instruction. **Origin in agent overreach** → fix is to add an anti-pattern.
</step_3>

<step_4 name="present_classification">
Present a classification table:

```
| # | Feedback (compressed) | Origin in skill | Where this goes | Fix sketch |
|---|---|---|---|---|
| 1 | <one-line summary>    | <line N or "agent overreach"> | <route>          | <one-line> |
```

Identify any items that are sub-issues of others; bundle them.

Identify items where origin is *another skill in the pipeline* (e.g. feedback on feather-brainstorm that originates in feather-spec's vocabulary). Note as cross-cutting.

Ask:
> "Approve the classification, or any item miscategorized?"

**Wait for approval.**
</step_4>

<step_5 name="resolve_design_questions">
Before drafting diffs, surface design questions that reshape multiple edits — for example:

- "How heavy should the new mode menu be (inline / inline + escape / structured menu)?"
- "Should we hide the internal taxonomy entirely, or rename for the user?"
- "Verbatim quotes inline only, or also in a bottom appendix?"

Resolving these first prevents re-editing the same lines twice.

If a question is reshape-level, present 2–4 options with concrete examples (the same content rendered each way). Ask the user to pick.

Apply **Concierge Default**: when offering choices, describe each option's fit, not just its name.
</step_5>

<step_6 name="draft_diffs">
For each skill-edit item, present a heal-skill-style diff:

```
### Edit N — <Section name> (<line range>)

**Before:**
<exact text from current file>

**After:**
<new text>

**Reason:** <why this fixes the issue>
```

For multi-edit items in one skill, batch them under the same approval gate. Use the heal-skill four-option menu:

```
1. Apply all edits, commit later
2. Apply some — name them
3. Revise — tell me what to change
4. Cancel
```

**Wait for response. Do not proceed without explicit approval.**

If the user says "auto" or "go ahead and make all edits without approval," switch to push-through mode for the rest of the session.
</step_6>

<step_7 name="apply_edits">
Use the Edit tool for each correction. After each edit, the tool returns confirmation.

For large edits (template rewrites), confirm by reading back the changed region with the Read tool.

For multi-skill edits, work skill-by-skill in dependency order (overview → upstream → downstream → tests).

Track progress with TodoWrite — one todo per item or per skill. Mark complete only after the Edit confirms.
</step_7>

<step_8 name="extract_principles">
For every classified `principle (vault)` item, write or update the principle file:

```
~/Dropbox/Siraj/Projects/siraj-claude-vault/cross-project/philosophy-<name>.md
```

Frontmatter (matches existing vault style):
```yaml
---
type: decision
project: cross-project
date: <YYYY-MM-DD>
status: active
impact: <ux | architecture | testing | ...>
tags:
  - Type/Decision
  - CrossProject/<area>
related:
  - cross-project/philosophy-design.md
  - cross-project/philosophy-concierge-default.md
  - cross-project/philosophy-markdown-readable-default.md
---
```

Body sections (in order):
1. The principle (one paragraph + 3–6 bullets)
2. Where to apply
3. Where NOT to apply
4. Relationship to other principles
5. Anti-patterns it prevents
6. Source (which session, which feedback)

Cross-link in the related skill's anti-patterns table:
```
| ❌ Don't <X> | <Concierge Default | Markdown-Readable Default | other> says <Y> |
```
</step_8>

<step_9 name="verification_rerun">
After edits land, propose a small re-run to confirm behaviour changed:

> "Edits are in. Want to re-run <skill-name> on a toy input (~30 seconds)
> to verify the fix actually changes behaviour? E.g. for feather-brainstorm:
> 'I want to build a small notes app' — see whether the new Phase 0 mode
> menu fires."

Re-run is verification, not bug-hunt. If the re-run surfaces *new* issues, those are Round 2 — capture them separately, don't retrofit Round 1.

If the user declines the re-run, mark the heal session complete and move on.
</step_9>

<step_10 name="commit_optional">
Skill files live in `~/.claude/skills/`, which may or may not be a git repo. If it is:

```bash
cd ~/.claude && git status
```

Offer the user:
1. Commit all changes with a structured message
2. Show the diff and let the user commit
3. Skip — leave files modified

Default: option 2 (show diff). Do NOT commit silently.

For the vault (`~/Dropbox/Siraj/Projects/siraj-claude-vault/`), use the obsidian skill if updates are needed beyond what was just written.
</step_10>

</process>

<route_classification_examples>

| Feedback symptom | Likely route | Why |
|---|---|---|
| "The skill says 'do X' but I want it to do Y" | skill-edit | Direct instruction change |
| "The agent kept doing X that I never asked for" | skill-edit (anti-pattern) | Agent overreach; codify the don't |
| "I want this kind of behaviour everywhere across all my skills" | principle (vault) + edits in each affected skill | Cross-cutting pattern |
| "I want to /<command> for this" | command (commands/) | Reusable invocation |
| "When X happens, automatically do Y" | settings (hook) | Harness automation |
| "I keep having to remind the agent to <X>" (recurring) | memory | Recurring correction |
| "Interesting observation about <X>" (no action) | observation-only | Capture, no fix |
| "The output looked stiff / cryptic / formatted badly" | skill-edit (template) + likely principle | Often surfaces a Concierge or Markdown-Readable Default issue |

</route_classification_examples>

<success_criteria>
- Every feedback item explicitly classified
- Origin in skill vs origin in agent overreach distinguished
- Design questions resolved before drafting diffs (no double-editing)
- All skill-edits applied with per-item or per-batch approval
- Cross-project principles extracted to vault and cross-linked from skill anti-patterns
- Verification re-run offered (and run if accepted)
- Skill files modified consistently (no orphan references to old vocabulary)
- Commit decision deferred to user
</success_criteria>

<verification>
Before declaring complete:

- Read back changed sections with the Read tool
- Confirm cross-skill consistency (e.g. if you renamed a section in feather-brainstorm, check feather-flow's quick reference doesn't still point at the old name)
- Confirm no skill mentions a path or vocabulary that another skill no longer uses
- Confirm the vault writes have correct frontmatter and cross-links to existing philosophy files
- Show the user a summary of what changed (file names + line counts is enough)
</verification>

<comparison_to_glittercowboy_heal_skill>
This command is adapted from the original [glittercowboy/heal-skill.md](https://github.com/glittercowboy/taches-cc-resources/blob/main/commands/heal-skill.md). Key differences:

| Original | feather-heal-skill |
|---|---|
| Single skill assumption | Multi-skill aware (handles pipelines like feather-*) |
| Path: `./skills/` (project-local) | Path: `~/.claude/skills/` (user-level), with project-local fallback |
| One reflection step | Explicit route-classification step (skill / principle / command / settings / memory / observation) |
| One approval gate | Per-item or per-batch approval, plus design-question resolution upfront |
| Edit and commit | Edit, extract principles to vault, propose verification re-run, defer commit |
| No principle extraction | Cross-project principles → `~/Dropbox/Siraj/Projects/siraj-claude-vault/cross-project/` |

Both share the heal-skill core: detect skill, present before/after diffs, get approval, apply, verify.
</comparison_to_glittercowboy_heal_skill>
