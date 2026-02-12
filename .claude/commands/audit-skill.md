---
description: Review a skill or command against best practices and flag issues with fixes
argument-hint: [path to SKILL.md or command file]
---

# /audit-skill — Skill Quality Auditor

Review a skill file against Anthropic best practices and the writing-skills checklist. Produce structured findings with severity, then offer to fix.

## Input

Read the file at `$ARGUMENTS`. If no argument given, ask: **"Which skill should I audit?"** and list skills from `~/.claude/skills/`, `~/.claude/commands/`, and `.claude/skills/` if they exist.

## Audit Process

### 1. Read the skill file completely
Read SKILL.md and any referenced files (workflows, references, templates). Understand the full skill before judging.

### 2. Determine skill complexity
Assess before applying rules — a 20-line command doesn't need the same rigor as a 300-line workflow skill:

- **Simple** (< 50 lines, single purpose): lighter standards
- **Medium** (50-200 lines, multi-step): full standards
- **Complex** (200+ lines or multi-file): full standards + architecture review

### 3. Run the checklist

Evaluate each item. Score: PASS, WARN, FAIL.

**Frontmatter:**
- [ ] `name` present (skills) or filename is descriptive (commands)
- [ ] `description` is specific with trigger keywords
- [ ] `description` does NOT summarize workflow (the CSO trap)
- [ ] `description` is third-person
- [ ] `argument-hint` present if skill takes arguments

**Description quality (deep check):**
- Does the description answer "should I read this skill right now?" for a given task?
- Would Claude select this skill from 100+ available skills based on this description alone?
- Are there trigger keywords matching how a user would phrase their need?
- Is the description under 500 characters?

**Content:**
- [ ] SKILL.md body under 500 lines
- [ ] No time-sensitive information
- [ ] Consistent terminology (no synonym drift)
- [ ] Concrete examples (not abstract placeholders)
- [ ] File references one level deep (no A→B→C chains)
- [ ] Success criteria defined

**Structure:**
- [ ] Clear overview/purpose in first section
- [ ] Workflows have numbered steps
- [ ] Degrees of freedom match task fragility
- [ ] Progressive disclosure used (complex skills only)
- [ ] Router pattern used if multiple workflows exist (complex skills only)

**Anti-patterns:**
- [ ] No narrative storytelling (skills are references, not war stories)
- [ ] No multi-language examples for the same pattern
- [ ] No vague descriptions ("helps with X", "useful for Y")
- [ ] No first-person in description
- [ ] No deeply nested file references

## Output Format

Present findings grouped by severity:

```
## Audit: [skill-name]

**Overall: PASS / NEEDS WORK / FAIL**

### Findings

**FAIL** (must fix):
- [F1] Description summarizes workflow — "dispatches subagent per task with review"
  → Rewrite to triggering conditions only: "Use when executing implementation plans with independent tasks"

**WARN** (should fix):
- [W1] No success criteria defined
  → Add "## Success Criteria" with measurable done conditions

**PASS** (good):
- Frontmatter structure correct
- Token budget within limits (127 lines)
- Examples are concrete and runnable
```

For each finding: state what's wrong, quote the offending content, and show the fix.

## After Audit

Ask: **What's next?**
- **Fix all** — apply all suggested fixes automatically
- **Fix critical only** — apply only FAIL-level fixes
- **Discuss** — talk through specific findings before changing anything
- **Done** — take the report and fix manually

<!-- Origin: Auditor concept, contextual judgment (proportional standards), structured severity output adapted from https://github.com/glittercowboy/taches-cc-resources -->
<!-- Checklist items from Anthropic best practices and writing-skills archive (superpowers) -->
