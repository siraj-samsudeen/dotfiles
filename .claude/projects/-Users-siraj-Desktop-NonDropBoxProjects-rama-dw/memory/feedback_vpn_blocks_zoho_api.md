---
name: feedback-vpn-blocks-zoho-api
description: Rama FortiClient VPN reaches BOTH SQL Server (192.168.2.62) and Zoho APIs in one connection — full-tunnel but FortiGate permits internet egress (verified 2026-05-21)
metadata:
  node_type: memory
  type: feedback
  originSessionId: 6221ee22-2492-46c2-9a7a-7a5e51c9d933
---

**Verified 2026-05-21 (supersedes earlier "VPN blocks Zoho" claim):** With the FortiClient VPN connected, a single connection reaches both `192.168.2.62:1433` (SQL Server) AND the Zoho APIs (`api.zakya.in`, `accounts.zoho.in`, `www.zohoapis.in`). `https://api.zakya.in` returns a real HTTP 302 round-trip. Confirmed identical from HO WiFi and from the office LAN — location-independent.

**Why:** It IS full-tunnel — both the SQL IP and public IPs (incl. 8.8.8.8) route via `utun5`. But the FortiGate gateway permits outbound internet egress, so Zoho traffic passes through the tunnel fine. The earlier "VPN blocks Zoho / hangs at TLS" behavior no longer reproduces — IT likely changed the FortiGate egress policy, or the earlier test used a different network/profile.

**How to apply:** No VPN toggling needed. A single dlt pipeline CAN fetch from Zoho and write to SQL Server in one process with the VPN on. The two-script split (`fetch_export.py` VPN-off / `dlt_sales_poc.py` VPN-on) and the split-tunnel request (issue #29) are no longer necessary. Note: on HO *guest* WiFi without VPN, SQL Server is unreachable — that WiFi routes via the ACT ISP and has no path to `192.168.2.0/24`; the VPN is still required, it just no longer breaks Zoho. See [[project_pbi_sales_allstores_categorywise]].
