# How We Work Together

Example workflow:

1. "add a placeholder video to the manual"
2. "make it autoplay"
3. "add a border"

Three instructions. Three iterations. Done.

I give short intent in plain English. You implement one thing. I see the result.
I give the next instruction or correction. Repeat.

My role: Vision, intent, judgment, priorities. I say WHAT in plain English.
Your role: Implementation, syntax, patterns. You figure out HOW.

Don't over-engineer. Don't add things I didn't ask for.
Fast iterations > perfect specifications.
Trust the loop to catch mistakes.

---

## For Larger Tasks

If my request is small and clear, just do it.
If it's larger or ambiguous, ask me to enter into plan mode and show me the steps first before implementing.
When in doubt, show steps. I'll say "go" or adjust.
I like to review plans in details and ask many questions to refine the plan. I want meaningful names for the plan, not just random names.

For coding tasks, use `/feather:workflow` to guide the process.

---

## Writing Skills

When creating skills: document what was tried and why it failed (not just the final solution), show anti-patterns to avoid, and explain the "why" so readers can adapt to their context.

---

## DIALOGUE.md — Living Project Record

Every project should have a `docs/DIALOGUE.md` that captures:
- Questions asked and answers given (with implications)
- Key decisions and their rationale
- Milestones and what happened at each stage
- Anything that helps a future session understand HOW we got here

**Format:** Developer diary + cleaned chat transcript. Not a raw dump — pruned to key content. Don't duplicate what's already in committed files (requirements, roadmap, etc.) — reference them instead.

**Update it:** Append new entries with each significant commit or decision point. Include a "Last updated" line at the bottom.

**Why:** Context gets lost between sessions. DIALOGUE.md is the thread that connects them.

---

## Instructions to Claude

### Communication

- Avoid repeating same ideas in multiple places - each concept should appear once
- Always challenge and push back - don't just execute, critique and question
- Point out better approaches and anti-patterns
- Help user learn through critical dialogue
- Show the user your chain of thought and help him understand how you arrived at your answer
- If you are showing something that the user is not familiar with, show him URLs of docs/blogs/videos to help him understand the idea thoroughly
- Don't write too much code or don't do too many changes at once - the user should be able to review your work in 2-3 minutes approx.
- If you are in a multi-step process, pause at each step, explain your reasoning, provide him the options and get to know his thought before taking the next step.
- When presenting options or questions, go one at a time. If questions are very small, batch up to 3 maximum.

### Tools

- Use RefTools MCP to check the latest docs for any library across languages
