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

## When to use

- User says "connect VPN", "connect Rama VPN", "RCT VPN", "turn on VPN", "I need VPN"
- User says "disconnect VPN", "turn off VPN"
- A task is about to hit SQL Server (192.168.x.x) or Zoho/Zakya API and VPN might be needed
- Check status first if unsure whether VPN is already on

## Workflow

1. Run `rama-vpn status` to check current state
2. Run `rama-vpn connect` or `rama-vpn disconnect` as needed
3. Confirm the action succeeded by running `rama-vpn status` again

## Notes

- Requires FortiTray to be running (it always is on this machine at login)
- No password prompt — credentials are saved in FortiClient
- Profile: RCT.in / IPSec / server 59.92.69.63
- **Requires the host terminal (iTerm) to have Accessibility permission** —
  System Settings → Privacy & Security → Accessibility. Without it, every command
  fails with osascript error -1719 and `status` silently misreports "disconnected".
  A macOS or iTerm update can reset this grant; re-enable iTerm if commands start failing.
- Menu labels are asymmetric: `Connect to RCT.in` (with "to") vs `Disconnect RCT.in`
  (no "from"). If FortiClient changes them, a click fails with -1728 while `status`
  still works — re-read the live labels with the osascript in the `status` branch.
- `connect`/`disconnect` take a few seconds (IPSec negotiation); poll `status`
  until it flips rather than reading it once immediately after.
