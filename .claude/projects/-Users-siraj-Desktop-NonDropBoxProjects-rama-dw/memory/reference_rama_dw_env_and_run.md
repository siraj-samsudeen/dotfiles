---
name: reference_rama_dw_env_and_run
description: "Where rama_dw secrets live (HANA in .env.local, MotherDuck in secrets/motherduck.env since 27-Aug-2026) and how to run HANA/MotherDuck Python, incl. from a worktree"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 15843b3a-71fa-449e-817c-ca06df5864ca
  modified: 2026-08-27T11:33:42.717Z
---

**Secrets locations (gitignored, main repo root):**
- `HANA_PROD_HOST/PORT/USER/PASSWORD/ENCRYPT` → main repo **`.env.local`**.
- **MotherDuck tokens → `secrets/motherduck.env`** (moved out of `rill/.env` on 27-Aug-2026,
  #2627; that file now holds no token). Gitignored, chmod 600, main-checkout-only — reach it
  from a worktree by absolute path. Three keys:
  `motherduck_token_read_only` (read-scaling), `motherduck_token_read_write` (owns bronze_sap,
  dbt_control, silver_*, gold*), and `motherduck_token` = **the read-only one**, kept for
  DuckDB CLI auto-auth. **The default is read-only on purpose**: anything that forgets to
  choose fails loudly on write instead of silently landing in prod. Writers (dbt via
  `run_dbt.sh`, `sync_bronze_to_md.py`) must take `motherduck_token_read_write`.
  Code accepts either `MOTHERDUCK_TOKEN` or `motherduck_token`.
- **⚠️ `motherduck_token_read_write` is read-only on bronze databases it does not OWN — but it is
  NOT a read-only token.** Corrected 2026-08-26 (#2686): its JWT claims say `tokenType=read_write`,
  `readOnly=false`, and
  it **writes every `silver_*`/`gold*` database** (verified by create+drop in `silver_zakya`). It is
  the exact token the production Railway `dbt-runner` runs on (byte-identical fingerprint), so it
  reads `bronze_*` and writes `silver_*` in one credential. MotherDuck's rule is **write =
  ownership**: `bronze_zakya` was re-homed to `zakya_extract` (#534), so this account reaches it via
  a read-only *share* — hence the 2026-08-19 (#2393) `readonly=True` / `INSERT ... read-only mode`
  observation. That is enforcement working, not a property of the token. Do **not** generalise it to
  "the rill/.env token can't write".
- **⚠️ `motherduck_token_read_scaling` in the same file is misnamed** — as of 26-Aug-2026 it holds
  the identical `read_write` PAT, so it buys no safety. And **never run `dbt debug`**: it prints the
  token in plaintext (the profile embeds it in the connection path).
- **For any WRITE / dlt load, use the owning service account's token from `.env.local`** — each
  bronze DB is owned by its extractor's account (#534), e.g. `zakya_extract_read_write_token` for
  `bronze_zakya` (`readonly=False`). Others present: `motherduck_dive_service_account_token`,
  `motherduck_essl_stylehr_sync_audit_read_write_token`. Each service's `DEPLOY.md` names the exact
  key — check it rather than guessing. Symptom of getting this wrong: the extractor logs
  `SINK_ERROR ... read-only mode`, or worse reports `ok` while landing nothing (see
  [[gotcha_zakya_extract_ok_can_be_a_phantom]]).

**⚠️ The old shared admin PAT (fp `96192ab5328d`) was REVOKED 27-Aug-2026** — it now fails
`Invalid MotherDuck token (PERMISSION_DENIED, RPC 'CREATE_SLT')`. Any cached shell export,
`rill/.env.bak-2686`, or box `.env.run` still holding it is dead.

**The box DID hold the revoked PAT and WAS an outage-in-waiting — fixed 27-Aug-2026 16:38 IST under
#2763.** Pre-swap, `~/sap_bronze/.env.run` had mtime Jul 16 and token fp `96192ab5328d` (the revoked
admin PAT), and a probe from the box with it returned `PERMISSION_DENIED, RPC 'CREATE_SLT'` while the
same probe with the new PAT returned `AUTH_OK` — so the 17:01 tick would have died. Pre-swap content
is preserved at `~/sap_bronze/.env.run.bak-20260827-issue2763`. It now holds
`motherduck_token_read_write` (fp `4db9f5482f7f`). **#2763 Part B — the #534-style re-homing of
`bronze_sap` from Siraj's personal account to `sap_extract` — is still open**;
`sap_extract_read_write_token_01` owns nothing but its own `my_db`, and write = ownership, so no
token swap can substitute for it.

⚠️ **A point-in-time reading cannot answer a historical question.** I checked that same file at
~16:45, found the live token, and concluded "the box was never affected" — I was reading another
session's fix, seven minutes old, as evidence the problem never existed, and nearly got a correct
chip withdrawn. **Check `mtime`/backups and ask "did someone just change this?" before drawing any
conclusion about the past from a current observation.** See [[feedback_absence_claims_need_positive_control]] —
my positive control was valid; the inference I hung on it was not.

**Run the sap_bronze service (or any HANA+MD script) locally:**
```
set -a; . .env.local; . secrets/motherduck.env; set +a
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

**From a git worktree:** the `.venv` AND the gitignored env files (`.env.local`,
`secrets/motherduck.env`) exist only in the **main repo**, never the worktree. Use absolute paths:
source `<mainrepo>/.env.local` + `<mainrepo>/secrets/motherduck.env` and run
`<mainrepo>/.venv/bin/python`. **But NEVER pass a main-checkout absolute path to an Edit/Write** —
the edit lands in main's tree while your `git add` stages nothing, and the commit succeeds claiming
a file it does not contain (repo gotcha `worktree-absolute-path-edit-makes-a-silent-no-op-commit`;
hit twice on 2026-08-27 by two sessions, neither raising an error). (Same
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
not a timedelta — don't call `.days`; (b) long box-SSH (`rmail@192.168.2.76` over Rama VPN) commands
occasionally **truncate mid-output** — add `-o ServerAliveInterval=15` and keep commands short / split.

**DuckDB:** `table`, `column`, `rows` are reserved words — quote them (`"table"`) in queries over CSVs.


**28-Aug-2026 (#2763):** RW PAT re-minted same-day under the name `motherduck_token_read_write` (UI name == env key, Siraj's revocation-traceability convention; the interim `_02` was revoked and its line removed — single key again, fp f9898ac0ca82). On future rotations: if the MD-side name is free, reuse it; a temporary _NN key needs the stable-alias duplication while it lives. **Rill is RETIRED** (org deleted, GitHub App uninstalled) — rill/.env is dead; cleanup #2834. The box's sap_bronze token is now the sap_extract SERVICE-ACCOUNT token, not an admin PAT.

**Token keys renamed 05-Sep-2026 (#167).** `secrets/motherduck.env` now holds `motherduck_token`, `motherduck_token_read_only` (read-scaling PAT — replicas, not for reconciliation), `motherduck_token_read_write_admin` (was `motherduck_token_read_write`) and `dbt_read_write_token_01` (the dbt service-account writer). Resolve the key from the file's own header comment rather than memorising a name — it has now changed twice.

**Consolidated 09-Sep-2026 (#3364):** every MotherDuck credential now lives in
`secrets/motherduck.env`. Moved out of `.env.local`: `motherduck_dive_service_account_token`
(READ-WRITE — owns/creates dives), `motherduck_dive_service_account_read_scaling_token` (read-only,
Feather Answers serving), `motherduck_essl_stylehr_sync_audit_read_write_token`. Values verified
identical by md5 fingerprint and functionally re-tested. `.env.local` keeps a breadcrumb.
**Only `motherduck_token_read_write_admin` can read `md_information_schema.query_history`** — the
dive service account cannot, which is why the telemetry had to be materialised into gold.
`docs/plans/issue_167_...md` line ~1160 still resolves the dive token from `.env.local` and is stale.
