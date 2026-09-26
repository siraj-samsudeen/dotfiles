---
name: code-walkthrough
description: >
  Walk through unfamiliar code with Siraj — structured, depth-first, and INTERACTIVE (one page at a time,
  then he asks). Use whenever Siraj shares code, a file, or a dbt model and wants to understand it, review it,
  trace it, or map its lineage. Trigger on casual phrasing too — "explain this", "what does this do", "walk me
  through", "review this", "how does X get computed", "what's the lineage / what runs before-after this model",
  or code pasted with no instruction. The skill picks one of FIVE modes (Overview · Walkthrough · Review · Trace
  · Lineage), auto-detects from phrasing, confirms in one line, and serves ONE page at a time — never a wall.
---

# Code Walkthrough Skill

Siraj is a data analytics consultant who codes seriously and wants to *own* the code the agent writes — not
just use it. He reads at depth. He will spot YAGNI. He will ask why something is done a certain way. Treat him
as a smart practitioner who is new to a specific concept, not as a beginner.

He does **not** want a wall of text dumped on him. He digests one page, then drives the next step himself.
Follow the Law below exactly.

---

## The Law — one page, then stop

This governs **every** mode. There are no exceptions.

1. **Detect the mode** from how Siraj phrased the request (table below).
2. **Name it in one line**, offering the alternatives:
   > *Looks like a **review** — starting there. (say `overview` / `walkthrough` / `trace` / `lineage` to switch)*
3. **Produce Page 1 only** — at most ~one screen — then **stop** and end with a short menu of where to go next.
4. **Wait.** Never pre-emptively produce sections 2, 3, 4… Siraj asks; you expand one page at a time.

The old "produce the full walkthrough in one go" behaviour is **retired**. One page, then he asks.

---

## Modes — detect, confirm, serve Page 1

| Mode | Siraj's job | Detection cues | Page 1 is… |
| **Overview** | "give me the gist" | *gist, overview, what is this, quick, high-level*, or a bare paste with no verb | The shared overview (below) — and that's the whole deliverable |
| **Walkthrough** | "I want to *own* this" | *walk me through, explain in depth, teach me, help me understand, own this* | The overview, then a menu of deep expansions |
| **Review** | "judge this diff" | *review, is this right, PR, critique, any issues, look for bugs/risks* | Overview + headline verdict + ranked findings |
| **Trace** | "how does X get computed" | *how does X work, trace, follow, where does this value come from* (within one file) | The one path, end to end, as an indented trace |
| **Lineage** | "what runs before/after, which tables" | *lineage, upstream/downstream, what runs before/after, who consumes this, which tables*, or a file under `dbt_runner/dbt/models/` | The DAG + before/after/tables summary |

**Default when there's no signal at all** (bare paste, "explain this"): **Overview**. It never over-produces, and
its menu footer lets Siraj pick a deeper mode. When in genuine doubt between two, name your guess and offer the
other — don't ask a blocking question for something a one-line confirm handles.

---

## Page 1 for most modes: the Overview

This is the shared entry page — Overview mode *is* this page; Walkthrough and Review open with it too.

**a. Full picture first.** A simple indented component map, then one short paragraph on what the file does and
*why it exists* — its role in the larger system.

```
echo          ← thin wrapper: prints to stderr via typer
register      ← wires the init command into the CLI app
  └── init    ← the command itself: calls core, prints messages
```

**b. Runtime flow** — what happens step by step, as an indented trace (not prose):

```
CLI receives "init"
    → register has already wired init() to that command name
    → init() calls core.init_project(Path.cwd())
        → core does the real work, returns InitResult
    → init() echoes messages to stderr
```

**c. 2–3 things worth knowing** — the non-obvious insights, one line each. Not definitions — *insights*
(a design choice and why; a subtle coupling; a place doing less than it looks like).

**d. Menu footer** — always end Page 1 with where-next, tuned to the mode:
> *Where to? `key terms` · `key ideas` · `block-by-block` · `how it connects` — or `review` / `trace X` / `lineage`.*

If earlier files were discussed in the conversation, add a small connection table so Siraj can orient without
scrolling back — reference each with a brief reminder ("previously seen — stamps feather.yaml to disk").

---

## Mode: Walkthrough (the deep one) — expansions, one page each

Page 1 is the Overview above. Then Siraj picks expansions; deliver **one page per turn**. The order below is
the natural progression, but follow whatever he asks for.

### Expansion — Key Terms (ON DEMAND, scoped)

Do **not** dump 30 terms. List only the **3–5 load-bearing** terms — the ones without which the code is opaque —
then invite the rest:
> *Those are the load-bearing ones. Ask me about any other term you want unpacked.*

Each entry gives a concrete one-sentence explanation and says *why* the thing exists, not just what it is:

> **`frozen=True`** — Makes the dataclass **immutable**: once created you can't change a field. Like a read-only
> record. `result.target = …` would raise.

> **`field(default_factory=dict)`** — You can't write `files = {}` as a dataclass default — Python would share
> one dict across all instances. `default_factory` says "call `dict()` fresh for each instance." It explains the
> bug it prevents.

If a term appeared earlier in the conversation, note it: "You've seen this — same pattern as `InitResult`."

### Expansion — Key Ideas (2–3 non-obvious concepts)

Insights, written as short paragraphs, not bullets. Each names a thing, shows where it lives in the code, and
explains why it matters or what it prevents.

> **Mutation during construction, immutability after.** `files`/`messages` are plain mutable dicts/lists while
> `init_project` builds the result — helpers mutate them freely. Once wrapped into `InitResult` (`frozen=True`)
> they're locked. Build freely, then seal.

> **`dir` is accepted but silently ignored.** `dir: str | None = None` is in the signature — so the CLI accepts
> `init some/path` without erroring — but the body never uses it; it always calls `Path.cwd()`. YAGNI. The hook
> is there, the behaviour isn't.

Don't force three if two are the real ones.

### Expansion — Block by Block (STAGED)

Group the code into a few logical stages. Deliver **one stage per page**, then stop and offer the next. For each
block:

1. Show the snippet.
2. Lead with the **most important concept in that block**, even if it appears last in the code.
3. Build up one idea at a time — don't dump all explanations at once.
4. Call out design decisions explicitly: *why this way and not another*.
5. If a line does nothing useful yet (YAGNI, unused param, stub), say so plainly.

> The outer function receives `app` — the same `app` from the test file. It doesn't run the command, it **wires**
> it in. This keeps the main `app` definition free of clutter. Notice the decorator is *inside* `register` —
> applied when `register` is called, not at import time. Intentional: registered only when the app is ready.

Lead with the question the reader is most likely asking, not with what the function does.

### Expansion — How it connects (tests optional)

Close the loop back to the wider system. **If tests are in view**, show which test assertion pins which line of
production code:

```
| Test                            | What it verified      | Where in production            |
| test_init...stamps_files        | feather.yaml exists   | _stamp_feather_yaml line 1     |
| test_stamped...matches_template | content matches       | FEATHER_YAML_TEMPLATE constant |
```

**If there are no tests** (common — many scripts and models have none), generalise: show the upstream inputs and
downstream consumers instead — which files/tables feed this one, and who depends on its output. (For dbt models,
that's the Lineage mode — point there.)

---

## Mode: Review — answer-first

Reviewing a diff or file for correctness, not teaching it. Mirrors the repo's Minto "answer-first control tower"
standard: **conclusion first, evidence on demand.**

**Page 1:**
- The Overview (brief — enough to anchor the change).
- **Headline verdict** in one line: ship it / ship with nits / needs work / blocked.
- **Ranked findings** — a short list, most-important first, each one line with a severity tag
  (`blocker` / `risk` / `nit` / `question`) and the location. ₹-impact or blast-radius where it applies.
- Footer: *Expand any finding for the detail and a suggested fix.*

Then expand **one finding per turn** on ask: the code, why it's wrong or risky, the edge case it breaks, and a
concrete fix. Call things what they are — if it's YAGNI, say YAGNI; if a line does nothing, say so. Security and
risk are lenses *inside* review, not a separate mode.

---

## Mode: Trace — one path, end to end

Needs a target ("how does `varsha_share_pct` get computed"). If Siraj didn't name one, ask for it in one line.

**Page 1** = that single path as an indented trace, from entry to result, **ignoring everything off the path**.
Name each hop, the transform it applies, and the shape of the data after it. Then offer to expand any hop into
its full block (which is just a Walkthrough block on that snippet).

---

## Mode: Lineage — the dbt DAG across files

For "what runs before / after this model, which tables are involved." This operates on the **dbt DAG**, not the
file text — so derive it from dbt's own graph, never from `ref()` regex alone.

**Method (authoritative → fallback):**
1. **`target/manifest.json`** is ground truth. Find the node (`model.<project>.<name>`), read `relation_name`
   (physical `db.schema.table`) and `config.materialized`.
2. `parent_map[node]` = direct upstream (models **and** sources, each with its physical relation).
3. `child_map[node]` = direct downstream.
4. For the **full** DAG (default depth — see below), walk `parent_map`/`child_map` transitively to bronze
   **sources** and terminal **leaves**, or use selectors: `dbt ls -s +name` (all upstream) / `dbt ls -s name+`
   (all downstream) / `+name+` (both).
5. **No manifest?** Do not silently guess. **Ask Siraj** which he wants:
   - *partial now* — grep `ref()`/`source()` for direct neighbours only, clearly labelled "partial — downstream
     may be incomplete"; or
   - *authoritative* — run `dbt parse` / `dbt ls` to build the manifest first (needs a working profile).

**Page 1** = the DAG to **source + leaves** (default depth), drawn as a diagram, plus a three-part summary:

```
UPSTREAM (runs before)                 THIS MODEL                DOWNSTREAM (runs after)
─────────────────────                 ──────────                ───────────────────────
bronze_sap.master.lfa1  ─(source)─►  silver_core.main.vendor ──┬─► gold.main.dim_vendor
   (raw SAP LFA1 load)                 [core/vendor.sql]        ├─► gold.main.procurement
                                                                └─► … (13 direct children)
```

- **Runs before it:** the upstream chain (models + the bronze source it ultimately depends on).
- **Runs after it:** the downstream children — flag high fan-out ("break this and N gold models inherit it").
- **Tables involved:** input relation(s), output relation, and any macros it calls (e.g. `sap_date()`).

Footer expansions, one page each: `[full ancestry]` · `[full descendants]` · `[column-level from source]` ·
`[show compiled SQL]` (from `target/compiled/…`).

---

## Tone and Style (all modes)

- Plain English. No unnecessary hedging.
- Call things what they are. YAGNI is "YAGNI"; a dead line is "this line does nothing useful yet."
- No padding. Every sentence earns its place — this matters doubly now that each page is short.
- When two things relate across files, make the connection explicit — don't leave Siraj to infer it.
- Analogies when they genuinely clarify ("CliRunner is a flight simulator, not a real plane"). Don't force them.
- Explain *why*, not just *what* — the crown jewel of this skill, in every mode.

---

## Reference Examples — the feather-etl CLI Walkthrough (May 2026)

Three files in `references/` contain complete block-by-block walkthroughs. Read the relevant one before
producing a Walkthrough, especially for similar patterns (CLI layers, dataclasses, test fixtures):

- `example-test-file-walkthrough.md` — the test file; Arrange/Act/Assert, fixture injection, CliRunner vs
  subprocess
- `example-core-walkthrough.md` — the domain layer; dataclass, frozen result, mutation-during-construction,
  YAGNI callouts
- `example-cli-bridge-walkthrough.md` — the CLI bridge; the best single example of the full structure and the
  loop-closed table connecting tests to production lines

These predate the mode split — read them for the *quality bar* of an expansion page, not the one-shot delivery.

## What made the feather-etl walkthrough work (keep doing this)

- Full picture opened every explanation — shape before detail.
- Runtime flow shown as an indented trace, not prose.
- YAGNI called out plainly.
- Key insights written as paragraphs with *why*, not just *what*.
- No padding, no hedging. Now: **plus one page at a time, and let Siraj drive.**
