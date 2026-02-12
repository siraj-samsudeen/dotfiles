# feather-flow Standalone Repo

## Status: Complete — published and tested

## Problem

Feather's 21 skills currently live as loose files in `~/.claude/skills/`. They can't be shared, versioned, or installed by others. GSD has a proper GitHub repo with distribution, but it's heavy (35+ commands, 15 agents, npm package, Node.js required). There's no lightweight alternative for quick projects or people new to Claude Code.

## Solution

Package feather as `feather-flow` — a standalone GitHub repo with a simple `curl | bash` installer. Zero dependencies, pure markdown, one command install. A competitor to GSD, not a plugin for it.

## Key Design Decisions

1. **Symlinks for skill discovery** — installs to `~/.claude/feather-flow/`, creates symlinks in `~/.claude/skills/` so Claude Code discovers them. `additionalDirectories` only controls file access scope, NOT skill scanning.
2. **Keep `feather:` prefix** — it's the brand, it namespaces cleanly, changing would break cross-references.
3. **No CLAUDE.md ships with it** — would overwrite user's existing one.
4. **No package.json, no node_modules, no build step** — pure markdown + two shell scripts.
5. **VERSION file at root** — plain text `1.0.0`, also serves as install marker.

## Lessons Learned

- **`additionalDirectories` is NOT for skill discovery.** It grants file read/write permission. Skills must be in `~/.claude/skills/` or `.claude/skills/` to be found. Symlinks from `~/.claude/skills/feather:*` → `~/.claude/feather-flow/skills/feather:*` solve this cleanly.
- **Stale cross-references compound.** The audit found 27 stale references across 11 files using 6+ different old naming conventions. Automated grep-based audits are essential before v1.0.
- **Bare repo dotfiles + git rm** leaves empty directories behind (`.DS_Store` files prevent cleanup). Manual cleanup needed.

## Repo Location

GitHub: https://github.com/siraj-samsudeen/feather-flow
Local: `/Users/siraj/feather-flow/`

## Superpowers Attribution

Several skills have lineage from [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent (MIT, v4.1.1). Full attribution in ACKNOWLEDGMENTS.md.

## Date

2025-02-10 (planned), 2026-02-11 (executed and published)
