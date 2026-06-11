# ADO Backlog Agent — Knowledge Acquisition Plan (research → draft → refine → ship)

> **Version:** 1.0 · **Date:** 2026-06-11 · **Status:** For review
> **Pairs with:** `ADO-Backlog-Agent-Knowledge-Plan.md` (v1.0 — *what* docs exist; this plan is *how to produce them*) · `ADO-Backlog-Agent-Architecture.md` (v1.4 — §3.4 gates, §4.9 KB, §4.11 field catalogs, §7 open items) · `Copilot-Studio-Knowledge-Preparation-Guide.md` (format rules) · `ADO-Backlog-Agent-Build-Plan.md` (KB-1/KB-2/KB-3 starter content).

This is an **executable playbook** for producing every knowledge document the ADO Backlog Agent needs. The companion *Knowledge Plan* defines the ~17 documents and their folder structure; **this** document defines the pipeline that researches, drafts, refines, and ships them — including a **Ralph Loop** that iteratively refines the generated drafts against a fixed rubric.

---

## 1. Why two tracks

The ~17 docs are not one kind of knowledge, and they cannot be acquired the same way:

| Track | Docs | Nature | Acquisition |
|---|---|---|---|
| 🟩 **Generatable** | KB-1 (×6), KB-2 (×4), KB-4 (×1) = **11 docs** | General agile/ADO best-practice + a restatement of this agent's own behavior | **Research → draft → Ralph-refine.** An AI can produce and polish these. |
| 🟦 **Team-only** | KB-3 (×6) = **6 docs** | Project-specific facts only your team holds (real area paths, custom-field reference names, the Epic owner) | **Template + structured interview.** No research or Ralph iteration can invent these — they must be *extracted* from the team. KB-3 is the agent's **blocking dependency** (Architecture §7.1). |

> **Why Ralph only touches the generatable track.** A Ralph Loop is built for "well-defined tasks with clear success criteria" and is explicitly *not* for "tasks requiring human judgment." Refining a draft against a format-and-quality rubric is the former; supplying an org's real iteration paths is the latter. Pointing Ralph at KB-3 would only produce confident, wrong facts.

```
                       ┌──────────────────────────────────────────────┐
                       │  Phase 0  Scaffold (folders, rubric, scorecard)│
                       └───────────────────┬──────────────────────────┘
              ┌────────────────────────────┴───────────────────────────┐
              ▼ 🟩 GENERATABLE TRACK                       🟦 TEAM-ONLY TRACK ▼
   ┌────────────────────────────┐                  ┌───────────────────────────────┐
   │ P1 Grounded research        │                  │ P4 KB-3 template + interview  │
   │ P2 Draft (11 .md)           │                  │   → 6 fill-in-blank docs       │
   │ P3 Ralph refinement loop ◄──┐                  │   → the unblocking question    │
   │    (rubric + scorecard)     │ loops            │     list (team answers)        │
   └──────────────┬──────────────┘ until pass       └───────────────┬───────────────┘
                  └───────────────────────┬─────────────────────────┘
                                          ▼
                       ┌──────────────────────────────────────────────┐
                       │ P5 Ship: .md → .docx → SharePoint → Copilot   │
                       │    Studio sources → verify retrieval          │
                       └──────────────────────────────────────────────┘
```

---

## 2. Working layout

All drafting happens in a `knowledge/` working folder so the Ralph Loop has real files to read and rewrite each iteration. Markdown is the **drafting** format (easy to edit, diff, and loop over); `.docx` is produced only at ship time (Copilot Studio retrieves `.docx`, **not** `.md` — Knowledge-Preparation-Guide).

```
knowledge/
├── _RUBRIC.md            ← the 4-check grading standard (Ralph re-reads every pass) — Appendix A
├── _SCORECARD.md         ← per-doc × per-check ✅/⚠️/❌ (Ralph rewrites every pass) — Appendix B
├── _research/            ← Phase 1 cited source notes
│   ├── KB-1-quality.md
│   ├── KB-2-leveling.md
│   └── KB-4-faq.md
├── KB-1-Work-Item-Quality/
│   ├── 1.1-definition-of-ready.md
│   ├── 1.2-writing-great-titles.md
│   ├── 1.3-testable-acceptance-criteria.md
│   ├── 1.4-descriptions-that-capture-value.md
│   ├── 1.5-invest-for-user-stories.md
│   └── 1.6-eliciting-a-child-from-its-parent.md
├── KB-2-Leveling-Hierarchy/
│   ├── 2.1-work-item-type-definitions.md
│   ├── 2.2-right-sizing-signals.md
│   ├── 2.3-hierarchy-and-parenting-rules.md
│   └── 2.4-common-type-mismatches.md
├── KB-3-Team-Conventions/        ← templates + placeholders only; team fills the facts
│   ├── 3.1-area-paths.md
│   ├── 3.2-iteration-paths.md
│   ├── 3.3-field-reference-and-picklists.md
│   ├── 3.4-tags-and-requested-by.md
│   ├── 3.5-naming-standards.md
│   ├── 3.6-ownership-and-escalation.md
│   └── _INTERVIEW.md             ← the question list that unblocks KB-3 — Appendix C
└── KB-4-Using-This-Agent/
    └── 4.1-what-this-agent-can-and-cant-do.md
```

> **Optional but recommended:** `git init` inside `knowledge/`. The folder is not currently under version control. Ralph's self-correction relies on files persisting between iterations; git additionally gives you history and one-command rollback if a refinement pass regresses a doc.

**The format contract (every generatable doc must satisfy — this is also Rubric Check 1):**
`.docx`-bound · one topic per file · H1 title + clear H2 sections · **answer-first `## Summary` at the top** · an **"Also known as:"** synonyms line (the terms users actually type) · under **~36,000 characters** · a **dated footer with a review cadence**.

---

## 3. Phase 0 — Scaffold

**Steps**
1. Create the `knowledge/` tree above (empty `.md` files for the 11 generatable docs + 6 KB-3 docs).
2. Drop in `_RUBRIC.md` (Appendix A) verbatim — it is the fixed goal the loop grades against.
3. Drop in `_SCORECARD.md` (Appendix B) pre-seeded with one row per generatable doc, every check marked ❌ (nothing drafted yet).
4. (Optional) `git init` and an initial commit.

**Verification:** the tree exists; `_RUBRIC.md` lists exactly the four checks; `_SCORECARD.md` has 11 rows.

---

## 4. Phase 1 — Grounded research

Gather **authoritative, citeable** sources before drafting, so the Ralph Loop refines real material instead of polishing guesses. Capture findings as cited notes — one file per source in `_research/`, each note tagged with its origin URL/title and verification date (2026-06-11).

**Source-to-research map**

| Target source | Research the agent needs | Where to get it |
|---|---|---|
| **KB-1 Work-Item Quality** | Definition of Ready; INVEST (origin & each letter's check); acceptance-criteria testability; Given/When/Then (Gherkin) structure; what makes titles/descriptions strong | **Web / `deep-research` skill** for INVEST (Bill Wake), DoR (Scrum community), Gherkin (Cucumber docs); **Microsoft Learn MCP** for ADO "best practices for Agile / Create your backlog / Define acceptance criteria" |
| **KB-2 Leveling & Hierarchy** | Canonical definitions of Epic / Feature / User Story / Task (size, horizon, value); portfolio-backlog hierarchy; decomposition signals | **Microsoft Learn MCP** (`microsoft_docs_search` → `microsoft_docs_fetch`): "Agile process work item types", "Define features and epics", "portfolio backlogs", work-item hierarchy; supplement with general agile leveling guidance via web |
| **KB-4 FAQ** | What the agent does / won't do, how to phrase requests, what fields it asks for | **No external research** — derive from `ADO-Backlog-Agent-Architecture.md` (§2 scope, §3.4 gates, §4.2 description, §4.8 topics) and the Knowledge Plan |

**Tooling**
- `microsoft-docs` MCP — `microsoft_docs_search` for breadth, `microsoft_docs_fetch` for full pages, `microsoft_code_sample_search` if a field/API example is needed.
- `WebSearch` / the `deep-research` skill for the agile standards (INVEST, DoR, Gherkin) that aren't Microsoft-specific.

**Verification:** each `_research/*.md` contains, per load-bearing claim, a one-line statement + its source (title/URL) + the 2026-06-11 date. Every claim a draft will rely on has a home here (this is what Rubric **Check 4 — Grounding** later verifies against).

---

## 5. Phase 2 — Draft

Generate each generatable doc as markdown from its research notes, following the format contract. These are **first drafts** — deliberately rough; the Ralph Loop is what makes them world-class. Per doc:

- Open with `## Summary` (answer-first, 2–4 sentences).
- Body in H2 sections; **one topic only**.
- Include the **required worked examples** (Rubric Check 2):
  - KB-1.2 / 1.3 / 1.4 — at least **one good + one bad example per type** (Feature, User Story, Task) with the fix.
  - KB-2.4 — each classic mismatch (task-that's-a-Story, Story-that's-a-Feature, Epic-sized request) with its corrective move.
- Add the **"Also known as:"** synonyms line and the **dated footer** (`*Verified 2026-06-11 · review quarterly.*`).
- Keep inline source markers so Check 4 can trace claims back to `_research/`.

**Verification:** 11 `.md` files exist and are non-empty; update `_SCORECARD.md` so Check 1 isn't trivially ❌ everywhere (the loop will do the real grading next).

---

## 6. Phase 3 — Ralph refinement loop (the core)

The loop refines all 11 generatable drafts against the rubric until every doc passes every check, then stops by emitting a completion promise.

### 6.1 The two files that make it converge
- **`_RUBRIC.md`** (Appendix A) — the **fixed goal**. The four checks, operationalized. Ralph re-reads it every iteration; it never changes during the loop.
- **`_SCORECARD.md`** (Appendix B) — the **working memory / progress bar**. A table of every doc × every check. Ralph re-reads it, fixes the lowest-scoring docs, re-grades, and rewrites it each pass. Without this, iteration *n* has no idea what iteration *n−1* already fixed and may undo it.

### 6.2 The four checks (what each pass enforces)
1. **Format-contract** — H1 + H2s; `## Summary` first; "Also known as:" line; < ~36,000 chars; dated footer with cadence.
2. **Content accuracy + worked examples** — the rubric/definitions are stated correctly **and** the required good/bad examples (§5) are present and correct.
3. **Consistency** — agrees with Architecture §3.4 (the three gates) and §4.11 (field catalogs); **no behavioral directives** in knowledge (the *knowledge ≠ instructions* boundary — e.g., "never create Epics" must **not** appear as a rule in any KB doc); **no contradictions between docs** (e.g., KB-1.5 INVEST "small" vs KB-2.2 right-sizing).
4. **Grounding** — every load-bearing claim still traces to a citation in `_research/`; flag any drift into unsourced assertion.

### 6.3 Invocation
```
/ralph-loop "Read knowledge/_RUBRIC.md and knowledge/_SCORECARD.md. Grade every draft
in knowledge/KB-1-Work-Item-Quality/, knowledge/KB-2-Leveling-Hierarchy/, and
knowledge/KB-4-Using-This-Agent/ against all four checks. Fix the lowest-scoring docs
this pass, then rewrite _SCORECARD.md with the new grades. When every doc passes every
check, output <promise>KB DRAFTS PASS</promise>."
  --completion-promise "KB DRAFTS PASS"  --max-iterations 20
```

- **Completion promise** — `KB DRAFTS PASS`, emitted only when the scorecard is all ✅.
- **`--max-iterations 20`** — safety stop so a never-converging check can't loop forever. If hit, inspect `_SCORECARD.md` for the stuck doc/check and fix manually or re-scope.
- **One doc at a time, smallest fix first** — the prompt steers Ralph to the lowest-scoring docs each pass rather than rewriting everything, which is what keeps "slightly refine" from becoming "rewrite from scratch."

### 6.4 Verification
`_SCORECARD.md` shows ✅ for all 11 docs × all 4 checks; the loop emitted `<promise>KB DRAFTS PASS</promise>` before max-iterations.

---

## 7. Phase 4 — KB-3 template + interview track (parallel; no Ralph)

Produce two things for the team-only source:

1. **Six fill-in-the-blank `.md` templates** (3.1–3.6) — correct headings, the format contract, and typed placeholders (`<<AREA_PATH_1>>`, `<<VALUE_AREA_PICKLIST>>`, …) where facts go. Structure-complete, content-empty.
2. **`_INTERVIEW.md`** (Appendix C) — the structured question list that extracts every value, each with a **"where to find this in ADO"** hint so the team can answer quickly.

This track has no Ralph loop: its success criterion is "the team supplied the facts," which is human judgment, not an automatable check. The templates can be format-checked against Rubric Check 1, but they are **not** done until the placeholders are filled.

**Verification:** 6 templates exist with placeholders; `_INTERVIEW.md` covers every placeholder and every open field-reference question from Architecture §7.8/§7.10. Hand `_INTERVIEW.md` to the team; KB-3 stays flagged as the blocking dependency until answers return.

---

## 8. Phase 5 — Ship & verify

1. **Convert** each approved `.md` → `.docx`, preserving H1/H2:
   `pandoc 1.1-definition-of-ready.md -o "1.1 Definition of Ready.docx"`
   (Optionally pass `--reference-doc=house-style.docx` to apply your SharePoint styling.)
2. **Upload** to the SharePoint document library, in the folder structure from the Knowledge Plan (`KB-1 Work-Item Quality/`, `KB-2 Leveling & Hierarchy/`, `KB-3 Team Conventions/`, optional `KB-4 Using This Agent/`).
3. **Add as knowledge sources** in Copilot Studio — one source per KB-* folder, with the descriptions from `ADO-Backlog-Agent-CopilotStudio-Setup.md` §4, **Enhanced search (Work IQ) ON**.
4. **Verify retrieval** per source with test queries (e.g., "what makes a good acceptance criterion?" → KB-1.3; "is this a Feature or a Story?" → KB-2.2; "what area paths can I use?" → KB-3.1).
5. **Re-verify after any solution import** — knowledge is **not** auto-reprocessed on ALM import (Architecture §4.10).

**Verification:** every source returns a relevant snippet for its test query; KB-3 queries return the team-supplied values (once filled).

---

## 9. Definition of done

- ✅ **Generatable track:** `_SCORECARD.md` all ✅ across 11 docs × 4 checks; Ralph emitted the promise.
- ✅ **Team-only track:** 6 KB-3 templates + `_INTERVIEW.md` delivered. *(Filled content remains pending the team — the expected, standing blocker, not a gap in this plan.)*
- ✅ **Ship checklist** (Phase 5) documented and runnable.
- ✅ Each shipped source verified to retrieve in Copilot Studio.

---

## 10. Open items (carried from the Architecture; resolved by KB-3 answers)

These are the same open questions the architecture flags; `_INTERVIEW.md` is built to close them:

1. **`[PROJECT]` and `[ORG: contact]`** values (Architecture §7.6) → KB-3.6 + agent config.
2. **Field reference names / which are custom** — `ValueArea` picklist values, Story-Points/Effort exposure per type, Release/Deploy/Feature-flag-notes names (Architecture §7.8) → KB-3.3.
3. **`RequestedBy` as a queryable field?** (Architecture §7.4) → KB-3.4.
4. **Epic write policy** — fully read-only vs comment-allowed (Architecture §7.10) → KB-3.6.
5. **KB-4 in or out** (Knowledge Plan Q1) — drafted here as generatable; drop the source if Topic T3's authored message proves sufficient.

---

## 11. Traceability

| Decision in this plan | Source |
|---|---|
| Two tracks (Ralph vs interview); Ralph only on generatable docs | Ralph Loop plugin guidance ("clear success criteria" vs "human judgment") + Architecture §7.1 (KB-3 blocking) |
| Markdown draft → `.docx` ship; one-topic-per-doc; < ~36,000 chars; Enhanced search ON | `Copilot-Studio-Knowledge-Preparation-Guide.md`; Architecture §4.9 |
| The 4 refinement checks (format / accuracy+examples / consistency / grounding) | This session's design decisions; Architecture §3.4 (gates), §4.11 (catalogs) |
| Rubric + scorecard as the loop's fixed-goal / working-memory pair | Ralph Loop self-reference mechanism (state lives in files between iterations) |
| KB-3 interview field list | Architecture §4.11 catalogs + §7.4/§7.6/§7.8/§7.10 open items; Knowledge Plan KB-3 |
| Grounded-research-first sourcing | This session; matches project knowledge-currency ethos (Scope Definition §6) |

---

## Appendix A — `_RUBRIC.md` (drop in verbatim)

```markdown
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
```

## Appendix B — `_SCORECARD.md` (seed; Ralph rewrites each pass)

```markdown
# Scorecard — ✅ pass · ⚠️ partial · ❌ fail. Loop ends when every cell is ✅.

| Doc | C1 Format | C2 Accuracy+Examples | C3 Consistency | C4 Grounding |
|---|---|---|---|---|
| KB-1.1 Definition of Ready          | ❌ | ❌ | ❌ | ❌ |
| KB-1.2 Writing Great Titles         | ❌ | ❌ | ❌ | ❌ |
| KB-1.3 Testable Acceptance Criteria | ❌ | ❌ | ❌ | ❌ |
| KB-1.4 Descriptions that Capture Value | ❌ | ❌ | ❌ | ❌ |
| KB-1.5 INVEST for User Stories      | ❌ | ❌ | ❌ | ❌ |
| KB-2.1 Work Item Type Definitions   | ❌ | ❌ | ❌ | ❌ |
| KB-2.2 Right-Sizing Signals         | ❌ | ❌ | ❌ | ❌ |
| KB-2.3 Hierarchy & Parenting Rules  | ❌ | ❌ | ❌ | ❌ |
| KB-2.4 Common Type Mismatches       | ❌ | ❌ | ❌ | ❌ |
| KB-4.1 What This Agent Can & Can't Do | ❌ | ❌ | ❌ | ❌ |

## Iteration log (append one line per pass: what was fixed)
- (pass 1) …
```

## Appendix C — `_INTERVIEW.md` (the KB-3 unblocking question list)

```markdown
# KB-3 Interview — the facts only the team can supply. Answer each; fills the templates.

## 3.1 Area Paths
- List every valid area path in [PROJECT].
- Which area is the DEFAULT when the user doesn't specify one?
- Which area maps to which team/component?
  (Find in ADO: Project Settings > Project configuration > Areas)

## 3.2 Iteration Paths
- Current/active iteration(s) and the naming scheme.
- Default iteration when the user doesn't specify (backlog? current sprint?).
- How far ahead may the agent assign?
  (Find in ADO: Project Settings > Project configuration > Iterations)

## 3.3 Field Reference & Picklists  (closes Architecture §7.8)
- Which process template? (Agile / Scrum / CMMI / custom inherited)
- Confirm the ADO reference name for each field in Architecture §4.11.1:
  Title, Description, AcceptanceCriteria, ValueArea, StoryPoints, Priority, Risk, Effort.
- The "Team" field — derived from Area Path, or a custom field? If custom, its reference name.
- Custom fields' exact reference names: Release notes, Deploy notes, Feature-flag notes.
- ValueArea picklist values (e.g. Business / Architectural) — and how "enabler" maps.
- Is Story Points exposed on Feature in your template? Is Effort exposed on User Story?
  (Find in ADO: Org Settings > Process > [your process] > [work item type] > Fields;
   or REST: GET {org}/{project}/_apis/wit/fields)

## 3.4 Tags & the Requested-By convention
- Standard tag taxonomy.
- Exact format of the requested-by stamp (e.g. `requested-by:user@org.com`).
- Do you want a queryable `RequestedBy` custom field, or tag/description line only? (§7.4)

## 3.5 Naming Standards
- Title prefixes/conventions per type.
- Ticket-number conventions.
- Casing rules.

## 3.6 Ownership & Escalation
- Who owns / creates Epics? (the Epic owner)
- The `[ORG: contact]` for fallback/help (Topics T2 & T5).
- Epic write policy (§7.10): fully read-only, or may the agent COMMENT on (never create/retype) Epics?
- The `[PROJECT]` name (§7.6).
```

---

*This plan reflects the project as of 2026-06-11. Review when the Knowledge Plan or Architecture §4.9/§4.11 changes, and re-confirm the format contract against the Knowledge-Preparation-Guide each quarter.*
