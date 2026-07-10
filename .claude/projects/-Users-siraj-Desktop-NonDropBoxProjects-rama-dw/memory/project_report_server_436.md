---
name: project-report-server-436
description: "#436 report server — LIVE at https://dash.jeyarama.com on CORPORATE Internal OAuth client (#451 CLOSED, #450 closed): ex-GST budget ACH, 4 period variants, drop-folder publishing, push-to-deploy; human queue = merge-to-main"
metadata: 
  node_type: memory
  type: project
  originSessionId: 97ab642c-1e32-4e36-8d66-bffa7d22a754
---

Epic #436 (serve RB's HTML dashboards live). **Shape 1 settled and fully proven 2026-07-07**:
template-ify RB's HTML (skeleton verbatim, rows regenerated on OUR canonical hierarchy),
daily 06:00 IST render + boot render per deploy, rendered file IS the cache, 0 MD reads/view.
Full design + alternatives in `docs/plans/issue_436_report_server.md` (kept current).

**Live** on Railway `report-server` (Jeyarama-ETL), branch `issue-436-dashboard-serving`,
code `report_server/`. URL `report-server-production-98d0.up.railway.app/<ACCESS_KEY>/`
(landing page; key in Railway vars). GitHub **auto-deploy works**: Root Dir `/report_server`,
config `/report_server/railway.json`, watch `report_server/**` — docs-only pushes SKIP.

- **MOT (#437) feature-complete for one tier**: all ₹ **ex-GST** (ADR 0018 — RB's original was
  incl-GST, numbers ~5% lower); Target/ACH%/Gap live from `gold.sales_budget_vs_actuals`
  using ITS OWN actual/target pair (as-of-now semantics; coincides with complete-days window
  at 6am). 4 period variants + switcher: MTD (phased target), Yesterday & Last-7 (linear
  days-in-month proration, window sales as numerator), Last Month (full budget). All verified
  exact vs SQL (69.2% / 63.3% / 80.3% / 68.2%).
- **RB publish loop**: `report_server/reports/` drop-folder + landing page; GitHub web upload
  → auto-deploy → live ~3 min; preview = double-click (self-contained HTML). README in folder.
- **OAuth (#451) BUILT + E2E-verified** (dev client, `LOGIN mailsiraj@gmail.com` audit line):
  flag-gated AUTH_MODE=secret_path|oauth, HMAC cookie, fail-closed, HEAD gated, audit log.
  Go-live = 6 Railway vars; rollback = 1. Dev client on Siraj's personal GCP (Testing; test
  users mailsiraj@gmail.com + rbchandran@jeyarama.com; prod callback URL pre-registered).
- **#450 CLOSED 2026-07-08**: dash.jeyarama.com LIVE (Bala added DNS; Railway verified, cert
  issued). `OAUTH_REDIRECT_BASE=https://dash.jeyarama.com`; dev client has the dash callback URI.
  **dash is the canonical URL — share only dash links**; legacy Railway URL still serves but its
  sign-in completes on dash (cookie lands there). When the Workspace Internal client arrives,
  register the dash callback on THAT client; only client id/secret vars swap.
- **#452 filed**: one-shot live reports — authoring skill emits template+SQL manifest (SQL-only,
  never chat Python = RCE), generic engine renders daily. Next build chunk candidate along
  with #438 (F&V Dump).

**4 PARALLEL CHIP SESSIONS RUNNING (launched 2026-07-07 EOD):** view-as impersonation ·
#438 F&V Dump · #439 SM 360 · #440 Kattakada. They develop on own branches and PR into
`issue-436-dashboard-serving` (pushes to that branch auto-deploy prod). Shared seams:
#438+#440 both need the shrink-₹ silver enrichment; #439+view-as both consume
gold.access_grants. Do NOT redo their scopes in the main session; #452 (one-shot engine)
is the remaining unstarted build chunk.

**#440 Kattakada LANDED 2026-07-08 (PR #460 → issue-436-dashboard-serving, unmerged).**
4th dashboard, same Shape-1 pattern as MOT: `report_server/kat/render_kat.py` +
`templates/scorecard.html` = RB's file with ONE injected `const LIVE = /*__LIVE_JSON__*/{}`;
Python replaces that + `__TITLE__/__PERIOD_UPPER__/__FOOTER__` tokens. 2 variants
kat.html(MTD)+kat_lastmonth.html, in-header `<select>` switcher. **Only Pillar 1 live**
(store 1515, gold.sales_wide + sales_budget_vs_actuals, ex-GST governed pair #441);
P2–P7+Insights+Action FROZEN at RB's May literals with visible stamps (pillar badge /
per-KPI chip / page banner via stampFrozen() prepend). HYBRID composite (live P1 + frozen
P2–P7). Sales/Emp run-rate-projected on partial MTD (cumulative metric vs monthly 5L
threshold); PSPD is daily-rate so window-comparable as-is. May backtest ties RB to the
rupee (Net 337.09L, PSPD 67.96, Sales/Emp 4.82); ACH 86.8% ex-GST vs RB gross 91.7%
(labelled). P&L pillar stays frozen — no EBITDA/expense in gold (#360/#407).

**#451 CLOSED 2026-07-08 — corporate Internal client LIVE.** Siraj created it HIMSELF with
siraj@jeyarama.com (admin never acted): the GCP org is **rct.in** (jeyarama.com is a secondary
domain in that Workspace — "Internal" admits the whole rct.in org; ALLOWED_EMAILS is the real
gate). Project `jeyarama-dashboards` under rct.in, client `report-server`
(`526042382398-…`), both callbacks registered. Swap = 4 Railway vars (id/secret,
OAUTH_HOSTED_DOMAIN=jeyarama.com, ALLOWED_EMAILS += siraj@jeyarama.com); verified live
(`hd=jeyarama.com` redirect, `LOGIN siraj@jeyarama.com` audit, NO unverified-app screen).
Sign-ins are @jeyarama.com now (Google refuses gmail on Internal); old dev client on personal
Quickstart project → Siraj deletes it. OPEN/human: merge to main + flip service branch
dropdown · RB GitHub write invite · single-day LY convention (calendar vs weekday-aligned,
ask RB) · ALLOWED_EMAILS→gold.access_grants sync owned by view-as chip.
Gotcha file: `railway-cli-cannot-set-root-directory-and-up-uploads-repo-root.md` (incl.
FAILED-status-while-serving corollary).
