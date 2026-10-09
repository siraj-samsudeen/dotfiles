---
name: probe-cloud-runtime-553
description: One-shot probe: inventory what a scheduled headless run can reach (MD/Railway/gh/box), for #553 design.
---

You are a one-shot environment PROBE for GitHub issue #553 (scheduled cloud agent design) in repo JeyaramaGroup/data-warehouse. Your ONLY job is to inventory what THIS scheduled runtime can reach, then report. Do NOT edit any code, do NOT change git state, do NOT modify any issue except posting ONE comment on #553. Everything here is read-only except writing one /tmp file and one GitHub comment.

Run each check below. If a check fails, capture the short error string — do NOT abort; continue to the next. Keep timeouts short so nothing hangs.

CHECKS (bash unless noted; use these exact absolute paths):
1. runtime: `pwd`; `hostname`; whether repo is on this filesystem: `ls /Users/siraj/Desktop/NonDropBoxProjects/rama_dw/CLAUDE.md 2>&1`.
2. local_secrets: does `/Users/siraj/Desktop/NonDropBoxProjects/rama_dw/.venv/bin/python` exist? does `/Users/siraj/Desktop/NonDropBoxProjects/rama_dw/rill/.env` exist? (report yes/no only, never print contents).
3. env_vars: for each of MOTHERDUCK_TOKEN, motherduck_token, CONTROL_PG_DSN, GH_TOKEN, GITHUB_TOKEN — report only whether it is SET or UNSET (never the value). e.g. `bash -lc 'for v in MOTHERDUCK_TOKEN motherduck_token CONTROL_PG_DSN GH_TOKEN GITHUB_TOKEN; do [ -n "${!v}" ] && echo "$v SET" || echo "$v UNSET"; done'`.
4. gh_cli: `gh auth status 2>&1 | head -5`; then `gh api user -q .login 2>&1`.
5. motherduck_mcp: call the MCP tool mcp__motherduck-jeyarama__execute_query with sql "SELECT 1 AS ok". Report whether it returned a row or errored (with the error). If the tool is unavailable in this runtime, say "TOOL UNAVAILABLE".
6. railway_mcp: call mcp__railway__whoami if available; report result or "TOOL UNAVAILABLE"/error. Then railway CLI: `railway whoami 2>&1 | head -3`.
7. motherduck_direct: the daily-loading access path — try, from the repo dir, loading the token from rill/.env and attaching md: via the venv. Run:
   `bash -lc 'cd /Users/siraj/Desktop/NonDropBoxProjects/rama_dw && set -a; . rill/.env 2>/dev/null; set +a; export MOTHERDUCK_TOKEN="${MOTHERDUCK_TOKEN:-$motherduck_token}"; .venv/bin/python -c "import duckdb; c=duckdb.connect(\"md:\"); print(\"MD_DIRECT_OK\", c.execute(\"select count(*) from gold.main.freshness\").fetchone())" 2>&1 | tail -5'`.
8. box_vpn: is the on-prem box reachable (a LOCAL-only signal)? `ssh -o ConnectTimeout=6 -o BatchMode=yes -o StrictHostKeyChecking=accept-new rmail@100.109.150.99 'echo BOX_OK' 2>&1 | tail -3`.

THEN assemble a JSON object with keys: runtime, local_secrets, env_vars, gh_cli, motherduck_mcp, railway_mcp, motherduck_direct, box_vpn — each value a short string verdict (include "OK"/"FAIL: <reason>"). Add a top-level "summary" string: one line stating which of {MotherDuck, Railway, GitHub, local-filesystem, box/VPN} are REACHABLE from this runtime.

EXFIL (do BOTH):
A. Write that JSON to `/tmp/probe_553_runtime.json` (pretty-printed).
B. Post it as a comment on issue #553 using: `gh issue comment 553 --repo JeyaramaGroup/data-warehouse --body-file <a temp file containing a markdown code block with the JSON, prefixed with the line "PROBE #553 runtime inventory (scheduled run):">`. If gh is unavailable/unauthed, note that in the /tmp file's summary (that itself is a key finding).

Finally, end your run with a plain-text final message that repeats the "summary" line and the full JSON, so the notifying session sees it.