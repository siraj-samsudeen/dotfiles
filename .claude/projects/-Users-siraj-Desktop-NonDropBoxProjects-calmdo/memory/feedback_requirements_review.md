---
name: Requirements Quality Filter
description: 5-rule filter for requirements — drop defaults, merge duplicates, separate what vs how, demand precision, challenge obvious CRUD
type: feedback
---

Before presenting requirements for review, every requirement must pass this filter:

### 1. Is this a real product decision?
A requirement is worth stating only if someone might reasonably build the system WITHOUT it. If every modern implementation does it by default, drop it.

**Drop:** "User session persists across browser refresh" (auth library default)
**Keep:** "Projects are shared by default" (could equally be private by default — this is a decision)

### 2. Is this WHAT or HOW?
Requirements describe user-facing behavior (WHAT). Implementation patterns, coding standards, and architectural decisions belong in CLAUDE.md or phase plans (HOW).

**Drop:** "All Convex functions use authenticated wrappers" (implementation pattern)
**Keep:** "Admin can invite users by email" (user-facing behavior)

### 3. Is this a duplicate?
Two requirements describing the same feature from different angles should be merged into one.

**Merge:** "Admin invites by email" + "User can only sign up via invite" → "Signup is invite-only — admin sends email invite, user signs up through invite link"

### 4. Is this vague?
Challenge fuzzy terms. "User can view projects they have access to" — access to WHAT? Push for specifics.

**Vague:** "User can view projects they have access to"
**Clear:** "User can view all shared projects and their own personal projects"

### 5. Is this obvious CRUD?
If a requirement exists for creating something, edit and delete are implied. Don't state them separately unless the behavior is non-obvious.

**Drop:** "User can edit task title" and "User can delete a task" (implied by task creation)
**Keep:** "User can archive a project" (archive ≠ delete — this is a design decision)

**Why:** Siraj reviewed 55 requirements and ~8 were defaults, duplicates, or implementation details. Fewer, sharper requirements > comprehensive but noisy ones.

**How to apply:** Run every requirement through this filter during generation. Don't generate first and filter after — apply while writing.
