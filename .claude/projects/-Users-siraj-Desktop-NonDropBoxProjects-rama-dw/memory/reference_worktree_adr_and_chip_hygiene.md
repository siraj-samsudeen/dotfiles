---
name: reference-worktree-adr-and-chip-hygiene
description: Merge to main before spawning chips; check origin/main before numbering an ADR; MD share model
metadata: 
  node_type: memory
  type: reference
  originSessionId: 9096bac0-c027-420f-8de8-3c0ad98d9388
---

Traps hit while landing #474 in the shared multi-agent checkout:

1. **Spawned chips (`spawn_task`) branch off `main`.** A chip that reads a file (e.g. an evidence CSV named in its prompt) fails if that file is only on an unmerged feature branch. **Merge the chip's dependencies to main FIRST**, or point the chip at `origin/<branch>`.
2. **ADR numbers get claimed on `main` by parallel agents.** Run `git ls-tree origin/main docs/adr/` before numbering — #474's ADR had to renumber **0048→0049** because #458 took 0048 (store-only) while the branch was open. `perl -i -pe 's/ADR 0048/ADR 0049/g'` on your own files only (don't touch main's real 0048 refs).
3. **Landing on main from a diverged worktree**: don't `git merge origin/main` into a stale feature branch (conflicts on CONTEXT.md/_seeds.yml). Instead branch fresh off `origin/main`, `git checkout <oldbranch> -- <additive files>`, re-apply the shared-file edits, PR + `gh pr merge --squash`.

**MotherDuck share access model** (enforcement surface for [[project_layer_access_474]]): `md_information_schema.main.owned_shares` → columns `name, access, grants`. `access` ∈ {`RESTRICTED` (+ per-user `grants[].grantee_name`), `ORGANIZATION` (any org member attaches)}. Lock a layer = set RESTRICTED + grant per registry. dbt local run: the token key in `rill/.env` is lowercase `motherduck_token`; dbt/duckdb needs it exported as `MOTHERDUCK_TOKEN` (build: `$MAIN/dbt_runner/.venv/bin/dbt build --select <seed> --project-dir <wt>/dbt_runner/dbt --profiles-dir $MAIN/dbt_runner/dbt`).
