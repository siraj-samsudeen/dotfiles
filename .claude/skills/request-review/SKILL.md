---
name: request-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements. Dispatches a code reviewer agent.
---

# Request Review

Dispatch a code reviewer agent to catch issues before they cascade.

**Core principle:** Review early, review often.

## When to Request Review

**Mandatory:**
- After each task in execute-with-agents
- After completing major feature
- Before merge to main

**Optional but valuable:**
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing complex bug

## How to Request

### 1. Get git SHAs

```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

### 2. Dispatch code-reviewer agent

Use Task tool with general-purpose type, fill the template below.

### 3. Act on feedback

- Fix Critical issues immediately
- Fix Important issues before proceeding
- Note Minor issues for later
- Push back if reviewer is wrong (with reasoning)

## Code Review Agent Template

```markdown
You are reviewing code changes for production readiness.

## What Was Implemented

[Brief description of what was built]

## Requirements

[Reference to spec or plan, or inline requirements]

## Git Range to Review

Base: [BASE_SHA]
Head: [HEAD_SHA]

Run: git diff [BASE_SHA]..[HEAD_SHA]

## Review Checklist

**Code Quality:**
- Clean separation of concerns?
- Proper error handling?
- Type safety (if applicable)?
- DRY principle followed?
- Edge cases handled?

**Testing:**
- Tests actually test logic (not mocks)?
- Edge cases covered?
- Integration tests where needed?

**Requirements:**
- All requirements met?
- No scope creep?

## Output Format

### Strengths
[What's well done? Be specific with file:line]

### Issues

#### Critical (Must Fix)
[Bugs, security issues, data loss risks]

#### Important (Should Fix)
[Architecture problems, missing features, test gaps]

#### Minor (Nice to Have)
[Code style, optimization, documentation]

### Assessment
Ready to merge: Yes / No / With fixes
Reasoning: [1-2 sentences]
```

## Example

```
[Just completed Task 2: Add verification function]

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch code reviewer agent with template]

[Agent returns]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed

[Fix progress indicators]
[Continue to Task 3]
```

## Integration with Workflows

**execute-with-agents:**
- Review after EACH task (built into workflow)

**execute-plan:**
- Review after each batch (3 tasks)

**Ad-Hoc Development:**
- Review before merge
- Review when stuck

## Red Flags

**Never:**
- Skip review because "it's simple"
- Ignore Critical issues
- Proceed with unfixed Important issues
- Argue with valid technical feedback

**If reviewer wrong:**
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification
