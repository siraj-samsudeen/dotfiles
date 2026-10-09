---
name: old-etl-box-decommission-readiness
description: Two-week check: can we remove OUR ETL footprint from the shared company app server to reclaim disk? (#297)
---

Assess whether **our ETL footprint** can be removed from the old on-prem box to reclaim the disk it uses, two weeks after the SAP migration. Produce a recommendation with per-directory rulings. **Do not delete anything** — this run is an assessment only.

## 🛑 READ THIS FIRST — the old box is NOT ours to tear down
`rmail@192.168.2.76` (hostname `alma10.mirror.in`) is the **COMPANY'S PRODUCTION APPLICATION SERVER**, shared with other services and teams. **NEVER** wipe it, reimage it, tear it down, reclaim its disk wholesale, or stop/disable any service that is not ours. Other services run there at **system level and under other users** — a `systemctl --user` check as `rmail` sees ONLY our stuff and tells you nothing about the rest of the box. Do not infer "nothing runs here" from a user-scoped check.

**Only these are ours** (per the operator): the **dlt** pipelines, **sap_bronze**, the **SAP/PTP extract**, and **StyleHR**. Everything else on that box belongs to the company — treat it as untouchable.

The goal of this task is narrow: **identify the disk our ETL leftovers consume under the `rmail` user, and propose reclaiming only that** — nothing more.

## Context (self-contained)
On 2026-07-16 the `sap_bronze` loader was migrated off the old box onto a new dedicated ETL VM:
- **OLD box (shared company app server):** `rmail@192.168.2.76`, SSH key `~/.ssh/rama_deploy_ed25519` (use `-o IdentitiesOnly=yes`). Our SAP timers there were **stopped + disabled** on 2026-07-16 (`sap-drive-{edge,nightly,catchup}`, `sap-drain-guard`). PTP (#517) and StyleHR (#413) moved to Railway earlier, leaving dormant dirs behind.
- **NEW box (ours, dedicated):** `ssh etl-box` (= `analytics@192.168.2.60`, hostname `etl-box`). Runs sap_bronze from `~/data-warehouse` + symlink `~/sap_bronze`. Timers: `sap-drive-edge` (hourly 09:00–20:00 IST), `sap-drive-nightly` (21:00 IST), `sap-drive-catchup` (06:00 IST).
- Our SAP dlt parquet (62 GB) was already copied + verified to `etl-box:~/dlt_archive` (finance spot-check: 6804 parquet files, exact match) — the DR backstop against MotherDuck loss.
- Repo `JeyaramaGroup/data-warehouse`; local checkout `/Users/siraj/Desktop/NonDropBoxProjects/rama_dw`. Issue **#297**.

## Prerequisite
Boxes are on the office LAN — **connect the VPN first**: `~/bin/rama-vpn connect`, then poll `~/bin/rama-vpn status` until `connected`.

## Part A — is our migration healthy enough to retire the old footprint?
1. **Two weeks of clean SAP runs on the new box.** Query PG `control.run` for `extractor='sap'` since 2026-07-16: expect a regular edge + nightly cadence, all `status=ok`, `host=etl-box`, no failures or gaps. Run a small Python/psycopg script ON etl-box via `~/data-warehouse/sap_bronze/.venv/bin/python`, reading `CONTROL_PG_DSN` from `~/sap_bronze/.env.run`. **Never print the DSN/tokens/passwords. Never use `bash -x` on anything sourcing .env.run.**
2. **Single-writer held:** no `extractor='sap'` runs with `host='alma10.mirror.in'` since the cutover.
3. **MotherDuck freshness current:** via the `motherduck-jeyarama` MCP, confirm `max(_loaded_at)` on `bronze_sap.finance.acdoca` and `bronze_sap.inventory.matdoc` is recent.
4. **DR archive intact** on etl-box: `du -sh ~/dlt_archive` ≈ 62 GB; `find ~/dlt_archive/sap_bronze_finance -name '*.parquet' | wc -l` = **6804**.
5. **Our timers on the old box are still disabled:** `export XDG_RUNTIME_DIR=/run/user/$(id -u); systemctl --user list-timers --all` as `rmail` — our `sap-drive-*` / `sap-drain-guard` should remain disabled/inactive. (This is a check on OUR units only — do not touch anything else.)

## Part B — inventory ONLY our footprint (read-only; sizes + identification)
Under `rmail`'s home, report size and contents for each, and classify **ours vs unknown/company's**:
- Known ours: `sap_bronze`, `sap_bronze_probe`, `sap_local`, `ptp_extract`, `stylehr_bronze`, `~/.dlt` (≈78 GB total: ~62 GB the 5 SAP pipelines + ~14 GB ptp/stylehr/bench/probe state that was **NOT** archived), `dlt_recovery_20260617` (likely ours — verify).
- **Unknown — do NOT assume ours, do NOT propose deleting:** `bankcis`, `decompiled`, `uniq_audit`, and anything else present. Report what they appear to be and flag them for the operator to rule on. If they aren't clearly our ETL, leave them alone.
- Report `df -h` for context, and how much reclaiming ONLY our dirs would free.

## Part C — output
- A recommendation: **which of OUR directories are safe to remove**, and how much disk that frees — with a per-directory ruling requested from the operator.
- Flag anything that should be archived first (e.g. the ~14 GB of ptp/stylehr dlt state was never archived; `etl-box` has only ~54 GB free, so check headroom before proposing to copy it there).
- **Do NOT execute any deletion.** Present the plan and stop. Deleting requires explicit, per-item operator approval.
- **Never** propose wiping/tearing down the box or touching non-ETL services.
- Post the assessment as a comment on the issue: `gh issue comment 297 --repo JeyaramaGroup/data-warehouse --body "..."`.