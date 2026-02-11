# feather-flow Standalone Repo

## Status: Execution complete

## Problem

Feather's 21 skills currently live as loose files in `~/.claude/skills/`. They can't be shared, versioned, or installed by others. GSD has a proper GitHub repo with distribution, but it's heavy (35+ commands, 15 agents, npm package, Node.js required). There's no lightweight alternative for quick projects or people new to Claude Code.

## Solution

Package feather as `feather-flow` — a standalone GitHub repo with a simple `curl | bash` installer. Zero dependencies, pure markdown, one command install. A competitor to GSD, not a plugin for it.

## Key Design Decisions

1. **Self-contained install** — installs to `~/.claude/feather-flow/`, adds skills path to `additionalDirectories` in settings.json. One directory = one product.
2. **Keep `feather:` prefix** — it's the brand, it namespaces cleanly, changing would break cross-references.
3. **No CLAUDE.md ships with it** — would overwrite user's existing one.
4. **No package.json, no node_modules, no build step** — pure markdown + two shell scripts.
5. **python3 for JSON manipulation** — ships with macOS, standard on Linux, avoids jq dependency.
6. **VERSION file at root** — plain text `1.0.0`, also serves as install marker.

## Relationship to feather-gsd

feather-gsd (the GSD fork with feather quality features) is already done and separate. feather-flow is the canonical source of truth for skill content. feather-gsd pulls from it when syncing — but that's feather-gsd's concern, not feather-flow's.

## Repo Location

GitHub: `sirajraval/feather-flow`
Local: `/Users/siraj/feather-flow/`

## Superpowers Attribution

Several skills have lineage from [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent (MIT, v4.1.1). Full attribution in ACKNOWLEDGMENTS.md. See the plan for detailed lineage categories.

## Date

2025-02-10 (planned), 2026-02-11 (executed)
