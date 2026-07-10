---
name: reference_sap_header_ride_dedup_cliff
description: "SAP date-cursor giants can't use dlt incremental (dedup cliff); refresh them via backfill-trailing. Cursor RESOLUTION decides incremental viability."
metadata: 
  node_type: memory
  type: reference
  originSessionId: 15843b3a-71fa-449e-817c-ca06df5864ca
---

**Never put a date-cursor SAP giant on the `incremental` path — it cliffs. Use backfill-trailing instead.**

**The cliff (observed 2026-06-18, #166):** `vbrp` (51M billing lines, header-ride on `vbrk`, cursor = the header's **date-only** changed-on) via `incremental --since 20260613` ran **16 min at 98% CPU and wrote 0 rows**. The same window via `backfill` streamed at **~4,300 rows/s**.

**Why:** dlt's incremental keeps an in-memory dedup set of the content-hash (`_dlt_id`) of every row on the cursor *boundary* (rows whose cursor == current max). A **date cursor (no time)** collapses every line of every document on a day onto one cursor value; header-ride + full-document re-extract fans that out massively, and dlt hashes all ~91 columns of every re-extracted row to maintain the set → CPU thrash, nothing flushed. dlt warns: `low resolution… increasing the deduplication state size`. `backfill` is immune — plain `WHERE date ∈ [start,end)` extract + SQL `MERGE` on the real PK, dedup is set-based in the engine, no cursor/boundary.

**The rule — cursor RESOLUTION is the dividing line, not header-vs-line:**
- **High-res giants** (`matdoc`, `ekbe` — `CPUDT‖CPUTM`, has time): incremental works, no cliff (matdoc reached 06-17 via incremental). → OK on the hourly cron.
- **Date-cursor giants** (`vbrp`, `lips`, `vbfa`, `eket`, `ekpo` — date-only / header-ride): incremental cliffs. → refresh via **backfill-trailing**: reset the trailing `backfill_grid` chunk to `pending` + extend `chunk_end` past today (catches late-posted docs whose CHANGED_ON is later than their billing date), then `backfill --only <t> --max-chunks 1`.

**#121 refinement (2026-06-27) — UNVERIFIED, test before trusting:** the #121 grill hypothesised the cliff is specifically a *big / unseeded-watermark* pull, and that a watermark-seeded **steady-state hourly** delta (only *today's* changed docs) might be small enough to avoid it — letting day-res giants edge by incremental after a one-time windowed bootstrap + watermark seed. **But the evidence above contradicts over-confidence:** `vbrp` cliffed on a mere ~4-day (`--since 20260613`) window, so day-res header-ride giants may still cliff even on modest pulls. So #121 treats this as a hypothesis: its box plan includes a **seed-then-incremental smoke test** (seed the watermark to recent, run one hourly incremental, confirm a small fast delta), with **windowed-edge as the fallback** if it cliffs. Do NOT assume hourly incremental works for day-res giants until that test passes — high-res giants (matdoc/ekbe/bkpf, and acdoca/vbrk after the #121 cursor fixes) are the safe-on-incremental ones.

**How to apply:** when a giant line/movement table's recent edge is stale, do NOT reach for `incremental --since`. `UPDATE bronze_sap.control.backfill_grid SET status='pending', chunk_end=DATE '<today+1>', rows_loaded=0 WHERE table_name='<t>' AND chunk_start=DATE '<trailing chunk start>'` then `run.sh backfill --only <t> --max-chunks 1`. Note `run_backfill`'s budget is **per-table greedy** — `--only a,b --max-chunks 2` can spend both chunks on `a`; run each table separately for one chunk each. A real fix to make incremental itself work needs a higher-resolution (timestamp) cursor — a HANA-side modelling change, not a config toggle. Backfill sidesteps it. See [[project_sap_bronze_status_2026_06_15]], [[reference_sap_bronze_throughput]].
