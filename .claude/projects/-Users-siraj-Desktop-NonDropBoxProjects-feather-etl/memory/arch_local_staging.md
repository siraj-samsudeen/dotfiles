---
name: Architecture decision - local DuckDB staging
description: User chose local DuckDB staging before MotherDuck over direct loading to save cost
type: project
---

Extract → Local DuckDB (bronze) → Transform locally → ATTACH + INSERT to MotherDuck

**Why:** Transforms run locally (free compute), only final results go to MotherDuck (reduces cloud cost). Local copy provides resilience against MotherDuck outages. Cost-sensitive Indian client.

**How to apply:** Design the loading pipeline with local DuckDB as the primary workspace. Use DuckDB ATTACH to push results to MotherDuck as the final step. Views/transforms execute against local data.
