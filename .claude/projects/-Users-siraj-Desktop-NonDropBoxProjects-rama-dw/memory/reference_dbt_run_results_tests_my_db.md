---
name: reference_dbt_run_results_tests_my_db
description: "dbt_control.main.run_results — test nodes' target_relation is my_db.dbt_test__audit.*, not the tested model's layer"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 94b6902f-392d-418c-94ff-a8c139569103
---

In `dbt_control.main.run_results` (#66 dbt observability), a **test** node's `target_relation`
always resolves to the profile's default catalog `my_db.dbt_test__audit.*`, regardless of which
layer (silver/gold) the tested model lives in. Only `model`/`seed` nodes record their real
destination catalog (`silver_core.*`, `gold.*`, …). The table has no column attributing a test
to a layer (only `node`/`name`/`target_relation`).

Consequence: do NOT split dbt monitoring silver-vs-gold by filtering `target_relation` — it
silently drops 100% of tests (the data-quality signal). Use a `layer` dimension instead:
`CASE resource_type='test' → 'tests'; starts_with(target_relation,'silver_') → silver;
starts_with(target_relation,'gold.') → gold`. The `my_db` rows are tests, not dev noise.

Lives in the #70 Rill `dbt_loads` metrics view. See [[project_gofrugal_silver_status_2026_06_17]].
