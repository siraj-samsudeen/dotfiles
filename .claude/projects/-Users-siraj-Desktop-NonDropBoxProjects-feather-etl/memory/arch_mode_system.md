---
name: Architecture decision - dev/prod/test mode system
description: Single mode field controls pipeline behavior — target schema, column filtering, gold materialization, row limits — without config duplication
type: decision
---

A single `mode` field (dev/prod/test, default dev) in feather.yaml controls all pipeline behavior differences. Implemented and merged 2026-03-28.

**Mode resolution precedence:** `--mode` CLI flag > `FEATHER_MODE` env var > YAML `mode:` field > default `dev`

| Behavior | Dev | Prod | Test |
|----------|-----|------|------|
| Target schema | bronze.{name} | silver.{name} | bronze.{name} |
| Column filtering | All columns | column_map keys only (if set) | All columns |
| Column rename | No | Via PyArrow post-extraction | No |
| Gold transforms | Views | Materialized tables | Views |
| Row limit | Ignored | Ignored | Applied from defaults.row_limit |
| Silver SQL transforms in setup | Created as views | Skipped (silver populated by extraction) | Created as views |

**Why:** Zero config duplication. Tables, column_map, filters defined once. Mode only changes HOW the pipeline processes them. Explicit `target_table` in YAML always overrides mode-derived target.

**How to apply:** Use dev mode for local iteration (bronze → silver views → gold views). Use prod for deployment (silver direct → materialized gold). Use test in pytest with row_limit for fast runs.

Alternatives rejected: multiple config files (duplication), Jinja in YAML (complexity), env overrides section (merge logic).
