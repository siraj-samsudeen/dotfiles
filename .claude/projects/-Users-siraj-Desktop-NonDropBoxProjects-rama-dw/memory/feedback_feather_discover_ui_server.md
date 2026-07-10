---
name: feather discover keeps running to serve schema viewer
description: After discovery, `feather discover` launches a localhost HTTP schema viewer and the process stays alive — don't mistake it for a hang
type: feedback
originSessionId: 48d9e41a-2e91-451b-9d44-ed4712193d38
---
After `feather discover` finishes its discovery work, it launches a built-in localhost HTTP server that serves `schema_viewer.html` and the schema JSON files. The CLI process does **not** exit on its own — it stays alive until the user (or signal) kills it.

**Why:** Hit this on 2026-05-11 in the rama_dw repo. Discover finished mi_db in ~3 sec but the process ran for 30+ min before I killed it, assuming it was hung on SQL Server re-validation. Wasted cycles polling and checking pids. The HTTP-server lines in stdout (`127.0.0.1 - - [...] "GET /schema_viewer.html HTTP/1.1"`) are the tell.

**How to apply:**
- When piping `feather discover` (e.g. `feather discover 2>&1 | tail -50`), stdout never flushes because tail waits for stdin to close. Either run it in foreground and Ctrl-C after the "N discovered, M cached" line, or background it with `run_in_background` and watch the state file (`feather_discover_state.json`) for completion rather than the process.
- The discovery result is durably written to disk *before* the HTTP server starts: check `feather_discover_state.json` and the per-source `schema_*.json` files to confirm completion. Killing the process after that point is safe.
- For non-interactive automation, kill the process by pid as soon as the state file's `last_run_at` updates.
