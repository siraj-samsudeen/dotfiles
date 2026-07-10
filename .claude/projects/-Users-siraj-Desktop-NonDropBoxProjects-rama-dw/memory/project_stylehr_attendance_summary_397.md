---
name: project_stylehr_attendance_summary_397
description: "#397 silver_stylehr.attendance_summary_daily LANDED — StyleHR's own app MIS grid, faithful flatten, for #439 scorecard"
metadata: 
  node_type: memory
  type: project
  originSessionId: 95ae3729-55b5-432f-855e-5da5f8eb72a4
---

#397 built `silver_stylehr.attendance_summary_daily` (PR #531, merged to main 2026-07-09) — a thin,
faithful flatten of `bronze_stylehr.public.common_attendancesummary.attendance_summary_data` (a JSON
blob) into StyleHR's OWN app-computed daily attendance MIS grid. Feeds #439 (JRBG SM 360° Scorecard,
epic #436) HR-Attendance + coarse-Ops pillars. Design = #385 decision A6.

**Shape:** grain one row per (store_id, date), `all_store=false` only (group rollups have store_id
NULL — filtered). 18 counts carried as typed INT with **source-faithful lowercased keys** (`WO→wo`,
`OD→od`, `lop`/`pfa` verbatim); 14 `*_pct` display strings dropped (re-derive ratios in consumer).
plant_code/region/entity via `stylehr_plant_recon`; incremental delete+insert on (store_id, date).
Verified exactly 1:1 with source (22,747 rows = distinct cells; spot-checked key-by-key).

**BASIS (do not "fix"):** these are StyleHR's *app-computed* figures — deliberately NOT reconciled to
canonical `silver_stylehr.attendance` (#274 owns that; the two answer different questions). RB's
scorecard is built from THIS MIS screen, so faithfulness to the screen is the requirement. Distinct
from the punch-derived compliance fact [[project_attendance_punches_465]] (#490) — complementary, not
overlapping.

**`pfa` meaning is UNCONFIRMED** — undocumented in StyleHR/repo (max 170). Surfaced faithfully, glossed
as unconfirmed in `_models.yml`. If you learn what it is, backfill the yml + this note.

**Consumer caveat for #439 (inherited from recon, NOT a #397 defect):** only **34 of 67** StyleHR
stores resolve to a plant_code; the other 33 map to NULL plant_code AND NULL region — `stylehr_plant_recon`
(ADR 0040) has no mapping for HO/warehouses/kitchens **plus the entire Chennai "AS" cluster** (AS T-Nagar,
AS Usman Road, AS Perambur, …). #439 must key on `store_id` if it needs those 33. Follow-up chip filed to
decide whether the "AS" cluster is in JRBG scope + extend recon. Related: [[project_store_dimension_249]],
[[project_stylehr_railway_413]].
