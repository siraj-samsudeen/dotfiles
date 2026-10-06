---
name: decision-twin
description: Apply the Decision Twin Framework to design, redesign, or critique dashboards as decision-support systems rather than reporting surfaces. Use this skill whenever the user is working on a dashboard, BI tool, KPI list, analytics requirement, operational reporting setup, or any "what should we measure" question — including when they share a dashboard screenshot, list metrics, describe a business problem that involves operational visibility, or ask how to improve an existing report. Trigger this even when the user does not explicitly ask for "decision-support design" — phrases like "design a dashboard", "review this dashboard", "what KPIs should we track", "this dashboard isn't working", "how should we measure X", or showing a BI mockup are all in scope. The framework synthesizes Theory of Constraints, Systems Thinking, and role-based decision design into a single process that produces dashboards organized around decisions, flow, and constraints rather than charts, departments, and KPIs.
---

# The Decision Twin Framework

A methodology for designing dashboards that change decisions, not just display data.

## What this framework is

The Decision Twin Framework treats a dashboard as an **operational mirror of how decisions should happen** in a business — not as a reporting surface, not as a KPI showcase, not as a data exploration tool.

The name borrows from "digital twin" in industrial systems: a live model of a physical process used to simulate and steer it. A decision twin is the same idea applied to operational decision-making — the dashboard mirrors the structure of the decisions a business actually has to make, at the cadence those decisions happen, for the roles that make them, with the signals that should trigger action.

The test of a good decision twin is behavioral, not visual: *what will someone do differently next month because this dashboard exists?* If the answer is "nothing concrete," the dashboard has failed regardless of how much data it shows or how clean it looks.

The framework synthesizes three lenses: Theory of Constraints (what to focus on), Systems Thinking (what to watch out for), and role-based decision design (how to shape the output). For the full reasoning behind why these three and what specifically was taken from each, read `references/foundations.md` — particularly useful when explaining the framework to a stakeholder or extending it to a new domain.

## When to use this skill

Trigger this skill whenever the user is:
- Designing a new dashboard from scratch
- Critiquing or redesigning an existing dashboard
- Evaluating a KPI list or metrics proposal
- Working through "what should we measure" for an operational process
- Reviewing a dashboard screenshot or mockup
- Translating business requirements into an analytics deliverable
- Asking why a current dashboard isn't being used

If the conversation is about metrics, dashboards, BI, or operational visibility — this skill applies.

## The methodology

Follow the phases in order. Do not skip Phase 0.

---

### Phase 0 — Clarify

Before any analysis, verify you have enough context to avoid confabulating constraints, roles, or decisions that don't match the user's reality. You need answers to:

1. **Who uses this and at what cadence?** (hourly, daily, weekly, monthly, quarterly)
2. **What recurring decision does each role make** that this dashboard should influence?
3. **What action can each role actually take?** (their levers, authority, time horizon)
4. **What data is realistically available** in the client's systems today?
5. **What is broken now** — ignored, misused, causing bad decisions?

If two or more of these are unknown or unclear, **stop and ask 3–5 sharp, specific questions**. Do not proceed on assumptions. If the user insists on proceeding without answers, state your assumptions explicitly and flag them as risks throughout the analysis.

Confabulating a "constraint" or a "role" without grounding is the single biggest failure mode of this framework. The clarification phase exists to prevent it.

---

### Phase 1 — Frame the system

In a tight section (under 200 words), establish four things:

- **System:** What flow is being managed? (orders, inventory, cash, attention, customer journey, decisions themselves)
- **Goal:** One balanced sentence. Not "maximize X" but "maximize X *subject to* Y *without breaking* Z." A goal that names only one variable is the wrong goal — it invites local optimization.
- **Constraint:** Where does throughput actually choke? Classify it:
  - *Physical* (capacity, stock, staff) → design queue and utilization views
  - *Policy* (approval rules, thresholds, SLAs, batch sizes) → design delay and exception views
  - *Market* (demand, lead time, customer behavior) → design variability and signal-strength views
- **Tension:** Name the structural tradeoff most likely to produce local optimization. Be specific about which roles sit on which side of it. (Example: "Store managers are rewarded for sell-through; supply chain is rewarded for low inventory. The dashboard must not let either side win silently.")

---

### Phase 2 — Map decisions, not metrics

For each role, build this table. **No metric enters the dashboard without a row here.**

| Decision | Cadence | Signal needed | Threshold / exception | Action | Who else cares |

Discipline rules:
- If "Action" is "be informed" or "stay aware," delete the row.
- If "Cadence" is unknown, you haven't talked to the user enough — go back to Phase 0.
- If two roles appear in "Who else cares" with conflicting interests, that's a tension you must surface in the design, not hide.
- Cadence determines refresh rate and time horizon for the visualization. Hourly decisions need real-time and short windows; quarterly decisions need trends and seasonality.

---

### Phase 3 — Design flow and exception views

Restrict yourself to three view types per role:

1. **Flow view** — where is movement slowing? Cycle time, aging, queue depth, throughput, WIP. Answers *"is the system moving?"*
2. **Exception view** — what crossed a threshold and needs a human now? Answers *"what requires attention?"*
3. **Constraint view** — is the bottleneck still where we thought? Has it been exploited, subordinated, elevated? Answers *"are we working on the right thing?"*

For each major exception, define the drilldown path as **symptom → likely cause → next action**. Not region → category → SKU. The drilldown should compress investigation, not expand browsing surface.

Prefer flow visualizations over stock snapshots. A balance number tells you what is; a flow number tells you what is happening.

---

### Phase 4 — Exclusion list

Name **at least three metrics you are refusing to display**, and the local-optimization risk each would create if shown.

Example: "We will not show store-level gross margin to store managers, because they will respond by suppressing markdowns on aged stock. This improves their local KPI while increasing inventory holding cost and reducing system throughput."

If you cannot name three exclusions, you have not thought hard enough about local optimization. Go back and find them. This phase is non-negotiable — the exclusion list is what distinguishes a decision twin from a prettier report.

---

### Phase 5 — Validate

Before finalizing, close three loops:

- **Behavioral test:** Name one decision that will be made differently next month because of this dashboard. Be specific — role, situation, old behavior, new behavior.
- **Anti-test:** What pattern would tell us the dashboard is being ignored or gamed?
  - Rising exception count with flat action count → alert fatigue
  - Drilldowns never used → wrong drilldown design
  - Same screenshot in every weekly meeting → it's a reporting artifact, not a decision tool
- **Minimum shippable:** If you could ship only one widget for one role, which one and why? Defend it against the alternatives. This forces prioritization and protects against feature creep.

---

### Optional — Conversational layer

If a natural-language interface is in scope, list 3–5 questions each role would actually type at their working cadence, and the evidence the dashboard surfaces in response.

If you cannot write real questions a real role would ask in their real workflow, **skip this section**. Do not invent ceremonial AI features.

---

## Operating rules

- Prefer one sharp widget over five mediocre ones.
- Every chart has a named owner, a named decision, and a named cadence — or it doesn't ship.
- Name tensions explicitly. Do not paper over inter-role conflict with "balanced scorecards."
- When data isn't available, say so directly. Do not design dashboards on data the client doesn't have.
- Criticize the existing setup specifically and concretely. Vague critique helps no one.
- Avoid BI jargon. Use the language of the operator's actual work.
- Always answer: *what better decision becomes possible because this exists?*

## What complete output looks like

A full Decision Twin analysis produces:

1. A short system frame (system, goal, constraint, tension)
2. A decision table per role
3. Three view designs per role (flow, exception, constraint)
4. Drilldown paths for the top exceptions
5. An exclusion list with reasoning
6. A behavioral validation plan
7. A minimum shippable proposal

If a section is missing, the framework hasn't been applied — it's been name-checked.

## Format and tone

- Use prose for reasoning sections (system frame, exclusions, validation). Use tables for decisions and view specs.
- Be concrete. Use the user's actual domain language (their roles, their processes, their constraints), not generic examples.
- If the user provides a screenshot or KPI list, reference specific elements by name when critiquing.
- Surface tradeoffs explicitly. Phrases like "this means we will not see X" are good — they signal you understand the cost of your choices.
- Length should scale with input depth. A vague brief warrants Phase 0 questions, not a 3000-word framework dump.
