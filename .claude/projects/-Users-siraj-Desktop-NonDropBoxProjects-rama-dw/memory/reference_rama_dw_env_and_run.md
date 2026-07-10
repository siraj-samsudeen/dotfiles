---
name: reference_rama_dw_env_and_run
description: "Where rama_dw secrets live (HANA in .env.local, MotherDuck in rill/.env) and how to run HANA/MotherDuck Python, incl. from a worktree"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 15843b3a-71fa-449e-817c-ca06df5864ca
---

**Secrets locations (gitignored, main repo root):**
- `HANA_PROD_HOST/PORT/USER/PASSWORD/ENCRYPT` → main repo **`.env.local`**.
- **MotherDuck token → `rill/.env`** (key `motherduck_token=`, a ~457-char JWT). It is **NOT** in
  `.env.local`; the root `.env` has only an empty commented `# MOTHERDUCK_TOKEN=` placeholder, and
  the live token used by the MCP server isn't in any readable file. So for dlt/duckdb loads you must
  source `rill/.env`. Code accepts either `MOTHERDUCK_TOKEN` or `motherduck_token`.

**Run the sap_bronze service (or any HANA+MD script) locally:**
```
set -a; . .env.local; . rill/.env; set +a
PYTHONPATH=sap_bronze/src .venv/bin/python -m sap_bronze --masters [--only t001w,t006]
```
The package isn't pip-installed → set `PYTHONPATH=sap_bronze/src`. Use the repo `.venv/bin/python`
(resident probe stack: hdbcli, duckdb, dlt, connectorx, pyarrow, pandas); never bare `python`.

**Python is 3.12 (NOT 3.14) — #73/#114 standard.** The local `.venv` was rebuilt on **3.12.13**
2026-06-15 (fix branch `fix/dev-env-py312`, commit 7b74d09): root `pyproject` now
`requires-python ">=3.12,<3.13"` + a `.python-version=3.12`, and **`hdbcli`/`paramiko` are now
DECLARED** (hdbcli in deps, paramiko in the `dev` group). This kills the dlt **`LoadPackageNotFound`**
that 3.14 caused — dlt loads now work on the Mac (verified to local-duckdb + MotherDuck), though
ADR 0011 still keeps prod loads on the box. **Gotcha (pre-fix):** `uv sync` PRUNES anything not in
`pyproject`/`uv.lock`; before the fix it silently removed hand-installed hdbcli/paramiko and broke
HANA + `ssh_box.py`. Post-fix `uv sync` is safe. **If `fix/dev-env-py312` isn't merged to `main` yet,
do NOT `uv sync` from a `main` checkout** (main's pyproject still says `>=3.10` → would re-prune +
re-drift to 3.14).

**From a git worktree:** the `.venv` AND the gitignored env files (`.env.local`, `rill/.env`) exist
only in the **main repo**, never the worktree. Use absolute paths: source
`<mainrepo>/.env.local` + `<mainrepo>/rill/.env` and run `<mainrepo>/.venv/bin/python`. (Same
class of gotcha as [[feedback_worktree_useless_for_untracked_cleanup]].)

**HANA / hdbcli gotchas:**
- Connect to tenant PS4: port **30041**, **omit `databaseName`** (SAPHANADB is the schema, not a DB —
  passing it gives "database not connected"), `encrypt=True`, `sslValidateCertificate=False`.
- `hdbcli` `cursor.execute(sql)` returns a **bool**, not the cursor — call `cur.fetchone()/fetchall()`
  separately (don't chain `.execute(...).fetchone()`).
- **hdbcli does NOT accept `%s` param placeholders** — `cur.execute("... WHERE c=%s", (v,))` throws
  `(257, 'sql syntax error ... near "%"')`. Use **`?`** placeholders, or inline safe constants
  (`WHERE MANDT='200'`). (Cost me 3 retries this session 2026-06-29; psycopg/connectorx DO use `%s`,
  hdbcli does not — they differ.)
- Free per-column stats (no business scan): `SYS.M_CS_ALL_COLUMNS` (`COUNT`, `DISTINCT_COUNT`) — see
  [[feedback_bronze_curation_profiling_driven]].

**Probes over SSH on the box — write a FILE, don't inline-heredoc with nested quotes:** running
`ssh box 'PYTHONPATH=src .venv/bin/python - <<PYEOF … PYEOF'` with **f-strings that contain quotes**
(`\x27…\x27`, nested `"`/`'`) repeatedly fails with `SyntaxError: unexpected character after line
continuation character` — the shell/heredoc mangles the escapes. Reliable pattern: `cat > /tmp/x.py
<< "PYEOF"` (QUOTED delimiter → no shell interpolation) to write the probe to a file, then run
`PYTHONPATH=src .venv/bin/python /tmp/x.py`. Inside the probe, prefer **`%`-formatting** over
f-strings-with-quotes. Two more: (a) Postgres date subtraction `(d2 - d1)` returns an **int (days)**,
not a timedelta — don't call `.days`; (b) long mesh-SSH (`100.109.150.99`) commands occasionally
**truncate mid-output** — add `-o ServerAliveInterval=15` and keep commands short / split.

**DuckDB:** `table`, `column`, `rows` are reserved words — quote them (`"table"`) in queries over CSVs.
