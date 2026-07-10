---
name: project_return_key_554
description: "#554 GoFrugal return-key collision fixed — silver return_key on ret_pk + populated sold_qty + gold txn_key; ADR 554"
metadata:
  node_type: memory
  type: project
  originSessionId: 1a135361-8d08-4631-9ad0-e5f4a060f874
---

**#554 LANDED on main (PR #560, 2026-07-09).** RB's SR11571 forensic ("₹27,888 return = critical
bronze/silver failure") was verified, corrected, and fixed.

**Root cause (real):** GoFrugal return numbers (`SR…` / `return_no`) are **store-scoped AND recycle
over time** — 90% of numbers span >1 store, 26% of (store,number) pairs recur across dates. Grouping
on the bare number folds unrelated documents (SR11571 = 10 lines / 7 real documents / 4 stores). Silver
was **sound** (line grain already unique); the gap was a missing return-document key.

**Shipped:** `return_key` = `gofrugal|store|return_date|ret_pk` built **in silver**
`silver_gofrugal.sales.return_lines` (ADR 554); `ret_pk` = GoFrugal's return-doc PK, added as a
first-class column. Zakya symmetric `return_key` on `credit_note_id`. `gold.sales` carries `return_key`
(null on sales) + `txn_key = coalesce(return_key, bill_key)`. Tests: grain guard `(return_key,line_no)`
+ warn-monitors. `on_schema_change='append_new_columns'`; first deploy was `--full-refresh`.

**Key data facts (verified):**
- `ret_pk` is document-exact; `return_no` maps to >1 `ret_pk` in 19 store-days (why key on ret_pk).
- The return feed has **NO sold-quantity field** (`sold_mtr_qty` is a meter-variant of RETURN qty, NOT
  sold qty). `sold_qty` recovered by joining to `invoice_lines` on
  (store, sold_bill_no, sold_bill_date, item_code_gofrugal) → **98.7% match**; tail sentineled via
  `sold_qty_match_status` (`matched`/`no_sold_bill_date`(4,173)/`unmatched`(2)), never dropped.
- RB's scary claims were **collision artifacts**: "13-month window" (real p99=16d); the 112-unit
  ₹27,888 line is genuine (bill CA560124 sold **144**, returned 112 — within sold).
- `gold.sales` is a **view** (147M rows, rebuilds free); silver return_lines are small (330k/252k).

**Ops worklist handed over (NOT a pipeline defect):** 65 return>sold lines (₹24,525, test
`gofrugal_return_exceeds_sold`) + 229 bulk-return lines qty≥50 (₹17.4L) — write-off-via-returns review,
belongs with #429 task A.

**Open follow-ups:** #561 (unmatched tail — source NULL sold_bill_date gap), #562 (silver-ize
`bill_key` for ADR-554 uniformity). **Not yet filed:** Zakya return-vs-sold control (KL sibling);
regroup+repoint RB's two returns dives (`1f5c0aee`, `b304c18a`) on `return_key` — SQL handed to RB in
the #554 comment (couldn't edit CEO-owned dives; classifier blocked, correctly).

**Why:** RB (CEO) forensics are requirements not gospel — verify claims against data before acting
([[feedback_ceo_requirements_not_design]]). **How to apply:** reuse `return_key`/`txn_key` for any
returns analytics; never group returns on the bare number. See [[feedback_silver_fixes_dq_not_gold]]
(ADR 554 identity-keys), [[project_sales_wide_380]] (bill_key precedent).
