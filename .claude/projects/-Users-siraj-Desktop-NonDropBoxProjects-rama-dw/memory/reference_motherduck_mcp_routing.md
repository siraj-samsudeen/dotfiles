---
name: reference-motherduck-mcp-routing
description: Which MotherDuck MCP to use for rama_dw — two accounts are live simultaneously; wrong one silently has different databases
metadata: 
  node_type: memory
  type: reference
  originSessionId: 9a60c915-5cea-46fb-b014-8c66af0906a1
---

Two MotherDuck MCP connections are active in this Claude session:

| MCP tool prefix | Account | Databases |
|---|---|---|
| `mcp__motherduck-jeyarama__*` | **Jeyarama Group** ← use this for rama_dw | `bronze_gofrugal`, `bronze_sap`, `bronze_zakya`, `_control`, `dbt_control`, `silver_core`, `silver_gofrugal` |
| `mcp__fa37d000-92e0-4621-9432-1850cc9a9624__*` | Different account | `bronze_essl`, `bronze_foobill`, `bronze_google_sheets`, `bronze_petpooja`, `bronze_ppos`, `bronze_sapb1` |

**Always use `mcp__motherduck-jeyarama__execute_query`** for all rama_dw queries.

The UUID-named MCP (`fa37d000...`) silently connects to a different MotherDuck account — queries against it will return "Catalog Error: no catalog + schema named X found" for any rama_dw database. Do not try `list_databases` on the UUID one to confirm; just go straight to the Jeyarama MCP.
