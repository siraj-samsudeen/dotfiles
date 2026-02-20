# Audit: request-review

**Status:** Analyzed — needs planning
**Verdict:** NEEDS WORK (0 fails, 2 warns)

## Context

- **Origin:** obra/superpowers `requesting-code-review` (MIT, Jesse Vincent)
- **Location:** `/Users/siraj/.claude/skills/request-review/SKILL.md` (148 lines)
- **Standalone:** Kept outside feather namespace — general code review skill

## Findings

### WARN (should fix)

**[W1] Description contains CSO trap**
Current: `"Use when completing tasks, implementing major features, or before merging to verify work meets requirements. Dispatches a code reviewer agent."`
The second sentence describes HOW it works, not WHEN to use it.
Fix: Drop second sentence.

**[W2] Stale workflow references**
"Integration with Workflows" section (lines 126-135) references `execute-with-agents` and `execute-plan` — these don't exist in current skill set.
Fix: Verify if these exist. If not, update to current workflow names or remove.

**[W3] No explicit success criteria**
The reviewer template has implicit criteria ("Ready to merge: Yes/No/With fixes") but no standalone section.
Fix: Add a one-liner defining done condition.

### PASS (good)
- Clear when-to-use triggers (mandatory + optional)
- Concrete agent template with copy-paste prompt
- Example shows real workflow
- Red flags section is practical

## Open Questions for Planning

1. Should this move into feather namespace too? (feather:request-review?)
2. Are the `execute-with-agents` and `execute-plan` references pointing to feather:execute?
3. Does the review agent template need updating for current Claude Code capabilities?

## Source File
- `/Users/siraj/.claude/skills/request-review/SKILL.md`
