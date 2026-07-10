---
name: reference_rama_vpn_control
description: "rama-vpn connect/disconnect/status ALL work from Claude's Bash once iTerm has Accessibility permission; plus operational gotchas about what's behind the tunnel"
metadata:
  node_type: memory
  type: reference
  originSessionId: 4e1fb30e-9bdc-49ae-95a3-04f147a67ab8
---

`~/bin/rama-vpn` (RCT.in FortiClient) toggles the VPN by AppleScript-clicking the
FortiTray menu. **All three commands — `connect`, `disconnect`, `status` — work from
Claude Code's Bash**, as long as the host terminal (iTerm) has **Accessibility
permission** (System Settings → Privacy & Security → Accessibility). The skill is
`rama-vpn` at `~/.claude/skills/rama-vpn/SKILL.md`.

**Correction (2026-05-31):** the earlier belief that toggling "needs an interactive GUI
session and can't be done from Bash" was WRONG. Two separate, fixable causes had been
conflated: (1) iTerm lost its Accessibility grant after an update → osascript **-1719**
on every command, and `status` silently fell through to reporting "disconnected";
(2) the disconnect menu label in the script was wrong (`Disconnect from RCT.in`) → **-1728**.
Fixed the label to `Disconnect RCT.in` and re-granted iTerm Accessibility; a full
disconnect→reconnect round-trip was verified working from Bash.

**How to apply:** I *can* connect/disconnect myself via Bash now — no need to ask the
user to click. But toggling drops their live tunnel, so still **confirm before
disconnecting an active connection**. connect/disconnect take a few seconds (IPSec
negotiation); poll `status` until it flips rather than reading it once. Labels are
asymmetric: `Connect to RCT.in` vs `Disconnect RCT.in`. If `status` ever reports
"disconnected" while commands error, suspect a lost Accessibility grant (-1719), not a
real disconnect.

**Operational gotchas (verified 2026-05-31, GoFrugal bronze tracer):**
- **Only SQL Server (`.62`) is behind the VPN.** The GoFrugal REST API
  (`jcterphq.gofrugalhq.com`) is on the public internet — API pulls succeed with the
  VPN down; only `Rama.*` SQL Server queries need it. So **batch VPN-dependent work**
  and let the user disconnect between batches.
- **The tunnel drops during multi-minute pulls.** A long SQL scan (e.g. day-filtering
  62 M-row `dbo.Sales`) can outlast the tunnel and fail mid-run with connectorx
  `RuntimeError: Timed out in bb8`. Keep SQL pulls short / resumable; re-confirm before
  long runs.
- **`scutil --nc status "VPN"` is unreliable** — it read `Disconnected` while the tunnel
  was actually up. Confirm connectivity with a **live `SELECT 1`**, not scutil (and never
  `grep -i connected`, which matches the substring inside "Dis**connected**").
