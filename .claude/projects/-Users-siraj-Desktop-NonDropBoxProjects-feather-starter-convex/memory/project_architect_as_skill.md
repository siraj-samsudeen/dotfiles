---
name: LLM Architect is a Claude Code skill, not an API client
description: Phase 999.3 pivot — architect conversation runs as /feather:architect Claude Code skill, not @anthropic-ai/sdk. No API key management. Leverages user's existing AI tool.
type: project
---

The LLM Architect Conversation (Phase 999.3) is a **Claude Code skill** (`/feather:architect`), NOT a standalone API client calling `@anthropic-ai/sdk`.

**Why:** User challenged the premise (2026-03-29): "I expect them to use Claude Code or open code or some terminal to run the program — do I really need to deal with API keys?" Since users already have an AI tool running, the architect should leverage that tool's LLM rather than managing its own API connection.

**Key decisions:**
- Claude Code only for v1 (port to Cursor/Windsurf later if demand)
- Web preview dashboard (ER diagram + YAML + sample data + validation) opens in browser
- JSON checkpoint files in `.feather/conversations/` for multi-session state
- 3-layer validation: Zod → sample data → dry-run generation

**How to apply:** When referencing the architect feature, describe it as a skill/workflow, not an SDK integration. No `@anthropic-ai/sdk` dependency needed. The conversation protocol lives in a skill file, not a binary.
