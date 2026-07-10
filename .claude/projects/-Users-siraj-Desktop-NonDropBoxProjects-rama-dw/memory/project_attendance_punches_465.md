---
name: project_attendance_punches_465
description: "#465 ESSL attendance — NO ingestion (already in StyleHR); silver attendance_punches + gold attendance_compliance on main"
metadata: 
  node_type: memory
  type: project
  originSessionId: 5ff6847e-8047-4946-a817-84f9da988695
---

#465 began as "ingest ESSL eTimeTrackLite biometric attendance" and ended as **do NOT ingest it** —
the punches are already in the warehouse via StyleHR.

**The load-bearing fact:** `bronze_stylehr.public.employee_attendance` IS the raw per-punch stream
(15.3M rows, `type_of_punch` in/out, `employee_code`/`employee_id`, `device_id`), and
`employee_punchtype` (`1=ESSL` 13.2M, GPS/ATR/OD/Deputation) is the **capture source**. StyleHR
consolidates multiple ESSL sites (~5,900 emp/day) — 3× the single reachable ESSL DB
(192.168.2.62/etimetracklite1, ~2,000/day). So direct ESSL ingestion would give a smaller,
directionless, region-partial slice. CEO confirmed no need for pre-Mar-2025 history. **Don't ever
re-open ESSL ingestion.** (#465's earlier "employee_devicelog is the only punch source" premise was
wrong — that table is app login/download; `employee_attendance` is the punches.)

**Built & merged on main:**
- `silver_stylehr.attendance_punches` (PR #481) — employee×day break/punch-out detail. Additive to
  `silver_stylehr.attendance` (join on employee_id,date); never redefines `man_hours`.
- `gold.attendance_compliance` (PR #490) — SM-360 Ops-pillar consumer fact (ADR 0046); atomic
  took_break/no_break/not_punched_out/single_out flags; ratios computed by consumer.

**This is SETTLED — don't re-file it.** #520 (filed 2026-07-09 as "employee_attendance is the punch
stream, unfreezes #439 Ops") was a **duplicate of #481/#490 and was closed**. If an ESSL "new punch
stream" discovery surfaces again, it's already modelled here — point at #481/#490, don't open a card.

**Punch DQ (reusable for any biometric punch work):**
- `type_of_punch` is **2.46:1 lopsided (defaulted to `in`)** — devices are directionless (raw ESSL
  `Direction` 93% blank). **Pair by SEQUENCE (odd=in, even=out), not the tag**; keep the tag only as a
  confidence signal. Source swap does NOT fix this — it's inherent to directionless punches.
- Break metrics computable on **even-count days (~94% over full history: 28% high-confidence clean-tag
  + 66% medium pairable-broken-tag)**; NULL+flagged on odd/single (~6%) — those flags ARE the
  Not-Punched-Out / Single-Out metric, not junk. Device storms (95 punches/s) de-bounced at 60s.
- Join key: `employee_attendance.employee_id` = `silver_stylehr.employee.employee_key` (the surrogate
  `id`, max ~34k), 100% match — NOT `employee_code`.

**Gotcha found in passing:** `silver_stylehr.attendance.attendance_status` is **mislabeled** — it
carries the punch capture-source (ESSL/GPS) not work-status (present/absent/WO), because
`employee_attendancestatus.punch_type_id` also resolves to `employee_punchtype`. Chip filed.

**Open (own sessions):** ESSL↔StyleHR completeness recon (chip) — but see [[project_essl_stylehr_recon_482]],
which already found StyleHR structurally drops agency/outsourced workforce; the recon should build on
#482, not redo it. `attendance_status` mislabel (chip). #439 report last-mile + break_compliance ratio
formula (handed to the live #439 session). Related: [[project_stylehr_railway_413]], [[project_store_dimension_249]].
