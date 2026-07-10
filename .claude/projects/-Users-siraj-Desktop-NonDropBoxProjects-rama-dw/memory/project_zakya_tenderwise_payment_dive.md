---
name: project_zakya_tenderwise_payment_dive
description: Zakya tenderwise payment report — MotherDuck Dive 1bcccabf; repointed onto gold.tender_lines (#180, 2026-07-04), now gold-only
metadata: 
  node_type: memory
  type: project
  originSessionId: c591cb73-3ed3-4ebe-a6a0-070d1e1fe168
---

The Kerala-stores Zakya "Tenderwise Payment" report (formerly two SQL Server `ZAKYA.dbo` views: `Tenderwise_Payment_vw2` = plain branch rollup, and `Tenderwise_Payment_with_GSTTreatment_vw` = per branch×GST-treatment) is a MotherDuck **Dive** — id `1bcccabf-e776-4eb9-a0c2-f141a27818b9`, "Zakya Tenderwise Payment — Daily Collections". Date picker + Branch/GST toggle + Export-Excel.

**#180 LANDED 2026-07-04 (PR #410, merged main):** the Dive was rebuilt off a durable silver→gold tender model and is now **gold-only** (this was triggered because `bronze_zakya` was revoked for viewer Manikandan and the Dive broke). Layers built:
- `silver_zakya.sales.invoice_tender_lines` — atomic tender fact, grain = `InvoicePayment ID` (one payment-application × invoice), from `export_customer_payments`. Raw `Mode` → canonical `tender_type` (10-value set A: cash/upi/card/gift_voucher/sodexo/bajaj_emi/**bank_transfer**/**credit_note**/cheque/other — Bank Transfer ₹104Cr & Credit Note ₹65Cr are now first-class, not buried in "Others"). `tender_amount` = Bajaj-EMI uses financed `invoice_amount`, else `amount` (validated #179). store_code via plant_alias, retail-only. 482 unapplied on-account advances (empty InvoicePayment ID) dropped. gst_treatment denormalised on.
- `silver_zakya.sales.invoice_headers` now **carries `gst_treatment`** (from `export_invoices`) — the old "headers does NOT have it" is fixed.
- `gold.tender_lines` (view, source-discriminated atomic fact) + `gold.tender_lines_wide` (**incremental TABLE**, flatten ⋈ store). The Dive reads `gold.tender_lines_wide`; `REQUIRED_DATABASES` = gold only.

**Why _wide is a table (not a view, diverges from ADR 0042):** see [[gotcha_gold_only_dive_materialize_wide_as_table]] — a gold *view* drags silver shares (incl. PII) into a Dive's required shares. Follow-ups: **#411** (GoFrugal leg + unified tender vocab, blocked #147), **#412** (headers gst CTE scans 86M each incremental build). GoFrugal already has `silver_gofrugal.sales.invoice_tender_lines` (#141) to union in.

Design done via the `/design-silver-layer` skill (lineage CSV + decision log D0–D12 at `docs/plans/issue_180_zakya_tender_silver_gold*`). Dives are authored via the hosted MotherDuck MCP (UUID `fa37d000…`, OAuth claude.ai connector, **jeyarama** account) — the token-based `motherduck-jeyarama` MCP has no Dive tools. See [[reference_motherduck_json_where_planner_bug]], [[reference_motherduck_mcp_routing]], [[feedback_model_atomic_fact_rewrite_consumer]].
