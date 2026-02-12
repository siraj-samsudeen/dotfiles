---
description: "Use when the user wants to study a URL/concept, log an idea for later research, or review their study queue."
argument-hint: "[url/concept to study or log]"
---

# /study-idea — Research & Queue Manager

## Your Input

The user will provide: $ARGUMENTS

## Phase 0: Route (Always Run First)

Read the queue file at `~/.claude/skills/study-idea/QUEUE.md`.

Then determine intent from `$ARGUMENTS`:

| User intent | How to detect | Action |
|-------------|--------------|--------|
| **Browse queue** | No arguments, or vague ("what's in my queue?") | → Show queue, ask what to do |
| **Log for later** | "log", "save", "queue", "capture", or a URL with a note but no study intent | → Append to QUEUE.md, confirm, stop |
| **Study now** | A URL/concept with clear study intent ("study this", "deep dive", "research") | → Proceed to Phase 1 |

### Browse Queue

1. Display queued items (unchecked `- [ ]` entries) as a numbered list:
   ```
   Study Queue (N items):

   1. short-name — brief note
      https://example.com/url
      Added: YYYY-MM-DD
   ```
   If queue is empty, say so.
2. Use AskUserQuestion with each queued item as an option plus "Log a new idea".
3. If they pick an item → proceed to Phase 1 with that item's URL and notes.
   If they pick "Log a new idea" → ask for URL and notes, append, stop.

### Log for Later

Append to the `## Queued` section of QUEUE.md:
```markdown
- [ ] **{short-name}** — {url}
  {user's note about what to look for}
  _Added: {YYYY-MM-DD}_
```
Confirm with the queue count. **STOP.**

---

## Phase 1: Study

Read the detailed study methodology from:
`~/.claude/skills/study-idea/SKILL.md`

Follow its steps (Fetch → Extract Core Ideas → Map to Skills → Generate Report).

Use the report template at:
`~/.claude/skills/study-idea/references/report-template.md`

Save the completed report to:
`~/.claude/siraj-experiments/study-idea-reports/{kebab-case-name}-{YYYY-MM-DD}.md`

Present the summary: top 3 integration opportunities + recommended first build.

**Then mark the queue item as studied** (if it came from the queue):
```markdown
- [x] **{short-name}** — {url}
  {original note}
  _Added: {date}_ · _Studied: {YYYY-MM-DD}_ · [Report](../study-idea-reports/{name}-{date}.md)
```

**STOP. Ask what's next.**

---

## After Study: What Next?

Use AskUserQuestion to present three options:

| Option | Description |
|--------|-------------|
| **Launch experiment** | Open-ended exploration — invokes `/experiment new` with context from the study (URL, core ideas, proposed experiments from the report) |
| **Build skill directly** | You know exactly what to build — proceeds to Phase 2 |
| **Done for now** | Keep the report, move on |

### Launch Experiment

Invoke the `/experiment` command in "new" mode. Pre-fill the context:
- **Question**: Derived from the study's top recommendation
- **Context**: Link to the study report, source URL, core ideas summary
- Let `/experiment` handle the rest (EXPLORATION.md, INDEX.md, etc.)

**STOP after handing off to /experiment.**

---

## Phase 2: Build Skill (Only If User Chose "Build Directly")

1. Design the skill (feather-spec if complex, brief sketch if simple)
2. Create in `~/.claude/siraj-experiments/{skill-name}/`:
   - `SKILL.md` — skill definition
   - `ORIGIN.md` — traceability (source URL, date, ideas extracted, report link)
   - `scripts/` and `references/` as needed
3. Provide 2-3 test prompts for verification

---

## Success Criteria

- Queue displayed when no clear study target provided
- New items appear in QUEUE.md with name, URL, note, and date
- Studied items marked `[x]` with studied date and link to report
- Never starts a deep dive without clear user intent to study now
- After study, user is offered experiment/build/done — not auto-routed
