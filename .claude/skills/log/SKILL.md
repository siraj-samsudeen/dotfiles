---
name: log
description: "Log a URL, image, pasted email, or meeting notes into the Obsidian vault. URLs and images go into reading/ (quick daily-log line or full reading note). Emails go into the right project's emails/ folder. Meeting notes go into meetings/. Both are indexed in that project's _index.md."
allowed-tools:
  - Read
  - Write
  - Bash
  - WebFetch
  - TodoWrite
---

<objective>
Turn a URL, image, or pasted email into a vault entry. Detect the input type,
branch to the right flow, show a draft, and only save on confirmation.
</objective>

<vault_root>
~/Dropbox/Siraj/Projects/siraj-claude-vault/
</vault_root>

---

## Step 1 — Detect the input type

| What the user gave you | Type | Flow |
|---|---|---|
| A URL (with or without an image) | URL | → Reading flow |
| An image only (no URL) | Image | → Reading flow |
| Pasted email text (From/To/Subject headers, or clearly a client message) | Email | → Email flow |
| Meeting notes or a summary of a call/meeting | Meeting | → Meeting flow |
| Ambiguous (plain pasted text, no clear signal) | Unknown | Ask: "Is this an article, an email, meeting notes, or something else?" |

---

# Reading Flow (URLs and images)

## Step R1 — Ingest

**URL:** Fetch with WebFetch. Extract: title, author, publication date, key ideas.
If fetch fails, ask the user to paste the content directly.

**Image only:** Read the image visually. Extract: what it shows, any text, the core idea.

**URL + image:** Fetch the URL; use the image as supplementary context.

## Step R2 — Ask the mode

> **Quick log or full note?**
> - **Quick** — one line in today's daily log only
> - **Full** — reading note in `reading/` + a daily log link

Wait for the answer before continuing.

## Step R3a — Quick mode

Draft a single line:

> Read [Title](URL) — [one-sentence takeaway].

Show it. Let the user edit. On confirmation, append under `## Reading` in today's
daily log (create the section if it doesn't exist).

## Step R3b — Full mode

### Draft the reading note

```markdown
---
type: reading
date: <YYYY-MM-DD>
source: <URL or "image">
author: <Author, omit if unknown>
tags:
  - <suggested tag>
---

# <Article Title> — <Author>

<One-sentence hook.>

## <Section heading or "The key ideas">

### <Key idea 1>
- <bullet>
- <bullet>

### <Key idea 2>
- <bullet>
- <bullet>

## Why I keep this

<One sentence in the user's voice — not a generic summary.>
```

**Tag rules:** Suggest 1–2 plain noun-phrase tags (e.g. `Product-Building`,
`Leadership`, `Design`). No `Type/` or `Topic/` prefixes. Surface them as part
of the draft, not as a separate question.

**"Why I keep this":** Always draft this, always confirm it explicitly.
Ask: *"Does this capture why you're keeping it, or do you want to change it?"*

### Show and confirm

Present the full draft. Do not save until the user confirms.

### Save

- Slug: lowercase title, spaces → hyphens, strip punctuation.
- Path: `reading/<slug>.md` (use `create_dirs: true`).

### Update the daily log

Append under `## Reading`:

> Filed [[reading/<slug>]] — <one-sentence summary>.

---

# Email Flow

## Step E1 — Extract email metadata

From the pasted content, pull out:
- **From** (sender name + email if present)
- **To** (recipient)
- **Date** (from headers if present, otherwise today)
- **Subject** (or infer a short title if missing)
- **Body** (the full message text)

## Step E2 — Identify the project

Scan the email for project signals: client name, product name, domain, any
reference to known projects in the vault.

List the matching project(s) and ask:

> "This looks like it's for **<project>**. Is that right, or should it go somewhere else?"

If no project is detected, ask: "Which project does this belong to?"

Show the list of known projects:
```bash
ls ~/Dropbox/Siraj/Projects/siraj-claude-vault/projects/
```

## Step E3 — Draft the email note

```markdown
---
type: email
project: <project-slug>
date: <YYYY-MM-DD>
from: <sender>
subject: <subject>
tags:
  - Projects/<project-slug>
  - Type/Email
---

# <Subject>

**From:** <sender>
**Date:** <date>

## Summary

<2–3 sentences on what the email says and why it matters.>

## Key points

- <point>
- <point>

## Action items

- [ ] <action>

## Original

<Full pasted email text, unedited.>
```

Omit **Action items** if there are none. Keep **Original** always — it's the
source of truth.

## Step E4 — Show and confirm

Present the draft. Do not save until the user confirms.

## Step E5 — Save

- Slug: derived from subject, lowercase, hyphenated.
- Path: `projects/<name>/emails/<YYYY-MM-DD>-<slug>.md`
- Create `emails/` if it doesn't exist (`create_dirs: true`).

## Step E6 — Update the project index

Append one line to `projects/<name>/_index.md` under the current month:

```
- YYYY-MM-DD [[emails/YYYY-MM-DD-<slug>]] — <one-line summary>
```

---

# Meeting Flow

## Step M1 — Extract meeting metadata

From the pasted notes or description, pull out:
- **Date** (when the meeting happened, not today unless it just occurred)
- **Attendees** (names/roles if mentioned)
- **Topic** or meeting title
- **Body** (the raw notes)

## Step M2 — Identify the project

Scan for project signals, confirm with the user:

> "Is this meeting related to a project, or is it a general/standalone meeting?"

If project-related: confirm the project name (same as Step E2).
If no project: route to the global meetings folder (see below).

## Step M3 — Draft the meeting note

```markdown
---
type: meeting
project: <project-slug>
date: <YYYY-MM-DD>
attendees: <comma-separated names>
topic: <short topic>
tags:
  - Projects/<project-slug>
  - Type/Meeting
---

# <Topic> — <YYYY-MM-DD>

**Attendees:** <names>
**Date:** <date>

## Summary

<2–3 sentences on what was discussed and what was resolved.>

## Discussion

- <key point or decision>
- <key point or decision>

## Action items

- [ ] <owner — action>

## Raw notes

<Full pasted notes, unedited.>
```

Omit **Action items** if there are none. Keep **Raw notes** always.

## Step M4 — Show and confirm

Present the draft. Do not save until the user confirms.

## Step M5 — Save

- Slug: derived from topic, lowercase, hyphenated.

**Project meeting:**
- Path: `projects/<name>/meetings/<YYYY-MM-DD>-<slug>.md`
- Create `meetings/` if it doesn't exist (`create_dirs: true`).

**Global meeting (no project):**
- Path: `meetings/<YYYY-MM-DD>-<slug>.md`
- Create `meetings/` at vault root if it doesn't exist (`create_dirs: true`).

## Step M6 — Update the index and daily log

**Project meeting:**
- Append to `projects/<name>/_index.md` under the current month:
  ```
  - YYYY-MM-DD [[meetings/YYYY-MM-DD-<slug>]] — <one-line summary>
  ```

**Global meeting:**
- Append to `meetings/_index.md` under the current month:
  ```
  - YYYY-MM-DD [[YYYY-MM-DD-<slug>]] — <one-line summary>
  ```
  Create `meetings/_index.md` if it doesn't exist:
  ```markdown
  ---
  type: meetings-index
  tags:
    - Type/MeetingsIndex
  ---

  # Meetings — Index

  Global index of all non-project meetings. Newest entries at the top.

  ---
  ```
- Also append under `## Meetings` in today's daily log:
  ```
  - [[meetings/YYYY-MM-DD-<slug>]] — <one-line summary>
  ```

---

# Project index (_index.md)

**If `_index.md` doesn't exist for the project**, create it:

```markdown
---
type: project-index
project: <project-slug>
tags:
  - Projects/<project-slug>
  - Type/ProjectIndex
---

# <Project Name> — Index

Chronological index of all project entries. Newest entries at the top.

---
```

**Append format** — newest first, grouped by month:

```
## YYYY-MM

- YYYY-MM-DD [[<folder>/<slug>]] — <one-line summary>
```

If the current month section already exists, insert the new line at the top of
that section. If it doesn't, add a new `## YYYY-MM` header at the top (below
the `---` divider).

---

# Shared rules

<anti_patterns>
- ❌ Saving before the user confirms the draft.
- ❌ Asking for tags before showing the draft — suggest tags inside the draft.
- ❌ Writing a generic "Why I keep this" — it should sound like the user wrote it.
- ❌ Long reading notes — distil, don't transcribe. Key ideas as H3s with tight bullets.
- ❌ Guessing the project silently — always confirm before writing to a project folder.
- ❌ Creating a new `## Reading` section per entry — one section per day, all items as bullets under it.
- ❌ Skipping `_index.md` for emails or meetings — it's the central index; always update it.
</anti_patterns>

<daily_log_format>
Path: `~/Dropbox/Siraj/Projects/siraj-claude-vault/daily-log/YYYY-MM-DD ddd.md`

Get today's date + day: `date +"%Y-%m-%d %a"`

If the file doesn't exist, create it with:
```yaml
---
type: daily-log
project: cross-project
date: YYYY-MM-DD
tags:
  - Type/DailyLog
---

# YYYY-MM-DD ddd
```

To append `## Reading`: check if the section exists first.
- Exists → add a new bullet under it.
- Doesn't exist → append the section at the end of the file.
</daily_log_format>
