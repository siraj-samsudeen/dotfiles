---
name: feedback_run_sap_work_on_the_box
description: "Do all heavy/long SAP work ON THE BOX (nohup), not the Mac — Mac↔HANA/box is VPN-flaky; box→HANA+MotherDuck are reliable. Mac only for git + edits + deploy touchpoints"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 15843b3a-71fa-449e-817c-ca06df5864ca
---

Siraj's directive (2026-06-16): **my work must not depend on his machine's state** (on/off, VPN
up/down). The Mac↔HANA and Mac↔box(SSH) paths go through a **flaky FortiGate VPN** — repeatedly:
60s HANA socket timeouts, dropped SSH (exit 255), truncated command output, and a `pgrep -f` that
self-matches the ssh command. The deploy box reaches **HANA directly (LAN, no VPN)** and **MotherDuck
over the internet** — both reliable. So:

**Run EVERYTHING heavy/long on the box, detached (`nohup`), never over the live SSH/VPN link:**
- HANA profiling (keep-list regen / `COUNT(DISTINCT)` scans), all loads / bootstraps / backfills,
  the deferred giant client-200 profiling — all `nohup` on the box, exit clean, resume next run.
- **Monitor via MotherDuck** (cloud, VPN-independent — `mcp__motherduck-jeyarama__execute_query` or
  `duckdb md:`) and the **box log files**, NOT by holding an SSH session (it drops mid-run).
- Tools that make this work: `build_keeplists.py` takes `SAP_META_DIR`/`SAP_KEEPLISTS_OUT`/`SAP_SRC_DIR`
  env overrides to run on the box; `ssh_box.py` has `put` AND `get` (pull regenerated files back).

**The Mac is ONLY for** brief touchpoints: editing code, `git` (commit/merge/push), and **deploy**
(`ssh_box.py put`). Keep these short; if the VPN flaps, reconnect (`~/bin/rama-vpn connect`) but do
not run scans/loads from the Mac. **Never run a multi-minute HANA scan or a dlt load from the Mac.**

**Gotchas learned:** kill box processes by a pattern that can't self-match (`pkill -f "[s]ap_bronze
--incremental"`); a killed dlt load leaves a **pending load package** — clear `~/.dlt/pipelines/
sap_bronze_<schema>` before a clean `--refresh` re-run. See [[reference_sap_bronze_deploy_box]],
[[reference_rama_dw_env_and_run]], [[feedback_destructive_ops_and_recoverable_design]].
