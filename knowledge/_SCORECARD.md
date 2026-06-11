# Scorecard — ✅ pass · ⚠️ partial · ❌ fail. Loop ends when every cell is ✅.

| Doc | C1 Format | C2 Accuracy+Examples | C3 Consistency | C4 Grounding |
|---|---|---|---|---|
| KB-1.1 Definition of Ready          | ✅ | ✅ | ✅ | ✅ |
| KB-1.2 Writing Great Titles         | ✅ | ✅ | ✅ | ✅ |
| KB-1.3 Testable Acceptance Criteria | ✅ | ✅ | ✅ | ✅ |
| KB-1.4 Descriptions that Capture Value | ✅ | ✅ | ✅ | ✅ |
| KB-1.5 INVEST for User Stories      | ✅ | ✅ | ✅ | ✅ |
| KB-1.6 Eliciting a Child from its Parent | ✅ | ✅ | ✅ | ✅ |
| KB-2.1 Work Item Type Definitions   | ✅ | ✅ | ✅ | ✅ |
| KB-2.2 Right-Sizing Signals         | ✅ | ✅ | ✅ | ✅ |
| KB-2.3 Hierarchy & Parenting Rules  | ✅ | ✅ | ✅ | ✅ |
| KB-2.4 Common Type Mismatches       | ✅ | ✅ | ✅ | ✅ |
| KB-4.1 What This Agent Can & Can't Do | ✅ | ✅ | ✅ | ✅ |

## Iteration log (append one line per pass: what was fixed)
- (seed) Scaffold created; drafts pending Phase 2.
- (Phase 1–2) Grounded research notes written to _research/ (KB-1, KB-2); first drafts written for all 10 generatable docs. Grades below remain ❌ until the Phase 3 Ralph Loop grades them.
- (Ralph pass 1) Graded all 10 docs against the 4 checks. C1/C2/C3 passed for all. Fixed two C4 grounding gaps: created _research/KB-4-faq.md (maps every 4.1 claim to its Architecture §; 4.1 had no grounding file); removed a drifted citation in 1.4 ("short Descriptions are a quality smell" was attributed to a Microsoft Learn page that doesn't support it). All 10 docs now pass all 4 checks.
- (KB-1.6 authored) Added new doc KB-1.6 "Eliciting a Child from its Parent" (parent-aware elicitation playbook) + _research/KB-1.6-elicitation.md. Grounded the NEW load-bearing claims (Task auto-inherits parent Area/Iteration Path; team default Area/Iteration assigned on add; Area/Iteration are common fields on every form) on Microsoft Learn (Plan and track work in Azure Boards; About teams and Agile tools; Query by area or iteration path, all 2026-06-11); cross-referenced KB-1/KB-2 research for INVEST, DoR, AC/Given-When-Then, Value Area, hierarchy, sizing, parenting, vertical slicing, and SPIDR rather than re-sourcing. Self-graded C1–C4 all ✅: format contract met (Summary-first, Also-known-as, footer, one topic, ~14.9k chars); both question banks + both worked dialogues present; inheritance table matches the field facts; no agent directives; no contradiction with KB-1/KB-2.
