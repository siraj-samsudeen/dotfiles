---
description: Guided wizard for creating new Claude Code skills with best practices
argument-hint: [optional: one-liner describing what the skill does]
---

# /create-skill — Skill Creation Wizard

Walk the user through creating a new skill iteratively. Complete each step before moving to the next. Ask questions one at a time.

## Step 1: Gather Intent

If `$ARGUMENTS` is provided, use it as the starting point. Otherwise ask:

**"What should this skill do?"** (one-liner)

Then ask two follow-up questions:

1. **Type**: Is this a **reference** skill (conventions, patterns, quick-reference) or a **task** skill (step-by-step workflow/action)?

2. **Location**: Where should it live?
   - `~/.claude/skills/<name>/SKILL.md` — personal skill, auto-invoked by Claude based on description
   - `~/.claude/commands/<name>.md` — personal command, user-invoked via `/name`
   - `.claude/skills/<name>/SKILL.md` — project skill, shared with team via git

## Step 2: Configure Frontmatter

Guide through each field based on choices above.

### Name
- Derive from intent, kebab-case
- Gerund form preferred for skills: `processing-pdfs` not `pdf-processor`
- Verb-first for commands: `create-skill` not `skill-creator`
- Confirm with user before proceeding

### Description (CRITICAL — read carefully)

**The description MUST contain triggering conditions only.** Write in third person. Start with "Use when..." for skills.

**THE CSO TRAP**: Testing revealed that when a description summarizes the skill's workflow, Claude follows the description as a shortcut and SKIPS the actual skill body. A description saying "code review between tasks" caused Claude to do ONE review even though the skill defined TWO.

```yaml
# BAD — summarizes workflow, Claude will shortcut
description: Dispatches subagent per task with code review between tasks

# BAD — too much process detail
description: Write test first, watch it fail, write minimal code, refactor

# GOOD — triggering conditions only
description: Use when executing implementation plans with independent tasks

# GOOD — triggering conditions only
description: Use when encountering any bug, test failure, or unexpected behavior
```

Draft the description and confirm with user.

### Additional frontmatter (ask only if relevant)
- `argument-hint` — if the skill/command takes arguments (e.g., `[task description]`)
- For commands only: no `name` field needed (filename IS the name)
- For skills only: `name` field required in frontmatter

## Step 3: Write the Skill Body

Based on type, guide through content structure:

### Task skills — use checklist pattern:
```markdown
# Skill Name

## Overview
Core principle in 1-2 sentences.

## The Job
1. Step one
2. Step two
3. ...

## [Detailed step sections]

## Quality Checklist
- [ ] Item one
- [ ] Item two
```

### Reference skills — use quick-scan pattern:
```markdown
# Skill Name

## Overview
What and why in 1-2 sentences.

## When to Use
Bullet list of symptoms/triggers.

## Quick Reference
Table or bullets for scanning.

## Core Pattern
Before/after or example code.

## Common Mistakes
What goes wrong + fixes.
```

### Complex skills — use the router pattern:
When a skill has multiple workflows (e.g., "create" vs "edit" vs "debug"), use SKILL.md as a router:
```markdown
# Skill Name

## Overview
Core principle.

## What do you need?
| Goal | Workflow |
|------|----------|
| Create new X | See [workflows/create.md](workflows/create.md) |
| Edit existing X | See [workflows/edit.md](workflows/edit.md) |
| Debug X issues | See [workflows/debug.md](workflows/debug.md) |

## Essential Principles
[Rules that apply to ALL workflows — always loaded]
```
Each workflow file then specifies which reference files to load. This keeps SKILL.md lean and routes Claude to only the relevant instructions.

### Degrees of freedom
Ask the user: **How much latitude should Claude have?**

- **Low freedom** (fragile ops like DB migrations, deployments): exact commands, no improvisation
- **Medium freedom** (standard patterns with variation): preferred approach with room to adapt
- **High freedom** (analysis, review, creative work): heuristics and guidelines only

Match the instruction specificity to the answer. Don't over-constrain creative tasks or under-constrain dangerous ones.

### Success criteria (mandatory)
Every skill MUST define explicit "done" conditions. Ask the user:

**"How will you know this skill worked correctly?"**

Add a `## Success Criteria` section with measurable completion conditions. This prevents Claude from drifting or stopping prematurely.

### Content guidelines:
- **Token budget**: SKILL.md body under 500 lines. Split to supporting files if exceeding.
- **Progressive disclosure**: Main file = overview + links. Details in separate files one level deep.
- **Conciseness**: Claude is smart. Only add context it doesn't already have.
- **Examples**: One excellent example > many mediocre ones.
- **Use `$ARGUMENTS`** for user input substitution in commands.
- **Use `!command`** syntax for dynamic context injection where useful.

Present a draft structure (headers + one-line descriptions) for approval before writing full content.

## Step 4: Quality Checklist

Before creating files, verify against Anthropic best practices:

- [ ] Description is specific with trigger keywords (not a workflow summary)
- [ ] Description is third-person
- [ ] No time-sensitive info
- [ ] Consistent terminology throughout
- [ ] Concrete examples (not abstract)
- [ ] File references one level deep (no nested chains)
- [ ] SKILL.md under 500 lines
- [ ] Workflows have clear steps
- [ ] Success criteria defined (measurable "done" conditions)
- [ ] Degrees of freedom match task fragility

Flag any violations and fix before proceeding.

For the full best practices guide, run: `/docs skills`

## Step 5: Create Files

1. Create the skill directory/file at the chosen location
2. Show the user the final result
3. Ask: **What's next?**
   - **Try it** — run the skill now to test it
   - **Audit it** — run `/audit-skill` to check against best practices
   - **Commit it** — commit to dotfiles or project repo
   - **Done** — finish here

## Anti-Patterns to Flag

If you notice the user doing any of these, push back:

| Anti-Pattern | Why It's Bad |
|---|---|
| Description summarizes workflow | CSO trap — Claude shortcuts the body |
| Vague description ("helps with X") | Won't trigger on relevant queries |
| First-person description | Injected into system prompt, causes confusion |
| Nested file references (A→B→C) | Claude may partially read deep files |
| 500+ lines in SKILL.md | Token budget pressure, split to files |
| Multiple languages for same example | Maintenance burden, pick one good one |
| Narrative storytelling | Skills are references, not war stories |

<!-- Origin: Router pattern, degrees of freedom, mandatory success criteria, post-action menus adapted from https://github.com/glittercowboy/taches-cc-resources -->
<!-- CSO trap, description pitfalls, token budget from writing-skills archive (superpowers) -->
<!-- Anthropic best practices from https://docs.anthropic.com/en/docs/agents-and-tools/agent-skills/best-practices -->
