---
name: feedback_constrained_resource_two_sided
description: Constrained-resource discipline — never read it twice AND never leave its window idle (two sides of one coin)
metadata: 
  node_type: memory
  type: feedback
  originSessionId: e3dd6b8a-509f-425b-b8b1-cbf6ccd6f11c
---

Siraj's principle (2026-06-29), two sides of one coin for a constrained/bottleneck resource (HANA is
the binding constraint for SAP — a remote private-cloud DB over a site-to-site VPN, see
[[reference_sap_hana_network_topology]]):

1. **Never WASTE a read of a constrained source.** Read it once into a durable local intermediate
   (the spool parquet); on a *downstream* failure, **fix-the-writer-and-re-drain from the
   intermediate — never re-read the source.** The dlt-merge path's read-HANA-on-every-retry is the
   anti-pattern this avoids. (Recorded in ADR 0035 as the "read once" principle.)
2. **Never WASTE an available WINDOW of a constrained source.** When its off-peak/overnight window is
   open, drain it *fully* — don't leave the constrained resource idle. This is why the giants drain
   20:00→09:00 and loads run off-peak ([[reference_sap_bronze_throughput]],
   [[project_sap_overnight_drain_watchdog]]).

**Why:** the source, not the warehouse, is usually the bottleneck (HANA read ~3k/s vs MD merge much
slower); both sides protect that scarce capacity — one by not re-spending it, the other by not
letting it sit idle.

**How to apply:** design loads so the source is read **exactly once** into a spool/parquet
([[reference_md_load_chunking_from_box]]) **and** so the open window is **saturated** (queue/parallel
work to fill it) rather than idle. When you record one side, record the other too — they're inseparable.
