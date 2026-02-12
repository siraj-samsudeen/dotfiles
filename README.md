# Dotfiles

Personal dotfiles managed with a [bare git repo](https://www.atlassian.com/git/tutorials/dotfiles) method.

## Setup (Fresh Mac)

```bash
# One-liner: clone, checkout, install everything
curl -sL https://raw.githubusercontent.com/siraj-samsudeen/dotfiles/master/setup.sh | bash
```

Or step by step: see `setup.sh` for what it does.

## What's Included

### Shell (zsh4humans + Powerlevel10k)
- `.zshrc` — main shell config (plugins, aliases, exports)
- `.zshenv` — z4h bootstrap (runs for every shell)
- `.p10k.zsh` — Powerlevel10k prompt theme

### Git
- `.gitconfig` — identity, aliases, editor, LFS, credential helpers
- `.gitignore` — global gitignore

### Tool Configs
- `.config/mise/config.toml` — version manager (node lts, python 3.13, bun)
- `RectangleConfig.json` — window manager shortcuts
- `.psqlrc` — PostgreSQL client (pspg pager, unicode borders)
- `.duckdbrc` — DuckDB (loads nanodbc ODBC extension)
- `.odbc.ini` — ODBC data source definitions (credentials stored separately)

### Claude Code
- `.claude/CLAUDE.md` — global AI assistant instructions
- `.claude/settings.json` — permissions and config
- `.claude/commands/` — custom slash commands
- `.claude/skills/` — custom skills
- `.claude/hooks/` — event hooks

## How It Works

Uses a **bare repo** in `~/.cfg` with `$HOME` as the work tree. The `.cfg-ignore` file uses an allowlist approach — everything is ignored by default (`*`), and tracked files are explicitly un-ignored with `!` entries.

See `.claude/siraj-experiments/dotfiles-audit.md` for the full audit of what's tracked, skipped, and why.
