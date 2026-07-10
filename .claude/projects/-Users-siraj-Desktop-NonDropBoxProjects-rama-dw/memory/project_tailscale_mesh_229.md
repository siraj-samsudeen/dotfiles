---
name: project_tailscale_mesh_229
description: "Tailscale mesh (#229) PROVEN 2026-06-25 — off-gateway/Railway services reach private SAP HANA, no VPN/static-IP; box subnet router LIVE; encrypt-false-over-mesh + route-approval gotchas; next=SAP-on-Railway experiment"
metadata: 
  node_type: memory
  type: project
  originSessionId: 690155d4-cbcc-4210-a93f-5040d93a2053
---

**#229 — Tailscale mesh as the cross-network DB fabric. PROVEN 2026-06-25.** An off-gateway machine (Railway service, CI, remote-agent proxy) reaches the private SAP **HANA** DB over a WireGuard mesh, replacing "VPN + static-IP whitelist." HANA is on a SAP private cloud reached via the office gateway's site-to-site tunnel (ADR 0011, corrected during #229; [[reference_sap_bronze_deploy_box]]).

**Tailnet:** `jeyaramagroup.org.github` — GitHub `JeyaramaGroup` org identity (sign in → "Select a tailnet" → **Create** next to JeyaramaGroup; NOT personal `siraj-samsudeen.github`). 14-day paid trial → free Personal. Decision recorded in ADR 0031.

**STANDING INFRA (LIVE as of 2026-06-25 — do NOT assume torn down):**
- **Box `sap-box` = `100.109.150.99`:** ROOT tailscaled (official dnf install, systemd `tailscaled.service`), **kernel subnet router advertising `10.10.10.39/32` (HANA), route APPROVED, `ip_forward=1`.** It runs on the SHARED prod box `rmail@192.168.2.76` that ALSO runs company mail (25/110/143/993) + ~25 Django/gunicorn apps (8001–8024) + MySQL + redis — Stage A install did NOT break them, but for production a **dedicated** subnet-router node is cleaner than this overloaded box (/ was at 96%).
- **Reach the box over the mesh now (VPN retired):** `ssh -i ~/.ssh/rama_deploy_ed25519 rmail@100.109.150.99`. The Mac runs the **Tailscale macOS GUI app (real TUN)** signed into the org tailnet (`sirajs-newmac-2023-april` = 100.125.7.66). **TESTING CAVEAT:** Siraj's Mac is usually NOT in the Rama office (e.g. Cove office, Chennai, own WiFi `10.20.x`); it can still reach the Rama LAN `192.168.2.x` (the box's office IP) via some inter-office path/VPN-remnant even with Rama VPN off — so **never use `192.168.2.76` as a mesh negative control**. Test mesh claims ONLY against `10.10.10.39` (HANA, on the SAP private cloud behind the gateway tunnel) — it is unreachable except via the mesh — with a VPN-off negative control.
- **Railway:** `sap-hana-smoke` service in project `Jeyarama-ETL` (service id `e4fa6441-a9a9-47e3-997e-f2994c3d4d27`, region Southeast Asia), idling on SMOKE OK. Code: `sap_hana_smoke/` in repo. Reusable client auth key (1-day) expires ~2026-06-26.

**PROVEN RECIPE:** client (userspace tailscaled, `--accept-routes=true`) → local SOCKS5 forwarder (`socks_forward.py`; userspace doesn't route 100.x for apps) → mesh → box kernel subnet router → IP-forward → gateway tunnel → HANA. hdbcli dials the localhost forwarder with **`encrypt=False`** (see gotcha 2).

**GOTCHAS (each cost a debug cycle — full chronology in #229 comments):**
1. **Subnet routes must be APPROVED** in the admin console (Machines → sap-box → Edit route settings). Unapproved → tailscaled SOCKS **silently falls back to the host OS** → false positives over VPN / `rc=104` resets without. Verify `tailscale status --json` PrimaryRoutes; ALWAYS use a VPN-off negative control (this caused a wrong "latency" diagnosis).
2. **Constrained container netstack + HANA TLS:** Railway containers run userspace tailscaled and CAN'T raise UDP buffers; HANA's TLS **certificate exchange (large-packet burst) resets** (`RTE 89013`). Fix: **`encrypt=False`** — WireGuard already encrypts transit, so HANA's own TLS is redundant on the mesh. (Alt: lower the Railway-side tailscale MTU to keep TLS.) Native clients (Mac) don't hit this.
3. **Latency was NOT the cause** — Singapore region (derp-sin ~60ms) failed identically to US (~232ms) until encrypt=False.
4. Fixed a real SOCKS5 reply-framing bug in `socks_forward.py` (`recvn` exact-read) — correct, but not the root cause.

**RESULT:** Railway queried private HANA over the mesh — `SMOKE OK`, `CURRENT_USER → ZS4_PS4_ETL`. Reachability fully proven (no VPN, no whitelist, no public endpoint), via the production kernel-subnet-router mechanism.

**STRATEGIC:** the mesh decouples reachability from "behind the gateway," but NOT from latency/throughput for chatty protocols. Mesh's real value: box→Railway-PG control plane, future AWS RDS, and AI-agent data access.

**AI-agent → private DB (corrects an earlier "Aperture unrelated" #229 comment):** **Tailscale Aperture's identity-aware connectors** ARE the productized version of the box-hosted MCP-DB-proxy — register a self-hosted DB→MCP adapter reachable over the tailnet, and Aperture fronts it with tailnet-identity gating + auto-injected auth at one `/v1/mcp` endpoint (reaches private resources with no public endpoint over the mesh). Caveats: (1) Aperture proxies MCP/HTTP, not raw SQL → you still build a DB→MCP adapter (e.g. a HANA-MCP server on the box). (2) **Consumption is tailnet-identity-based**: off-tailnet clients need `ts-unplug` (a daemon that joins the tailnet) — a locked-down Claude Code **cloud** agent can't run it (same sandbox wall as tailscaled; **no public API-key/token endpoint documented**). So Aperture fits **tailnet-connected / self-hosted agents** (incl. a self-hosted Claude Agent-SDK agent on our infra) well; for **Anthropic-hosted cloud agents** you'd still self-host a public token-auth MCP gateway, OR wait for Aperture to expose a public endpoint (worth asking Tailscale — it's public alpha). Aperture is for **AI-agent MCP access, NOT raw ETL** (the mesh handles ETL). Docs: tailscale.com/docs/aperture/{mcp-server,how-aperture-works,connect-outside-tailnet}.

**NEXT (Siraj wants to try):** move SAP extraction itself to Railway over the mesh and measure. ⚠️ **CONCERN to set expectations:** the SAP giants are HANA-read-bound BULK reads (millions of rows, thousands/s on the LAN); the same container userspace netstack that couldn't carry a TLS handshake burst will very likely **throttle bulk reads hard** — expect slow. Empirical test is fine; don't expect it to beat the box. Plan: `docs/plans/issue_229_tailscale_mesh_fabric.md`.
