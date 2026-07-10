---
name: project_sm360_scorecard_439
description: SM 360° scorecard wired live from the warehouse (Slices A–D) — all MERGED to main but NOT deployed; report-server prod stuck on a stale commit
metadata: 
  node_type: memory
  type: project
  originSessionId: 3a3a6368-238e-4d28-9ce8-06b1fc79d694
---

#439 (epic #436, 3rd dashboard, first MULTI-STORE) — RB's JRBG Store Manager 360° Scorecard, token-injected live from gold. RB's JS SPA + scoring engine (`PILLARS`/`computeScores`/A-B-C-D) survive byte-identical; only hardcoded placeholders swapped for live inputs (`report_server/sm360/`, `build_template.py` = the one-off transform).

**Live-scored (all gold, ADR 0046):** Sales Efficiency SPE/RPH/MCR (replaces RB's placeholder 60) · Attendance rate · Ops punch/break/punch-out (`gold.attendance_compliance`, #465) · Engagement attrition/retention/notice (`gold.hr_movement`, built this session #496) · HR abs/late/LOP/PFA/profile + WO (`gold.hr_attendance_summary`, Slice B, projection of #397 `attendance_summary_daily`). Dual-show (D1): att-rate + Ops show OUR figure + RB's StyleHR-MIS as a labelled cross-check; break/punch-out carry the formula (D2). Scoring bands = wired defaults (Scoring Logic page), changeable. **Only frozen (no source anywhere):** shift_coverage, Compliance (statutory/training/safety), grievance → need RB.

**Access model (proper access-grants, #532):** `ALLOWED_EMAILS` = ADMINS ONLY (rbchandran, siraj = master); everyone else admitted **iff** in `gold.access_grants` and scoped to it (SM→their store, region_viewer→their region). New SM = one access_grants row, no env edit. `_authorized()` in `report_server/main.py` reads the sm360 manifest (= all grant principals). Per-scope files: master + KL/TN region + 15 store variants (Slice D, `out/sm360_manifest.json`).

**Merged to main:** #496 gold.hr_movement · #507 Slice A renderer · #521 Slice D variants · #532 access-grants auth · #533 Slice B. Skill `wire-report-live` updated (Step 0 data-audit, freeze-don't-reweight, per-scope variants, probe-every-table gotcha).

**LIVE on dash.jeyarama.com as of 2026-07-09** (deploy verified: render logs show render_sm360 producing master + KL/TN regions + 15 store variants + 18-principal manifest; serve guard google-oauth). Access-grants auth (#532) live: `ALLOWED_EMAILS`=2 admins (rbchandran, siraj), SMs admitted+scoped via `gold.access_grants`. `ACCESS_KEY` blanked (secret path dead).

**Deploy trap that bit this session (now FIXED):** report-server built from stale branch `issue-436-dashboard-serving`, so main merges didn't deploy (prod stuck at 756c774). Fixed two ways: (1) interim — FF'd issue-436-dashboard-serving → main to trigger the deploy; (2) permanent — **Railway service Source branch flipped to `main`** (root `/report_server`, auto-deploy on). Future main merges now deploy normally. The old issue-436-dashboard-serving branch is now redundant (delete-able). Gotcha: `docs/agents/gotchas/report-server-deploys-from-issue-436-branch-not-main.md` (PR #536). A **302→/auth/login is NOT proof a page shipped** — verify via deploy render logs. See [[project_report_server_436]], [[reference_rama_dw_deployment_topology]].
