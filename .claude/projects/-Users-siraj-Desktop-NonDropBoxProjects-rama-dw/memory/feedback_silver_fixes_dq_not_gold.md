---
name: feedback_silver_fixes_dq_not_gold
description: Silver is the DQ-fix layer (clean/type/resolve); bronze is faithful-to-source; gold does NO DQ fixes
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 42213d56-e0f3-42ed-a75b-16719c2e036b
---

**Silver's job is to fix data quality — clean junk, type measures, resolve/default keys — and make
the data correct.** The faithful-to-source layer is **bronze**. **Gold does NO DQ fixes** (business
marts/aggregation only). Do not defer measure junk-casting, key resolution, blank/default handling,
or type-cleaning to gold "to keep silver faithful" — that conflates *faithful* (a bronze property)
with silver. Silver is faithful to **reality**, i.e. corrected.

**Why:** if gold does DQ, every downstream mart re-implements the same fixes inconsistently, and the
one governed "correct" layer never exists. Silver must be the single place the data becomes right.

**Silver is source-SHAPED, not source-faithful** — recognizable to a source-system user (renamed,
retyped, cleaned), but NOT "faithful" (that word is **bronze**). Silver renames columns (GoFrugal
`_outlet_code`→`store_code`), keeps SAP's native names (`netwr`) for that source's users, and does
**not** flatten header/line. Cross-source canonical renaming is gold's (ADR 0016).

**Silver also builds composite/business IDENTITY keys** — the surrogate/composite keys we synthesize
for dedup and document identity (e.g. `return_key`). **ADR 554**: all composite identity keys built in
silver, carried by gold; overrides the old gold-only `bill_key` placement (#356/#380). Gold selects
keys through, never mints them. Key rule: never key on a store-scoped source running-number
(`return_no`) — it recycles across stores/dates; key on the source's document PK (GoFrugal `ret_pk`,
Zakya `credit_note_id`) + store + date, and carry the running number as a display attribute only.
See [[project_return_key_554]].

**Canonical home:** now **ADR 0044** (silver is the DQ layer) + **ADR 554** (silver builds identity
keys) + the `design-silver-layer` skill (§3 "silver is the correctness layer", §1 cast-measures-by-data).
This memory = the "watch for it" note.

**How to apply:** in a silver conform/model, DO the cleaning in-layer — `TRY_CAST` stringly measures
to canonical DECIMAL with junk→NULL + coercion-failure tests, apply blank/default rules and
`__unmapped__` sentinels (ADR 0043), resolve keys. Gold only joins dims and aggregates. Corrects the
[[project_ptp_conform_386]] D6 stance ("measure-casting deferred to gold" was wrong). Pairs with
[[feedback_show_dq_details_never_bury]] (surface the DQ, and fix it in silver).
