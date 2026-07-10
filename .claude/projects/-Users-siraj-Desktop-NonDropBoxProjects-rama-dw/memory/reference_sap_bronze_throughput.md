---
name: reference_sap_bronze_throughput
description: "sap-bronze load throughput is HANA-read-bound (~7,200/s single conn), not dlt-bound; off-peak 1,600-4,847/s; merge≈2x append; arrow blocked by Decimal scale-drift"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 15843b3a-71fa-449e-817c-ca06df5864ca
---

Measured 2026-06-16 (#109, box benchmarks against a throwaway MotherDuck DB + ground truth from `bronze_sap.control.run_events`). The dlt→MotherDuck path is **NOT** the bottleneck:

- **Real fleet rates 1,600–4,847 rows/s off-peak; HANA-read-bound** — `extract` ≈ 7,200/s on a single hdbcli connection; `normalize`/`load` are faster. The ~7,200/s single-connection HANA read is the ceiling.
- **Business-hours HANA contention tanks it** — eban read 488/s at 08:27 IST vs **7,761/s** off-contention (ekko, a larger table, ran 2,192/s 15 min later). So the "488/s crisis" was a transient window, not code → **run heavy loads off-peak** (the nightly schedule already does).
- **parquet is already the MotherDuck loader default**; `FILE_MAX_ITEMS=50000` + `LOAD__WORKERS=4` are set (the original #109 scope).
- **merge ≈ 1.5–2× append on the LOAD stage** (dlt merge = COPY-to-staging + MERGE; the `*_staging` schemas confirm it). Full rebuilds (`--initial` / `--refresh`) now load with `replace` (skip staging) while the incremental cursor still **seeds the watermark** (verified: rebuild reguh 2037 → edge merge resumes at 0). merge stays for edge + the idempotent backfill.
- **Arrow yield is BLOCKED** — hdbcli returns Python `Decimal`s whose scale drifts per chunk (`decimal128(6,2)` vs `(5,1)`), so `pa.Table.from_pylist` needs an explicitly pinned schema; rejected (real risk for a faithful bronze mirror, and the gain is HANA-bound anyway). Dict-yield is correct.
- **Only lever past ~7,200/s = parallel partitioned HANA reads** (multiple connections, key/date-range partitions) — matters only for the giants (acdoca/bseg/matdoc/vbrp), deferred until profiled → issue #118.

See [[reference_sap_bronze_deploy_box]], [[feedback_run_sap_work_on_the_box]], [[project_sap_bronze_status_2026_06_15]].
