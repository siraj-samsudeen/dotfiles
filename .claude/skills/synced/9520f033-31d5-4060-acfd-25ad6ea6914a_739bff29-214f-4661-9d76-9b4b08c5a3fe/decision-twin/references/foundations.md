# Foundations of the Decision Twin Framework

This document explains *why* the Decision Twin Framework looks the way it does — the problems it responds to, the established bodies of thought it draws from, and what specifically was taken (and deliberately left out) from each.

Read this when you need to:
- Explain the framework to a stakeholder who asks "why this approach?"
- Defend a design choice against a competing methodology (balanced scorecard, OKRs, classical BI)
- Extend the framework to a new domain and need to know which principles are load-bearing
- Decide whether a deviation from the methodology is principled or sloppy

---

## The problems we are responding to

Conventional dashboard design fails in predictable, expensive ways. The framework exists because of these specific failures:

**1. Dashboards are designed as reports, not decisions.** Most dashboards begin with "what data do we have?" and end with "what charts can we make?" Nobody asks "what decision will this change?" The result is screens full of metrics that nobody acts on, because no action was ever the point.

**2. KPI overload and vanity metrics.** Stakeholders ask for "everything on one screen." Designers comply. The dashboard becomes a wall of numbers, none of which is urgent, so none of which gets attention. Signal-to-noise collapses.

**3. Local optimization.** Each department gets its own KPIs. Store managers optimize for sell-through. Supply chain optimizes for low inventory. Marketing optimizes for conversion. Each succeeds at their metric while the system as a whole degrades — because nothing surfaces the tension between them.

**4. Symptoms without causes.** Dashboards typically show *that* sales dropped, *that* inventory aged, *that* a delay occurred — but not why. The user is left to investigate manually, which means the investigation rarely happens.

**5. One dashboard for all roles.** A CEO and a warehouse operator see the same screen. The CEO drowns in operational detail; the operator drowns in strategic abstraction. Neither is served.

**6. No notion of flow.** Static snapshots dominate. The dashboard shows stocks (how much exists right now) but not flows (how things move, where they slow, where queues build). Operational reality is about flow; reporting is about stocks. The mismatch is constant.

**7. Designing on data you don't have.** Frameworks recommend ideal metrics without checking whether the client's warehouse can actually produce them. The dashboard gets specced, then dies in implementation.

**8. No feedback loop.** Dashboards get built and shipped. Nobody asks six months later whether decisions actually changed. The artifact is treated as the deliverable, not the behavior change.

Each phase of the Decision Twin Framework addresses one or more of these failures directly.

---

## What we borrowed from Theory of Constraints (Goldratt)

TOC's core claim is that every system has a constraint — a single bottleneck that limits the throughput of the whole — and that improvement effort spent anywhere except the constraint is wasted. The improvement cycle is *identify → exploit → subordinate → elevate → repeat.*

**The constraint focus.** Most dashboards treat all metrics as equally important. TOC says no — find the one thing limiting throughput and design the dashboard around it. This kills KPI overload at the source. If a metric isn't about the constraint or doesn't help subordinate other activities to the constraint, it probably doesn't belong on the primary view. *Addresses problems 1, 2.*

**Constraint classification.** TOC distinguishes physical constraints (machines, stock, staff capacity), policy constraints (approval rules, batch sizes, SLAs), and market constraints (demand, lead time). Each implies a completely different dashboard. Physical constraints want queue and utilization views; policy constraints want delay and exception views; market constraints want variability and signal-strength views. Lumping them together produces generic dashboards. *Addresses problem 6.*

**The full cycle, not just identification.** A common misuse of TOC in dashboard design is "show the bottleneck." But identification is step one of five. A real decision twin also helps users *exploit* the constraint (squeeze maximum throughput from it), *subordinate* everything else to it (stop optimizing non-constraints), and detect when the constraint *moves* (because solving one bottleneck always reveals the next). The Phase 3 "constraint view" exists for this. *Addresses problems 4, 8.*

**What we deliberately don't take from TOC:** the full operational machinery — drum-buffer-rope scheduling, throughput accounting as a replacement for cost accounting. These are valuable but belong in operations design, not dashboard design.

---

## What we borrowed from Systems Thinking

Systems thinking treats organizations as networks of interacting feedback loops, where behavior emerges from structure rather than from individual decisions. Key concepts include reinforcing loops, balancing loops, delays, and unintended consequences.

**Local optimization is the enemy.** This is the single most important contribution. Systems thinking insists that improving a part can damage the whole — and that this happens *by default* when each part is measured in isolation. The Decision Twin Framework enforces this by requiring an explicit **exclusion list** (Phase 4): metrics you refuse to show, with the local-optimization risk each one would create. If you can't name what you're excluding, you haven't thought about the system. *Addresses problem 3.*

**Inter-role tension as a feature, not a bug.** Different roles legitimately want different things — and the friction between them is often where the right answer lives. A dashboard that hides this tension (by giving each role only their own metrics) lets local optimization run unchecked. A decision twin makes the tension visible: when store managers and supply chain look at the same flow metric, they should see *each other's pressure*, not just their own. The "Who else cares" column in the Phase 2 decision table exists for this. *Addresses problems 3, 5.*

**Flow over stock.** Systems thinking emphasizes that what matters operationally is movement — how things flow through the system, where they queue, where they age, where variability accumulates. Stock-style snapshots (totals, balances, counts) hide flow. Flow views (cycle time, aging, throughput, queue depth) reveal it. *Addresses problem 6.*

**Delays and feedback.** Most operational decisions are made under delayed feedback: you act today, you see the consequence in two weeks. Dashboards that don't represent delay cause overcorrection. A decision twin shows *when* a signal will produce a result, not just the signal itself. *Addresses problems 4, 8.*

**What we deliberately don't take from systems thinking:** full causal-loop diagramming as a deliverable. It's a thinking tool for the designer, not an artifact for the operator.

---

## What we borrowed from Role-Based Decision Design

The premise here is that decisions are made by specific people at specific cadences with specific authority — and that information design should be shaped by the decision-maker's context, not by the data's structure.

**Decision cadence drives granularity.** A store manager making hourly stocking decisions needs different data shape than a CEO doing quarterly capital allocation. Cadence is the missing dimension in most dashboard work. The Decision Twin Framework makes cadence a first-class column in the decision table. *Addresses problem 5.*

**Authority constrains usefulness.** Showing someone a problem they cannot act on creates anxiety, not improvement. Every metric must connect to a lever the viewer actually controls. If the action belongs to someone else, the metric belongs on *their* dashboard, with an escalation path — not on yours. The "Action" column in Phase 2 enforces this; the "delete the row if Action is 'be informed'" rule is the enforcement mechanism. *Addresses problems 1, 5.*

**Cognitive layering.** Executives need abstraction and trend. Managers need exception and comparison. Operators need specific, immediate, action-shaped signals. The same underlying data should produce three different dashboards, not one compromised dashboard for everyone. *Addresses problem 5.*

**What we deliberately don't take:** rigid persona frameworks. Roles are defined by the decisions they make, not by job titles.

---

## The synthesis

These three lenses combine into a single design discipline:

- **TOC** tells us *what to focus on* (the constraint and its full improvement cycle).
- **Systems thinking** tells us *what to watch out for* (local optimization, hidden tensions, flow over stock, delayed feedback).
- **Role-based decision design** tells us *how to shape the output* (cadence, authority, cognitive layer).

The output of applying all three is a dashboard organized around **decisions** (not metrics), **flow** (not stock), **constraints** (not departments), and **roles** (not screens) — with explicit attention to what is *excluded* and why.

The validation phase (Phase 5) closes problem 8 — the missing feedback loop. The clarification phase (Phase 0) closes problem 7 — designing on data that doesn't exist. Together, the six phases form a single chain where each phase prevents a specific failure mode of conventional BI.

---

## What this framework is not

A few things worth being explicit about, to prevent misuse:

- **Not a replacement for data modeling.** This is a design methodology, not a warehouse architecture. It assumes the data work has been done or will be done.
- **Not a methodology for exploratory analytics.** It's for operational decision support. Ad-hoc analysis, data science workflows, and research dashboards have different goals.
- **Not anti-chart.** It's against charts that don't support a decision. A well-placed time-series in a flow view is a decision twin element; the same chart on an executive summary "for awareness" is not.
- **Not a balanced scorecard.** Balanced scorecards try to give every department their fair share of metrics. This framework actively excludes metrics that would cause local optimization, even if a department wants them.
- **Not OKR tracking.** OKRs are about goal alignment over quarters. Decision twins are about operational decisions at their natural cadence — which is usually much shorter than a quarter.
