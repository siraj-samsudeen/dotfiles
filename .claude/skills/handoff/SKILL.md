---
name: handoff
description: Use when the user asks to hand off a specific task to a fresh agent after a long or topic-switching conversation — extracts only the decisions, artifacts, and context load-bearing for that one task and writes them to ./AGENT_HANDOFF.md at the repo root.
---

# handoff

## Overview

When a conversation has covered multiple topics and the user wants to pass one specific task to a fresh agent, this skill extracts only the load-bearing slice for that task. Output always goes to `./AGENT_HANDOFF.md` at the repo root.

Goal: a fresh agent reads the handoff cold and has everything it needs for the named task — nothing more, nothing tangential.

## When to use

- User says "/handoff", "hand off this to an agent", "write a handoff for X", "extract context for the next task".
- Conversation covers multiple topics; the next task is only one of them.
- User wants structured context for a fresh agent without dumping the whole conversation.

## When NOT to use

- Single-topic conversation where the full conversation IS the handoff.
- Handoff intended for a human teammate who wants prose — write a normal doc.
- The task doesn't exist yet — brainstorm first, then handoff.

## Process

1. **Ask the task.** "What task are you handing off?" Confirm scope if the user already named it.
2. **Scan for load-bearing artifacts.** Decisions made, files written, issues filed, vault principles referenced.
3. **Curate ruthlessly.** Apply Just Enough — include only what the fresh agent needs to act on THIS task. Pointer-link to vault principles / issues / files rather than inlining.
4. **Draft the handoff** using the template below; follow the repo's file-layout conventions.
5. **Write to `./AGENT_HANDOFF.md`** at the repo root. Overwrite if it exists — one handoff lives at a time. The user reviews the file in their editor; edit the file directly if they request changes. **Do NOT paste the full draft inline in chat** — long markdown blocks are hard to read there.

## Template

```markdown
# Agent Handoff: <task name>

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

## References

- Issues, specs, principles, related conversations.
```

## Curation rules

- **No user-local paths.** Never reference `~/Dropbox/...`, `/Users/<name>/...`, or any other machine-specific path. Handoff docs must be portable — a teammate cloning the repo on their machine should find everything they need. If a vault principle is load-bearing, fold its essential content into a repo doc first (e.g., `docs/conventions/...`), then link the repo doc.
- **Pointer beats inline** (for repo-local paths only). "See `docs/conventions/code-layout.md`" beats repeating the content.
- **Include decisions, not debates.** Summarize conclusions; skip the meta back-and-forth that produced them.
- **Cite concrete file paths and line ranges** where useful.
- **Test each section with the strip test** — would a fresh agent still know how to act if this were deleted?

## Common mistakes

- Writing the handoff before asking the user for the task scope. The user knows what's load-bearing; guessing wastes a round trip.
- Inlining whole principle files that already exist in the vault. Link instead.
- Including tangential discussions. Just Enough — if the fresh agent can act without it, drop it.
- Writing to a non-standard location. Always `./AGENT_HANDOFF.md` at repo root; if the user wants a different target, that's a different skill or a manual edit.

## Related principles

- `principle-just-enough.md` — sizing discipline for the handoff itself.
- `patterns/file-layout-template.md` — formatting conventions.
- `principle-design-for-agents-and-humans.md` — note: this skill is agent-only by design; if the handoff also needs a human-readable version, write it separately.
