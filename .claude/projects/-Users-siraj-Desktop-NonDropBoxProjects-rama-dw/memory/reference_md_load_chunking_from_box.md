---
name: reference_md_load_chunking_from_box
description: Loading large data box→MotherDuck is slow + deadline-bounded → chunk into small load files; dlt Arrow ignores FILE_MAX_*
metadata: 
  node_type: memory
  type: reference
  originSessionId: a63ec7ed-c2cf-486b-b62b-03e06802aa9b
---

Hard-won during the #251 local→MD upload (banked SAP masters → MotherDuck on the on-prem box). Full
write-ups: GitHub #251 (field report) + #121 (rewrite cross-ref). Applies to **every MD-writing job
from the box**, so the SAP rewrite ([[project_sap_116b_partition_bootstrap]]) must design for it.

- **box→MD uplink is slow (~240 KB/s effective, bursty)** AND **MotherDuck enforces a per-request
  deadline.** A single load file that takes longer than that to upload FAILS (`time-based lease
  expired` / `DEADLINE_EXCEEDED RPC UPLOAD_BRIDGE_DATA`) and dlt **retries it from scratch forever** —
  on this uplink a big file never completes. Empirically: one 533 MB parquet always expired; ~10 MB
  chunks succeed.
- **Bound every MD load file small.** The pattern that worked: **app-level row-range chunking** —
  `LIMIT/OFFSET` Arrow slices (~500k rows ≈ 10 MB), one `pipe.run()` each, first chunk `replace` then
  `append`, **`SET threads TO 1`** for a stable cut, resume-append from the MD count. Each commits
  incrementally (resumable; a drop loses ≤1 chunk). Tunable `SAP_UPLOAD_CHUNK_ROWS`.
- **dlt's Arrow writer ignores BOTH `FILE_MAX_ITEMS` and `FILE_MAX_BYTES`** — one parquet per resource.
  You cannot size Arrow loads via dlt config; chunk at the app level. (Dict rows DO split but are ~20x
  too slow through dlt's per-row extract — don't use dicts for big tables.)
- **Never `insert-from-staging` on a multi-table schema** — it stages the whole dataset and the swap
  mis-qualifies (`Catalog Error: Table mara does not exist, did you mean master.mara`). Default
  truncate-and-insert; for absent tables it's a clean create.
- **`pipe.run()` resumes pending load packages first** — a broken/oversized pending package in
  `~/.dlt/pipelines/<name>/load/{normalized,new}` blocks the next run. A broken package whose data is
  re-derivable from source CAN be cleared (the blanket "never clear pending packages" is too absolute;
  never clear the *only* copy of data).
- **Watermark seeding for header_ride tables via `--incremental --since` HITS THE DEDUP-CLIFF**
  ([[reference_sap_header_ride_dedup_cliff]]): the marc seed crawled 40k rows at 59/s and slowing
  ("201 records sharing cursor `_cursor`" = low-res date cursor → dlt dedup-state bloat). So after a
  bulk-create of a header_ride table, do NOT seed its watermark by pulling — set the dlt incremental
  state directly, or accept a one-time bounded edge re-walk. (#251 abandoned the seed step; marc/mvke/
  rseg/mbewh watermarks are UNSET — the #121 rewrite owns seeding them properly.)
- **Box access:** `ssh rmail@100.109.150.99` (Tailscale **mesh DOES have ssh now** — reliable fallback
  when rama-vpn drops, which it does often) or `192.168.2.76` over VPN. Corrects
  [[reference_sap_bronze_deploy_box]] / handoff_sap_rewrite.md ("mesh = no ssh" is outdated). Box loads
  via nohup survive VPN/session drops; monitor from fresh box `duckdb.connect`, not the MCP ([[reference_motherduck_mcp_routing]]).
