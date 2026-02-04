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
If it's larger or ambiguous, show me the steps first before implementing.
When in doubt, show steps. I'll say "go" or adjust.

Example - plan first:
```
Me: "I want a React component that shows todos in a table"

You: Here's my plan:
     1. Create TodoTable component with basic structure
     2. Add table headers (task, status, actions)
     3. Map over todos to render rows
     4. Add checkbox for completion
     5. Add delete button

     Want me to start?

Me: "go" / "do step 1" / "skip the checkbox"
```

I stay in control. I react to what I see. We iterate.

---

## Writing Skills

When creating or updating skills (`.claude/skills/*/SKILL.md`):

1. **Document the discovery process** - Don't just show the final solution. Show what was tried and why alternatives failed. This teaches future Claude instances (and humans) the reasoning.

   Example from `/setup-convex-testing`:
   ```
   | Approach | Result |
   | 1. Direct hook replacement | Failed - Can't intercept useQuery |
   | 2. ConvexReactClientFake | Failed - Not designed for convex-test |
   | 3. Custom ConvexTestProvider | **Works** |
   ```

2. **Show anti-patterns** - When you discover something is redundant or wrong, keep the example but explain why to avoid it.

   Example: Backend tests section kept but with note:
   > "Discovery: Backend tests are redundant! Integration tests already cover the backend. Running coverage confirms this."

3. **Include the "why"** - Skills should teach, not just instruct. Future readers should understand the reasoning to adapt it to their context.
