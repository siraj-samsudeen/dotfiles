---
name: rama-vpn
description: Connect or disconnect the Ramachandran (RCT.in) FortiClient VPN. Use when the user asks to connect/disconnect Rama VPN, RCT VPN, or office VPN, or when a task requires VPN access (e.g. SQL Server, Zoho API from office network).
---

You have access to the `rama-vpn` command in ~/bin/rama-vpn. Use it via Bash.

## Commands

```bash
rama-vpn connect       # Connect to RCT.in
rama-vpn disconnect    # Disconnect from RCT.in
rama-vpn status        # Prints "connected" or "disconnected"
```

## When VPN is needed

Tasks that reach the office network — SQL Server on 192.168.x.x, or the
Zoho/Zakya API from the office IP — need the VPN up first.

## Workflow

1. Run `rama-vpn status` to check current state
2. Run `rama-vpn connect` or `rama-vpn disconnect` as needed
3. Poll `rama-vpn status` every couple of seconds until it flips — IPSec
   negotiation takes a few seconds, so one immediate read shows the old state

## Notes

- Requires FortiTray to be running (it always is on this machine at login)
- No password prompt — credentials are saved in FortiClient
- Profile: RCT.in / IPSec / server 59.92.69.63
- **Requires the host terminal (iTerm) to have Accessibility permission** —
  System Settings → Privacy & Security → Accessibility. Without it, every command
  fails with osascript error -1719; `status` prints `error: ...` to stderr and exits 2.
  A macOS or iTerm update can reset this grant; re-enable iTerm if commands start failing.
- Menu labels are asymmetric: `Connect to RCT.in` (with "to") vs `Disconnect RCT.in`
  (no "from"). If FortiClient changes them, a click fails with -1728 while `status`
  still works — re-read the live labels with the osascript in the `status` branch.

