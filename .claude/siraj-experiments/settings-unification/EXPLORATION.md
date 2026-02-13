# VS Code & Cursor Settings Unification

> **Question:** Can VS Code and Cursor share one settings.json via symlink, with a Cursor profile for theme differentiation?
> **Status:** Phase 2 Complete
> **Started:** 2026-02-13
> **Last Updated:** 2026-02-13

---

## Context

VS Code and Cursor maintain separate `settings.json` files that have diverged over time. VS Code's is well-organized and curated; Cursor's is organic with stale extension settings accumulated over months. VS Code has Settings Sync enabled, making it the source of truth.

**Goal:** Merge into one shared file via symlink. Cursor uses a profile to override just the theme (Default Light+ instead of Monokai).

**Approach:** This is an experiment — backups of both originals are in `artifacts/` for easy rollback.

---

## Log

### Setting-by-Setting Decisions

| Category | Decision | Rationale |
|----------|----------|-----------|
| **Default formatter** | Biome globally (was Prettier) | Biome handles JS/TS formatting + linting + import sorting in one tool |
| **Code actions on save** | `source.fixAll` + `source.organizeImports` = `"explicit"` | Biome auto-fix and import sorting on save |
| **Python** | Keep Black formatter + existing overrides | Black is Python standard; Biome doesn't support Python |
| **HTML** | Keep built-in formatter | No need for Prettier here |
| **Markdown** | Keep markdown-all-in-one formatter | Specialized for markdown |
| **Elixir** | All settings removed | No longer using Elixir |
| **Stale extensions** | Removed: Atlassian, Java, Julia, Rust, Svelte, Cody, CodeSnap, SonarLint, Camel, PowerQuery, Prisma, Ruff, LiveServer, FiveServer | Not installed or unused |
| **Diff editor** | wordWrap `"on"`, ignoreTrimWhitespace `true`, hideUnchangedRegions `false`, useInlineView `true` | Better diff readability |
| **Theme** | Monokai in shared file | Cursor profile overrides to Default Light+ |
| **suppressSuggestions** | `true` (was `false` in VS Code) | Cursor's value preferred — reduces noise |
| **largeFileOptimizations** | `true` (was `false` in Cursor) | VS Code's value — better performance |
| **notebook.output.textLineLimit** | `15` (was `10` in VS Code) | Cursor's value — more visible output |
| **Emmet** | `{javascript: javascriptreact}` | From Cursor; replaces Elixir-specific emmet config |
| **File nesting** | Merged DB patterns (VS Code) + JS/TS patterns (Cursor) | Union of both |
| **Removed settings** | `githubPullRequests.pullBranch`, `json.schemaDownload.enable`, `git-rebase-todo` editor association | Use defaults instead |
| **Added from Cursor** | `css.lint.unknownAtRules`, `tailwindCSS.emmetCompletions`, `markdown.preview.fontSize` | Useful for web dev |
| **Cursor-specific** | `cursor.cpp.*`, `cursor.aipreview.*`, `cursor.composer.*` kept | VS Code ignores unknown keys |

### Symlink Strategy

```
~/Library/Application Support/Code/User/settings.json  ← THE FILE (VS Code owns it)
~/Library/Application Support/Cursor/User/settings.json ← SYMLINK to above
```

VS Code Settings Sync pushes changes upstream. Cursor reads via symlink. Theme differentiation via Cursor profile (manual step — profiles live in Cursor's internal storage).

### Cursor Keybinding

Added `Cmd+Down` → `editor.action.inlineSuggest.acceptNextLine` for line-by-line AI suggestion acceptance.

---

## Findings

### What Was Done

1. **Merged settings.json** written to VS Code location — 16 stale extension configs removed, Biome set as global formatter, Elixir purged, web dev settings added from Cursor, diff editor tuned
2. **Symlink created** — `Cursor/User/settings.json → Code/User/settings.json` (verified with `ls -la`)
3. **Keybinding added** — `Cmd+Down` → `editor.action.inlineSuggest.acceptNextLine` in Cursor's `keybindings.json`
4. **Backups saved** — both originals in `artifacts/`

### What's Left (Manual)

- Create Cursor profile for theme override (Step 5 in plan — must be done in Cursor UI)
- Verify all 6 test scenarios listed in Next Steps

### Removed Settings (Full List)

**Elixir:** `[elixir]`, `[phoenix-heex]`, `elixirLS.*` (4 settings), elixir emmet mappings, `*.heex` file association, elixir code-runner configs, elixir search/watcher excludes

**Stale extensions:** `yaml.schemas` (Atlassian), `atlascode.*`, `redhat.telemetry`, `sonarlint.*`, `camelk.*`, `[java]`, `java.*`, `julia.*`, `terminal.integrated.commandsToSkipShell` (Julia), `[rust]`, `[svelte]`, `svelte.*`, `cody.*`, `codesnap.*`, `[powerquery]`, `prisma.*`, `ruff.*`, `liveServer.*`, `fiveServer.*`, `python.formatting.provider` (deprecated), `Cargo.toml` file nesting

**Defaults removed:** `githubPullRequests.pullBranch`, `json.schemaDownload.enable`, `git-rebase-todo` editor association

---

## Phase 2: Extension Cleanup + Full Config Unification

### Extension Cleanup

**VS Code — 26 extensions uninstalled:**
Elixir stack (5): `vscode-elixir-snippets`, `elixir-ls`, `ash-studio`, `phoenix`, `elixir-test`
Svelte: `svelte-vscode`
Python dev tools (4): `black-formatter`, `debugpy`, `vscode-pylance`, `vscode-python-envs`
Jupyter/notebooks (2): `jupyter`, `vscode-marimo`
DB clients (3): `dbclient-jdbc`, `duckdb-packs`, `vscode-mysql-client2`
Other stale (6): `code-runner`, `copilot-chat`, `blockman`, `dbt`, `sqlmesh`, `csv`
Replaced: `prettier-vscode` (→ Biome)
Late cuts (5): `editorconfig`, `git-graph`, `playwright`, `pdf`, `prettier-sql-vscode`

**Cursor — 42 extensions uninstalled:**
Elixir (2): `elixir-ls`, `phoenix`
Rust (2): `rust-analyzer`, `rust-pack`
Python dev tools (6): `black-formatter`, `debugpy`, `isort`, `vsc-python-indent`, `arepl`, `ruff`
Jupyter/data (4): `jupyter`, `datawrangler`, `typescript-notebook`, `gc-excelviewer`
API/GraphQL (4): `thunder-client`, `rest-client`, `vscode-graphql`, `vscode-graphql-syntax`
Collaboration (3): `vsliveshare`, `codespaces`, `gitpod-desktop`
Web dev stale (6): `liveserver`, `five-server`, `react-proptypes-intellisense`, `import-cost`, `language-babel`, `javascript-repl`
Replaced by Biome (3): `prettier-vscode`, `prettier-eslint`, `headwind`
Other stale (8): `codesnap`, `powerquery`, `prisma`, `peacock`, `docker`, `dotnet-runtime`, `dark-plus-tailwind`, `inline-fold`, `quick-select`, `markdown-todo`
Late cuts (4): `editorconfig`, `git-graph`, `playwright`, `pdf`

### Settings Cleanup

Removed from shared `settings.json`:
- `[python]` block + 3 `python.analysis.*` settings (Black formatter uninstalled)
- 14 `notebook.*` + 2 `jupyter.*` + `interactiveWindow.*` settings (Jupyter uninstalled)
- 4 `code-runner.*` settings (Code Runner uninstalled)
- `database-client.autoSync` (old DB client replaced by dbcode)
- `remote.SSH.defaultExtensions` (gitpod extension uninstalled)
- `files.associations` for `*.qmd` (Quarto/Elixir related)
- `[sql]` block removed (prettier-sql-vscode uninstalled, Biome doesn't format SQL)

### Keybindings Unification

Merged into one file at VS Code location. Cursor reads via symlink.

**Kept (shared):** `alt+w` emmet wrap, `cmd+r` reload, `shift+enter` terminal newline-without-execute (using Cursor's `\u001b\r`), `cmd+k cmd+w` close all editors

**Kept (Cursor AI):** `shift+cmd+k` unbind aipopup (2 variants), `shift+cmd+l` unbind AI chat, `cmd+i` composer agent, `ctrl+shift+k` clear composer tabs, `cmd+t` unbind symbols + open Claude terminal

**Removed (stale):** 2x Quarto `shift+cmd+k` unbinds, `shift+cmd+,` erb.toggleTags (Elixir/Phoenix)

```
~/Library/Application Support/Code/User/keybindings.json     ← THE FILE
~/Library/Application Support/Cursor/User/keybindings.json    ← SYMLINK
```

### Snippets Cleanup

All 6 snippet files deleted (django-html, elixir, html, javascript, markdown, phoenix-heex). User doesn't write code by hand — AI agent handles it.

```
~/Library/Application Support/Code/User/snippets/             ← EMPTY DIR (source of truth)
~/Library/Application Support/Cursor/User/snippets             ← SYMLINK
```

### Artifacts (Phase 2 Backups)

- `artifacts/vscode-keybindings.json.bak`
- `artifacts/cursor-keybindings.json.bak`
- `artifacts/vscode-snippets-bak/` (6 files)

---

## Rollback

```bash
# Phase 1 — settings.json
cp ~/.claude/siraj-experiments/settings-unification/artifacts/vscode-settings.json.bak \
   ~/Library/Application\ Support/Code/User/settings.json
cp ~/.claude/siraj-experiments/settings-unification/artifacts/cursor-settings.json.bak \
   ~/Library/Application\ Support/Cursor/User/settings.json

# Phase 2 — keybindings
cp ~/.claude/siraj-experiments/settings-unification/artifacts/vscode-keybindings.json.bak \
   ~/Library/Application\ Support/Code/User/keybindings.json
rm ~/Library/Application\ Support/Cursor/User/keybindings.json
cp ~/.claude/siraj-experiments/settings-unification/artifacts/cursor-keybindings.json.bak \
   ~/Library/Application\ Support/Cursor/User/keybindings.json

# Phase 2 — snippets
rm ~/Library/Application\ Support/Cursor/User/snippets
mkdir ~/Library/Application\ Support/Cursor/User/snippets
cp -r ~/.claude/siraj-experiments/settings-unification/artifacts/vscode-snippets-bak/*.json \
   ~/Library/Application\ Support/Code/User/snippets/
```

---

## Next Steps

### Phase 1 (Settings)
- [ ] Open VS Code — confirm Monokai theme, Biome formatting works on a .tsx file
- [ ] Open Cursor — confirm Default Light+ theme (via profile), same settings otherwise
- [ ] Change a setting in VS Code → verify it appears in Cursor (symlink test)
- [ ] Open a JS/TS file with unsorted imports → save → confirm Biome auto-sorts
- [ ] Create Cursor profile: `Cmd+Shift+P` → "Profiles: Create Profile" → name "Cursor" → set `"workbench.colorTheme": "Default Light+"` only

### Phase 2 (Extensions + Keybindings + Snippets)
- [ ] `code --list-extensions` — confirm stale extensions gone
- [ ] `cursor --list-extensions` — confirm stale extensions gone
- [ ] `ls -la` keybindings and snippets paths — confirm symlinks
- [ ] VS Code: `alt+w` wraps with emmet, `cmd+r` reloads
- [ ] Cursor: `cmd+i` opens composer, `cmd+t` opens Claude terminal
- [ ] Both editors: no errors in Output panel
