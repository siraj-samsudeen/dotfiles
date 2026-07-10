---
name: feedback_destructive_ops_and_recoverable_design
description: "Be critical on the operational-safety axis, not just data-correctness: destructive ops → stop+options+confirm; fix the mechanism not the symptom; verify before acting; design long ops for heartbeat+recoverability"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 15843b3a-71fa-449e-817c-ca06df5864ca
---

Siraj's feedback (2026-06-16, SAP bronze): strong on **data-correctness** (uniqueness, timestamp
cursors, profiling) but careless on the **operational-safety / recoverability** axis. Four concrete
misses in one session — treat these as standing rules:

1. **Destructive / irreversible ops → STOP, present the options, get explicit confirmation.** Do NOT
   treat a schema-drop, data-wipe, or a "just re-run it" that drops data as routine recovery. The
   global narrate-and-proceed default is for SAFE actions; destructive ones need a higher bar — walk
   through alternatives (e.g. `--masters` plain *replace* leaves siblings intact vs `--refresh` which
   drops) and confirm. (I ran a schema-dropping `--refresh` restore as if routine.)
2. **Fix the MECHANISM, not the symptom.** When fixing a bug, re-derive the *correct behaviour across
   ALL use-cases* — especially the targeted / `--only` / edge case — not just make the observed
   failure stop. (I changed per-table `drop_sources` → once-per-schema `drop_sources`; both wipe the
   whole schema. Correct = `drop_resources` per-table = drop only the named table. I only tested the
   all-tables path, which masked the `--only` danger.)
3. **Verify the authoritative signal BEFORE acting under uncertainty** — never act on inference from
   ambiguous signals, least of all to re-trigger a destructive op. (I read mid-flight "1 table" +
   empty buffered ssh output + a VPN flap as "restore died" and launched a SECOND destructive restore
   that nearly wiped the successful first; the box log / `control.run_events` showed it had finished.)
4. **Design long operations for observability + recoverability from the start.** A multi-hour
   monolithic load with no heartbeat and no checkpoint is a design failure: you can't tell hung from
   progressing, and a kill/flap loses everything. Required shape (the `zakya_extract` pattern):
   **heartbeat every ~100k rows or ~2 min (flushed)** + **commit each small batch up to the
   destination with a per-batch control checkpoint** + **time-budgeted runs** + **resume grid**.

5. **Verify CONSUMER-FACING parity before a decommission/cutover stop — not just that bronze exists.**
   "We have the data in bronze" is necessary but not sufficient. Check whether the DW reproduces the
   *shape consumers actually read*: a live report/analyst reads denormalized business extracts (e.g.
   SAP `SAPSALES_B` with COGS, stock/vendor downloads), not raw normalized tables. (2026-06-17 legacy
   decommission: **GoFrugal passed** — all 6 legacy feeds present in `bronze_gofrugal`, fresh, so it
   was a true drop-in; **SAP failed** — `bronze_sap` had raw tables + sales-only normalized silver but
   no gold reproducing the extracts, so the stop froze the PBI report's source with no replacement.)
   Substantiate parity with row counts + freshness + silver/gold coverage, per source, before acting.

**Calibration — heavy/costly ≠ destructive; don't OVER-gate (2026-06-29).** The higher bar is for
*irreversible/data-losing* ops. A **costly-but-reversible** action (e.g. merge-to-main that triggers a
130M dbt build during business hours) is NOT in that class — surface the tradeoff in 1–2 lines, give a
one-keystroke override path, and lean toward *proceeding*, not deferring. I deferred the #121/#286
merge + finance-silver build to "tonight" on cost grounds; Siraj overrode ("merge now, run it today —
I want current numbers when the CEO checks"). Lesson: when there's a clear business need (CEO-facing
freshness), the build cost rarely outweighs it — present + proceed on his go, don't dig in on the defer.

**Why this happens:** I bias toward "make the observed problem go away and keep moving" — minimal
fix, proceed, infer-and-act. That under-weights *what could this break / how do I recover / is this
reversible*. Be deliberately critical on that axis — **but** don't swing to over-caution on merely
*expensive* actions (the calibration above).

**How to apply:** before any state-changing box/DB action, ask "is this destructive or
hard-to-reverse? then stop + options + confirm." Before declaring something failed, read the
authoritative log/control row. When fixing, write the test for the case that would re-expose the bug
(here: `--refresh --only X` must leave siblings). For any load that can exceed a couple minutes, build
heartbeats + batched/checkpointed commits ([[reference_rama_dw_env_and_run]], zakya HEARTBEAT pattern).
See issues #115 (the wrong fix + destructive missteps) and #116 (heartbeat/recoverable loads).
Related: [[feedback_implementation_closeout_loop]], [[feedback_tableau_rule_defaults]].
