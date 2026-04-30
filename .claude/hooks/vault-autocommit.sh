#!/usr/bin/env bash
# Stop hook (global).
# Auto-commits any vault working-tree changes using the externalized git dir
# at $HOME/.vault-git. Silent on success and silent on "nothing to commit".
# Always exits 0 — never blocks Claude Code.
#
# Pairs with:
#   - ~/.claude/hooks/vault-freshness.sh   (SessionStart — staleness nag)
#   - ~/.claude/hooks/vault-sync-reminder.sh (Stop — capture nag)
# This script doesn't nag; it just preserves history so an overwrite can
# always be recovered with `vault log` + `vault checkout HEAD~ -- <path>`.
set -u

GIT_DIR="$HOME/.vault-git"
WORK_TREE="$HOME/Dropbox/Siraj/Projects/siraj-claude-vault"

[ -d "$GIT_DIR" ] || exit 0
[ -d "$WORK_TREE" ] || exit 0

git --git-dir="$GIT_DIR" --work-tree="$WORK_TREE" add -A 2>/dev/null

# Bail silently if there's nothing staged.
if git --git-dir="$GIT_DIR" --work-tree="$WORK_TREE" diff --cached --quiet 2>/dev/null; then
    exit 0
fi

git --git-dir="$GIT_DIR" --work-tree="$WORK_TREE" \
    -c user.name="Siraj Samsudeen" -c user.email="mailsiraj@gmail.com" \
    commit -m "auto $(date +%Y-%m-%dT%H:%M:%S%z)" >/dev/null 2>&1 || true

exit 0
