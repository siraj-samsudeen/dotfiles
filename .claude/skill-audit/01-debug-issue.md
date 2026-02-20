# Audit: debug-issue → feather:debug

**Status:** Plan ready — awaiting execution
**Verdict:** PASS with migration needed

## Context

- **Origin:** obra/superpowers `systematic-debugging` (MIT, Jesse Vincent)
- **Created:** ~Jan 30 2026, renamed from systematic-debugging to debug-issue
- **Location:** `/Users/siraj/.claude/skills/debug-issue/` (4 files, ~485 lines)
- **Standalone:** Kept outside feather namespace originally — "General debugging discipline, useful beyond feather workflow"
- **Decision:** Move into feather as `feather:debug`, harvest best ideas from gsd-debugger

## Completed Work (this session)

### Fixes Applied to debug-issue SKILL.md
- [x] **F1** Added attribution: `<!-- Based on obra/superpowers systematic-debugging (MIT) by Jesse Vincent -->`
- [x] **W1** Restored "Human Partner Signals" section from original superpowers
- [x] **W2** Restored "When Process Reveals No Root Cause" section
- [x] **W3** Removed unattributed statistics ("95% vs 40%")
- [x] **W4** Fixed "Phase 4.5" → "Phase 4, step 5"
- [x] **W5** Added cross-reference to `/gsd:debug`

### Comparison with gsd:debug completed
- gsd:debug = orchestrator command (163 lines) + gsd-debugger agent (1199 lines)
- debug-issue = methodology (270 lines + 3 reference files)
- They share core philosophy but gsd-debugger has ~517 lines of unique valuable content
- Decision: Harvest best gsd-debugger ideas into feather:debug

## Remaining Work: Create feather:debug

### Target Structure
```
/Users/siraj/.claude/feather-flow/skills/feather:debug/
├── SKILL.md                        (~350 lines, enhanced from debug-issue)
├── root-cause-tracing.md           (113 lines, keep as-is)
├── defense-in-depth.md             (123 lines, keep as-is)
├── condition-based-waiting.md      (100 lines, keep as-is)
├── investigation-techniques.md     (~220 lines, NEW from gsd-debugger)
└── hypothesis-and-verification.md  (~250 lines, NEW from gsd-debugger)
```

### What to harvest from gsd-debugger (specific line ranges)

**For SKILL.md enhancements:**
- Cognitive biases table (gsd-debugger lines 69-74) → new "Cognitive Foundation" section
- Research vs reasoning (lines 608-703) → new section after "Common Rationalizations"
- Brief falsifiability note → enhance Phase 3

**For investigation-techniques.md (NEW file):**
- Binary search (lines 223-238)
- Rubber duck (lines 240-254)
- Minimal reproduction (lines 256-282)
- Working backwards (lines 284-306)
- Differential debugging (lines 308-337)
- Observability first (lines 339-364)
- Comment out everything (lines 366-384)
- Git bisect (lines 386-401)
- Technique selection table (lines 403-412)
- Combining techniques (lines 414-425)

**For hypothesis-and-verification.md (NEW file):**
- Meta-debugging (lines 42-55)
- Hypothesis testing framework (lines 102-217): falsifiability, experimental design, evidence quality, multiple hypotheses
- Verification patterns (lines 428-602): what verified means, reproduction, regression, stability, test-first, checklist

### Implementation Steps

1. Create `/Users/siraj/.claude/feather-flow/skills/feather:debug/` directory
2. Write SKILL.md (base from current debug-issue + enhancements)
3. Copy 3 unchanged reference files from debug-issue
4. Write investigation-techniques.md (extract from gsd-debugger)
5. Write hypothesis-and-verification.md (extract from gsd-debugger)
6. Create symlink: `~/.claude/skills/feather:debug → feather-flow path`
7. Delete old `~/.claude/skills/debug-issue/`
8. Verify: all 6 files exist, SKILL.md < 500 lines, symlink works

### Source Files (for the executing agent)
- `/Users/siraj/.claude/skills/debug-issue/SKILL.md` — base for new SKILL.md
- `/Users/siraj/.claude/skills/debug-issue/root-cause-tracing.md` — copy unchanged
- `/Users/siraj/.claude/skills/debug-issue/defense-in-depth.md` — copy unchanged
- `/Users/siraj/.claude/skills/debug-issue/condition-based-waiting.md` — copy unchanged
- `/Users/siraj/.claude/agents/gsd-debugger.md` — source for harvested content

### Attribution
```yaml
---
name: feather:debug
description: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes. Find root cause first - no fixes without investigation.
attribution: Based on systematic-debugging by Jesse Vincent (MIT). Investigation techniques and hypothesis framework incorporate ideas from gsd-debugger.
---
```
