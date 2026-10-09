---
name: reference_sap_bronze_deploy_box
description: "sap_bronze runs on etl-box (analytics@192.168.2.60) since 16-Jul-2026 — NOT the old rmail box; monorepo clone + symlink, systemd --user timers, manual deploy"
metadata:
  node_type: memory
  type: reference
---

**sap_bronze is live on `etl-box` = `analytics@192.168.2.60`** (ssh alias `etl-box`, key
`~/.ssh/jeyarama-etl-deploy`) since the **2026-07-16 cutover (#297)**. Bare `ssh etl-box` works.

> ⚠️ **This memory previously said `rmail@192.168.2.76`. That is the OLD box and is wrong** —
> corrected 2026-08-24 (#2107). SSH to the old box now fails `Permission denied (publickey)`; the
> key was removed or the account changed. The repo is authoritative: `docs/agents/deployment.md`.

- **Layout:** a **monorepo clone at `~/data-warehouse`**, with `~/sap_bronze` a **symlink** into
  `~/data-warehouse/sap_bronze` (so the units' `%h/sap_bronze/...` paths resolve). This diverges from
  ADR 0036's *per-service* clone, which is why **`deploy/box/sync.sh` does not work here**.
- **Deploy is MANUAL and `git push` does NOT do it.** Every Railway service auto-deploys on push, so
  the box silently opts out of that model — the clone sat 4 weeks behind main before anyone noticed
  (#2107). **Always check `ssh etl-box 'cd ~/data-warehouse && git rev-parse --short HEAD'` before
  assuming a merged change is live.** Deploy = drain timers → `git pull --ff-only origin main` →
  `uv sync` → re-arm. Full sequence in `docs/agents/deployment.md` § "Deploying sap_bronze".
- **Schedule = `systemd --user` timers, NOT cron.** `crontab -l` is empty and a bare
  `systemctl list-timers` shows nothing — **you must pass `--user`** or you will wrongly conclude it
  is unscheduled. `sap-drive-edge` (hourly 09–20), `sap-drive-catchup` (06:00), `sap-drive-nightly`
  (21:00, 510-min budget). `Linger=yes`. Units are version-controlled at `sap_bronze/deploy/systemd/`.
- **Re-arm timers IMMEDIATELY after launching a long manual run, not after it finishes.** The fd-200
  flock makes a concurrent timer tick skip cleanly, so holding the timers down buys nothing — and
  forgetting costs a missed nightly (happened 12-Aug-2026, #2107).
- **Secrets:** `~/sap_bronze/.env.run` (chmod 600) — HANA_PROD_* + `motherduck_token` + `MD_DATABASE`.
- **Run loads ON THE BOX, not the Mac** — dlt raises `LoadPackageNotFound` on macOS/Python 3.14.
- **No passwordless sudo.** Our jobs are rootless `--user` units and need none (ADR 0014).
- **ACCESS: Rama VPN only.** `rama-vpn connect`, then `ssh etl-box`. See [[reference_rama_vpn_control]]
  — the tunnel drops during long operations.

**The OLD box `rmail@192.168.2.76` is the company's shared PRODUCTION APPLICATION SERVER** — never
wipe, reimage, or reclaim its disk, and never stop a service that isn't ours (#297 correction,
2026-07-16). Only our ETL footprint there is ours; retiring it is #297's open item (operator GO given
2026-08-24, **blocked on SSH access being restored**). Legacy root-owned `/opt/DownloadSetup` Java
daemons also live there — see [[project_legacy_zakya_loader_stopped]].

Related: [[project_box_deploy_215_298]] · [[reference_rama_dw_env_and_run]] · [[reference_rama_vpn_control]]
