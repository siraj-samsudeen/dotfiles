---
name: project_essl_stylehr_recon_482
metadata: 
  node_type: memory
  type: project
  originSessionId: d443c651-f86a-4442-bb52-58c4a5e4e125
---

#482 audit: does StyleHR silently drop ESSL biometric punches? (the assumption behind [[project_stylehr_railway_413]]-adjacent #465's decision NOT to ingest ESSL). Baseline RUN 2026-07-08, branch `issue-482-essl-stylehr-recon`, folder `essl_stylehr_recon/`.

**Verdict:** 97.9% crosswalked; StyleHR is a faithful deduped superset for 99.67% of crosswalked employee×days — NO drop for the bulk. BUT residual is a **structural cohort, not noise**: 395 MISSING_DAY rows on just 53 employees (HK294 missing 36/43 days) + 150-employee unresolved tail, both dominated by alphanumeric code-prefixes **HK/J/SG/TCS/INT/GIF** (specific stores/categories un-mapped into StyleHR). Aggregate totals hid it (Jul 1: ESSL site 8,637 vs StyleHR 19,189 superset).

**Method traps (all empirically real):** compare **day-presence + first-in/last-out span at distinct-punch-minute**, NOT raw counts. Three false-positive sources designed out: (1) ESSL per-second device chatter; (2) spurious secondary-device bursts (emp 6217 = 35 midday swipes at device 50, real in/out on device 20 — span identical); (3) trailing-day sync lag → skip last 2 days + require real attendance span.

**Access:** ESSL = SQL Server 192.168.2.62 DB etimetracklite1, DeviceLogs_<M>_<YYYY> monthly tables, pyodbc+Driver18 Encrypt=no over Rama VPN ([[reference_rama_dw_env_and_run]]). Crosswalk = DeviceLogs.UserId ↔ StyleHR employee_code (direct ~97.8%; ESSL DeviceId==StyleHR machine_id). StyleHR = bronze_stylehr.public.employee_attendance punch_type_id=1.

**Deliverables:** baseline_audit.py (re-runnable), crosswalk.csv (**shared with #465** attendance_punches provenance), gap_report.csv, SENTINEL_DESIGN.md (weekly deterioration-vs-baseline for #400 rail). **Caveat:** one ESSL login only — multi-site blind spot (StyleHR consolidates ~5,891 emp/day vs our ~2,016).

**ROOT CAUSE DIAGNOSED 2026-07-09** (comment on #482): the cohort = **outsourced/agency workforce**, and StyleHR is NOT buggy — it correctly imports punches only for active, master-registered employees. Prefixes are agency/category codes (NOT stores): **HK=HouseKeeping, SG=Security-Guard, TCS/GIF/EFM/DEL/AVM=outsourcing companies (Companies table), INT=interns**; **J=main Jeyarama house code (Regular, syncs fine = the 97.9%)** with only a legacy J-Agency-Operations slice under-propagating. Three mechanisms, all identity-keyed: **M1 deactivated-but-still-enrolled** (agency staff `payroll_active=false`/dropped from StyleHR master but biometric template still live on ESSL device → clean per-employee cutoff date, ESSL keeps logging; 52/53 MISSING had historical StyleHR punches that just stop, 17/19 in-master are Agency); **M2 never-onboarded/unmappable** (148/150 UNRESOLVED totally absent from StyleHR; ESSL issues badge #s **per-agency so NumericCode is NOT unique — 1,368/7,953 collide, up to 14-way**, e.g. 294→HK294/SG294/TCS294/bare-294; bare-numeric punches unmappable; Ancy enrolled as both HK294 AND 294); **M3 case drift** (3,000 lowercase-leading codes hk038 vs HK038). Remediation = HR/device hygiene not pipeline: delete templates on deactivation + reconcile ESSL-enrolled-vs-StyleHR-active; require StyleHR code before enrollment, kill bare-numeric/dup aliases; normalize case. For #465: StyleHR attendance complete ONLY for payroll-active master-registered emps — agency staff structurally biometric-dark, flag in any headcount mart.
