---
name: convert-jargon-to-beginner-friendly-terms
description: >
  Decode jargon into plain terms for Siraj, and judge or propose names against his "self-evident"
  naming standard. Use when he asks what a term means, finds a doc or codebase too jargon-heavy to
  follow, wants plainer wording, or asks what something should be called or whether a name is
  self-evident; when naming any column, value, flag, status or business-facing identifier; and
  unprompted when something he is reading or writing uses vocabulary that would block a newcomer.
---

# Convert Jargon to Beginner-Friendly Terms

## Self-evident

The whole standard, in Siraj's own words — written in `rama_dw/docs/agents/naming-conventions.md` long before this skill existed:

> **Self-evident** — no acronyms or house codes; readable by an industry veteran; a newcomer can understand it on first explanation and remember it easily; using terminology AI agents are trained on.

**Use the word.** It is shared vocabulary across his repos, not skill-local shorthand, and *"is this name self-evident?"* puts an entire naming argument onto one footing in four words. Say it in recommendations, in glossary entries, in review comments.

Everything below is that sentence expanded:

- **no acronyms or house codes** — a gate applied before any candidate is scored at all
- **readable by an industry veteran** — the first reader
- **understood on first explanation, and remembered** — the second reader; the *remembered* half is what separates a term that sticks from one re-explained every week
- **terminology AI agents are trained on** — the third reader

Two jobs, run on every term:

1. **Decode** — what the term means **in this document**. Not the dictionary entry. `register` is not the CPU thing or the cash thing; it is the list of what this system watches.
2. **Rename** — alternative names, judged against three readers.

Run rename even for terms Siraj already understands. He wants the options regardless.

You **propose and argue**. Siraj **decides**. Always land on a recommendation — offering options with no recommendation hands the work back — but his pick overriding yours is the skill working, not failing.

**Grep the project glossary for every candidate before proposing it — mechanically, one term at a time.** Reading the glossary is not the check; a mature `CONTEXT.md` runs to hundreds of entries and skimming it will miss the collision. Run the candidate *and* the original through `grep -n` and read every hit.

Generic-sounding candidates are the ones most likely to be taken: in a mature glossary a plain word can already carry a specific meaning another metric depends on, or be defined twice, and every such collision is findable with a single grep. **The older and larger the glossary, the more likely the right answer is "this is already named — use theirs."**

A term may also already be settled, and re-litigating a decision wastes his time and risks contradicting the repo. Decided vocabulary lives in `CONTEXT.md` at the repo root — `feather-flow/CONTEXT.md` for data-platform and monitoring terms, `rama_dw/CONTEXT.md` for retail. Both use the house format: `**Term**:` / definition / `_Avoid_: rejected candidates`. Write decisions back in that format, never as a table — prose has no width limit, diffs stay one line, and `grep -n '^\*\*'` gives the index for free.

**This skill's own vocabulary obeys its own rules.** Every heading, column name and scale level here has to pass the six-months-later test: Siraj reads it half a year from now, with no memory of writing it, and knows what it means. Two or three plain words beat one compressed one; the usual failure is squeezing a clear idea into a one-word label that only made sense to whoever coined it. When labelling anything in the output, spell it out.

## What must not be translated

Some jargon is deliberate and renaming it is a bug, not an improvement:

- **Source-faithful names.** Bronze-layer columns mirror the source system verbatim — SAP, GoFrugal, Zakya — so they can be traced back. Fidelity beats friendliness there.
- **External standards.** `MATKL`, GST HSN chapters, ISO codes, ticker symbols. They are shared with the outside world and a local rename breaks the shared meaning.
- **Product names.** *Azure Lighthouse*, *Dagster*. Explain them; never translate them.

Ask which of these a term is **before** generating candidates. In `rama_dw` the boundary is written down in [`docs/agents/naming-conventions.md`](docs/agents/naming-conventions.md), which cites ADR 0008 for the bronze rule.

## Getting the decode right

Every candidate is scored against this one sentence, so a definition missing a clause produces a whole table of confidently wrong names with nothing downstream to catch it. *like for like* was first decoded as "only stores open in both periods," omitting that materially changed stores are excluded too — and that omission is exactly what made *same-store sales* look like a clean replacement when it drops a real distinction. **State what the term excludes as well as what it covers.**

**Decode far enough to choose a name, then stop.** This is a naming skill, not a requirements session. Where a term hides a genuine business-rule ambiguity — *sell-through* can be measured against receipts only, or against opening stock plus receipts — record it once so it isn't lost, and move on. Press for a decision only when the answer would change which name wins. It usually doesn't.

**Say what the original word implies, not only what it denotes.** This is the teaching half — it tells a beginner why a veteran reached for that word, so the jargon stops feeling arbitrary. *"Ledger means it is append-only and permanent: entries are added, never edited or deleted."* The implication is usually the reason the term survives, and naming it feeds the dropped-implication check below.

**Explain by contrast with the term next door.** Where a near-miss word exists, the sharpest explanation is the boundary between them: *"a scheduler decides when; an orchestrator also handles dependencies, retries and ordering."* The reader learns what the term is and what it is not in one sentence, which is what stops the two collapsing together later.

## Three verdicts, not one

Replacing the term is one outcome of three. Reaching for it every time is the most common way this goes wrong.

- **Replace it** — the original earns nothing. *hybrid hub-and-spoke* → *central control + customer-side collectors*.
- **Add a word to it** — keep the original, add the word that kills the wrong reading. *estate* → *customer estate*. The veteran's word survives and the newcomer stops guessing.
- **Keep it** — the jargon is genuinely the best name available and any replacement loses information. Say so plainly and explain what a replacement would cost.

## The three readers

These are the three clauses of **self-evident**, scored one at a time. A name is self-evident when it passes all three; naming which clause it fails is what makes the argument concrete instead of a matter of taste.

- **Veteran approves** — a ten-year hand would say it out loud in a design review without feeling talked down to.
- **Newcomer gets it** — three levels: **understands it first time** (no help needed) · **needs explaining once, then sticks** · **needs re-explaining every time** (they will ask again next week).
- **Agent reads it as** — what the model's training data pulls the word toward. Name the competing meaning, or write *nothing competes*.

**When the readers conflict, tie-break toward the agent.** A human gap usually closes with one sentence of explanation; an agent's priors don't move no matter what the document says. Spend the naming budget where teaching can't reach. This applies only when the human difference is marginal — a term that leaves a newcomer stuck still loses, however cleanly an agent reads it.

### Whether it sticks

The gap between *needs explaining once* and *needs re-explaining every time* is whether the reader can **rebuild** the meaning from the words, or has to **memorise** an arbitrary mapping.

- *estate* → everything a person owns → everything a customer runs. Rebuildable; explain once and it holds.
- *control plane* → "plane" contributes nothing toward *deciding*. No path from word to meaning, so every recall is memory. Explained repeatedly, still asked about.

Score this by trying to walk from the words to the meaning. If you can't, it *needs re-explaining every time*, no matter how standard the term is.

A metaphor can be rescued by its one-sentence explanation, but only if that sentence draws a **picture** rather than states a definition. *tenant* → shared building, walls between: the reader can reason from that image to new questions (who holds the keys, can one tenant see another's rooms) and get right answers, so one sentence makes it stick permanently. *plane* has no image, so its explanation is a fact to memorise. Whenever the recommendation keeps the original word, write the picture.

### What agents read the word as

Siraj's repos are worked on heavily by agents, so a word that misleads a model is as expensive as one that misleads a person — and the two pull in **opposite directions**. Everyday words are the crowded ones: `environment` (dev/staging/prod, env vars, virtualenv), `setup` (`setup.py`, test setup), `site` (`site-packages`), `layer` (OSI, Docker, neural nets), `range` (`range()`, date ranges), `markdown` (the text format), `account` (AWS, billing), `agent` (an LLM agent). Rare words like `estate` and `planogram` have almost no technical prior, which makes them clean handles — nothing competes, so the model takes the definition from the document.

**The grep test:** search the candidate in a normal repo. Unrelated hits mean an agent carries the same competing readings.

This splits by where the word lives: **prose takes the plain phrase; identifiers — filenames, functions, tables — take the distinctive one**, because identifiers are what agents grep.

## Where candidates come from

**The primary move: find the word carrying no meaning and swap only that.** Most jargon is one dead word attached to live ones — multi-**tenant** → multi-**client**, managed data **layer** → managed data **platform**.

**When every word is metaphor, describe the parts instead.** *hybrid hub-and-spoke* → *central control + customer-side collectors*.

Then, for spread — generate across sources rather than five variations of one idea:

- **Say what it does.** *idempotent* → *safe to retry*
- **Swap abstract for concrete.** *persistence layer* → *storage*
- **Name the outcome, not the machinery.** *denormalization* → *pre-joined for speed*
- **Borrow a domain the concept genuinely resembles** — post, kitchen, warehouse, plumbing — but only if the resemblance survives two follow-up questions.

**Never propose an acronym or a house code.** A name that needs a lookup table to decode fails before any of the three readers see it — `SC-M-LWGF-N`, `BB`, `FAS` are not candidates. This applies to names being coined; existing external acronyms are a separate case, handled above.

**Check how the term reads in the reader's market.** The locally-used word is sometimes *less* clear than the global one, and the writer can't see it because it's their own usage. In India *department store* reads as a large kirana, so the precise format word is clearer. Prefer the globally-standard term when the local one misleads, and say why.

Siraj rejects metaphors that need a hop. *footprint* for a set of systems asks him to already hold the metaphor; *territory* imports geography that isn't there. **Plain and long beats elegant and compact** — he took *customer's systems* over *footprint* without hesitating.

## Three disqualifiers

- **Collision.** The candidate already means something else in this field, or at a different level of the same hierarchy. *site* looks right for one customer's systems, but in RMM tools a site is one location *inside* a customer — it silently shrinks the unit. Near-misses at the wrong level are worse than obvious mismatches.
- **Dropped implication.** The original carries something load-bearing that the replacement loses. *tenant* implies **walls between tenants**; *client* does not. Before recommending, ask what the original implied that the candidate no longer does — and if the answer matters for reporting or architecture, put it back in the words.

  A dropped implication is not automatically fatal: it can be **carried by the explanation instead of the name**. *data pipeline scheduler (orchestrator)* keeps a word that loses dependencies and retries, then restores them by contrast in the explanation. Prefer this when the plainer name is much easier to read — but only when the explanation genuinely travels with the term, never when the name will appear alone in a schema or a chart label.

- **Wrong axis.** The name answers a different question than the one the thing labels. A store-format label called *Big Box* encodes **size**; *City Center* encodes **location**; neither says what the store **sells**, which is what a format is. The name reads fine and quietly classifies on the wrong dimension, so the error surfaces only when someone filters on it. Same failure in a catch-all — a value like `SPECIAL` that covers two unrelated cases means the column no longer has one meaning. Ask: does this name answer the question its column is asking?

## One thing, one word

Sweep every document for **one concept appearing under two names**. This is a defect on its own — a reader cannot tell whether two words mean two things, so they burn attention deciding, and often guess wrong. It is independent of whether either name is any good.

Found twice in one report: *heartbeat* and *liveness signal* for the same message; *client* and *customer* for the same entity. Neither was a bad word. The duplication was the whole problem.

When you find one:

1. Check whether it is genuinely **two concepts, both badly named** — *heartbeat* the message sent versus the derived alive-or-dead status computed from it. If so, name them separately and clearly. Only Siraj can answer this; ask.
2. Otherwise pick one and sweep the whole document, including anything already settled.
3. Report which earlier decisions the sweep changes, so the ripple is visible rather than discovered later.

**Watch for vocabulary carried in from a previous industry or employer.** It is invisible to the writer — it feels like plain English to them — and reads as jargon to everyone else. *Client* arrived in Siraj's writing from consulting, where it is standard; in a product context *customer* is the word everybody understands. Ask where a word came from when it seems oddly formal for its surroundings.

## Brackets

The output is often **two names, not one** — a plain phrase leading, the original riding behind it in brackets: *product selection (assortment)*, *shelf layout (planogram)*.

- **Where the original is strong industry-standard jargon** — every practitioner uses it, it is what Siraj searches for and says to veterans — the bracket is **not optional and not just first use**. Lead with the plain phrase, keep the original in brackets. Two names is the correct answer here, not a compromise.
- **Otherwise** the bracket is a first-use device. After that one name has to carry; say which.

Never leave the original unbracketed and unexplained just because a plain phrase reads better.

## Output

**Walking terms — numbered list.** The working format. Number each term so Siraj can answer by number, letter the alternatives on separate lines so he can answer "1A, 4C", then give your preferred choice and one or two sentences of reasoning.

> **1. term** — what it means here, including what the original word implies.
>
> - **A.** candidate *(the original)*
> - **B.** candidate
> - **C.** candidate — ✗ disqualified, and why
>
> **Preferred: B.** One or two sentences. Name what the losing options cost.

Two rules that make the shorthand safe:

- **Letters are stable.** If Siraj asks for more options on a term, continue **D, E, F** — never restart at A, or "3B" means different things in different messages.
- **The original is on the ballot.** Whenever *keep it* is a live verdict, list the original as a lettered option marked *(the original)*, so keeping is something he picks rather than an exception he has to type out.

**Sweeping a whole document — summary table**, one row per term: Jargon · What it means here · Alternatives · Preferred term. Use it to show the whole inventory at once, then work the terms in batches using the numbered format.

**A contested term — expanded block.** Only for a term load-bearing enough to argue about; most never need one.

> **`term`** — what it means here.
> *Why it trips people:* one clause. Skip when the term is merely unfamiliar rather than misleading.
>
> | Candidate | Veteran approves | Newcomer gets it | Agent reads it as | Trade-off |
> |---|---|---|---|---|
> | ... | yes/no | understands it first time / needs explaining once, then sticks / needs re-explaining every time | competing prior, or *nothing competes* | one clause |
>
> **Verdict:** replace it, add a word to it, or keep it — with the cost of the call stated plainly.

## Two worked examples

Kept deliberately few — the settled vocabulary lives in each project's `CONTEXT.md`, and these two exist only because each demonstrates a rule the prose above can't fully carry.

**`multi-tenant` → keep it.** *multi-client* reads plainer and drops the walls between tenants — the exact guarantee the architecture argues for. The human gap is one sentence wide; the agent gap doesn't close, so the tie-break toward the agent decides it. First use *multi-tenant (one system, many customers, walled off from each other)* — that explanation is a picture, which is why it holds. **Shows: the tie-break, the dropped implication, and the picture, all deciding one term together.**

**`markdown` → replace it.** A permanent price cut to clear stock. Perfectly clear to humans; catastrophic in a repo, where `markdown` means the text format to every model. Settled as **permanent price cut** — Siraj's improvement on the first proposal *price cut*, which dropped the permanence separating a markdown from a promotion. **Shows: the agent column deciding a term on its own, against a human reading that had no problem at all.**

## Pacing

For a document, first list **every** jargon term found — bare names, no definitions. The completion bar is **every term on that list either decided or explicitly skipped by Siraj**; a term dropped silently is unfinished work.

Then work **three to five terms per batch** in the numbered format, grouping terms from the same subsystem so each batch hangs together. Sixteen at once is too many to decide on; one at a time is too slow once the format is running. Drop to one term at a time when a single term is genuinely contested.

**Silence means agreement.** Siraj replies only where he wants to change something. Any number he doesn't mention is settled as your preferred choice — record it as decided and move on. Never re-ask about a term he passed over.

The reasoning matters more than the output: when he rejects a candidate, find the rule underneath the rejection rather than swapping in a replacement, and ask him directly when the rule isn't clear. Those rules belong back in this file.
