---
name: project_box_deploy_215_298
description: "On-prem box deploy model (#215/ADR 0036) landed; target substrate = OCI containers (#298); box is now SAP+ESSL only"
metadata: 
  node_type: memory
  type: project
  originSessionId: 6b308b60-c374-4478-8e18-472a78e6f466
---

On-prem ETL box deploy/observe program. Two live threads:

- **#215 (model) — LANDED on `main` 2026-07-09** as **ADR 0036** + `deploy/box/` (generic
  `sync.sh`/`status.sh` + the box-service contract README). This is the git-clone **transport B**
  skeleton, built before the container pivot was noticed (I read the plan from the pre-pivot
  `c891e49` branch). The **model** carries; the **transport** is interim.
- **#298 (target substrate) — OCI containers** (Podman+Quadlet on-prem, one image portable to
  Railway/AWS). RB's 2026-06-29 pivot (recorded on #297). Supersedes `sync.sh`'s `git reset --hard`
  → **registry image pull**, and **ADR 0037** deploy key → **registry pull token**. ADR 0036's
  model (single-writer lease/flock, `is-active` = sole liveness authority, no relaunch-on-lease-lapse,
  auto-drain, read-only smoke, atomic single-writer cutover) is substrate-independent and carries in.

**Box roster shrank to SAP + ESSL.** StyleHR → Railway (#413) and **PTP → Railway (#517/ADR 0050)**;
neither is a box service now. `sap_bronze` is the only remaining on-prem *load*.

- **`essl_stylehr_sync_audit`** (#482) — new read-only service (reads ESSL server + StyleHR DB on the
  LAN, emails a diff; no shared-DB write → no lease). Scaffold + stub `src/` on `main`; **ships now
  NON-container** via the interim skeleton (RB approved 2026-07-09). Builder's real audit logic
  (already sending test emails) should be committed into `src/` to replace the stub. Containerize
  later under #298.
- **`sap_bronze`** — old box `rmail@192.168.2.76` → new VM `analytics@192.168.2.60` (alias `etl-box`,
  #297). The old→new cutover is the remaining SAP prod move; do it as a **container cutover on the
  #298 track** (NOT `deploy/box/sync.sh`), supervised, in a fresh session. SAP edge still paused (#295).

The `sap-drain-guard` pgrep-relaunch watchdog + spent giant-drain layer were **deleted** (#215) — that
relaunch-on-lease-lapse was the nightly duplicate-writer root cause. Related: [[project_stylehr_railway_413]],
[[reference_sap_bronze_deploy_box]], [[project_sap_116b_partition_bootstrap]].
