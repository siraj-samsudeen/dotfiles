---
name: verify-1400-slot-after-deadlock-fix
description: Verify the 14:00 IST load slot ran clean after the control-plane deadlock fix (#3091/#3093)
---

Verify that the 14:00 IST load slot on 04-Sep-2026 ran clean, after the control-plane startup deadlock fix (issue #3091, PR #3093, merged 10:30 IST today as commit e43857bb).

Repo: /Users/siraj/Desktop/NonDropBoxProjects/rama_dw (work read-only; do not commit, push, or merge anything).

# Background — what broke and what was fixed

`control_plane.store.ensure_schema()` ran at EVERY extractor startup and issued `ALTER TABLE ... ADD COLUMN IF NOT EXISTS` unconditionally. `ALTER` takes an AccessExclusiveLock even when the column already exists, so two writers starting in the same moment deadlocked. Postgres killed one, and under ADR 0028's hard dependency that aborts the run BEFORE it reads its source — leaving NO `control.run` row, so the control plane could not even report it.

At the 10:00 IST slot today, before the fix:

```
10:00  featherbase      ok          <- survivor
10:01  ptp_tamilnadu    DEADLOCK    <- did not load
10:03  gofrugal         ok          <- survivor
10:03  ptp_kerala       DEADLOCK    <- did not load
10:09  ptp_kannammal    ok          (started alone, loaded fine)
```

zakya and stylehr also produced no load at 10:00 — recorded as "unexplained, consistent with the deadlock", NOT as proven victims.

The fix makes steady state a catalog read with no lock; DDL runs only when something is genuinely missing, serialized by `pg_advisory_xact_lock`.

# What to check

The fleet runs a 4-hourly grid: 06:00 / 10:00 / 14:00 / 18:00 / 22:00 / 02:00 IST. (StyleHR's cold slot is 00:00 IST; dbt-runner moved to 07/11/15/19/23/03 IST as of PR #3085, merged today.)

1. **Did every extractor load at the 14:00 slot?** Compare against the 10:00 slot.
2. **Specifically: did `ptp_tamilnadu` and `ptp_kerala` load?** They are the two that deadlocked at 10:00. Their loading is the proof the fix worked.
3. Did `zakya` and `stylehr` load at 14:00? That resolves their "unexplained" 10:00 status.
4. Any new failure signature.

# How to check — use these exact methods

MotherDuck token: `/Users/siraj/Desktop/NonDropBoxProjects/rama_dw/secrets/motherduck.env` (gitignored). Use the READ-ONLY key:

```bash
export motherduck_token=$(grep '^motherduck_token=' /Users/siraj/Desktop/NonDropBoxProjects/rama_dw/secrets/motherduck.env | cut -d= -f2- | tr -d '"'"'"' ')
duckdb "md:?motherduck_token=$motherduck_token" -markdown -c "..."
```

The reliable oracle is `_dlt_loads` (the load-package record), per source:

```sql
select strftime(inserted_at at time zone 'Asia/Kolkata','%d-%b %H:%M') as load_ist
from bronze_zakya.landing._dlt_loads where inserted_at > now() - interval 12 hour
order by inserted_at desc limit 10;
```

Table locations (they differ — do not guess):
- `bronze_zakya.landing._dlt_loads`
- `bronze_gofrugal.landing._dlt_loads`
- `bronze_stylehr.public._dlt_loads`
- `bronze_ptp_tamilnadu._dlt_loads`, `bronze_ptp_kerala._dlt_loads`, `bronze_ptp_kannammal._dlt_loads`
- `bronze_featherbase.public._dlt_loads`

Also useful: `bronze_stylehr.control.run_events` (per-table telemetry) and `dbt_control.main.runs` (dbt runs).

# Traps that produced THREE wrong conclusions today — do not repeat them

1. **Do NOT use `railway deployment list` to decide whether a cron tick fired.** Cron executions do not appear there reliably; the entries you see are mostly push records (`SKIPPED` = a push that did not touch the service's watch path). dbt ran at 10:01 with no visible execution record. Use load data.
2. **NEVER compare a TIMESTAMPTZ against `now() AT TIME ZONE 'UTC'`.** The session renders TIMESTAMPTZ in IST; `AT TIME ZONE 'UTC'` returns a NAIVE timestamp that is then re-read as IST — a 5.5 h error that produced a NEGATIVE age. Use `epoch()` differences: `(epoch(now()) - epoch(max(x)))/3600`.
3. **Validate that your oracle measures what you think.** A data table's `max(_dlt_load_id)` only advances when data CHANGES — an idle-but-healthy feed looks dead. Use `_dlt_loads`, not a data table.
4. MotherDuck's catalog lags a write by ~25 s. Wait before concluding a write did not land.

# Output

A short report:
- A table: source × did it load at 14:00 (with the timestamp).
- **The verdict on the fix**: did `ptp_tamilnadu` and `ptp_kerala` load? State it plainly.
- Whether zakya and stylehr resolved.
- Anything anomalous, with evidence.
- If something is still failing, say so clearly and propose the next diagnostic step — do NOT attempt a fix, and do not merge, push or commit anything.

If you cannot reach MotherDuck, say so explicitly rather than reporting a clean result.