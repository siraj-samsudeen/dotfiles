---
name: reference_motherduck_mcp_routing
description: Both MotherDuck MCP servers are the SAME account; dive/share tools only on the UUID one — see the repo gotcha
metadata: 
  node_type: memory
  type: reference
  originSessionId: 29df9977-42d0-4aba-b4da-c0bfcb2a5a4d
---

Promoted to the repo per the single-source rule (2026-07-10): the full trap and fix live in
`docs/agents/gotchas/motherduck-two-mcp-servers-same-account-dive-tools-on-uuid.md` — read that file;
do not restate it here.

**Corrected 2026-07-17 (#752):** this memory previously said the UUID-named server (`fa37d000-…`) was
"a different account". That was wrong and cost a session real time. Both servers are one account
(verified: identical `current_user`, shares, owners, and databases). The UUID server is the **only**
one carrying the dive tools (`list_dives`/`read_dive`/`edit_dive_content`) and `list_shares` — reach
for it whenever a dive is involved. The old evidence (`Catalog 'rama_dw' does not exist`) proved
nothing: `rama_dw` is the REPO name, not a database. Never infer account identity from a
missing-catalog error — query `current_user`.

Related: [[project_mydb_migration]].
