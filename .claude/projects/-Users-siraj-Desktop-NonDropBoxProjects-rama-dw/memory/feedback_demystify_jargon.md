---
name: Demystify jargon — map unfamiliar terms to familiar ones
description: When explaining tools/features, always translate jargon to terms the user already knows
type: feedback
originSessionId: a63bfde6-ef29-41f0-963c-ae8c21711e0c
---
When explaining any tool, feature, or concept, actively map unfamiliar jargon to terms the user already understands. Don't just use the tool's native vocabulary and hope it clicks.

**Example trigger (2026-04-19, Datasette walkthrough):** I explained "facets" as facets. User said: *"facets = filters. you should review familiar terminology and demystify jargons."*

**How to apply:**
- When introducing a new term, give the plain-English equivalent in parentheses or as a translation: "facets (clickable filters on the sidebar)", "migration (renaming/reshuffling your data)", "merge_key (the column used to match rows when upserting)".
- If a tool uses a jargon term for a familiar concept (facet = filter, fixture = test data, mixin = shared code), lead with the familiar name, then mention the jargon once so the user can recognize it in docs.
- Before writing explanations, scan for jargon and ask: would someone who hasn't used this tool before understand this sentence? If not, translate.
- This applies to: DB terminology, framework concepts, Claude Code internals, CLI tool conventions, design patterns. Basically anywhere a term is "obvious" to me but opaque to someone new.

**Rule of thumb:** A walkthrough is for the user, not for the tool. Use the user's vocabulary; borrow the tool's only where it adds value.
