# Audit: receive-review

**Status:** Analyzed — needs planning
**Verdict:** PASS (0 fails, 1 warn)

## Context

- **Origin:** obra/superpowers `receiving-code-review` (MIT, Jesse Vincent)
- **Location:** `/Users/siraj/.claude/skills/receive-review/SKILL.md` (191 lines)
- **Standalone:** Kept outside feather namespace — general code review skill
- **Note:** This is the best-written skill in the collection

## Findings

### WARN (should fix)

**[W1] Minor redundancy in "Real Examples" section**
Lines 164-183 partially overlap with examples already given in earlier sections (Forbidden Responses at line 29, YAGNI Check at line 87). The same patterns appear twice.
Fix: Trim "Real Examples" section or consolidate — the earlier inline examples are stronger because they appear in context.

### PASS (good)
- Description is excellent — trigger-focused with key behavior
- "Forbidden Responses" is a standout section — concrete anti-patterns
- YAGNI check is unique and valuable
- Implementation order is practical
- "The Bottom Line" works as success criteria
- Consistent voice throughout

## Open Questions for Planning

1. Should this move into feather namespace? (feather:receive-review?)
2. Should request-review and receive-review be merged into one skill?
3. Is the redundancy worth fixing or is it minor enough to leave?

## Source File
- `/Users/siraj/.claude/skills/receive-review/SKILL.md`
