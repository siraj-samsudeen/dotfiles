---
name: verify-0700-build-and-stylehr-cold-pass
description: Verify the first 07:00 dbt build on the new offset and StyleHR's 00:00 cold pass
---

Verify two overnight changes that shipped 04-Sep-2026: dbt-runner's new consumer offset (PR #3085) and StyleHR's restored 00:00 IST cold slot (PR #3072).

Repo: /Users/siraj/Desktop/NonDropBoxProjects/rama_dw (work read-only; do not commit, push, or merge anything).

# Change 1 — dbt-runner moved off the extractor slots (PR #3085, issue #3082)

The fleet loads on a 4-hourly grid: 06:00 / 10:00 / 14:00 / 18:00 / 22:00 / 02:00 IST. dbt-runner USED to fire on those same minutes and so raced the loads it consumes — proven on 04-Sep: GoFrugal committed at 06:29 while the dbt build ran 06:00→06:29 and read bronze first, so `gold.health.freshness` reported gofrugal 2 days stale on data already in bronze.

dbt-runner now runs **07:00 / 11:00 / 15:00 / 19:00 / 23:00 / 03:00 IST** (+60 min, chosen because Zakya's 02:00 tick finishes at +45.1 min so a 45-min offset would have landed on the slowest routine finisher).

**Check:** did the 07:00 IST build run, and did it succeed? Is gold now current?

```sql
select strftime(started_at at time zone 'Asia/Kolkata','%d-%b %H:%M') as ist, status,
       round(duration_s/60.0,1) as minutes, left(detail,90) as detail
from dbt_control.main.runs where started_at > now() - interval 20 hour
order by started_at desc limit 8;
```

The single observable that proves the race is closed:

```sql
select table_name, source, is_stale, load_stale, max_business_date
from gold.health.freshness order by source;
```
**gofrugal `max_business_date` should be the prior day with `is_stale = false`.** On 04-Sep it was stale at 2026-09-02 before the 10:00 build healed it.

Also confirm Zakya's freshness target took effect (it was seeded manually on 04-Sep, changed 2h → 6h because a 2h target was unsatisfiable on a 4-hourly grid and went red ~84% of its own 11:00–22:00 window daily):

```sql
select source, intraday_max_age_hours from gold.health.gold_freshness_targets where source='zakya';  -- expect 6
```

# Change 2 — StyleHR's cold pass restored to 00:00 IST (PR #3072, issue #3071)

The 4-hourly grid had moved StyleHR's nightly full sweep from 00:00 to 02:00 IST, and it regressed badly. Baseline versus the failure:

| night | tables | failed | span |
|---|---|---|---|
| 24-Aug → 03-Sep, 11 nights at 00:0x | 460 | **0** | ~184 min |
| 04-Sep at 02:03 (the bad slot) | **81** | **5–6** | 282 min, still running 7 h later, shedding every subsequent tick |

Failures were `57014 canceling statement due to statement timeout` on `employee_attendancestatus*`. Something on the StyleHR source appears to contend 02:00–07:00 IST. The cold slot is back at 00:00 (`COLD_HOUR_UTC=18`, cron `30 0,4,8,12,16,18 * * *`).

**Check last night's cold pass against the 460 / 0 / ~184 min baseline:**

```sql
select run_id, strftime(min(ran_at),'%d-%b %H:%M') as started_ist,
       count(*) as n_tables,
       count(*) filter (where status <> 'loaded') as n_failed,
       round((epoch(max(ran_at)) - epoch(min(ran_at)))/60.0, 0) as span_min
from bronze_stylehr.control.run_events
where ran_at > now() - interval 36 hour
group by 1 order by min(ran_at) desc limit 6;
```
A healthy cold pass is ~460 tables, 0 failed, ~3 h, starting ~00:0x. A hot tick is ~31 tables in ~13 min.

# How to query

MotherDuck token: `/Users/siraj/Desktop/NonDropBoxProjects/rama_dw/secrets/motherduck.env` (gitignored). READ-ONLY key:

```bash
export motherduck_token=$(grep '^motherduck_token=' /Users/siraj/Desktop/NonDropBoxProjects/rama_dw/secrets/motherduck.env | cut -d= -f2- | tr -d '"'"'"' ')
duckdb "md:?motherduck_token=$motherduck_token" -markdown -c "..."
```

`_dlt_loads` locations differ per source — do not guess: `bronze_zakya.landing._dlt_loads`, `bronze_gofrugal.landing._dlt_loads`, `bronze_stylehr.public._dlt_loads`, `bronze_ptp_tamilnadu._dlt_loads` (also `_kerala`, `_kannammal`), `bronze_featherbase.public._dlt_loads`.

# Traps that produced THREE wrong conclusions on 04-Sep — do not repeat them

1. **Do NOT use `railway deployment list` to decide whether a cron tick fired.** Cron executions do not appear there reliably; most entries are push records (`SKIPPED` = a push that missed the service's watch path). Use load data.
2. **NEVER compare a TIMESTAMPTZ against `now() AT TIME ZONE 'UTC'`.** The session renders TIMESTAMPTZ in IST while `AT TIME ZONE 'UTC'` yields a NAIVE timestamp re-read as IST — a 5.5 h error that produced a negative age and a dead alarm. Use `(epoch(now()) - epoch(x))/3600`.
3. **Check your oracle measures what you think.** A data table's `max(_dlt_load_id)` only moves when data CHANGES, so an idle-but-healthy feed looks dead. Use `_dlt_loads`.
4. MotherDuck's catalog lags a write by ~25 s.

# Output

- **dbt**: did 07:00 run, status, duration. Did 03:00 and 23:00 run too?
- **gofrugal freshness**: `is_stale` and `max_business_date` — the race verdict, stated plainly.
- **Zakya target**: 6, and `load_stale` false.
- **StyleHR cold pass**: tables / failures / span versus the 460 / 0 / ~184 min baseline. If it failed again at 00:00, that is important — it would mean the 02:00 slot was not the cause and the source has a broader problem.
- Anything anomalous, with evidence.

Do NOT attempt fixes, and do not commit, push or merge. If something is broken, report it with a proposed next step. If you cannot reach MotherDuck, say so explicitly rather than reporting a clean result.