---
name: PyPI publish workflow
description: Use twine (not uv publish) for PyPI uploads — uv doesn't read ~/.pypirc; bump version in both pyproject.toml and __init__.py
type: feedback
---

Publish with `uv build` then `twine upload dist/*`. Do NOT use `uv publish` — it doesn't read `~/.pypirc`.

**Why:** `uv publish` requires env vars or `--token` flag for auth. `twine` reads `~/.pypirc` natively, which is PyPI's officially recommended credential storage. Credentials are in `~/.pypirc` (chmod 600).

**How to apply:**
1. Bump version in both `pyproject.toml` and `src/feather_etl/__init__.py`
2. `rm -rf dist && uv build`
3. `twine upload dist/*`
4. Installed via `uv tool install twine`
