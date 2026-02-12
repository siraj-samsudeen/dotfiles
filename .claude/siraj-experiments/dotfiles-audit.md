# Dotfiles Audit & Cleanup

**Purpose:** Review all dotfiles in `$HOME`, decide what to track/delete/ignore, and clean up stale configs.

**Date:** 2026-02-11
**Repo:** `~/.cfg` (bare repo) → https://github.com/siraj-samsudeen/dotfiles

---

## Background: Zsh File Load Order

```
.zshenv    → EVERY shell (login, interactive, scripts, subshells)
.zprofile  → login shells only
.zshrc     → interactive shells only
.zlogin    → login shells only (after .zshrc)
```

- `.zshenv` is the entry point — z4h (zsh4humans) bootstraps here
- `.zshrc` is where most config lives (plugins, aliases, exports)
- `.zprofile` / `.zlogin` — rarely needed for personal use
- Bash equivalents (`.bash_profile`, `.profile`) are **never read by zsh**

---

## Decisions

| # | File | Decision | Reason |
|---|------|----------|--------|
| 1 | `.gitconfig` | **Track** | Identity, aliases, editor, LFS, credential helpers. No secrets. |
| 2 | `.gitignore` | **Track** | Global gitignore. Currently ignores `.cfg` bare repo db. |
| 3 | `.zprofile` | Skip | Just Homebrew boilerplate (`eval brew shellenv`). Machine-specific, re-added on install. |
| 4 | `.bash_profile` | **Deleted** | Zsh never reads it. SDKMAN uninstalled. Conda/Volta already in `.zshenv`. |
| 5 | `.profile` | **Deleted** | Zsh never reads it. Volta already in `.zshenv`. |
| 6 | `.iterm2_shell_integration.zsh` | Skip | Sourced in `.zshrc` line 99. Enables command marks, Cmd+click paths, directory tracking, imgcat. Not tracked because iTerm2 manages and auto-updates it. |
| 7 | `.iex.exs` | **Deleted** | Empty file. Elixir IEx config — no customization present. |
| 8 | `.condarc` | **Deleted** | Only contained `channels: defaults` — Conda's built-in default. |
| 9 | `.npmrc` | Skip | Contains `${NPM_TOKEN}` env var reference. Not needed cross-machine. |
| 10 | `.psqlrc` | **Track** | pspg pager, unicode borders. Personal config that makes psql usable. |
| 11 | `.duckdbrc` | **Track** | Loads nanodbc ODBC extension. Active across multiple DuckDB versions. |
| 12 | `.mcp.json` | **Deleted** | Empty placeholder `{}`. Real MCP config lives in project-level files and `~/.claude/settings.json`. |

---

## Secrets Strategy

**Decision:** Use `~/.secrets` file (sourced from `.zshrc`)

Alternatives considered:
- **macOS Keychain** — encrypted, most secure, but harder to audit/edit. Overkill for dev tokens.
- **1Password CLI** — requires vault unlock, most friction.
- **`~/.secrets` file** — simple, plaintext, `chmod 600`. Good enough for dev tokens on a personal machine.

Note: FileVault is currently **OFF**. Recommended to enable (System Settings → Privacy & Security → FileVault). No performance impact on Apple Silicon.

Setup:
- `~/.secrets` — untracked file, `chmod 600`, holds `export NPM_TOKEN=...` (and future secrets)
- Sourced in `.zshrc` (line 98) via `[[ -f ~/.secrets ]] && source ~/.secrets`
- `.npmrc` updated to reference `${NPM_TOKEN}` instead of hardcoded token
- Old classic token was auto-revoked by npm (policy change: all classic tokens revoked)
- New granular token: 90-day expiry (npm's max), read+write for `convex-test-provider`
- Rotation reminder: token expires ~May 2026

---

## Files Changed

- `~/.cfg-ignore` — added comments to Git section, added `.gitignore` to allowlist, added "Intentionally NOT tracked" section
- `~/.npmrc` — replaced hardcoded token with `${NPM_TOKEN}`
- `~/.zshrc` — added secrets sourcing block
- `~/.odbc.ini` — removed inline credentials, reference ~/.secrets instead
- `~/.npmrc` — replaced hardcoded token with `${NPM_TOKEN}`
- `~/.secrets` — created with NPM_TOKEN, bank passwords, ODBC credentials
- Deleted: `.profile`, `.bash_profile`, `.iex.exs`, `.condarc`, `.mcp.json`,
  `.opencode.json`, `.tcshrc`, `.xonshrc`, `.yarnrc`, `.zprofile.pysave`,
  `.p10k.zsh.zwc`, `.DS_Store`, `.bank_passwords`, `.claude.json.backup*`

---

*Last updated: 2026-02-11*
