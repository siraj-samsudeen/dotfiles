---
name: Format whole codebase as separate commit before every push
description: Standing rule — before `git push`, run `ruff format .` across entire repo and land as its own cosmetic commit; no pre-commit hook
type: feedback
originSessionId: f9e63b32-f092-4c35-8523-edfddbac5674
---
Before any `git push`, run `ruff format .` across the **entire feather-etl codebase** (not just changed files) and commit the result as its **own dedicated cosmetic commit**. Message format: `style: ruff format entire codebase`. Do not squash into a feature commit.

**Why:** User explicitly does not want a pre-commit hook — wants this to be a deliberate step. Scope-limited formatting (only changed files) leaves pre-existing drift in other files and the codebase looks permanently half-formatted. A single whole-codebase pass per push keeps drift at zero. Separate commit lets reviewers and `git blame` cleanly skip over the format noise.

**How to apply:**
- Finish all feature commits first.
- Run `ruff format .` (zero arguments — entire repo).
- Run `uv run pytest -q` to verify no regressions.
- `git add -u` and commit with a `style:` prefix message that names "ruff format entire codebase" so reviewers know it's cosmetic.
- Then push.
- **Do not** set up a pre-commit hook to enforce this — the user has explicitly opted out.

**Origin:** 2026-04-13, issue #16 (`feather discover` auto-save JSON) final push prep. Commits `caf534c` → `7c5e6c0`. 32 files reformatted, purely whitespace/line-breaks, 460 pytest still green.

**Cross-project principle:** `~/Dropbox/Siraj/Projects/siraj-claude-vault/cross-project/principle-format-all-before-push.md` (same rule, framed to apply to any project with an opinionated formatter).
