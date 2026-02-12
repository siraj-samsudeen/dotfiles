# Dotfiles Audit & Cleanup

> **Question:** Which dotfiles should be tracked, deleted, or ignored in the bare repo?
> **Status:** Complete
> **Started:** 2026-02-11
> **Last Updated:** 2026-02-11

---

## Context

The `~/.cfg` bare repo tracks dotfiles via `alias dotfiles='git --git-dir=$HOME/.cfg --work-tree=$HOME'`. Over time, stale configs accumulated — bash files never read by zsh, empty placeholders, and secrets mixed into tracked files. This audit reviewed every dotfile in `$HOME` to decide: track, delete, or ignore.

### Zsh File Load Order (Reference)

```
.zshenv    → EVERY shell (login, interactive, scripts, subshells)
.zprofile  → login shells only
.zshrc     → interactive shells only
.zlogin    → login shells only (after .zshrc)
```

- `.zshenv` is the entry point — z4h (zsh4humans) bootstraps here
- `.zshrc` is where most config lives
- Bash equivalents (`.bash_profile`, `.profile`) are never read by zsh

---

## Log

Audited 12 dotfiles in `$HOME`. Applied three criteria: (1) does zsh actually read this? (2) does it contain secrets? (3) is it machine-specific or portable?

Deleted 5 files outright — bash files never read by zsh, empty placeholders, and a redundant conda config. Moved secrets to a new `~/.secrets` file sourced from `.zshrc`. Updated `.npmrc` to reference `${NPM_TOKEN}` instead of hardcoded tokens.

Also cleaned up 8 additional stale files: `.opencode.json`, `.tcshrc`, `.xonshrc`, `.yarnrc`, `.zprofile.pysave`, `.p10k.zsh.zwc`, `.DS_Store`, `.claude.json.backup*`.

---

## Findings

### Decisions Table

| # | File | Decision | Reason |
|---|------|----------|--------|
| 1 | `.gitconfig` | **Track** | Identity, aliases, editor, LFS. No secrets. |
| 2 | `.gitignore` | **Track** | Global gitignore. Ignores `.cfg` bare repo db. |
| 3 | `.zprofile` | Skip | Homebrew boilerplate. Machine-specific. |
| 4 | `.bash_profile` | **Deleted** | Zsh never reads it. |
| 5 | `.profile` | **Deleted** | Zsh never reads it. |
| 6 | `.iterm2_shell_integration.zsh` | Skip | iTerm2 manages and auto-updates it. |
| 7 | `.iex.exs` | **Deleted** | Empty file. |
| 8 | `.condarc` | **Deleted** | Only `channels: defaults` — Conda's built-in default. |
| 9 | `.npmrc` | Skip | Contains `${NPM_TOKEN}` env var reference. |
| 10 | `.psqlrc` | **Track** | pspg pager, unicode borders. |
| 11 | `.duckdbrc` | **Track** | Loads nanodbc ODBC extension. |
| 12 | `.mcp.json` | **Deleted** | Empty `{}`. Real config in project-level files. |

### Secrets Strategy

**Decision:** `~/.secrets` file sourced from `.zshrc` — simple, `chmod 600`, good enough for dev tokens on a personal machine.

Alternatives considered: macOS Keychain (overkill), 1Password CLI (too much friction).

Setup: `~/.secrets` holds `export NPM_TOKEN=...` and ODBC credentials. Sourced via `[[ -f ~/.secrets ]] && source ~/.secrets` in `.zshrc`. Note: FileVault is currently OFF — recommended to enable.

**Token rotation reminder:** npm granular token expires ~May 2026.

### Files Changed

- `~/.cfg-ignore` — added comments, allowlist, "Intentionally NOT tracked" section
- `~/.npmrc` — replaced hardcoded token with `${NPM_TOKEN}`
- `~/.zshrc` — added secrets sourcing block
- `~/.odbc.ini` — removed inline credentials
- `~/.secrets` — created with NPM_TOKEN, bank passwords, ODBC credentials

---

## Next Steps

None — audit complete. Re-run when adding new tools or switching machines.
