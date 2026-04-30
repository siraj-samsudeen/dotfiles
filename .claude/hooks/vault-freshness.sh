#!/usr/bin/env bash
# SessionStart hook (global).
# Reports two freshness signals when a Claude Code session begins:
#   1. days since last daily-log entry in the Obsidian vault
#   2. days since last write in the vault folder for the current repo
# Always exits 0. Emits SessionStart additionalContext only when stale.
set -u

VAULT_PROJECTS="$HOME/Dropbox/Siraj/Projects/siraj-claude-vault/projects"
VAULT_DAILYLOG="$HOME/Dropbox/Siraj/Projects/siraj-claude-vault/daily-log"

# Bail silently if vault isn't present (e.g. on a different machine).
[ -d "$VAULT_PROJECTS" ] || exit 0

CWD="$(pwd)"
git -C "$CWD" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
REPO_ROOT="$(git -C "$CWD" rev-parse --show-toplevel)"
REPO_NAME="$(basename "$REPO_ROOT")"

# Resolve a vault folder slug for the current repo. Tries the exact name
# first, then _↔- variants (so local repo `rama_dw` matches vault folder
# `rama-dw` and vice versa). Echoes the matched slug or empty.
resolve_vault_slug() {
    local name="$1"
    if [ -d "$VAULT_PROJECTS/$name" ]; then echo "$name"; return; fi
    local alt="${name//_/-}"
    if [ "$alt" != "$name" ] && [ -d "$VAULT_PROJECTS/$alt" ]; then echo "$alt"; return; fi
    local alt2="${name//-/_}"
    if [ "$alt2" != "$name" ] && [ "$alt2" != "$alt" ] && [ -d "$VAULT_PROJECTS/$alt2" ]; then echo "$alt2"; return; fi
    echo ""
}

VAULT_FOLDER="$(resolve_vault_slug "$REPO_NAME")"

# Returns "" (no dir), "never" (no md files), or integer days.
days_since_latest_md() {
    local dir="$1"
    [ -d "$dir" ] || { echo ""; return; }
    local mtime
    mtime=$(find "$dir" -type f -name "*.md" -not -name ".*" \
        -exec stat -f "%m" {} \; 2>/dev/null | sort -rn | head -1)
    if [ -z "$mtime" ]; then
        echo "never"; return
    fi
    local now=$(date +%s)
    echo $(( (now - mtime) / 86400 ))
}

dl_days=$(days_since_latest_md "$VAULT_DAILYLOG")

if [ -n "$VAULT_FOLDER" ]; then
    proj_days=$(days_since_latest_md "$VAULT_PROJECTS/$VAULT_FOLDER")
else
    proj_days=""
fi

# Thresholds: daily-log nags after 2 days, per-project after 3.
msg=""
case "$dl_days" in
    "")    ;;
    never) msg="${msg}- Vault: no daily-log entries yet."$'\n' ;;
    *)     [ "$dl_days" -ge 2 ] && msg="${msg}- Vault daily-log last entry was ${dl_days} days ago."$'\n' ;;
esac

if [ -z "$VAULT_FOLDER" ]; then
    msg="${msg}- Vault: no folder yet for [${REPO_NAME}] (expected at projects/${REPO_NAME}/). Create one if this is an ongoing project."$'\n'
else
    case "$proj_days" in
        never) msg="${msg}- Vault: folder [${VAULT_FOLDER}] has no entries yet."$'\n' ;;
        *)     [ "$proj_days" -ge 3 ] && msg="${msg}- Vault [${VAULT_FOLDER}]: last write was ${proj_days} days ago."$'\n' ;;
    esac
fi

# Nothing stale → stay silent.
[ -z "$msg" ] && exit 0

msg="Obsidian vault freshness check:"$'\n'"${msg}"$'\n'"If significant work happens this session (decisions, principles, completed plans), invoke the obsidian skill to update the vault before ending."

if command -v jq >/dev/null 2>&1; then
    printf '%s' "$msg" | jq -Rs \
        '{hookSpecificOutput: {hookEventName: "SessionStart", additionalContext: .}}'
else
    escaped=$(printf '%s' "$msg" \
        | sed 's/\\/\\\\/g; s/"/\\"/g' \
        | awk 'BEGIN{ORS="\\n"} {print}')
    escaped=${escaped%\\n}
    printf '{"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": "%s"}}\n' "$escaped"
fi
