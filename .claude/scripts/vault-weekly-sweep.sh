#!/usr/bin/env bash
# Weekly vault freshness sweep.
# Compares latest Claude Code transcript mtime per project against the latest
# Markdown mtime in the matching vault folder. Writes a report to
# ~/Dropbox/Siraj/Projects/siraj-claude-vault/_audit/staleness-YYYY-MM-DD.md
# only when there's drift to surface. Prints the report path on stdout, or
# the literal string "fresh" if there is nothing to report.
#
# Triggered by ~/.claude/scheduled-tasks/vault-weekly-sweep (Mondays 8am).
# Slug resolution mirrors ~/.claude/hooks/vault-{freshness,sync-reminder}.sh.
set -u

VAULT_PROJECTS="$HOME/Dropbox/Siraj/Projects/siraj-claude-vault/projects"
VAULT_AUDIT="$HOME/Dropbox/Siraj/Projects/siraj-claude-vault/_audit"
TRANSCRIPTS="$HOME/.claude/projects"
THRESHOLD_DAYS=7

[ -d "$VAULT_PROJECTS" ] || { echo "vault-not-found"; exit 0; }
[ -d "$TRANSCRIPTS" ] || { echo "no-transcripts"; exit 0; }
mkdir -p "$VAULT_AUDIT"

# Slugs to skip — one-off demos, dead experiments, vault-leads-activity cases.
# Tune over time based on each Monday's report.
EXCLUDE_PATTERNS=(
    "iab-todo1-direct"        # client demo, one-off
    "iab-ThankUCafe-POS"      # client demo, one-off
    "afans-etl"               # one-off, ignored
    "shipnative-superpowers"  # old experiment
    "shipnative-todo"         # old experiment
    "feather-testing"         # experimental scratch
    "todo-instantdb"          # experiment
    "todo-convex"             # experiment
    "convex-test-provider"    # utility
    "talentbridge-ali"        # one-off
    "hellooo"                 # scratch
    "hellp"                   # scratch
    "calmdo-solveit"          # subdir of calmdo
    "calmdo-apps-app"         # subdir of calmdo
    "feather-flow"            # vault leads activity here
)

is_excluded() {
    local slug="$1"
    for pat in "${EXCLUDE_PATTERNS[@]}"; do
        [ "$slug" = "$pat" ] && return 0
    done
    return 1
}

# Resolve transcript dir slug → vault folder. Try exact, then _↔- variants.
resolve_vault_slug() {
    local name="$1"
    [ -d "$VAULT_PROJECTS/$name" ] && { echo "$name"; return; }
    local alt="${name//_/-}"
    [ "$alt" != "$name" ] && [ -d "$VAULT_PROJECTS/$alt" ] && { echo "$alt"; return; }
    local alt2="${name//-/_}"
    [ "$alt2" != "$name" ] && [ "$alt2" != "$alt" ] && [ -d "$VAULT_PROJECTS/$alt2" ] && { echo "$alt2"; return; }
    echo ""
}

vault_mtime() {
    local d="$1"
    [ -d "$d" ] || { echo 0; return; }
    local m=$(find "$d" -type f -name "*.md" -not -name ".*" \
        -exec stat -f "%m" {} \; 2>/dev/null | sort -rn | head -1)
    echo "${m:-0}"
}

transcript_mtime() {
    local d="$1"
    [ -d "$d" ] || { echo 0; return; }
    local m=$(find "$d" -maxdepth 1 -type f -name "*.jsonl" \
        -exec stat -f "%m" {} \; 2>/dev/null | sort -rn | head -1)
    echo "${m:-0}"
}

# Extract project slug from a transcript dir name.
# Patterns: -Users-siraj-Desktop-NonDropBoxProjects-<slug>
#           -Users-siraj-Dropbox-Siraj-Projects-<slug>
#           -Users-siraj-feather-flow              (one-off)
extract_slug() {
    local dirname="$1"
    case "$dirname" in
        -Users-siraj-Desktop-NonDropBoxProjects-*)
            echo "${dirname#-Users-siraj-Desktop-NonDropBoxProjects-}"
            ;;
        -Users-siraj-Dropbox-Siraj-Projects-*)
            echo "${dirname#-Users-siraj-Dropbox-Siraj-Projects-}"
            ;;
        *) echo "" ;;
    esac
}

now=$(date +%s)
threshold_secs=$(( THRESHOLD_DAYS * 86400 ))

drift_lines=()
missing_lines=()

for d in "$TRANSCRIPTS"/-*; do
    [ -d "$d" ] || continue
    dname=$(basename "$d")
    slug=$(extract_slug "$dname")
    [ -z "$slug" ] && continue
    # Skip worktree subdirs. Both `<slug>--claude-worktrees-...` (Claude Code
    # convention) and `<slug>--worktrees-...` (manual git worktrees) are used.
    case "$slug" in *-worktrees-*) continue ;; esac
    is_excluded "$slug" && continue

    tx_m=$(transcript_mtime "$d")
    [ "$tx_m" -eq 0 ] && continue
    tx_age=$(( (now - tx_m) / 86400 ))

    vault_slug=$(resolve_vault_slug "$slug")
    if [ -z "$vault_slug" ]; then
        missing_lines+=("- **$slug** — last transcript ${tx_age}d ago, no vault folder")
        continue
    fi

    v_m=$(vault_mtime "$VAULT_PROJECTS/$vault_slug")
    if [ "$v_m" -eq 0 ]; then
        missing_lines+=("- **$slug** → vault \`$vault_slug\` — last transcript ${tx_age}d ago, vault folder is empty")
        continue
    fi

    drift_secs=$(( tx_m - v_m ))
    if [ "$drift_secs" -gt "$threshold_secs" ]; then
        drift_days=$(( drift_secs / 86400 ))
        drift_lines+=("- **$slug** → vault \`$vault_slug\` — transcript ${tx_age}d old, vault ${drift_days}d behind")
    fi
done

if [ ${#drift_lines[@]} -eq 0 ] && [ ${#missing_lines[@]} -eq 0 ]; then
    echo "fresh"
    exit 0
fi

today=$(date +%Y-%m-%d)
report="$VAULT_AUDIT/staleness-$today.md"

{
    echo "---"
    echo "type: audit"
    echo "project: cross-project"
    echo "date: $today"
    echo "tags:"
    echo "  - Type/Audit"
    echo "  - vault"
    echo "---"
    echo
    echo "# Vault staleness sweep — $today"
    echo
    echo "Threshold: vault folder more than **${THRESHOLD_DAYS} days** behind the latest Claude Code transcript for that project."
    echo
    if [ ${#drift_lines[@]} -gt 0 ]; then
        echo "## Drift — vault is behind transcript activity"
        echo
        for l in "${drift_lines[@]}"; do echo "$l"; done
        echo
    fi
    if [ ${#missing_lines[@]} -gt 0 ]; then
        echo "## No vault folder, or folder is empty"
        echo
        for l in "${missing_lines[@]}"; do echo "$l"; done
        echo
    fi
    echo "---"
    echo
    echo "Auto-generated by \`~/.claude/scripts/vault-weekly-sweep.sh\`. To stop nagging on a project, add its slug to \`EXCLUDE_PATTERNS\` in that script."
} > "$report"

echo "$report"
