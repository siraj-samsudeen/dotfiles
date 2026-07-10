---
name: project_sap_morning_report_287
description: "SAP CEO morning-load report (#287) — design drafted, one decision open, PG-not-MD correction; resume from the issue comment"
metadata: 
  node_type: memory
  type: project
  originSessionId: c086743e-a70a-4a8e-b8c3-8afa8debaaa6
---

**#287 = repeatable SAP→DW morning load report for the CEO's week-1 review** (one-command generator +
a `sap-morning-report` skill). Design session 2026-07-01: **plan drafted, NOT implemented.** The full,
durable record is the **dated comment on issue #287** — read it to resume cold.

Redesign around CEO feedback: **lead with a freshness banner**, then a **latency / data-currency
mental model** (load fires → ingestion → dbt transform → live; + inverse "at 11:00 you see SAP as of
~10:5X") — that mental model is THE key deliverable; per-area sections in CEO priority order
(Sales → Purchasing&GRN → Inventory → Master → **Accounting last**) with plain-English `What it is`
labels (no `erdat`, no "wedge"); load-time as a light bottom narrative; include dbt transform time.

**Load-bearing correction:** completeness/run-health come from the **Railway Postgres control plane**
(`cp.control.sap_backfill_grid`/`sap_partition_grid`/`run`/`event`/`lease`, ATTACH READ_ONLY like
`health.py`), **NOT** the stale MotherDuck `control.sap_*` tables (#311 deletes them; #312 says
PG-only for SAP). Box has `CONTROL_PG_DSN`. See [[reference_sap_bronze_log_and_grid_contract]],
[[reference_dbt_run_results_md_table]].

**OPEN DECISION (resume here first):** how #287 relates to `pipeline-health`/#312 (which adds SAP to
the 5-question health engine). 3-way fork — A(rec): #312 first + shared SAP control-plane reads, #287
= CEO layer; B: #287 now, independent, corrected to PG; C: merge into pipeline-health as a CEO mode.
AskUserQuestion was cut off (stream closed) — unanswered. Related: #121, #286, #312, #311, #70;
ADR 0028/0003/0014. Build shape: box writes markdown to a file → skill scp's it to `docs/reports/`
(SSH truncation gotcha). See [[project_daily_pipeline_health_check]].
