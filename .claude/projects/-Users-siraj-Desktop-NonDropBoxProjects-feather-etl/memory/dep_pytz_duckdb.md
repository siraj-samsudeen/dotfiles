---
name: pytz is a hidden DuckDB runtime dependency
description: pytz is never imported in feather-etl code but DuckDB's Python client needs it for timestamp→Python datetime conversion — do not remove
type: feedback
---

Do not remove `pytz` from dependencies — it looks unused but is required at runtime.

**Why:** DuckDB's Python client uses pytz internally when converting TIMESTAMP columns to Python datetime objects (e.g., `_etl_loaded_at`). Removing it causes `ModuleNotFoundError` at query time, not import time. Discovered when we removed it during publish prep and 4 tests failed.

**How to apply:** When cleaning up dependencies, verify runtime usage (not just imports) before removing. A comment in pyproject.toml marks this.
