---
name: project-layer-access-474
metadata: 
  node_type: memory
  type: project
  originSessionId: 9096bac0-c027-420f-8de8-3c0ad98d9388
---

#474 landed on main (PRs #491 + #483): the **access-side** complement to [[project_demand_side_gold_build_191]] (which is the demand side). **ADR 0049** — who may *attach* each MotherDuck share: **bronze** = DW admins only (sole reader = the dbt silver build); **silver_<system>** = that source-system owner + DW admins; **silver_core** = DW admins only (cross-source conformed dims + governance, republished to gold as views — not a consumer layer); **gold** = business users (**everyone by default, unlisted**).

Enforced via MD share access (`RESTRICTED` + per-user `grants`); **enforcement is GRANDFATHERED/DEFERRED — no share flipped** — until #191/#348 move the dives onto gold (else the CEO's ~130 live dives break). Registry = `silver_core.layer_access_registry` (dbt seed under `seeds/access_control/`, keyed on **MotherDuck username** not email; 6 schema tests). Roster so far: `siraj_jeyarama`=dw_admin/all, `jerosa_angel`=system_owner/all; **per-system SAP/Zakya/GoFrugal/PTP/StyleHR owners still TBD**. `scripts/reconcile_layer_grants.py` = read-only drift check (live grants vs registry). Orthogonal to ADR 0041 (Rill row-level access *inside* gold). A `reference` system value is reserved for hand-seed data (budgets/org/taxonomy/rates), grantable only after silver_core is untangled (follow-up **#477**).

Dive audit evidence (`docs/dives/layer-access-audit-2026-07-08.csv`): of 151 dives, 56 read bronze, 67 silver, 37 my_db/jrpl, 6 fully hardcoded, only 2 of 151 have source in the repo. ADR renumbered 0048→0049 (0048 was taken by store-only on main). See [[project_report_rationalization_478]], [[reference_worktree_adr_and_chip_hygiene]].
