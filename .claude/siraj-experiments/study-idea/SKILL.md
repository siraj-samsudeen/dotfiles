---
name: study-idea
description: >
  Deep-dive research and integration agent for new ideas, tools, repos, and concepts found
  on the internet. Use this skill whenever you encounter an interesting GitHub repo, blog post,
  library, framework, technique, or workflow and want to systematically study it, compare it
  against your existing Claude Code skills, and create a working integration experiment.
  Triggers on: "study this", "assimilate this idea", "research this repo", "integrate this into
  my skills", "study-idea", or any URL accompanied by a request to learn from it. Even if the
  user just pastes a URL and says "interesting", consider triggering this skill.
---

# Study Idea

A two-phase research-to-integration agent for assimilating new ideas into your skill ecosystem.

## Philosophy

The best way to learn something new is to study it deeply, then find where it connects to
what you already know, and finally build something that bridges the two. This skill automates
that process: it takes a URL or concept, performs a deep-dive analysis, produces a structured
report for your review, and — once you approve — creates a working skill or integration
experiment.

## When This Skill Activates

- User shares a URL (GitHub repo, blog post, documentation, tool page) and wants to learn from it
- User says "study this", "assimilate", "research", "integrate this"
- User pastes something interesting and asks what can be extracted from it
- User wants to compare a new approach against their existing workflow

## Two-Phase Workflow

```
Phase 1: STUDY (always runs)
  Fetch → Analyze → Map → Compare → Report → Present for review

Phase 2: INTEGRATE (runs after user approval)
  Design → Build → Test → Deploy to experiments folder
```

---

## Phase 1: Study & Report

### Step 1: Fetch & Classify

Determine what kind of source the user has shared:

| Source Type | Fetch Strategy |
|-------------|---------------|
| GitHub repo | Clone/fetch README, scan file tree, read key source files, check package.json/pyproject.toml |
| Claude Code skill/plugin | All of the above PLUS: read SKILL.md for activation patterns, study hooks for feedback loops, analyze how the skill teaches Claude to use it (see "Skill Design Pattern Analysis" below) |
| Blog post / Article | Fetch content, extract core ideas and code samples |
| Documentation | Fetch key pages, map concepts and patterns |
| npm/PyPI package | Fetch docs, examine API surface, check examples |
| General URL | Fetch and extract whatever structured information exists |

For GitHub repos specifically, do a deep dive:
1. **README** — understand purpose, features, installation, usage
2. **File tree** — understand architecture and organization
3. **Key source files** — read the main implementation files (not just configs)
4. **Dependencies** — what does it build on?
5. **Examples** — any example code or demos?
6. **Issues/discussions** — any known limitations or interesting conversations?

#### Skill Design Pattern Analysis

When the source is a Claude Code skill, plugin, or any tool that instructs an AI agent,
also study **how it teaches the agent to use it**. This is meta-learning — the skill design
patterns are often more transferable than the tool's features. Look for:

1. **Activation triggers** — Does the frontmatter/description specify trigger phrases or
   intent patterns? How does it tell the agent *when* to fire?
2. **Pre-action gates** — Does it force the agent to think before acting? ("Check brand
   guidelines before creating", "Read the spec before implementing")
3. **Decision tables** — Does it help the agent choose between modes/approaches based on
   context? (e.g., "Use React for dashboards, Vanilla for portability")
4. **Inline API reference** — Does it include a complete reference of available tools,
   components, or APIs directly in the skill definition so the agent never has to guess?
5. **Layered reference system** — Does it separate quick-reference (inline) from
   deep-reference (separate files read on-demand)?
6. **Decision guidance** — Does it teach *when* to use feature A vs. feature B, not just
   document both? (e.g., "Use state for current values, events for audit trails")
7. **Reusable building blocks** — Does it provide pre-built components/templates with
   documented props/parameters that the agent can compose?

Document these patterns as a separate Core Idea in the report. They're often the
highest-transferability finding because they improve every skill in the ecosystem.

### Step 2: Extract Core Ideas

Break down what you found into structured knowledge:

```markdown
## Core Ideas

### Idea 1: [Name]
- **What**: One-sentence description
- **How**: Technical approach (2-3 sentences)
- **Why it matters**: What problem does this solve?
- **Key pattern**: The reusable pattern or technique

### Idea 2: [Name]
...
```

Focus on patterns and techniques that are transferable — not just "what this tool does" but
"what approach does it use that could apply elsewhere."

### Step 3: Map to Existing Skills

Read the user's existing Claude Code skills from `~/.claude/` to understand what they
currently have. Then create an explicit mapping:

```markdown
## Integration Map

| New Idea | Existing Skill | Integration Opportunity | Effort |
|----------|---------------|------------------------|--------|
| State sync pattern | (none) | New skill: bidirectional state management | Medium |
| Self-correction loop | feather-spec | Add feedback capture to spec workflow | Low |
| Session wrap-up | create-shortcut | Auto-generate shortcuts from session learnings | Low |
```

Categorize each opportunity:

- **Enhance existing** — add capability to a skill you already have
- **New skill** — create something new inspired by the idea
- **New workflow** — combine multiple skills in a new way
- **Reference only** — interesting to know but not actionable right now

### Step 4: Feasibility & Impact Assessment

For each integration opportunity, assess:

- **Feasibility**: Can this be built with Claude Code's current capabilities?
- **Impact**: How much would this improve your workflow?
- **Dependencies**: Does this need external tools, APIs, or packages?
- **Risk**: Could this break existing skills or workflows?

### Step 5: Coverage Audit

Before writing the report, audit what you actually read vs. what you skipped. This
prevents blind spots from silently making it into the final report.

**Create a mental checklist:**

| Category | Files/Sources | Read? | Likely Important? |
|----------|--------------|-------|-------------------|
| Core source files | (list main implementation files) | Yes/No | Yes/No |
| Config/build files | (package.json, tsconfig, etc.) | Yes/No | Probably not |
| Examples/demos | (examples/, demos/, DEMOS.md) | Yes/No | Yes — shows intended usage |
| Tests | (tests/, __tests__/) | Yes/No | Maybe — shows edge cases |
| Docs/references | (docs/, references/, CONTRIBUTING.md) | Yes/No | Maybe |
| Research/design | (research/, design/, ADRs) | Yes/No | Yes — shows decisions and alternatives |
| Client/browser code | (if applicable) | Yes/No | Yes — other half of the architecture |
| Issues/discussions | (GitHub issues, PRs) | Yes/No | Maybe — community feedback |

**Rules:**
- If something is marked "Likely Important" but "Not Read" — go read it now, or flag it
  explicitly in the report as a known gap.
- If the source is a Claude Code skill/plugin and you haven't read the SKILL.md or hook
  definitions, that's a critical gap — go back and read them.
- It's OK to skip files. It's NOT OK to skip them silently.

### Step 6: Generate the Report

Create a structured markdown report and save it to:
`~/.claude/siraj-experiments/reports/{idea-name}-{date}.md`

Use this template (read from `references/report-template.md`).

The report should be thorough but scannable. Use the template structure but write with
personality — explain why things are interesting, not just what they are.

### Step 7: Present for Review

After generating the report, present a summary to the user with:
1. Top 3 most promising integration opportunities
2. Recommended next step (which integration to build first)
3. Ask: "Which of these would you like me to build into a working skill?"

Wait for the user's response before proceeding to Phase 2.

---

## Phase 2: Integrate & Build

This phase runs only after the user reviews the report and approves specific integrations.

### Step 1: Design the Skill

Based on the user's selection, design the new skill following these patterns:

- Follow the feather-spec approach for requirements if the skill is complex
- Use the standard skill structure (SKILL.md + scripts/ + references/)
- Keep it lean — start with the core value and iterate

### Step 2: Build the Skill

Create the skill in: `~/.claude/siraj-experiments/{skill-name}/`

Structure:
```
{skill-name}/
├── SKILL.md              # The skill definition
├── scripts/              # Any automation scripts
├── references/           # Reference docs or examples
└── ORIGIN.md             # Where this came from (URL, date, key insights)
```

The ORIGIN.md file is important — it creates traceability back to the source idea. Include:
- Source URL
- Date studied
- Key ideas extracted
- Which ideas were integrated
- Link to the study report

### Step 3: Test the Skill

Create 2-3 realistic test prompts and describe them to the user. The user can run these
in Claude Code to verify the skill works as expected.

### Step 4: Document for Future Integration

If the user has a feather-skills repo (or plans to create one), generate a short summary
of what this skill does and where it fits, so it can be added to the repo later.

---

## Report Template

The report follows this structure (see `references/report-template.md` for full template):

```markdown
# Study Report: {Source Name}

**Source:** {URL}
**Studied:** {Date}
**Type:** {GitHub Repo | Blog Post | Documentation | Package | Other}

## Executive Summary
{2-3 sentences: what this is and why it's interesting}

## Source Analysis
### Overview
### Architecture & Key Patterns
### Technical Stack
### Strengths
### Limitations
### Comparison with Existing Ecosystem

## Core Ideas Extracted
### Idea 1: {Name}
### Idea 2: {Name}
...

## Integration Map
{Table mapping ideas to existing skills}

## Recommendations
### Quick Wins (Low effort, high impact)
### Strategic Integrations (Higher effort, transformative)
### Reference Only (Interesting but not actionable now)

## Proposed Experiments
### Experiment 1: {Name}
- **Goal:** ...
- **Approach:** ...
- **Success criteria:** ...

## Next Steps
{What to build first and why}
```

---

## File Locations

| What | Where |
|------|-------|
| Study reports | `~/.claude/siraj-experiments/reports/` |
| Built skills | `~/.claude/siraj-experiments/{skill-name}/` |
| This skill | `~/.claude/siraj-experiments/study-idea/` |

---

## Tips for the Agent

- When studying a GitHub repo, don't just read the README. Read the actual source code to
  understand the patterns and techniques used. The README tells you what it does; the code
  tells you how, and the "how" is where the reusable insights live.

- When mapping to existing skills, think creatively about connections. A state management
  pattern from a UI library might inspire a new way to handle skill configuration. A testing
  approach from one domain might improve how you validate another skill's output.

- The user values depth over breadth. It's better to deeply understand 3 patterns from a
  repo than to superficially list 10.

- Always include the ORIGIN.md file in built skills. Traceability matters — months later,
  the user should be able to see where an idea came from and revisit the source.

- The user is building a personal knowledge and skill ecosystem. Each study-idea run should
  feel like it's adding a meaningful node to that ecosystem, not just generating a report.

- When the source is a Claude Code skill or plugin, the **skill design patterns** (how it
  teaches Claude to use it) are often the most transferable finding. Don't just study what
  the tool does — study how it instructs the agent. Activation triggers, pre-action gates,
  decision tables, and inline references are patterns that improve every skill in the ecosystem.

- **WebFetch summarizes content through an AI model**, which loses precision for source code.
  For GitHub repos, prefer `gh api repos/{owner}/{repo}/contents/{path} -q '.content' | base64 -d`
  to get raw file content when exact code matters (e.g., hook scripts, skill definitions,
  core logic). Use WebFetch for READMEs and prose where summaries are acceptable.

- **Always compare with the existing ecosystem.** Before writing Core Ideas, check what the
  user already has that's similar. The comparison section often surfaces the most actionable
  insight: "you already have X, this new thing adds Y on top of it" is more useful than
  "here's a cool new thing" in isolation.
