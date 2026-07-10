---
name: project-powerbi-rethink-514
metadata: 
  node_type: memory
  type: project
  originSessionId: a3dfb935-a9cb-4459-9f74-8cf598dd93bc
---

CEO (via **Umakant**) sent 5 Power BI snapshots — **Target vs Actual**, **Sales FTD/MTD/YTD**, **Stock Statement**, **Store-wise Margin** — asking us to reproduce/improve them in the HTML report server. Filed as **#514** (title "Rethink Daily PowerBI Report on Sales and Stock by Umakant"), which holds the full comparison + data-readiness + open decisions.

**Built, merged (PR #516) & DEPLOYED LIVE:** `report_server/reports/Group_Sales_Control_Tower_review.html` — self-contained **dark board-pack** deck, **4 tabs × 3 views** (heat matrix, radar, gauges, bullet, growth quadrant, treemaps, margin bands, ranked bars) + KPI bands + filter chips, **all live data to 08 Jul 2026**. Live (static snapshot) at **https://dash.jeyarama.com/reports/Group_Sales_Control_Tower_review.html** — CEO has access. Siraj is sending it for feedback, then resuming.

**DEPLOY GOTCHA (cost me a step):** the report-server Railway service builds from the **epic branch `issue-436-dashboard-serving`, NOT `main`** (documented in `docs/agents/deployment.md` + wire-report-live Step 8). Merging to main did NOT deploy; I had to fast-forward the epic branch to main (epic had 0 divergence) to trigger the redeploy. Read the deployment doc before pushing report_server changes — see [[reference_rama_dw_deployment_topology]].

**Data ties out:** 23 stores (16 KL + 7 TN) match. Sources: `gold.sales_budget_vs_actuals` (#441), `gold.sales_wide` (#380), `gold.inventory_soh`, `gold.store`. **Margin COGS is derivable NOW** via `sales × inventory.moving_avg_cost` at ~99.5% line coverage — smaller gap than feared.

**Open decisions parked for the grill (post-feedback):** (1) LFL/NLFL/New buckets — our `lifecycle_stage` vs his exact definition; (2) one tabbed deck vs 4 separate reports; (3) dark vs light house style; (4) target basis GROSS→ex-GST ([[project_canonical_budget_441]], #469); (5) Transit qty + Avg SP feeds = Phase 2; (6) FTD daily target phasing.

**Next when resumed:** CEO feedback → `/grill-with-docs` the 6 forks → plan → template-ify live like MOT ([[project_report_server_436]] epic #436, MOT pattern #437, `render_*.py`). This is the group-wide portfolio-matrix counterpart to the single-store MOT deep-dive.
