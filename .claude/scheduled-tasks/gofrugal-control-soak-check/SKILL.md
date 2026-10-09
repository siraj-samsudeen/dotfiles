---
name: gofrugal-control-soak-check
description: Monday soak check of the GoFrugal control-in-bronze migration (#65 P1); surface the _control.main.* drop decision.
---

Run a soak check for the GoFrugal "control-in-bronze" migration (issue #65 P1), then surface a drop decision to Siraj. This task runs fresh with no memory of the originating conversation — everything you need is below.

## Background
On 2026-06-06 we moved GoFrugal's completeness grid + telemetry tables OUT of the shared `_control` MotherDuck database INTO a `control` schema inside the bronze DB. They now live at `bronze_gofrugal.control.grid` and `bronze_gofrugal.control.run_events`. The OLD tables `_control.main.grid` and `_control.main.run_events` were left in place as a frozen BACKUP, pending this weekend soak. The `gofrugal-extract` Railway cron fires 00:30 UTC daily (06:00 IST) and now writes ONLY to the new bronze location.

Baselines at migration (the frozen backup must NOT change): `_control.main.grid` = 20,640 rows; `_control.main.run_events` = 19,776 rows. After night 1, `bronze_gofrugal.control.grid` = 20,688 and grows ~48/day (one new edge date per night). Each nightly run = 144 telemetry events (3 edge dates x 48 cells), 0 errors.

## Analysis (use the `motherduck` MCP `execute_query`)
Note: `_control` has a leading underscore — quote it as `"_control"`. `rows` is a reserved word — quote it if selected.
1. Per-night health since migration:
   `SELECT left(run_id,9) AS night, count(*) AS events, count(*) FILTER (WHERE status='error') AS errors, min(business_date) AS min_d, max(business_date) AS max_d, max(event_ts) AS latest FROM bronze_gofrugal.control.run_events WHERE run_id >= '20260606' GROUP BY 1 ORDER BY 1;`  -- expect each night 144 events, 0 errors.
2. New grid health:
   `SELECT count(*) AS total, count(*) FILTER (WHERE status<>'ok') AS not_ok, max(business_date) AS max_d FROM bronze_gofrugal.control.grid;`  -- expect not_ok = 0, max_d = yesterday.
3. Old backup still frozen:
   `SELECT (SELECT count(*) FROM "_control".main.grid) AS grid, (SELECT count(*) FROM "_control".main.run_events) AS events;`  -- must STILL be 20640 / 19776.

## Verdict + reminder
- If every night since 06-06 is clean (0 errors), new grid not_ok = 0, AND `_control` is unchanged at 20640/19776 → soak is CLEAN. Recommend dropping the backup and SHOW the command but DO NOT execute it:
  `DROP TABLE "_control".main.grid;`  and  `DROP TABLE "_control".main.run_events;`
  (The `_control` DB itself can be dropped later once Zakya also moves off it — Zakya isn't deployed yet, so after these two drops `_control` would be empty.)
- If anything diverged (any error night, not_ok > 0, or `_control` counts changed) → do NOT recommend dropping; report exactly what's off.

Then tell Siraj: "It's Monday — we agreed to decide on dropping the old `_control.main.*` GoFrugal backup after the weekend soak. Here's the soak result — want me to run the DROP?" Reference issue #65 (P1) and `docs/plans/issue_65_control_in_bronze.md`.

Report concisely: per-night clean/errors, grid health, whether `_control` stayed frozen, and the recommendation.