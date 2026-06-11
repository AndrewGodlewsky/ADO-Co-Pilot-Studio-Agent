# Knowledge Draft Rubric — grade every generatable doc against ALL four checks

A doc passes only when all four are ✅. Fix the lowest-scoring docs first; make the
smallest change that moves a ❌/⚠️ to ✅. Do not rewrite passing docs.

## Check 1 — Format contract
- [ ] H1 title + clear H2 sections
- [ ] `## Summary` is the FIRST section (answer-first)
- [ ] An "Also known as:" synonyms line is present (terms users actually type)
- [ ] Under ~36,000 characters
- [ ] Dated footer with a review cadence (e.g. "Verified 2026-06-11 · review quarterly.")
- [ ] Exactly one topic (no doc covers two subjects)

## Check 2 — Content accuracy + worked examples
- [ ] The rubric/definitions are stated correctly
- [ ] Required worked examples present and correct:
      - KB-1.2/1.3/1.4: >=1 good + >=1 bad example PER TYPE, each with the fix
      - KB-1.5: each INVEST letter has a one-line check
      - KB-2.1: Epic/Feature/Story/Task each defined (size, horizon, value)
      - KB-2.4: task-that's-a-Story, Story-that's-a-Feature, Epic-sized — each with corrective move

## Check 3 — Consistency (with the architecture AND across docs)
- [ ] Agrees with Architecture §3.4 (the three gates) and §4.11 (field catalogs)
- [ ] NO behavioral directives in knowledge (knowledge != instructions);
      "never create Epics" / "always confirm" must NOT appear as rules here
- [ ] No contradictions between docs (e.g. 1.5 "small" vs 2.2 right-sizing)

## Check 4 — Grounding
- [ ] Every load-bearing claim traces to a citation in knowledge/_research/
- [ ] No unsourced assertions introduced during refinement
