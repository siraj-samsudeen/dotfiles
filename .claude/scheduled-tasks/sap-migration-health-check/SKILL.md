---
name: sap-migration-health-check
description: Day-after health check of the SAP bronze loader migration to the new ETL box (#297)
---

Verify the SAP bronze loader migration is healthy, one day after cutover. Report a clear verdict and post a brief status comment on GitHub issue #297.

## Context (self-contained)
On 2026-07-16 the `sap_bronze` on-prem loader was migrated:
- OLD box: `rmail@192.168.2.76` (hostname `alma10.mirror.in`), SSH key `~/.ssh/rama_deploy_ed25519` (use `-o IdentitiesOnly=yes`). It is **stopped + disabled** (all `sap-drive-*` and `sap-drain-guard` timers stopped/disabled).
- NEW box: `ssh etl-box` (= `analytics@192.168.2.60`, hostname now `etl-box`). Runs sap_bronze from a monorepo clone at `~/data-warehouse`, with a symlink `~/sap_bronze -> ~/data-warehouse/sap_bronze`. Timers: `sap-drive-edge` (hourly 09:00–20:00 IST), `sap-drive-nightly` (21:00 IST), `sap-drive-catchup` (06:00 IST).
- dlt cursor state was copied from the old box; the new box resumes at the watermark. A 62 GB dlt DR archive lives at `etl-box:~/dlt_archive`.
- Repo: `JeyaramaGroup/data-warehouse` (local checkout `/Users/siraj/Desktop/NonDropBoxProjects/rama_dw`). Issue **#297** tracks this migration.

## Prerequisite
The boxes are on the office LAN (192.168.2.x) — **connect the VPN first**: run `~/bin/rama-vpn connect`, then poll `~/bin/rama-vpn status` until it prints `connected` (takes a few seconds; poll, don't read once).

## Checks
1. **Timers armed** on etl-box: `ssh etl-box 'export XDG_RUNTIME_DIR=/run/user/$(id -u); systemctl --user list-timers "sap-drive*" --all'` — all three should be active/waiting.
2. **PG control plane** — query `control.run` for recent `extractor='sap'` rows. Run a small Python script ON etl-box via `~/data-warehouse/sap_bronze/.venv/bin/python`, reading `CONTROL_PG_DSN` from `~/sap_bronze/.env.run` with psycopg. **Never print the DSN, tokens, or passwords.** Expect: rows with `host=etl-box`, `status=ok`, `stop_reason=clean`, including the **21:00 IST nightly from 2026-07-16** and edge runs. Also check `control.lease` (a `sap` lease is held only DURING a run and expires right after — an expired lease between runs is NORMAL, not a fault).
3. **CRITICAL — single-writer (ADR 0005):** confirm there are **no** `extractor='sap'` runs with `host='alma10.mirror.in'` (the old box) after 2026-07-16 05:00 UTC. Any would mean two writers — flag loudly.
4. **Logs:** `ssh etl-box 'tail -40 ~/sap_bronze/logs/drive.log'` — look for errors. Filter secrets out of any output (`grep -viE "token|password|postgresql://"`). dlt warnings about "Large number of records sharing the same cursor value / low resolution" are PRE-EXISTING and harmless.
5. **MotherDuck freshness:** using the `motherduck-jeyarama` MCP, confirm `bronze_sap` is still loading — e.g. `select max(_loaded_at) from bronze_sap.finance.acdoca` and a couple of other tables; it should have advanced past 2026-07-16.
6. **Disk:** `ssh etl-box 'df -h ~'` — it was 55% used / ~54 GB free (the 62 GB DR archive at `~/dlt_archive` is expected). Flag if filling.

## Rules
- **Do NOT use `bash -x`** on anything that sources `.env.run` — it leaks secrets into the console.
- **Read-only.** Do not make production changes; if you find a problem, diagnose and report it, and ask the operator before acting.

## Output
Give the operator a concise verdict (healthy vs issues, with evidence), then post a short status comment on the issue: `gh issue comment 297 --repo JeyaramaGroup/data-warehouse --body "..."`.