# VBW Framework Analysis

**Sources:** https://github.com/yidakee/vibe-better-with-claude-code-vbw
**Studied:** 2026-02-10
**Type:** GitHub Repo (Claude Code Plugin)
**Note:** This analysis predates the study-idea system. Migrated from two loose experiment files.

---

## Executive Summary

VBW (Vibe Better With Claude Code) is a ground-up Claude Code plugin by Tiago Serodio that claims 75% reduction in coordination overhead tokens through 15 optimization mechanisms across 7 architectural layers. The biggest insight: **shell pre-computation** (26 bash scripts, 1,624 lines) moves state discovery, routing, and infrastructure tasks to zero-model-token shell execution. The framework comparison with GSD reveals they solve different problems — VBW excels at execution infrastructure (Agent Teams, hooks, permissions), while GSD excels at research and verification. Neither has Feather's quality layer.

---

## Part 1: Architecture Deep Dive

**Version analyzed:** 1.10.6

### Token Optimization Claims

VBW claims 75% total reduction in coordination overhead tokens and 46% reduction in dollar cost per session vs stock Agent Teams.

**Stock Agent Teams overhead per phase (3-agent team): 57,000-133,000 tokens BEFORE productive work.**

VBW's measured reduction (Balanced effort, 1 phase, 3-plan build):

| Category | Stock Teams | VBW | Saving |
|---|---|---|---|
| Base context overhead | 10,800 | 3,200 | 70% |
| State computation | 1,300 | 200 | 85% |
| Agent init context (x4) | 24,000 | 6,400 | 73% |
| Coordination messages | 12,000 | 2,400 | 80% |
| Task CRUD overhead | 10,000 | 8,000 | 20% |
| Context duplication | 16,500 | 5,000 | 70% |
| Compaction recovery | 5,000 | 2,000 | 60% |
| CLAUDE.md duplication | 6,000 | 6,000 | 0% |
| Tool call waste | 1,500 | 0 | 100% |
| **Total** | **87,100** | **33,200** | **62%** |
| **Agent model costs** | **$2.78** | **$1.59** | **43%** |

### The 7 Optimization Layers (15 Mechanisms)

**Layer 1 — Context Diet (Mechanisms 1-6):** `disable-model-invocation` on 19/27 commands removes them from always-on context (7,600 tokens saved per request). Brand consolidation (329→50 lines), capped context injections (`head -40`), lazy reference loading, effort profile lazy-loading, reference deduplication.

**Layer 2 — Shell Pre-Computation (Mechanisms 7-9):** 26 shell scripts, 1,624 lines of bash, all at zero model token cost. `phase-detect.sh` (202 lines) pre-computes 22 state variables. `session-start.sh` (314 lines) performs 10 silent infrastructure tasks. `suggest-next.sh` (215 lines) computes context-aware routing.

**Layer 3 — Model Routing (Mechanism 10):** Scout=Haiku, QA=Sonnet, Dev/Lead=Opus. Biggest dollar-cost win — scout queries drop from $0.90 to $0.015.

**Layer 4 — Compaction Resilience (Mechanism 11):** PreCompact hook injects agent-specific preservation priorities. Post-compact hook tells each agent exactly what to re-read. Stock teams: ~8,000 tokens. VBW: ~2,000 tokens.

**Layer 5 — Agent Scope Enforcement (Mechanisms 12-14):** Platform-enforced `disallowedTools` per agent. File guard blocks writes outside plan scope. `maxTurns` hard caps (Scout:15, QA:25, Architect:30, Debugger:40, Lead:50, Dev:75).

**Layer 6 — Structured Coordination (Mechanism 15):** Disk-based coordination with 5 typed JSON schemas (scout_findings, dev_progress, dev_blocker, qa_result, debugger_report). Per-agent overhead: ~800 tokens vs ~4,000 in stock teams.

**Layer 7 — Effort Scaling:** Turbo mode eliminates entire agent categories (Thorough: 5-7 agents → Turbo: 1 Dev only).

### The 6 Agents

| Agent | Model | maxTurns | Key Constraint |
|---|---|---|---|
| vbw-lead | Opus | 50 | No subagents, writes PLANs to disk |
| vbw-dev | Opus/Sonnet | 75 | One atomic commit per task |
| vbw-qa | Sonnet | 25 | Cannot write/edit files |
| vbw-scout | Haiku | 15 | Read-only, up to 4 parallel |
| vbw-architect | Opus | 30 | Cannot edit, no bash |
| vbw-debugger | Opus | 40 | Scientific method protocol |

### The Compression Milestone (v1.10.1 → v1.10.2)

Three-phase content compression on top of architectural optimizations:
- Instruction compression: 4,804 → 2,266 lines (53%)
- Artifact compaction: 382 → 196 lines (49%)
- Reference diet: eliminated 9 orphaned files, remaining 8 compressed 72%
- Combined: ~75% total coordination overhead reduction

### Platform Limitations (What VBW Cannot Optimize)

- CLAUDE.md loaded in every agent (~6,000 tokens duplication)
- Task CRUD tool calls (~8,000-10,000 tokens)
- System prompt/tool schemas (~3,000-4,000 per agent)
- Idle notification tokens (~500-2,000/phase)

---

## Part 2: Framework Comparison (VBW vs GSD vs Feather)

**TL;DR:** VBW is NOT a GSD fork. It's a ground-up rebuild with genuinely better architecture (Agent Teams, plugin system, 18 native hooks, platform-enforced permissions). But it's 3 days old, single-author, and has the same quality gaps as GSD. The real question isn't "GSD vs VBW" — it's "which base is easier to add Feather's quality layer to?"

### Head-to-Head

| Dimension | GSD | VBW | Verdict |
|---|---|---|---|
| Install | Bash script clones to ~/.claude | Plugin marketplace | VBW cleaner |
| Parallelism | Task tool subagents | Agent Teams (real concurrent) | VBW better (but experimental) |
| Hooks | ~5 hooks | 18 hooks across 10 event types | VBW far more comprehensive |
| Agent permissions | Instructions in markdown | Platform-enforced `disallowedTools` | VBW more reliable |
| Crash recovery | Manual resume | `.execution-state.json` auto-detection | VBW more robust |
| Effort control | quality/balanced/budget | thorough/balanced/fast/turbo + per-command override | VBW more granular |

### What GSD Has That VBW Doesn't

1. 4 parallel researchers with Context7 integration
2. Model allocation profiles per agent role
3. Context budget tracking (30/50/70% thresholds)
4. 3-level stub detection (Exists/Substantive/Wired)
5. Dedicated cross-phase integration checker
6. Codified deviation rules
7. Roadmap 100% coverage validation
8. Plan-checker agent (verifies plans BEFORE execution)
9. Mature community, more battle-testing

### What Neither Has (Feather's Unique Value)

12 gaps exist in both: TDD enforcement, read-only test contract, test coverage gates, EARS spec format, Gherkin derivation, end-to-end traceability, structured feedback tracking, full-stack test strategy, two-stage independent review, design exploration, polish queue, UI mockups.

### Decision Framework

- **VBW as base** if: hooks architecture is needed for quality enforcement, plugin distribution matters, Agent Teams proves reliable
- **GSD as base** if: research pipeline is critical, battle-tested stability preferred, existing 10-phase integration plan is valuable
- **Best of three** if: willing to invest more work for the best long-term architecture

---

*Migrated from: vbw-architecture-analysis.md + vbw-vs-gsd-handoff.md*
*Original analysis: 2026-02-10*
