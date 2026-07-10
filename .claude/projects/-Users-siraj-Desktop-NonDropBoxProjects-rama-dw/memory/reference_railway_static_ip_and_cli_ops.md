---
name: reference_railway_static_ip_and_cli_ops
description: Railway ops facts learned in
metadata: 
  node_type: memory
  type: reference
  originSessionId: cb004b17-881f-4cf6-bbb1-102d66292c0c
---

Railway operational facts gathered migrating StyleHR onto Railway (#413, 2026-07-06):

- **Static Outbound IPs** (Pro plan) let a Railway service reach an IP-allowlisted source: HA gives it
  **3 load-balanced egress IPs**, **region-bound** (moving region reassigns them). Manage via CLI:
  `railway outbound-network static-ip status|enable|disable --service <svc>` (`--json` for scripting).
  This is how a `pg_hba.conf`/firewall source whitelists a Railway service — 3 IPs, once. (Type shows
  "Shared" — not guaranteed dedicated; fine behind password auth.)
- **The Railway MCP is REMOVED from this machine (2026-07-10)** — its auth flapped mid-session
  ("Unauthorized. Please run `railway login`") so Siraj had it deleted from `~/.claude.json`
  (`claude mcp remove railway -s user`). **Do not look for `mcp__railway__*` tools or suggest
  re-adding the MCP — the `railway` CLI is THE path** (it stays authed; check `railway whoami`):
  `railway link -p <proj> -e production -s <svc>`, `railway add -s <svc>`, `railway variables --set`,
  `railway service redeploy`, `railway up`, `railway deployment list --json`, `railway logs`.
- **`railway up` now works** (CLI 5.23.3) — the old #79 snapshot-unpack failure is gone. It uploads the
  cwd and builds via the Dockerfile there (no root-dir needed since cwd IS the context).
- **The CLI CANNOT set a service's Root Directory** (nor connect-source-with-root). With the MCP
  removed, that's **dashboard-only** now. So a full GitHub-connect of a monorepo subdir service
  needs the dashboard, not the CLI.
- **The auto-mode safety classifier can go "temporarily unavailable"** and then blocks ALL non-read
  tool calls (MCP writes AND Bash) until it recovers — retry with backoff (ScheduleWakeup), or hand
  the step to the user.

**How to apply:** do ALL Railway work via the `railway` CLI (the MCP is gone from this machine —
don't reach for `mcp__railway__*` tools). For static-IP-gated DB sources, enable Static Outbound IPs
and give the source admin the 3 IPs. Related: [[project_stylehr_railway_413]], [[reference_rama_dw_deployment_topology]].
