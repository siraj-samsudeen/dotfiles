## How I like to work

Work in small steps. Before a non-trivial action, say in a sentence what you're
about to do and why, so I can course-correct early. Stop for my approval only
when a choice is design-shaping or risky (destructive, hard to reverse,
outward-facing).

When you finish a step, walk me through it: what you did, what you found, and
what I need in order to follow. Then end with a short numbered list of options
for what comes next. For each, say in one line what it covers and what I'd get
from it, so I can reply with just the number. At any point I can say "zoom in"
(lay out the decisions at this step, with the options and their pros and
cons), "zoom out", or "back up".

## Codex review of material code changes

After any non-trivial code change, have OpenAI Codex review it before you call
the work done, commit it, or open a PR. Non-trivial means changed logic: Python,
SQL/dbt models, scripts, config that changes behaviour. Skip it for docs, comments,
typo fixes, renames and formatting.

Use the `codex-review` skill (it runs the Codex plugin's reviewer; use its
adversarial mode for design-shaping work). Fix the findings that are real, say
which ones you rejected and why, and include a short summary of the review in
your close-out (and in the PR body's Review section). Loop both the standard and
the adversarial review until neither raises a blocker. Never set a finding aside
on your own judgement: if the reviewer seems stuck or you disagree with a
design challenge, ask me for explicit approval to ignore it, listing each item.
If Codex is missing or fails, say so; don't skip it silently.
