---
name: Tableau Standard — Smart Defaults, Open for Power Override
description: Core design principle for all Feather DX decisions — infer from context, pick smart defaults, always open for power-user override. Apply BEFORE asking.
type: feedback
---

## The Tableau Standard: Smart Defaults, Open for Power Override

When designing any Feather feature or config option: **infer from context first**, pick a sensible default that works for the common case, and **always allow power-user override**.

**Why:** This is the user's core design philosophy. It maps directly to the 3-tier generatability model (auto-generated → declarable → custom). Most questions about "how should X be configured?" can be answered by applying this principle without asking.

**The reference:** Tableau is the gold standard. When you drag an Excel file with one tab, it auto-imports (no "which tab?" question). Double-click a dimension → bar chart. Double-click a measure → different chart. It infers from context and only asks when genuinely ambiguous. Compare to Power BI/SAP where you have to: name this, pick data source, name that, configure columns → "configuration death." Feather must be Tableau, not Power BI.

**How to apply:**
- Infer from context first (single tab = auto-import, field type = infer from data, one option = auto-select)
- When facing a design question: first ask "what's the sensible default?" and "can the user override it?"
- If both answers are clear → make the decision yourself, document the default + override mechanism
- Only ask the user when the sensible default is genuinely ambiguous or when the override mechanism isn't obvious
- Avoid configuration death: one config surface (YAML), no right-click menus, no multi-step wizards
- Examples already decided using this principle:
  - Quick entry form: auto from required fields (default) + YAML field list (override)
  - Identity/naming: auto-increment UUID (default) + expression format (override)
  - `feather update`: hard overwrite generated/ (default) + YAML override pointer for custom components (override)
  - Excel import: single tab auto-imported, types inferred, relationships detected. Only prompt when ambiguous.
