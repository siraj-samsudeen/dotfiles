# Study Report: Browser Canvas

**Source:** https://github.com/parkerhancock/browser-canvas
**Studied:** 2026-02-11
**Type:** GitHub Repo (Claude Code Plugin)
**Studied by:** study-idea skill

---

## Executive Summary

Browser Canvas is a Claude Code plugin that turns file writes into live, interactive browser UIs — write `App.jsx` or `index.html` to `.claude/artifacts/`, and a hot-reloading browser window opens automatically. The biggest insight is its **file-as-protocol** architecture: Claude never calls an API or manages a server connection — it just writes files, and the system handles everything else (rendering, validation feedback, bidirectional state sync, screenshot capture). This is a fundamentally different approach from the existing feather/GSD mockup skills, which render static HTML snapshots via Playwright.

---

## Source Analysis

### Overview

Built by Parker Hancock, browser-canvas solves the problem of Claude Code having no native way to render interactive UIs. Where the existing mockup skills (feather:create-ui-mockup, gsd:mockup) produce static HTML screenshots, browser-canvas creates a **persistent, interactive, hot-reloading environment** where Claude can build React apps with shadcn/ui or vanilla HTML pages, get real-time validation feedback, and even exchange state with the running UI.

### Architecture & Key Patterns

```
Claude Code (writes files)
    │
    ├── .claude/artifacts/<name>/App.jsx     ← React mode
    ├── .claude/artifacts/<name>/index.html  ← Vanilla mode
    ├── .claude/artifacts/<name>/_state.json ← Bidirectional state
    └── .claude/artifacts/<name>/_log.jsonl  ← Unified event log
    │
    ▼
Bun + Hono Server (port 9847)
    │
    ├── chokidar file watcher (detects changes, debounced 100ms)
    ├── WebSocket bridge (pushes code/state to browser)
    ├── Validation pipeline (ESLint, scope check, Tailwind, bundle size, axe-core)
    ├── Component loader (skill → global → project layered lookup)
    └── Tailwind CSS builder (with project extensions)
    │
    ▼
Browser Window
    │
    ├── react-runner (executes JSX in-browser, React mode)
    ├── Injected bridge script (vanilla mode)
    ├── useCanvasState() hook / window.canvasState() API
    ├── window.canvasEmit() → _log.jsonl
    └── html2canvas screenshot capture
```

Key architectural decisions:
1. **File-as-protocol** — No APIs, no MCP tools. Claude just writes files. The watcher does the rest.
2. **Dual mode** — React (App.jsx with full component library) or vanilla (index.html, zero build).
3. **PostToolUse hook** — After every Write/Edit to App.jsx, a bash hook polls the validation API and injects errors as `additionalContext` back into Claude's conversation. Claude self-corrects without the user having to report errors.
4. **Layered component resolution** — skill → `~/.claude/canvas/components` → project `.claude/canvas/components`. Higher layers override lower.
5. **State bridge** — `_state.json` is read/written by both Claude (file ops) and browser (WebSocket), enabling forms, wizards, and interactive workflows.

### Technical Stack

- **Runtime:** Bun
- **Server:** Hono (HTTP + WebSocket)
- **File watching:** chokidar
- **React rendering:** react-runner (in-browser JSX execution)
- **JSX compilation:** sucrase (server-side, for custom components)
- **UI components:** shadcn/ui (Radix primitives), Tailwind CSS
- **Charts:** Recharts
- **Icons:** lucide-react
- **Validation:** ESLint (flat config), axe-core (a11y), custom scope/Tailwind validators
- **Screenshots:** html2canvas / modern-screenshot
- **Plugin system:** Claude Code plugin format (`.claude-plugin/marketplace.json`, hooks, skills)

### Strengths

1. **Zero-friction activation** — Claude writes a file, browser opens. No setup commands needed per-canvas.
2. **Auto-feedback loop** — The PostToolUse hook means Claude sees validation errors *automatically* after every edit. This is the killer feature — it creates a tight feedback loop without user intervention.
3. **Full React component library** — shadcn/ui + Recharts + custom components means Claude can build real dashboards, not just mockups.
4. **Vanilla escape hatch** — For simple needs, just write HTML. No React overhead.
5. **Extensible** — Projects can add their own components, Tailwind plugins, and scope packages.
6. **Plugin distribution** — Uses Claude Code's plugin system for installation.

### Limitations

1. **Bun dependency** — Requires Bun runtime, not Node.js. Extra install step for many users.
2. **macOS-centric** — `exec("open ...")` for browser launching is macOS-only (though easily fixable).
3. **Port hardcoded** — Validation hook hardcodes port 9847.
4. **React-runner limitations** — In-browser JSX execution can't handle all patterns (no imports, limited to scope).
5. **No Playwright integration** — Uses html2canvas for screenshots instead of Playwright, which you already have via MCP. Lower fidelity.
6. **Separate server process** — Must run alongside Claude Code as a background process.

### Comparison with Existing Mockup/UI Skills

You already have three skills that do UI rendering. Here's how they compare to browser-canvas:

#### feather:create-ui-mockup
- **Location:** `~/.claude/skills/feather:create-ui-mockup/SKILL.md`
- **What it does:** Quick, disposable UI mockups during design validation. Text diagram first, then inline HTML rendered via Playwright `data:text/html,` URLs. Dark mode default, pre-built CSS components (cards, buttons, badges, forms). Saves optionally to `docs/mockups/<slice-id>.html`.
- **Philosophy:** Lightweight and disposable — validate direction quickly, not final designs. Unlimited iterations.

#### gsd:mockup
- **Location:** `~/.claude/commands/gsd/mockup.md`
- **What it does:** Visual validation checkpoint before implementation. Same two-step process (text diagram → HTML render). Saves to `docs/mockups/{phase_slug}.html` with PNG screenshots alongside. Max 3 iteration limit. Reads from CONTEXT.md and SPEC.md for design decisions. Commits artifacts.
- **Philosophy:** More rigorous — required save + commit + feedback loops.

#### create-mockup.md (GSD workflow detail)
- **Location:** `~/.claude/get-shit-done/workflows/create-mockup.md`
- **What it does:** Detailed workflow spec powering gsd:mockup. Single-file self-contained HTML, inline CSS, system fonts, placeholder data. Shows multiple states (empty, loaded, error, hover). Mobile-responsive.

#### How browser-canvas differs

| Aspect | feather:create-ui-mockup | gsd:mockup | browser-canvas |
|--------|-------------------------|-----------|----------------|
| **Purpose** | Quick design sketches | Phase-level visual validation | Interactive UI prototyping |
| **Rendering** | Playwright via `data:` URL | Playwright via `file://` | Bun server + WebSocket hot-reload |
| **Interactivity** | None (static screenshot) | None (static screenshot) | Full (React hooks, event handlers, state) |
| **Feedback loop** | Manual (user reports issues) | Manual (user reports issues) | Automatic (PostToolUse hook injects errors) |
| **State sync** | None | None | Bidirectional via `_state.json` |
| **Component library** | Inline CSS snippets | From scratch each time | shadcn/ui + Recharts + custom components |
| **Iteration speed** | Write → screenshot → review | Write → screenshot → review → commit | Write → instant hot-reload |
| **Persistence** | Optional (`docs/mockups/`) | Required (saved + committed) | Always (`.claude/artifacts/`) |
| **Dependencies** | Playwright MCP (already have) | Playwright MCP (already have) | Bun runtime (new dependency) |
| **Build step** | None | None | Initial `bun install` + `bun run build` |
| **Best for** | "Does this layout feel right?" | "Does this match the spec?" | "Build me a working dashboard" |

**Key takeaway:** The existing skills are **design validation** tools (static snapshots for approval). Browser-canvas is an **interactive prototyping** tool (live, stateful UIs). They serve different stages — mockup skills validate direction early, browser-canvas builds working prototypes later. They complement rather than replace each other.

---

## Core Ideas Extracted

### Idea 1: File-as-Protocol for UI Rendering

- **What:** Use the filesystem as the communication protocol between Claude and a UI rendering system — write files to create/update UIs, read files to get state/events back.
- **How:** A file watcher (chokidar) monitors a known directory. When files appear or change, the watcher triggers rendering in a connected browser via WebSocket. State flows back through a `_state.json` file. Events flow to a `_log.jsonl` file.
- **Why it matters:** Eliminates the need for custom MCP tools, API calls, or server management from Claude's perspective. Claude already knows how to write files — this leverages that existing capability.
- **Key pattern:** **Convention-based file protocol** — specific filenames trigger specific behaviors (`App.jsx` = React, `index.html` = vanilla, `_state.json` = state sync, `_log.jsonl` = event log). The directory structure IS the API.
- **Transferability:** High — this pattern could be applied to any tool that needs to communicate with Claude: testing dashboards, documentation previews, API explorers.

### Idea 2: PostToolUse Hook as Automatic Feedback Loop

- **What:** A shell script that runs after every Write/Edit tool call, checks for validation errors, and injects them as `additionalContext` back into Claude's conversation — creating automatic self-correction.
- **How:** The hook intercepts Write/Edit events, extracts the file path, calls a validation API (`/api/canvas/:id/status?wait=true`), and if errors exist, returns JSON with `additionalContext` containing the error details. Claude sees these and fixes them without user prompting.
- **Why it matters:** This turns Claude from "write and hope" to "write, validate, fix" — a real development loop. The user doesn't have to copy-paste error messages or tell Claude something is wrong.
- **Key pattern:** **Hook-driven validation injection** — PostToolUse hooks that validate outputs and feed corrections back into the conversation. The pattern is: intercept tool call → validate result → inject context → Claude self-corrects.
- **Transferability:** High — this pattern works for ANY validation: linting, type checking, test running, accessibility auditing, security scanning. Any tool that can produce errors from a file can be wired into this loop.

### Idea 3: Bidirectional State Bridge via Shared File

- **What:** A `_state.json` file that both Claude (via file ops) and the browser (via WebSocket) can read and write, creating bidirectional state synchronization.
- **How:** Claude writes `_state.json`, the server detects the change and pushes state to the browser via WebSocket. The browser updates state via `useCanvasState()` hook or `window.canvasState()`, which sends state back to the server, which writes `_state.json`. Both sides see the same state.
- **Why it matters:** This enables interactive workflows — Claude can set form defaults, the user fills in the form, Claude reads the result. It turns a static UI into a conversation partner.
- **Key pattern:** **File-mediated state sync** — a shared file acts as the state bus between an AI agent and a running application. The file is the source of truth that both sides can observe and mutate.
- **Transferability:** Medium — requires a running application with WebSocket support. But the concept of "shared state file" between Claude and a running process is broadly applicable.

---

### Idea 4: SKILL.md as Comprehensive Activation System

- **What:** browser-canvas's SKILL.md is a ~450-line document that doesn't just describe the tool — it teaches Claude *when* to activate, *how* to think before acting, and provides a complete component/API reference inline. It's a masterclass in skill design.
- **How:** The SKILL.md uses several deliberate patterns:

  **1. Activation triggers in frontmatter:**
  ```yaml
  description: |
    Use when users ask to: show forms, render charts/graphs, create dashboards,
    display data tables, build visual interfaces, or show any UI component.
    Trigger phrases: "show me", "render", "display", "create a form/chart/table/dashboard".
  ```
  This tells Claude *when* to activate the skill without the user needing to invoke it explicitly. The skill fires on intent, not on command.

  **2. "Design First" gate before action:**
  Before creating anything, the skill instructs Claude to: check for brand guidelines, read `references/frontend-design.md` for typography/color/motion guidance, and consider the aesthetic direction. This prevents Claude from jumping straight to generic-looking UIs.

  **3. Mode selection guidance:**
  A decision table helps Claude choose the right mode:
  | File | Mode | Best For |
  |------|------|----------|
  | `App.jsx` | React | Rapid prototyping, complex forms, dashboards with charts |
  | `index.html` | Vanilla | Portable artifacts, standards-based code, durability |

  **4. Complete inline API reference:**
  Instead of sending Claude to external docs, the SKILL.md includes every available component, hook, icon, utility, and CSS variable — with copy-paste-ready examples. Claude never has to guess what's in scope.

  **5. Layered reference system:**
  The skill separates quick-reference (inline) from deep-reference (files):
  | Reference | When to Read |
  |-----------|--------------|
  | `references/frontend-design.md` | Before creating any new canvas |
  | `references/components.md` | Need specific component props |
  | `references/charts.md` | Building charts |
  | `references/patterns.md` | Building forms, tables, wizards |

  This keeps the main SKILL.md scannable while providing depth on demand.

  **6. State vs Events decision guide:**
  | `_state.json` | `_log.jsonl` events |
  |---------------|---------------------|
  | Current snapshot | Append-only log |
  | Two-way sync | One-way (canvas → agent) |
  | "What's true now" | "What happened" |

  Instead of just documenting both APIs, the skill teaches Claude *when to use which*. This is decision guidance, not just reference.

  **7. Reusable component catalog with props:**
  Pre-built components (ContactForm, DataChart, DataTable, StatCard, ActivityFeed, ProgressList, MarkdownViewer) are documented with full props and working examples. Claude can assemble dashboards from these building blocks without writing everything from scratch.

- **Why it matters:** Most skill definitions are thin instructions. This one is a full operating manual that makes Claude competent at a complex task without trial and error. The patterns — activation triggers, design gates, decision tables, inline references, layered docs — are transferable to any skill.
- **Key pattern:** **Skill-as-operating-manual** — A SKILL.md that combines activation triggers, pre-action thinking gates, decision guidance, inline API reference, and layered deep-references. The skill doesn't just tell Claude what the tool does — it teaches Claude how to think about using it well.
- **Transferability:** High — every skill in the feather/GSD ecosystem could benefit from these patterns. Especially: activation triggers in frontmatter, "think before acting" gates, and decision tables for choosing approaches.

---

## Integration Map

| # | New Idea | Existing Skill | Integration Type | Opportunity | Effort | Impact |
|---|----------|---------------|-----------------|-------------|--------|--------|
| 1 | PostToolUse validation hook | feather:create-ui-mockup, gsd:mockup | Enhance | Add auto-validation to existing mockup skills — when Claude writes HTML, validate it (HTML validity, a11y, broken links) and inject errors automatically | Low | High |
| 2 | File-as-protocol UI rendering | feather:create-ui-mockup | Enhance/Replace | Replace static Playwright screenshots with live hot-reloading previews. Keep Playwright for screenshots but add live preview | Med | High |
| 3 | Bidirectional state bridge | feather:verify | New | Create interactive verification UIs — user fills in a verification form in browser, Claude reads results from `_state.json` | High | Med |
| 4 | Plugin installation pattern | Study-idea skill | Reference | Learn from browser-canvas's plugin distribution to package skills for sharing | Low | Low |
| 5 | PostToolUse hook pattern | All skills that write code | New Skill | Create a generic "auto-lint" hook that validates any code Claude writes (not just canvas JSX) — TypeScript, Python, etc. | Med | High |
| 6 | Layered component resolution | feather:create-ui-mockup | Enhance | Add reusable component library for mockups (global components + project components) | Med | Med |
| 7 | SKILL.md activation patterns | All feather/GSD skills | Enhance | Add activation triggers, design-first gates, decision tables, and inline API references to existing skill definitions | Low | High |

---

## Feasibility Assessment

### Technical Feasibility

**Can this be integrated with current tools?** Yes, but with trade-offs:

- **Installing browser-canvas directly:** Fully feasible. Just `bun install` and run. But adds Bun as a dependency.
- **Extracting the PostToolUse hook pattern:** Very feasible. This is just a bash script — works today, no dependencies.
- **Replacing Playwright mockups with browser-canvas:** Partially feasible. You already have Playwright MCP, which handles screenshots. browser-canvas adds hot-reload and interactivity but requires the Bun server. The two could complement each other.
- **Building a validation hook skill:** Very feasible. The core pattern is simple: PostToolUse hook → validate → inject `additionalContext`.

### Dependencies

- **Bun runtime** — Required for browser-canvas itself. Not needed for extracting patterns.
- **Playwright MCP** — Already available in your setup. Can be used for screenshots instead of html2canvas.
- **Claude Code hooks system** — Already supported. PostToolUse hooks with `additionalContext` are the key mechanism.

### Risks

- **Server management complexity** — Running a background Bun server adds operational overhead.
- **Port conflicts** — Hardcoded port 9847 could conflict.
- **Doesn't replace Playwright** — You already have a working Playwright MCP for browser interaction. browser-canvas is additive, not a replacement.

---

## Recommendations

### Quick Wins (Low effort, high impact)

1. **Build a generic PostToolUse validation hook skill** — Extract the hook pattern from browser-canvas and create a configurable validation hook that auto-lints code after Claude writes it. Start with TypeScript/ESLint, extend to other languages. This is the most transferable and highest-impact idea, and it requires zero new infrastructure.

2. **Install browser-canvas as a plugin** — If you have Bun installed, just try it: `/plugin install parkerhancock/browser-canvas`. See if the interactive UI workflow is useful for your projects. This gives you the full experience with minimal effort.

### Strategic Integrations (Higher effort, transformative)

1. **Enhance feather:create-ui-mockup with hot-reload** — Instead of the current "write HTML → Playwright screenshot → iterate" loop, integrate browser-canvas so that mockups are live and interactive. Keep Playwright MCP for screenshot capture but use browser-canvas for rendering. This would make the mockup workflow significantly faster and more iterative.

2. **Interactive verification UIs** — For feather:verify, build interactive checklists/forms that run in the browser. The user checks off verification items in the browser, Claude reads the results via `_state.json`. This turns verification from a CLI conversation into a visual, interactive process.

### Reference Only (Interesting but not actionable now)

1. **Plugin distribution model** — browser-canvas uses Claude Code's plugin system (`marketplace.json`, hooks, skills). When you're ready to share your feather skills more broadly, this is the distribution pattern to follow.

2. **react-runner for in-browser JSX execution** — Interesting for building dynamic UIs without a build step, but Playwright MCP already handles browser interaction. Worth knowing about for future "Claude builds an app" workflows.

---

## Proposed Experiments

### Experiment 1: Auto-Validation Hook Skill

- **Goal:** Create a reusable PostToolUse hook that automatically validates code Claude writes and injects errors back into the conversation.
- **Approach:**
  1. Create a hook that intercepts Write/Edit tool calls
  2. Run validators based on file extension (eslint for .ts/.js, ruff for .py, etc.)
  3. Return `additionalContext` with errors/warnings
  4. Package as a configurable skill with enable/disable per project
- **Based on ideas:** #2 (PostToolUse hook as feedback loop)
- **Success criteria:** Claude auto-corrects a lint error without user intervention
- **Estimated effort:** 1-2 sessions

### Experiment 2: Live Mockup Preview

- **Goal:** Replace static Playwright screenshots in the mockup workflow with live hot-reloading browser previews.
- **Approach:**
  1. Install browser-canvas as a dependency
  2. Modify feather:create-ui-mockup to write to `.claude/artifacts/` instead of `data:` URLs
  3. Keep Playwright MCP for screenshot capture when needed
  4. Add iteration workflow: write → auto-reload → user feedback → edit → auto-reload
- **Based on ideas:** #1 (file-as-protocol), #2 (auto-validation)
- **Success criteria:** Mockup iteration is faster than current screenshot-based workflow
- **Estimated effort:** 2-3 sessions

### Experiment 3: Interactive Verification Forms

- **Goal:** Build browser-based verification forms that sync results back to Claude via `_state.json`.
- **Approach:**
  1. Use browser-canvas to render a verification checklist from feather:verify output
  2. User checks items in the browser
  3. Claude reads `_state.json` to see results
  4. Generate verification report from interactive feedback
- **Based on ideas:** #3 (bidirectional state bridge)
- **Success criteria:** User can complete a verification checklist in the browser instead of CLI
- **Estimated effort:** 3-4 sessions

---

## Next Steps

**Recommended first build:** Experiment 1 (Auto-Validation Hook Skill). It's the highest-impact, lowest-effort integration. It extracts the most transferable pattern from browser-canvas (the PostToolUse feedback loop) without requiring any new infrastructure. It works today with just a bash script and whatever linters you already have installed.

**Open questions:**
- Do you have Bun installed? If so, Experiment 2 becomes much more feasible.
- How often do you iterate on UI mockups? If frequently, the live preview (Experiment 2) might be worth prioritizing over the validation hook.
- Are there specific validators you'd want in the auto-validation hook? (TypeScript, Python, Go, etc.)

---

*Generated by study-idea skill on 2026-02-11*
*Source: https://github.com/parkerhancock/browser-canvas*
