---
name: Generator must produce proper tests — never hand-write
description: Fix generators to produce tests following testing philosophy. Never hand-write tests for generated features. Generate → verify → improve generator.
type: feedback
---

Tests for generated features must come from the generator, not be hand-written.

**Why:** If you hand-write tests, every new generated feature needs the same hand-writing. Fix the generator template once, every feature benefits forever. Phoenix gen.live is the model: it produces both working code AND proper tests.

**The workflow:**
1. Fix generator test templates to follow the testing philosophy (integration-first, MECE, property-based for happy path, edge case unit tests)
2. Re-run generators to produce code + tests
3. Verify output follows principles
4. Improve generator templates based on gaps
5. Repeat until generators produce production-quality tests

**Even for existing features:** Use generators to produce tests, compare with hand-written Phase 7 tests, and improve generators to match. The generator output should be indistinguishable from a senior developer's tests.

**How to apply:** When writing tests for ANY generated feature, ask: "Should this be in the generator template?" If yes, fix the template. Only hand-write truly domain-specific test logic that can't be generalized.
