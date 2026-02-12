---
description: "Use when the user wants to study a URL/concept, log an idea for later research, or review their study queue."
argument-hint: "[url/concept to study or log]"
---

# /study-idea — Research & Queue Manager

## Your Input

The user will provide: $ARGUMENTS

## Phase 0: Route (Always Run First)

Read the queue file at `~/.claude/siraj-experiments/study-idea/queue.md`.

Then determine intent from `$ARGUMENTS`:

| User intent | How to detect | Action |
|-------------|--------------|--------|
| **Browse queue** | No arguments, or vague ("what's in my queue?") | → Show queue, ask what to do |
| **Log for later** | "log", "save", "queue", "capture", or a URL with a note but no study intent | → Append to queue.md, confirm, stop |
| **Study now** | A URL/concept with clear study intent ("study this", "deep dive", "research") | → Proceed to Phase 1 |

### Browse Queue

1. Display queued items (unchecked `- [ ]` entries) as a numbered list:
   ```
   Study Queue (N items):

   1. short-name — brief note
      https://example.com/url
      Added: YYYY-MM-DD
   ```
   If queue is empty, say so.
2. Use AskUserQuestion with each queued item as an option plus "Log a new idea".
3. If they pick an item → proceed to Phase 1 with that item's URL and notes.
   If they pick "Log a new idea" → ask for URL and notes, append, stop.

### Log for Later

Append to the `## Queued` section of `~/.claude/siraj-experiments/study-idea/queue.md`:
```markdown
- [ ] **{short-name}** — {url}
  {user's note about what to look for}
  _Added: {YYYY-MM-DD}_
```
Confirm with the queue count. **STOP.**

---

## Phase 1: Study

Follow this methodology to deeply study the source and produce a structured report.

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

Create a structured markdown report using the template at:
`~/.claude/siraj-experiments/study-idea/report-template.md`

Save the completed report to:
`~/.claude/siraj-experiments/study-idea/reports/{kebab-case-name}-{YYYY-MM-DD}.md`

The report should be thorough but scannable. Use the template structure but write with
personality — explain why things are interesting, not just what they are.

### Step 7: Present for Review

After generating the report, present a summary to the user with:
1. Top 3 most promising integration opportunities
2. Recommended next step (which integration to build first)
3. Ask: "Which of these would you like me to build into a working skill?"

Then **mark the queue item as studied** (if it came from the queue):
```markdown
- [x] **{short-name}** — {url}
  {original note}
  _Added: {date}_ · _Studied: {YYYY-MM-DD}_ · [Report](reports/{name}-{date}.md)
```

**STOP. Ask what's next.**

---

## After Study: What Next?

Use AskUserQuestion to present three options:

| Option | Description |
|--------|-------------|
| **Launch experiment** | Open-ended exploration — invokes `/experiment new` with context from the study (URL, core ideas, proposed experiments from the report) |
| **Build skill directly** | You know exactly what to build — proceeds to Phase 2 |
| **Done for now** | Keep the report, move on |

### Launch Experiment

Invoke the `/experiment` command in "new" mode. Pre-fill the context:
- **Question**: Derived from the study's top recommendation
- **Context**: Link to the study report, source URL, core ideas summary
- Let `/experiment` handle the rest (EXPLORATION.md, INDEX.md, etc.)

**STOP after handing off to /experiment.**

---

## Phase 2: Build Skill (Only If User Chose "Build Directly")

1. Design the skill (feather-spec if complex, brief sketch if simple)
2. Create in `~/.claude/siraj-experiments/{skill-name}/`:
   - `SKILL.md` — skill definition
   - `ORIGIN.md` — traceability (source URL, date, ideas extracted, report link)
   - `scripts/` and `references/` as needed
3. Provide 2-3 test prompts for verification

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

---

## Success Criteria

- Queue displayed when no clear study target provided
- New items appear in queue.md with name, URL, note, and date
- Studied items marked `[x]` with studied date and link to report
- Never starts a deep dive without clear user intent to study now
- At least 3 core ideas extracted with transferable patterns
- Integration map completed (every idea mapped to existing skill or gap)
- Coverage audit performed (no silently skipped important files)
- Report saved to `~/.claude/siraj-experiments/study-idea/reports/`
- Report uses the template at `~/.claude/siraj-experiments/study-idea/report-template.md`
- After study, user is offered experiment/build/done — not auto-routed
