---
name: Bronze is clean copy, not complete copy
description: For Indian SMB clients, filter junk at extraction (YAML filter:) so bronze has only production-relevant data — not medallion's "complete copy" pattern
type: decision
---

Bronze in feather-etl is a **clean copy** of source data, not a complete mirror. Business-logic filters (`extinct = 0`, `STATUS <> 1`) go in the YAML `filter:` field and are applied at extraction time. Rows excluded by filter never enter bronze.

**Why:** Resource-constrained Indian SMB deployments — local disk is not cheap/unlimited. Storing soft-deleted POS records and cancelled invoices wastes space with no audit requirement.

**How to apply:** When porting source configs, put data quality filters (soft deletes, cancelled records, test data) in YAML `filter:`. Silver transforms should be pure column rename + join views with no WHERE clauses. For regulated clients who need complete bronze, omit the filter and let silver views handle exclusion.

Documented in PRD under FR3 as a decision note (2026-03-28).
