---
name: reference_sap_bronze_deploy_box
description: "The on-prem Linux box that runs sap-bronze (rmail@192.168.2.76) — SSH key auth, paths, cron, secrets"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 15843b3a-71fa-449e-817c-ca06df5864ca
---

**sap-bronze runs on-prem, not Railway** (#82). The box is on the office LAN, so it reaches SAP
HANA `10.10.10.39` **directly — no VPN, no egress whitelisting** — and reaches MotherDuck outbound.

- **Box:** `rmail@192.168.2.76` — AlmaLinux 10, 16 cores, 15 GiB RAM, 1.6 TB free, `python3.12` at
  `/usr/bin/python3.12`, `uv` at `~/.local/bin/uv`, git present. TZ `Asia/Kolkata` (cron times = IST).
- **SSH = key auth only.** Private key `~/.ssh/rama_deploy_ed25519` on the Mac. Pass it **explicitly
  with `-o IdentitiesOnly=yes`** (`ssh -i ~/.ssh/rama_deploy_ed25519 -o IdentitiesOnly=yes rmail@…`):
  bare `ssh rmail@192.168.2.76` fails `Permission denied (publickey)` because the Mac offers its other
  default keys first and the box cuts off before reaching the deploy key. `.env.local` holds
  `LINUX_DEPLOY_HOST/USER(=rmail)/KEY`; `LINUX_DEPLOY_PASSWORD` is blanked (the login/sudo password
  is the rmail account password, re-pasted into LINUX_DEPLOY_PASSWORD only if a one-time sudo/systemd install is ever needed — user has it).
- **PREFERRED ACCESS: reach the box over the Tailscale mesh — no Rama VPN needed (2026-06-25, #229).**
  The box is now a tailnet node `sap-box` = **`100.109.150.99`** (root tailscaled, also a kernel
  subnet router for HANA). The Mac runs the Tailscale macOS app, so:
  `ssh -i ~/.ssh/rama_deploy_ed25519 rmail@100.109.150.99` works from anywhere, VPN-free. The old
  `rmail@192.168.2.76` (office LAN) + Rama VPN path still works as a fallback but is no longer
  required. ssh_box.py / `LINUX_DEPLOY_HOST` can be pointed at `100.109.150.99`. See
  [[project_tailscale_mesh_229]]. **Do NOT tear down the box's tailscaled — it's a live subnet router.**
- **Helper:** `sap_bronze/deploy/ssh_box.py` — `run` / `sudo` / `put` (key-auth SFTP). From a
  worktree set `SAP_ENV_FILE=<main-repo>/.env.local` (the helper resolves .env.local relative to
  itself). See [[reference_rama_dw_env_and_run]].
- **App:** `/home/rmail/sap_bronze` (transferred via `ssh_box.py put`, or `git clone` after merge);
  venv built with `uv sync --no-dev`; secrets in `~/sap_bronze/.env.run` (chmod 600 — HANA_PROD_* +
  `motherduck_token` + `MD_DATABASE=bronze_sap`).
- **Schedule:** rootless user crontab `30 2 * * * /home/rmail/sap_bronze/deploy/run.sh masters`
  (02:30 IST off-peak). `run.sh <mode>` sources `.env.run`, runs `python -m sap_bronze --<mode>`,
  logs to `~/sap_bronze/logs/<mode>.log`. Run history also in `bronze_sap.control.run_events`.
- **Gotcha:** run loads **on the box, not the Mac** — dlt raises `LoadPackageNotFound` on the Mac
  dev env (macOS / Python 3.14); on the box (Linux / Python 3.12) it loads cleanly.
- **SSH gotchas** (pkill/pgrep self-match; XDG_RUNTIME_DIR for `--user` systemd) — promoted to
  `docs/agents/gotchas/ssh-pkill-pgrep-self-match-the-remote-shell.md` and
  `docs/agents/gotchas/systemctl-user-over-ssh-needs-xdg-runtime-dir.md` (2026-07-10).
- **`rmail` has NO passwordless sudo** (`sudo -n` → "a password is required"). Anything needing
  root (stopping legacy services, editing root-owned files) must be run by the user as root — give
  them a clear copy-paste runbook rather than trying to `sudo` from a Bash tool. Our own
  `sap_bronze` jobs are **rootless** `--user` units and need no sudo (ADR 0014).
- **Legacy ETL is separate & root-owned:** the `/opt/DownloadSetup` Java daemons (`sapAuto`,
  `gofrugal`, `zakyaAuto`, `zakya`) are **root system units** in `/etc/systemd/system/` writing to
  the legacy SQL warehouse `192.168.2.62` — distinct from our rootless bronze pipelines. Stop/disable
  needs root + neutralizing the 23:58 restart in `/opt/DownloadSetup/bin/log_filename_change.sh`.
  See [[project_legacy_zakya_loader_stopped]].
