---
name: feedback_bronze_curation_profiling_driven
description: "Curate bronze keep-lists from column profiling (client-200 distinct), never from DDIC field names alone"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 15843b3a-71fa-449e-817c-ca06df5864ca
---

When deciding which SAP fields to keep at bronze, **profile the data first — do not curate from
field names/labels.** Names lie both ways: useful-sounding fields (`MARA.CARE_CODE`, `FIBER_CODE1`,
`NSNID`) are often dead in productive client 200, and SAP masters are 70–95% dead columns there
(MARC 262/308, KNA1 231/264). Rule: keep a column iff it's a key/watermark/deletion flag, OR it's
alive (`DISTINCT_COUNT ≥ 2`) in **client 200** and not filler; drop dead (`≤ 1`) fields.

**Why:** keeping dead columns wastes storage on multi-million-row masters; dropping live ones loses
data — only distinct counts tell them apart. For full-refresh masters it's reversible for free
(re-add on next refresh, no backfill), so aggressive curation is safe.

**How to apply:**
- Profile **on MANDT='200'**, never all-client (all-client stats overstate liveness — KNA1 looked
  0-dead all-client, 231-dead in client 200).
- Working-hours-safe: `SYS.M_CS_ALL_COLUMNS.DISTINCT_COUNT` (free, no scan) for loaded giants; a
  single `COUNT(DISTINCT)`-per-column query for small/medium tables (MARA 307 cols ~9 s); all-client
  stat floor for the 15–27M giants (no big scan).
- Back it with two gates: **uniqueness gate** (`COUNT(*)` vs `COUNT(DISTINCT key)`) before trusting
  `merge` on a key (ThankU_DW #8 lost 107,719 rows on a non-unique key); **count gate** reconcile
  after load.
- Reproducible probes live in `sap_bronze_probe/scripts/` (`profile_columns.py`,
  `build_keeplists.py`); the full decision + rationale is `docs/adr/0010-bronze-keeplists-are-profiling-driven.md`.
- Cycle slices #83–#86 must profile their own tables the same way, not curate from names.

Refines [[project_gofrugal_bronze_curated_not_full]] (the *how* of "drop dead/constant fields") and
applies [[feedback_curation_no_mechanical_defaults]] (decide per-table on evidence, not by default).
