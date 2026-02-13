# Skill Audit — Lineage Map

Tracks where each piece of feather:debug came from.

## SKILL.md (304 lines)

### From superpowers (Jesse Vincent, MIT)
- Overview, Iron Law, When to Use
- Phase 1 steps 1-5 (Read Errors, Reproduce, Check Changes, Gather Evidence, Trace Data Flow)
- Phase 2: Pattern Analysis (all 4 steps)
- Phase 3 original structure (form hypothesis, test minimally, verify, when you don't know)
- Phase 4: Implementation (all 5 steps including 3+ fixes → question architecture)
- Red Flags section (base bullets)
- Common Rationalizations (merged into Red Flags as inline reframings)
- Quick Reference table
- Human Partner Signals
- When Process Reveals No Root Cause
- 3 original reference files (root-cause-tracing, defense-in-depth, condition-based-waiting)

### From gsd-debugger
- Phase 1 step 6: "Check Your Freshness" (sunk cost antidote, gsd-debugger line 74)
- Phase 3 step 1: "Generate Multiple Hypotheses First" (anchoring antidote, line 72)
- Phase 3 step 2: "Make It Falsifiable" (lines 104-118)
- Phase 3 step 4: "Actively Seek Disconfirming Evidence" (confirmation bias antidote, line 71)
- Research vs Reasoning section (lines 608-703)
- investigation-techniques.md (lines 220-426)
- hypothesis-and-verification.md (lines 42-55, 102-217, 428-602)

### New for feather
- Combined attribution in frontmatter (superpowers + gsd-debugger)
- "Decorative → actionable" rewrite: merged rationalizations table into red flags, rewrote all 5 reference files
- Dropped /gsd:debug cross-reference (content harvested, pointer redundant)
- Fixed skill reference: write-tests → feather:write-tests

## Remaining Skills (audit pending)

| Skill | Status | Notes |
|-------|--------|-------|
| request-review | Analyzed | Move to feather namespace? Fix CSO trap, stale references |
| receive-review | Analyzed | Move to feather namespace? Merge with request-review? |
| setup-convex-testing | Analyzed | Move to feather namespace? Break into SKILL.md + refs, trim narrative |
