---
name: project_legacy_zakya_loader_stopped
description: Legacy Zakya ETL loader stopped & disabled on the box 2026-06-17 (gate overridden for duplicate-API-spend); 4 non-invoice tables now frozen
metadata: 
  node_type: memory
  type: project
  originSessionId: a402cd16-01df-48f4-bb0c-f9c4d5e99f66
---

On **2026-06-17** the legacy Zakya loader on `alma10`/`192.168.2.76` was **stopped and disabled**:
`zakyaAuto.service` + `zakya.service` → `disable --now` (now `inactive`/`disabled`), and their two
`systemctl restart` lines (23–24) in `/opt/DownloadSetup/bin/log_filename_change.sh` were commented
(`# DISABLED 2026-06-17 #145:`) to defeat the nightly 23:58 resurrection. `/opt/DownloadSetup` was
backed up to `/root/DownloadSetup_backup_20260617.tgz`. Verified clean; full audit trail in **#145**.

**Why (the two-gate rule in [[project_sap_bronze_status_2026_06_15]]'s sibling ADR 0016 was consciously overridden):**
duplicate API spend — the legacy loader and our `zakya_extract` both pull the Zakya/Zoho APIs, so
every invoice was metered twice — plus invoice silver was nearly ready. Decision by siraj.

**How to apply:**
- **Zakya legacy is OFF.** Don't assume it's still running (CONTEXT.md "Legacy ETL" and the
  decommission plan describe it as gated/untouched — that's now stale for Zakya).
- **4 tables on `.62` are frozen** at their last load: `ZAKYA.dbo.SalesCredit`, `Payment`,
  `PaymentCreatedBy`, `ItemMaster`. Live consumers still read them (`CombinedSales_vw` UNIONs
  `Sales`+`SalesCredit`; the Portal app reads `ZAKYA`). Closing this gap = parity slices 1–4 under
  **#34** (see `handoff_zakya-parity-slices.md`).
- **Rollback** is one `enable --now` + uncommenting lines 23–24 (runbook in #145); the date-windowed
  loader self-heals the gap on next pull, no `.62` data deleted.
**GoFrugal (`gofrugal.service`) was also stopped the same day (2026-06-17)** — same reversible
procedure, restart line 25 commented `# DISABLED 2026-06-17 #144:`. Rationale: bronze is system of
record (all 6 feeds verified in `bronze_gofrugal`: 70.5M sales / 334.8K returns / 12.6M tender /
114.5K cancels, fresh through 2026-06-16), DW = single source of truth. Note GoFrugal is **not** a
duplicate-API case — legacy pulls the HQ API `jcterphq.gofrugalhq.com`, our bronze pulls the store
RPOS7 servers. Audit + evidence in **#144**.

**SAP (`sapAuto.service`) was also stopped the same day (2026-06-17), CEO-approved (#143)** — restart
line 26 commented. Driver: avoid interference (legacy pulls SAP **OData** while `bronze_sap` reads
**HANA**). **⚠️ SAP parity is NOT met** (unlike Zakya/GoFrugal): the legacy loader writes
denormalized business extracts (`SAPSALES_B`+COGS, stock, vendor, GRN/PO/PGI/plant) but the DW only
has raw `bronze_sap` (115 tables) + `silver_sap` **sales-only** normalized models — no gold extract
reproduces `SAPSALES_B`/stock/vendor. Gate consciously overridden with an explicit revert path; the
PBI `Sales_AllStores_Categorywise` report (stale since 01/01/25) + `RRPL-LT-06` analysts may still
need `.62`. Build silver/gold replacements or confirm-dead before relying on the stop.

- **All four legacy daemons are now stopped + disabled + resurrection-proofed** (Zakya #145,
  GoFrugal #144, SAP #143) — `/opt/DownloadSetup` legacy ETL is fully quiet as of 2026-06-17. Our
  rootless `bronze_sap` units (`sap-bronze-catchup.timer`) are untouched and still ingesting.
- Residual consumer-cutover risk across all: `.62` tables freeze until consumers repoint to the DW
  (#93/#103); `CombinedSales_vw` + PBI reports still read `.62`. Each stop reverts via
  `enable --now <svc>` + uncommenting its line; runbooks in #143/#144/#145.
- See [[reference_sap_bronze_deploy_box]] for the root/sudo constraint when touching these.
