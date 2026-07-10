---
name: project_pl_budget_458
metadata: 
  node_type: memory
  type: project
  originSessionId: 22349f30-5849-42ef-9895-c4e9de924dc3
---

#458 LANDED to main (PR #466, 2026-07-08): the **store P&L budget** — cost/EBITDA sibling of #441's
`sales_target` ([[project_canonical_budget_441]]). Source = RB's P&L workbooks (2026-07-07/08).

- **Silver** `silver_core.profit_and_loss_budget` — grain = region × store_code × cal_year × cal_month
  × canonical `pl_line`. **23 selling stores + 5 TN godowns**; entity rollups (TN 1100 / KL 1150)
  excluded as derivable. Ex-GST (ADR 0018); Rs Lacs → INR for money lines; plant-keyed (ADR 0032).
  Built by `scripts/build_pl_budget_seed.py` (P&L Summary Budget+Actual cols, **Apr+May FY27 only** —
  the months RB has filled) + `scripts/build_pl_line_map.py` (line-item conform seed `pl_line_map`).
- **Gold** `gold.profit_and_loss_budget_vs_actuals` — store P&L variance; `favourable_inr` sign-adjusted
  (+ve=good). `actual_source='excel_management_pl'` is **INTERIM** — canonical actuals are SAP GL
  (`silver_sap.finance.acdoca`, #360/#403); repoints to GL when **#407** `dim_gl_account` taxonomy lands.
- **ADR 0048 (NEW, this session)** — *store only irreducible source values; derive-and-verify the rest.*
  Fact stores **leaf + memo** lines only; subtotals (Gross/Net Margin, Total Store Opex, Store EBITDA,
  EBITDA…) + PSPD/Cost% are EXCLUDED and derived downstream, their source values become tie-out tests.
- **KEY FINDING → #469**: the net-sales tie-out proved **#441 `sales_target` is effectively GROSS-basis**
  (ties to P&L Gross Sales at 1.003, ~5.5% ABOVE ex-GST Net Sales) despite being documented ex-GST —
  so #441 achievement % (MOT #437, KAT #440) is understated ~5.5%. #458's own P&L is ex-GST-consistent
  (KAT May Net Sales ₹368.2L bud / ₹337.1L act ties to ADR 0018 to the rupee).
- **Scope split**: #458 = load the numbers; **#447 owns the AOP driver engine** (the FY27 projections —
  Chennai budget workbook = monthly full-year FY27 w/ 11-line opex detail; KL `TVM_FY27_PnL_Projection`
  = annual driver model w/ Controls/Assumptions). Source-of-record = annual projections; monthly budget
  = RB's own columns, NO synthetic phasing (fixed costs don't sales-curve; his May ≠ our phased May).
- Naming: NO `fact_`/`dim_` (rule) → `profit_and_loss_budget` (Siraj chose spelled-out over `pl_budget`).
  Also fixed stale `silver_core.fact_target` → `sales_target` across ADR 0047 / aop_budget_methodology /
  CONTEXT.md (the built table abandoned the `fact_` name; docs lagged).

**Deferred (follow-ups)**: GL actuals (blocked #407); full-year monthly (Chennai workbook Jun→Mar + KL
annual control rows — MVP loaded only Apr+May summary cols); qualitative "Things to be filled" panels +
Controls/Assumptions as reference data; TN budget-workbook 9th-store rows (RDH/PML) vs 7 summary stores.
Store short_codes validated against KL projection sheet names (ATK/MOT/KAT…). See
[[feedback_show_examples_before_decision_question]] (grill lesson) and ADR 0048.
