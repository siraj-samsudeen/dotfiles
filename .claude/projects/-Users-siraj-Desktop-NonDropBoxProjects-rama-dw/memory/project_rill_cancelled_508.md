---
name: rill-cancelled-508
description: "Rill Cloud subscription cancelled 2026-07-09; access until 2026-08-01; report server (#436) supersedes it"
metadata: 
  node_type: memory
  type: project
  originSessionId: 6915cd74-7ec0-4474-a856-4b1125183019
---

**Rill Cloud subscription is CANCELLED** (by Siraj, 2026-07-09; recorded retroactively as #508). Access runs until **2026-08-01**, then Rill dashboards stop. Reason: Rill metrics-view reports not rich enough vs. the bespoke HTML reports; the report server trial ([[report-server-436]] dash.jeyarama.com) succeeded and supersedes it.

**Do not build new work on Rill.** Disposition sweep DONE (2026-07-09, full rationale in #508 comments). Closed as moot (content transferred first): #181→#226+#455 (CEO's role list), #159→#452 (formatting conventions), #212→#206 (ptp/stylehr health gap). Kept open, retargeted onto report server (design content copied forward, only Rill delivery dropped): #309/#270/#416→also copied to #436 as candidate dashboards for #452's live-report engine; #363/#369/#377 (access-control track, incl. buyer-identity problem + L1/L2/L3 layer model)→#455; #167→mostly unaffected, just drop the rill-bi token row.

**RLS enforcement needs a new home** — MotherDuck has no RBAC as of 2026-07; **#455** (report-server access_grants-driven scoping + admin "View as") is now the live successor to the Rill RLS design, building on #377's `gold.access_grants` engine which survives untouched. Known losses vs Rill (no replacement built yet): team-shareable chats, and Rill's answer-plus-custom-report-link feature (full pros/cons in #508 comment). `rill/` in the repo + its auto-deploy path + the Rill MCP server go inert after 2026-08-01.
