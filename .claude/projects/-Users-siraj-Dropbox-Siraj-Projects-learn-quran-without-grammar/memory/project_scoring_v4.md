---
name: Scoring v4 — sentence-level 3-dimension model
description: 2026-04-17 scoring redesign — waqf sentences, D1/D2/D3, four-phase A1/A2/B/C, اللَّه excluded
type: project
originSessionId: 510c6fe2-d3b6-4c87-9920-1d3d31295358
---
Scoring algorithm was redesigned 2026-04-17 from verse-level 4-dimension to sentence-level 3-dimension.

**Why:** Teacher found that (a) full verses are too large as teaching units, (b) word-frequency scoring across ALL words in a verse matters more than single-root metrics, (c) the proper noun اللَّه dominates 92% of candidates and adds no teaching value.

**How to apply:**
- Scoring unit = waqf-split sentence, not full verse. `build-quran-db.py` pre-fragments.
- 3 dimensions: D1 (avg word freq), D2 (content coverage %), D3 (length sweet spot 5-12 words). Renumbered sequentially after dropping original D2 (total coverage).
- Four phases: A1 (universal objective, instant), A2 (LLM hookScore), B (curriculum overlap, lesson-time), C (student memorization/affinity).
- اللَّه excluded from form partitioning. Sentences kept only if they have إِلٰه, اللَّهُمَّ, or kabura forms.
- Diversity via diminishing returns decay (0.7 default), not form-first navigation.
- Recommended weights: D1=35, D2=25, D3=40.
- Spec: `docs/superpowers/specs/2026-04-17-slice-1-verse-picker-design.md`
- Interactive mockups: `docs/design/mockups/picker-scoring/` (v1-v4)
