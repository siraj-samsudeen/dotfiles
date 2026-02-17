# Feather Install UX

**Question:** How should feather-flow handle installation and updates — with the best UX in the Claude Code skills ecosystem?
**Status:** In Progress
**Started:** 2026-02-17
**Last Updated:** 2026-02-17

## Context

feather-flow currently uses a bash installer (`curl | bash`) that does destructive wipe-and-replace on updates. No local modification detection, no changelog, no update notifications. GSD has a better model (npm-based, SHA256 manifest, backup of local mods) but its reapply-patches step just dumps files and leaves the user stranded. Vercel's `npx skills` has zero local mod handling — updates silently overwrite. The goal is to leapfrog both.

## Log

### 2026-02-17 — Deep research on three approaches

Researched three install/update ecosystems in depth:

**GSD (get-shit-done):**
- npm package (`npx get-shit-done-cc`), 1815-line Node.js installer
- SHA256 manifest (`gsd-file-manifest.json`) for per-file change detection
- Backs up locally modified files to `gsd-local-patches/`
- `/gsd:reapply-patches` command for manual re-application (but UX is poor — just dumps files)
- SessionStart hook for background update check + statusline indicator
- Changelog display before updating

**Vercel `npx skills`:**
- npm package, multi-agent support (35+ agents)
- SKILL.md format (which feather-flow already uses!)
- Git SHA tracking per skill folder (not per file)
- Zero local modification handling — updates overwrite silently
- skills.sh registry for discoverability
- Symlink or copy installation modes

**Current feather-flow:**
- Bash installer, zero dependencies
- Copies to `~/.claude/feather-flow/`, symlinks into `~/.claude/skills/`
- Update = re-run install.sh (destructive wipe)
- No manifest, no update check, no changelog

**Proposed architecture:**
- Own npm package (`npx feather-flow`) for install — calls could wrap Vercel internally but we need full control for manifest/hooks
- `/feather:update` Claude skill for interactive update — shows diff per locally-modified file, user picks keep/take/compare
- SessionStart hook for background update check (stdout notification, not statusline — avoids GSD conflict)
- Vercel SKILL.md compatibility so `npx skills add` works as alternative basic install
- Full implementation plan written at `/Users/siraj/.claude/plans/iterative-toasting-torvalds.md`

## Findings

### Three-approach comparison

| Aspect | feather-flow (current) | GSD | Vercel `npx skills` |
|--------|----------------------|-----|---------------------|
| Install | `curl \| bash` | `npx get-shit-done-cc` | `npx skills add owner/repo` |
| Update | Re-run install (wipe) | `/gsd:update` → npx | `npx skills update` |
| Local mod handling | None | SHA256 manifest → backup | None (overwrites) |
| Dependencies | Zero | Node.js | Node.js |
| Update notification | None | SessionStart hook + statusline | None |

### Key insight: the interactive merge gap

No one in the Claude Code ecosystem does interactive merge well. GSD detects modifications and backs them up, but the reapply step is manual and unguided. Vercel doesn't detect modifications at all. The opportunity is to be the first to show diffs inline in the Claude conversation and walk the user through each decision.

### Vercel PR opportunity

Vercel's `npx skills update` (in `cli.ts`) has no per-file hashing, no local mod detection, no merge strategy. Three additions would benefit the entire ecosystem:
1. Per-file content hashing in lock file
2. Local modification detection on update
3. Interactive merge prompt

### Notification strategy

Can't use statusline (GSD owns it at `settings.json` line 117-120). SessionStart hook stdout goes into system prompt — Claude sees it and can proactively inform user. This is actually cleaner.

## Next Steps

- Implementation plan is ready at `/Users/siraj/.claude/plans/iterative-toasting-torvalds.md`
- Slice 1+3: npm package + CLI + manifest + update hook
- Slice 2: `/feather:update` skill with interactive merge
- Slice 4: Vercel compat docs
- Pre-flight: verify `feather-flow` is available on npm
