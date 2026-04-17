---
name: Scoring v4 — sentence-level 3-dimension model
description: 2026-04-17 scoring redesign — waqf sentences, D1/D3/D4, four-phase A1/A2/B/C, اللَّه excluded
type: project
originSessionId: bdc24368-1822-4849-843b-47958e6e6521
---
Scoring algorithm was redesigned 2026-04-17 from verse-level 4-dimension to sentence-level 3-dimension.

**Why:** Teacher found that (a) full verses are too large as teaching units, (b) word-frequency scoring across ALL words in a verse matters more than single-root metrics, (c) the proper noun اللَّه dominates 92% of candidates and adds no teaching value.

**How to apply:**
- Scoring unit = waqf-split sentence, not full verse. `build-quran-db.py` pre-fragments.
- 3 dimensions: D1 (avg word freq), D3 (content coverage %), D4 (length sweet spot 5-12 words). D2 (total coverage) dropped as redundant.
- Four phases: A1 (universal objective, instant), A2 (LLM hookScore), B (curriculum overlap, lesson-time), C (student memorization/affinity).
- اللَّه excluded from form partitioning (decision C). Sentences kept only if they have إِلٰه, اللَّهُمَّ, or kabura forms.
- Diversity via diminishing returns decay (0.7 default), not form-first navigation.
- Recommended weights: D1=35, D3=25, D4=40.
- Spec: `docs/superpowers/specs/2026-04-17-slice-1-verse-picker-design.md`
- Interactive mockups: `docs/design/mockups/picker-scoring/` (v1-v4)
