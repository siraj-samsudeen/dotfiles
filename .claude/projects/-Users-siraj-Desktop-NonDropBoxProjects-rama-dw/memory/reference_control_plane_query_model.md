---
name: reference_control_plane_query_model
metadata: 
  node_type: memory
  type: reference
  originSessionId: 736373d5-13a0-405c-9834-0063174f940e
---

How to read the Postgres control plane correctly, and why bronze re-walk duplicates are safe to leave (learned doing the #238 triage).

**Which table is the oracle.** In the shared `control` schema: `control.<ext>_grid` (e.g. `control.zakya_grid`, `control.gofrugal_grid`) is the **completeness oracle** — one row per `(source/branch, business_date, status)`, the thing the backfill reads for its frontier. `control.event` is **only the append-only event LOG since cutover** (~tens of rows/entity) — it does NOT carry historical done-state and will mislead you into thinking history is missing. For "is date X loaded?" query `<ext>_grid`, never `event`. Run lifecycle = `control.run` (stop_reason `clean` vs `budget_time` tells you whether a tick finished its work or ran out of walltime); budgets = `control.budget_usage` (`export_hourly` hit=False + `api_daily` <7k/25k = lots of headroom, so a stall is NOT rate-limiting).

**Querying it from the Mac:** public proxy DSN `reseau.proxy.rlwy.net:49512` (Railway → Postgres service → `DATABASE_PUBLIC_URL`; password in Railway vars, never repo). `.venv` has `psycopg` 3.x + `duckdb`. The `/pipeline-health` skill does this reconcile (PG hot vs MotherDuck) for you — prefer it over ad-hoc probes.

**Silver dedup makes bronze re-walk dups harmless — NEVER bulk-delete `landing.*`.** Zakya silver `zakya_invoice_lines` does `qualify _loaded_at = max(_loaded_at) over (partition by Invoice ID)` — keeps exactly ONE (latest) load per invoice. Verified at invoice AND line grain: a date's 452,585 bronze rows across ~25 loads collapse to 151,542 in silver; a 3-load invoice resolves to its true 6 lines (each load carries the full line-set — `/export` never returns a partial invoice). So across-load duplicates (e.g. the #238 re-walk's ~11M rows) cause **zero double-count and zero loss** — pure storage.

**Why a dupclean is the wrong move (the Q3 reversal in #238):** a blunt "delete post-cutover rows" filter would (a) lose genuine post-only *new arrivals* (~971 invoices the re-walk caught late), and (b) since silver is `incremental delete+insert` on `invoice_id`, deleting a re-walk load wouldn't trigger reprocessing → silver serves the deleted version's data until a full refresh. Leave the dups; let silver absorb them. The within-load paginator dup (#148, ~17 invoices/wk, CEO-assigned) is a SEPARATE line-grain issue that neither the re-walk nor any dupclean touches. See [[project_control_plane_204_status]].
