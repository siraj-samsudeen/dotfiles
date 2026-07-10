---
name: project_sap_overnight_drain_watchdog
description: "SAP #121 overnight giant drain (overnight_giants.sh) + box-resident sap-drain-guard watchdog; oversized-seed-window kill-loop debug recipe"
metadata: 
  node_type: memory
  type: project
  originSessionId: e3dd6b8a-509f-425b-b8b1-cbf6ccd6f11c
---

The current SAP giant drain (post-#121) is `sap_bronze/deploy/overnight_giants.sh` (nohup, fd-201 flock,
round-robins acdoca/bseg/bkpf `backfill --only X --max-chunks 1`, HARD STOP 09:00 IST, per-chunk
`timeout -k 60 5400` = 90-min backstop). It's the MERGE path (`run_backfill`, `[backfill]` log prefix),
not the faster spool/append path — the spool cutover is #121's remaining work. Each grid row loads
directly as `[chunk_start,chunk_end)` with NO sub-splitting, so **window size == grid seed size**.

**Box-resident watchdog (this session, commit 37e9021, documented in #121 comment):**
`sap-drain-guard.timer` fires `deploy/sap-drain-guard.sh` every 5 min (systemd --user, Linger=yes →
survives laptop-off + reboot). Logs health to `logs/drain_monitor.log`; relaunches the drain via
`systemd-run --user --collect --unit=sap-overnight-drain` ONLY if the process is DEAD before STOP.

**GOTCHA it does NOT cover — the oversized-seed-window kill-loop (debugged 2026-06-28):** the grid
(`control.sap_backfill_grid`, Railway PG) seeds history as 5-day slices BUT the current/partial month
as ONE monthly window. bseg `[2026-06-01,2026-06-27)` = 26d / 10.2M rows couldn't load in 90 min →
SIGKILL (rc=137) → the kill orphaned the control-plane LEASE for its full 300s TTL (no release-on-kill;
lease in `control.lease`, acquire is steal-only-if-`lease_expires_at < now()`) → ~22 `rc=1` "another
live run holds the lease" failures → drain re-loads the SAME monster → starves acdoca. Self-healed only
because dlt RESUMED the pending load-package (attempt 2 = load-only, fit under 90 min). **Debug recipe:
"grid frozen + rc=1 lease errors" ⇒ check for a pending window >7d (`chunk_end-chunk_start`); the live
`sap` lease holder's run_id pid is the running load.** Durable fix filed as a spawn_task: cap seeding
≤7d + release lease on SIGTERM (see [[project_control_plane_204_status]] cutover rules). Chunk size is
otherwise well-tuned at 5-day (~1.4M rows, ~25 min) — shrinking to per-day/50k SLOWS the cycle (more
merge-into-giant-target overhead), per [[feedback_load_cost_incremental_default]].
