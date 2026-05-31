---
name: handoff
description: Use when the user asks to hand off a specific task to a fresh agent after a long or topic-switching conversation — extracts only the decisions, artifacts, and context load-bearing for that task and writes them to ./handoff_[topic].md at the repo root.
---

# handoff

## Overview

When a conversation has covered multiple topics and the user wants to pass one specific task to a fresh agent, this skill extracts only the load-bearing slice for that task. Output goes to `./handoff_[topic].md` where `[topic]` is derived from the task scope.

Goal: a fresh agent reads the handoff cold and has everything it needs for the named task — nothing more, nothing tangential. Topic naming makes multiple handoffs discoverable and avoids clobbering.

## When to use

- User says "/handoff", "hand off this to an agent", "write a handoff for X", "extract context for the next task".
- Conversation covers multiple topics; the next task is only one of them.
- User wants structured context for a fresh agent without dumping the whole conversation.

## When NOT to use

- Single-topic conversation where the full conversation IS the handoff.
- Handoff intended for a human teammate who wants prose — write a normal doc.
- The task doesn't exist yet — brainstorm first, then handoff.

## Process

1. **Identify possible handoff topics.** Scan the current conversation and user's request. If multiple distinct tasks/topics exist, list them (2-4 max). If only one is clear, proceed. If user specified a topic explicitly, use that.
2. **Prompt for choice if multiple topics.** Ask the user which topic(s) to write a handoff for. Offer single or multiple selections.
3. **Suggest a topic slug.** For the chosen task, derive a kebab-case topic name (e.g., `bugfix-auth`, `feature-dark-mode`, `refactor-db-layer`). Show the user the suggested name; allow them to override.
4. **Scan for load-bearing artifacts.** Decisions made, files written, issues filed, vault principles referenced — specific to this task.
5. **Curate ruthlessly.** Apply Just Enough — include only what the fresh agent needs to act on THIS task. Pointer-link to vault principles / issues / files rather than inlining.
6. **Draft the handoff** using the template below; follow the repo's file-layout conventions.
7. **Write to `./handoff_[topic].md`** at the repo root. The user reviews the file in their editor; edit the file directly if they request changes. **Do NOT paste the full draft inline in chat** — long markdown blocks are hard to read there. Multiple handoffs can coexist (one per topic).

## Template

Filename: `handoff_[topic].md` (e.g., `handoff_bugfix-auth.md`, `handoff_feature-dark-mode.md`)

```markdown
# Handoff: <task name>

**Task:** <one-line summary of what the next agent must do>
**Scope:** <one-line what's in; what's out>
**Date captured:** YYYY-MM-DD

## Decisions already made

- <decision> — <pointer to rationale: issue, vault principle, commit>
- ...

## Artifacts produced in this conversation

| Artifact | Location | Role for this task |
|---|---|---|
| ... | ... | ... |

## Prerequisites

Verifications or setup the agent must do before starting.

## Where to start

Concrete first action. Usually: "read these files, then <do X>."

## Deferred / out of scope

Items explicitly NOT to tackle, with pointers to where they live instead.

## Suggested skills

Skills the next agent should invoke for this task (e.g. `/diagnose` for the bug, `/to-issues` to file follow-ups). Omit if none apply.

## References

- Issues, specs, principles, related conversations.
```

## Curation rules

- **No user-local paths.** Never reference `~/Dropbox/...`, `/Users/<name>/...`, or any other machine-specific path. Handoff docs must be portable — a teammate cloning the repo on their machine should find everything they need. If a vault principle is load-bearing, fold its essential content into a repo doc first (e.g., `docs/conventions/...`), then link the repo doc.
- **Redact secrets.** Never write API keys, passwords, tokens, connection strings with credentials, or PII into the handoff. Reference the secret's location (env var name, vault entry) instead of its value.
- **Pointer beats inline** (for repo-local paths only). "See `docs/conventions/code-layout.md`" beats repeating the content.
- **Include decisions, not debates.** Summarize conclusions; skip the meta back-and-forth that produced them.
- **Cite concrete file paths and line ranges** where useful.
- **Test each section with the strip test** — would a fresh agent still know how to act if this were deleted?

## Common mistakes

- Writing the handoff before asking the user for the task scope (or identifying multiple possible scopes). The user knows what's load-bearing; guessing wastes a round trip.
- Skipping the topic-suggestion step. A thoughtful topic name (`bugfix-auth` vs `refactor-db`) makes handoffs discoverable and helps the user choose if multiple exist.
- Inlining whole principle files that already exist in the vault. Link instead.
- Including tangential discussions. Just Enough — if the fresh agent can act without it, drop it.
- Writing to a non-standard location. Always `./handoff_[topic].md` at repo root; topic should be kebab-case and concise. Multiple handoffs can coexist (one per topic).

## Related principles

- `principle-just-enough.md` — sizing discipline for the handoff itself.
- `patterns/file-layout-template.md` — formatting conventions.
- `principle-design-for-agents-and-humans.md` — note: this skill is agent-only by design; if the handoff also needs a human-readable version, write it separately.
