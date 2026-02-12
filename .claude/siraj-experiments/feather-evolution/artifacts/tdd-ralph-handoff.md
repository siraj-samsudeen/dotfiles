# TDD Ralph with Vertical Slices - Session Handoff

> **Status:** Plan mode active, design phase
> **Last Updated:** 2025-02-04
> **Context:** Session ending due to context limits

---

## What We're Building

A development workflow that:
1. Takes vague request → produces ordered vertical slices (PRD for Ralph loop)
2. Works ONE slice per session with context handoff
3. Enforces TDD with 100% coverage during execution

**Key Difference:**
- Ralph/GSD: Write code → run tests → commit if green
- This: Write test (RED) → verify fails → write code (GREEN) → verify passes → commit

---

## Research Completed ✅

All research is documented in: `~/.claude/siraj-experiments/tdd-ralph-vertical-slices/EXPLORATION.md`

### Sources Synthesized

| Source | Key Ideas Extracted |
|--------|---------------------|
| **Anthropic Harness** | Dual-agent (initializer + coder), claude-progress.txt |
| **Ralph** | One task per loop, prd.json with passes: true/false, loopback prompt |
| **Huntley stdlib** | Composable rules folder, learn → capture rule |
| **Huntley /specs** | Specification domains, SPECS.md overview, build core first |
| **GSD** | STATE.md digest, .continue-here.md handoffs, pause/resume, plan checker loop |

### GSD Patterns Explored (this session)

**Session Management:**
- `.continue-here.md` structure: YAML frontmatter + XML sections
- STATE.md: <100 line digest with position, decisions, blockers
- Progress routing: Count artifacts (plans vs summaries) → route to next action
- Deterministic state machine

**State Files:**
- PROJECT.md - vision (rarely changes)
- REQUIREMENTS.md - scoped deliverables with REQ-IDs
- ROADMAP.md - phase structure + progress table
- STATE.md - cross-session memory
- config.json - workflow settings

---

## Existing Assets

### My Skills (at `~/.claude/skills/`)
| Skill | Purpose | Reuse? |
|-------|---------|--------|
| `create-design` | Has vertical slicing | Extend for slice-project |
| `create-spec` | Feather-spec format | Use as-is |
| `derive-tests-from-spec` | Gherkin + claude-progress.md | Use as-is |
| `setup-tdd-guard` | Hook-based TDD enforcement | Core differentiator |
| `write-tests` | RED→GREEN→REFACTOR | Use as-is |
| `verify-feature` | 100% coverage gate | Use as-is |
| `dev-workflow` | Master reference | Update to integrate |

### GSD Commands (at `~/.claude/commands/gsd/`)
| Command | Pattern to Borrow |
|---------|-------------------|
| `pause-work` | .continue-here.md structure |
| `resume-work` | Context restoration flow |
| `progress` | Artifact counting → routing |
| `new-project` | State file initialization |

---

## Design Decisions Needed

1. **File structure:** Use GSD's `.planning/` or create new structure like `.slices/`?

2. **State format:**
   - JSON (prd.json style) for machine-readable slice status
   - Markdown (STATE.md style) for human-readable context
   - Recommendation: Both - `slices.json` + `STATE.md`

3. **Slice storage:** Per-slice folders or single file?
   - Recommendation: Per-slice folders like `docs/specs/<slice-id>/`

4. **Naming:** slices vs phases vs features?
   - Recommendation: "slices" (vertical slice terminology)

5. **Integration with tdd-guard:** Already a hook, just needs to be active

---

## Proposed New Skills

### 1. `/slice-project` (Session 1 - Initialization)
```
Input: Vague request ("Build project management like Basecamp")
Output:
- DOMAIN.md (data model tree)
- slices.json (ordered slices with passes: false)
- STATE.md (session state)
- SLICES.md (overview table)
```

### 2. `/work-slice` (Session 2+ - Execution)
```
Input: Reads slices.json, picks first incomplete
Process:
- create-spec for this slice
- derive-tests-from-spec
- TDD loop (RED → GREEN) with tdd-guard
- verify-feature (100% coverage)
Output:
- Updates slices.json: passes = true
- Updates STATE.md
- STOPS with "Next: [slice-id]"
```

### 3. `/resume-slice` (Resume after break)
```
Input: Reads STATE.md + slices.json
Output:
- Shows current position
- Shows incomplete slices
- Routes to /work-slice or other action
```

---

## Proposed File Structure

```
project/
├── .slices/
│   ├── STATE.md              # Session state (like GSD)
│   ├── slices.json           # Machine-readable slice status
│   ├── SLICES.md             # Overview table
│   └── DOMAIN.md             # Data model tree
├── docs/specs/
│   ├── auth-1/
│   │   ├── spec.md           # Feather-spec
│   │   ├── gherkin.md        # Derived tests
│   │   └── status.json       # Slice-specific status
│   ├── auth-2/
│   └── todo-1/
└── src/                      # Implementation
```

---

## slices.json Format

```json
{
  "project": "Basecamp Clone",
  "created": "2025-02-04",
  "slices": [
    {
      "id": "AUTH-1",
      "name": "Username/password auth",
      "order": 1,
      "depends_on": [],
      "passes": false,
      "spec_path": "docs/specs/auth-1/spec.md"
    },
    {
      "id": "AUTH-2",
      "name": "Magic link auth",
      "order": 2,
      "depends_on": ["AUTH-1"],
      "passes": false
    },
    {
      "id": "TODO-1",
      "name": "Basic todo list",
      "order": 3,
      "depends_on": ["AUTH-1"],
      "passes": false
    }
  ]
}
```

---

## STATE.md Format (adapted from GSD)

```markdown
# Slice Loop State

## Current Position
- **Active Slice:** AUTH-1 (1 of 6)
- **Status:** In progress - spec created, tests pending
- **Last Activity:** 2025-02-04 14:30

## Progress
| Slice | Status | Coverage |
|-------|--------|----------|
| AUTH-1 | 🔄 In progress | — |
| AUTH-2 | ⏳ Pending | — |
| TODO-1 | ⏳ Pending | — |

## Decisions Made
- Using Convex for backend (real-time, TypeScript)
- React + Vite for frontend
- Vitest for testing with ConvexTestProvider

## Blockers
- None

## Next Action
Continue AUTH-1: Run /work-slice to create spec
```

---

## Implementation Order

1. **Create slices.json schema** and STATE.md template
2. **Create /slice-project skill** - initialization
3. **Create /work-slice skill** - execution with TDD
4. **Create /resume-slice skill** - session restoration
5. **Update dev-workflow** - integrate with slice system
6. **Add rules/ folder** - atomic constraints
7. **Test end-to-end** with sample project

---

## To Resume This Work

```bash
# Read the exploration document
cat ~/.claude/siraj-experiments/tdd-ralph-vertical-slices/EXPLORATION.md

# Read this handoff
cat ~/.claude/siraj-experiments/tdd-ralph-vertical-slices/HANDOFF.md

# Continue in plan mode to finalize design
```

**Next Action:** Finalize the skill designs and write the plan file at `/Users/siraj/.claude/plans/robust-pondering-tide.md`

---

## Key Files for Context

| File | Purpose |
|------|---------|
| `~/.claude/siraj-experiments/tdd-ralph-vertical-slices/EXPLORATION.md` | Full research |
| `~/.claude/siraj-experiments/tdd-ralph-vertical-slices/HANDOFF.md` | This file |
| `~/.claude/skills/dev-workflow/SKILL.md` | Current master workflow |
| `~/.claude/skills/setup-tdd-guard/SKILL.md` | TDD enforcement hook |
| `~/.claude/commands/gsd/pause-work.md` | GSD handoff pattern |
| `~/.claude/commands/gsd/resume-work.md` | GSD resume pattern |
