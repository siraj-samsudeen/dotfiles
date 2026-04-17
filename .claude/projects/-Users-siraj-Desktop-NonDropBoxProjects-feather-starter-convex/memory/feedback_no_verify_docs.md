---
name: Use --no-verify for docs-only commits
description: Pre-commit hooks guard code quality — skip them for .planning/ docs commits
type: feedback
---

Use `--no-verify` when committing documentation-only files (`.planning/` context, discussion logs, roadmap updates). The pre-commit hook runs typecheck + tests, which is meant to guard code changes, not docs.

**Why:** Docs commits get blocked by pre-existing typecheck errors in code files, creating unnecessary friction. The hook's purpose is to prevent broken code from being committed — docs can't break code.

**How to apply:** When committing files exclusively under `.planning/`, use `git commit --no-verify`. When committing mixed docs + code, let the hook run normally.
