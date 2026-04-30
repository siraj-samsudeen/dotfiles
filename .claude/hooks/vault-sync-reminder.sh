#!/usr/bin/env bash
# Stop hook (global).
# Two-tier nag:
#   Tier A: in-repo docs (devlog/decisions/plans/specs) edited in last 60min
#           but vault folder hasn't been updated since → nudge to /obsidian.
#   Tier B: no recent doc edits but source files in a real dev project were
#           modified in last 60min → nudge to start a docs/devlog.md and/or
#           capture in vault. Gated on the repo having a recognisable
#           manifest (package.json, pyproject.toml, ...) so random `cd`d
#           directories don't trigger nags.
# Always exits 0. Silent unless there's something to say.
set -u

VAULT_PROJECTS="$HOME/Dropbox/Siraj/Projects/siraj-claude-vault/projects"
[ -d "$VAULT_PROJECTS" ] || exit 0

CWD="$(pwd)"
git -C "$CWD" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
REPO_ROOT="$(git -C "$CWD" rev-parse --show-toplevel)"
REPO_NAME="$(basename "$REPO_ROOT")"

# Resolve vault slug, allowing _↔- equivalence so local `rama_dw` matches
# vault `rama-dw` and vice versa.
resolve_vault_slug() {
    local name="$1"
    if [ -d "$VAULT_PROJECTS/$name" ]; then echo "$name"; return; fi
    local alt="${name//_/-}"
    if [ "$alt" != "$name" ] && [ -d "$VAULT_PROJECTS/$alt" ]; then echo "$alt"; return; fi
    local alt2="${name//-/_}"
    if [ "$alt2" != "$name" ] && [ "$alt2" != "$alt" ] && [ -d "$VAULT_PROJECTS/$alt2" ]; then echo "$alt2"; return; fi
    echo ""
}

VAULT_SLUG="$(resolve_vault_slug "$REPO_NAME")"
VAULT_DIR=""
[ -n "$VAULT_SLUG" ] && VAULT_DIR="$VAULT_PROJECTS/$VAULT_SLUG"

now=$(date +%s)

# --- Tier A: most-recent in-repo doc mtime ---
candidates=()
[ -f "$REPO_ROOT/docs/devlog.md" ] && candidates+=("$REPO_ROOT/docs/devlog.md")
for sub in decisions plans specs; do
    d="$REPO_ROOT/docs/$sub"
    [ -d "$d" ] || continue
    while IFS= read -r f; do candidates+=("$f"); done < <(find "$d" -type f -name "*.md" 2>/dev/null)
done

recent_doc_mtime=0
recent_doc_file=""
if [ ${#candidates[@]} -gt 0 ]; then
    for f in "${candidates[@]}"; do
        [ -f "$f" ] || continue
        m=$(stat -f "%m" "$f" 2>/dev/null)
        [ -z "$m" ] && continue
        if [ "$m" -gt "$recent_doc_mtime" ]; then
            recent_doc_mtime=$m
            recent_doc_file=$f
        fi
    done
fi

doc_recent=false
if [ "$recent_doc_mtime" -gt 0 ] && [ $(( now - recent_doc_mtime )) -le 3600 ]; then
    doc_recent=true
fi

# Vault freshness for this repo
vault_mtime=0
if [ -n "$VAULT_DIR" ]; then
    vault_mtime=$(find "$VAULT_DIR" -type f -name "*.md" -not -name ".*" \
        -exec stat -f "%m" {} \; 2>/dev/null | sort -rn | head -1)
    vault_mtime=${vault_mtime:-0}
fi

msg=""

if $doc_recent && [ "$vault_mtime" -lt "$recent_doc_mtime" ]; then
    relpath="${recent_doc_file#$REPO_ROOT/}"
    if [ -n "$VAULT_SLUG" ]; then
        msg="Doc touched this session: $relpath. Vault [$VAULT_SLUG] not updated since. Run /obsidian if this work deserves a vault entry."
    else
        msg="Doc touched this session: $relpath. No vault folder yet for [$REPO_NAME] — run /obsidian to capture if this is an ongoing project."
    fi
else
    # --- Tier B: was source code touched in a real dev project? ---
    is_dev=false
    for manifest in package.json pyproject.toml Cargo.toml mix.exs go.mod Gemfile composer.json; do
        [ -f "$REPO_ROOT/$manifest" ] && { is_dev=true; break; }
    done

    if $is_dev; then
        # Find one non-junk file modified in the last 60 min. maxdepth caps
        # the walk so the hook never blows the 5s timeout on big repos.
        recent_src=$(find "$REPO_ROOT" -maxdepth 5 -type f -mmin -60 \
            -not -path '*/.git/*' \
            -not -path '*/node_modules/*' \
            -not -path '*/.venv/*' \
            -not -path '*/venv/*' \
            -not -path '*/dist/*' \
            -not -path '*/build/*' \
            -not -path '*/.next/*' \
            -not -path '*/target/*' \
            -not -path '*/_build/*' \
            -not -name '.DS_Store' \
            -print 2>/dev/null | head -1)

        if [ -n "$recent_src" ]; then
            if [ ! -f "$REPO_ROOT/docs/devlog.md" ]; then
                if [ -n "$VAULT_SLUG" ]; then
                    msg="Active dev session in [$REPO_NAME] but no docs/devlog.md to track it locally. Consider creating one, or run /obsidian to capture in vault [$VAULT_SLUG]."
                else
                    msg="Active dev session in [$REPO_NAME] but no docs/devlog.md and no vault folder. Consider creating docs/devlog.md, or run /obsidian to start a vault folder."
                fi
            else
                # devlog exists but wasn't touched this session.
                # Stay silent if the vault was updated within the last 24h.
                if [ -n "$VAULT_SLUG" ] && [ "$vault_mtime" -gt 0 ] && [ $(( now - vault_mtime )) -lt 86400 ]; then
                    :
                else
                    msg="Active dev session in [$REPO_NAME], docs/devlog.md not updated. Consider appending an entry, or /obsidian for the vault."
                fi
            fi
        fi
    fi
fi

[ -z "$msg" ] && exit 0

if command -v jq >/dev/null 2>&1; then
    jq -n --arg msg "$msg" '{systemMessage: $msg}'
else
    escaped=$(printf '%s' "$msg" | sed 's/\\/\\\\/g; s/"/\\"/g')
    printf '{"systemMessage": "%s"}\n' "$escaped"
fi
