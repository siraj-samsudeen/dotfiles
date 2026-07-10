---
name: project_stylehr_railway_413
description: "StyleHR bronze MIGRATED off the on-prem box onto Railway (#413) — durable"
metadata: 
  node_type: memory
  type: project
  originSessionId: cb004b17-881f-4cf6-bbb1-102d66292c0c
---

StyleHR bronze no longer runs on the box — it runs on **Railway** as of 2026-07-06 (#413), the
durable fix for #404 (the box's office egress IP flapped across WAN uplinks and kept dropping out of
StyleHR's `pg_hba.conf` allowlist, stalling the source for 4 days).

- **Service `stylehr-bronze`** (id `aa08da88-a247-4e63-aa07-16384b03da62`) in project `Jeyarama-ETL`/
  `production`, region **`sfo`**, mirroring zakya/gofrugal (Dockerfile + railway.json + deploy.sh).
- **Egress = Railway Static Outbound IPs** (Pro, HA, region-bound): **`162.220.232.251`,
  `152.55.176.240`, `152.55.177.181`** — whitelisted once in the source `pg_hba.conf` for
  `readonly_user2`/`hrms_store_test`. ⚠️ Do NOT move the service off `sfo` — that reassigns the IPs and
  breaks the whitelist.
- **Schedule** daily cron `30 4 * * *` (= 10:00 IST, unchanged), restart `NEVER` (loader exits 1 when
  any table fails all retries → an auto-restart would re-run all 459).
- **Control plane unchanged** — still MotherDuck `bronze_stylehr.control.run_events` (ADR 0005). The
  Postgres control-plane migration (#224) remains deferred / out of scope.
- **Box loader retired** — `stylehr-bronze-incremental.timer` disabled + inactive; **SAP bronze on the
  same box is untouched** (SAP stays box-pinned, ADR 0011 — HANA behind a gateway tunnel, a different
  case that static IPs can't solve).
- **GitHub-connected** (`main`, root dir `stylehr_bronze`, watch `stylehr_bronze/**`) → auto-deploy on
  push + railway.json as config-as-code. PR #414 merged. First full run: **459/459 loaded, 0 failed**.

**Why:** relocation, not redesign — bronze output + control telemetry are identical, just from a stable
whitelisted egress instead of a flapping office IP.

**How to apply:** for StyleHR deploy/ops use the Railway path now, not the box (deploy = push to main;
secrets = deploy.sh; DEPLOY.md rewritten). See ADR 0045 + `docs/sources/stylehr.md` §7. Related:
[[reference_rama_dw_deployment_topology]], [[reference_railway_static_ip_and_cli_ops]],
[[reference_sap_bronze_deploy_box]].
