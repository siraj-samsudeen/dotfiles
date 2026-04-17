---
name: Two-track architecture decision
description: InstantDB web app for immediate teacher+student experience with SRS; Expo native app pinned for long-term (background audio, offline-first). Decided April 2026.
type: project
---

Track 1 (now): Extend InstantDB Next.js app to serve both teacher AND student. Add FSRS-based SRS, auth, real-time issue sync, student progress. Web-first for fast iteration.

Track 2 (later): Port proven UX to Expo/React Native when pedagogy is validated. Adds background audio, true offline, App Store.

**Why:** Real-time teacher↔student sync (the "smooth and seamless" requirement) is native to InstantDB but impossible in the offline-first Expo architecture. Building Expo first would take months before a testable student experience. InstantDB gets there in weeks.

**How to apply:** All immediate feature work targets the Next.js InstantDB app. Don't build Expo infrastructure yet. When discussing native capabilities (background audio, push notifications), acknowledge them as Track 2 items, not blockers.
