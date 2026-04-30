---
name: vault-weekly-sweep
description: Monday 8am audit of Obsidian vault freshness vs Claude Code transcript activity
---

Run the weekly Obsidian vault freshness sweep.

Step 1: Execute `~/.claude/scripts/vault-weekly-sweep.sh` via the Bash tool.

Step 2: Interpret the script's stdout:
- If it prints the literal string `fresh`, the vault is up to date. Reply with one sentence: "Vault fresh — no projects more than 7 days behind transcript activity." Stop.
- If it prints a file path (e.g. `/Users/siraj/Dropbox/Siraj/Projects/siraj-claude-vault/_audit/staleness-YYYY-MM-DD.md`), read that file with the Read tool.

Step 3: When a report exists, summarize it for the user in this exact shape:

  - Total stale/missing projects: N
  - Top 3 most-drifted (or "no vault folder yet") items, one line each
  - One-line recommendation: if the top item has no vault folder, suggest creating one; if it's drift, suggest /obsidian on next session in that repo
  - Link the full report file path so the user can open it in Obsidian

Step 4: Do NOT modify the vault, do NOT write session notes, do NOT triage automatically. This sweep only surfaces — the user decides what to do.

Context: the script and the SessionStart/Stop hooks at ~/.claude/hooks/vault-{freshness,sync-reminder}.sh are part of the same vault-sync system. Excludes (one-off projects, dead experiments) are configured in the EXCLUDE_PATTERNS array at the top of the script. If a project keeps appearing that the user wants to silence permanently, the fix is to edit that array.