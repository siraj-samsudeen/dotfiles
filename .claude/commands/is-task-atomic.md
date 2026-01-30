---
description: Check if a task is small enough for an AI agent to complete in one session
argument-hint: [task description]
---

# Is Task Atomic?

Evaluate this task against the atomic task criteria:

## Task
$ARGUMENTS

## Criteria

1. **ONE OUTCOME** - Produces exactly one visible result?
2. **TESTABLE** - Clear way to verify it works?
3. **15-30 MIN** - Completable in one short session?
4. **INDEPENDENT** - No waiting on other incomplete work?
5. **DEMOABLE** - Can show someone it working?

## Response Format

**Verdict:** PASS | TOO BIG | TOO VAGUE | MISSING TEST

**Checklist:**
- [ ] One outcome
- [ ] Testable
- [ ] 15-30 min
- [ ] Independent
- [ ] Demoable

**If fails:** State the problem and show a rewritten version.
