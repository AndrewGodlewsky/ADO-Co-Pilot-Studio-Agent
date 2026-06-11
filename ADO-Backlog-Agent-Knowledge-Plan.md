# ADO Backlog Agent — Knowledge Plan (spec for review)

> **Version:** 1.0 · **Date:** 2026-06-11 · **Status:** For review
> **Pairs with:** `ADO-Backlog-Agent-Architecture.md` (v1.4 — expands §4.9), `ADO-Backlog-Agent-CopilotStudio-Setup.md` (§4 descriptions), `Copilot-Studio-Knowledge-Preparation-Guide.md` (format rules).

This plan lists every knowledge document for the agent, organized as the SharePoint folder structure you'll build. Each document is single-topic by design.

---

## Design principles for this knowledge base

1. **Knowledge-light, by design.** This is a tool-heavy agent — its value is in the ADO flows, not a big library. The KB exists only to (a) judge/improve work-item quality, (b) right-size work-item types, and (c) hold this team's conventions. Everything else is a tool call.
2. **Three knowledge *sources*, many small *documents*.** Copilot Studio searches per source (folder); within a folder, small single-topic docs win the 15-snippet retrieval budget. So: **3 sources** (well under the 25-source pre-filter cap) containing **~17 focused `.docx` files**. (An optional 4th source is noted.)
3. **Knowledge ≠ instructions.** No directive/behavioral rules go in knowledge documents (they'd be subject to XPIA sanitizing and could be edited by anyone with doc access). Knowledge is *reference content the agent reads and cites*. Behavior lives in agent/child instructions.
4. **Attached to the parent agent only.** All sources attach to `ADO Backlog Agent`. `Backlog_Builder` uses its instructions, not its own knowledge sources.
5. **Format contract (every doc):** `.docx` in SharePoint · one topic per file · clear H1/H2 · answer-first ("## Summary" up top) · an "Also known as" synonyms line · under ~36,000 characters · a dated footer with a review cadence.

---

## Folder structure

```
ADO-Backlog-Agent-Knowledge/                         (SharePoint document library)
│
├── KB-1  Work-Item Quality/                          ◄ Knowledge SOURCE 1  (feeds Gate 3 + T3 answers)
│   ├── 1.1  Definition of Ready.docx
│   ├── 1.2  Writing Great Titles.docx
│   ├── 1.3  Testable Acceptance Criteria.docx
│   ├── 1.4  Descriptions that Capture Value.docx
│   ├── 1.5  INVEST for User Stories.docx
│   └── 1.6  Eliciting a Child from its Parent.docx
│
├── KB-2  Leveling & Hierarchy/                        ◄ Knowledge SOURCE 2  (feeds Gate 1 right-sizing)
│   ├── 2.1  Work Item Type Definitions.docx
│   ├── 2.2  Right-Sizing Signals.docx
│   ├── 2.3  Hierarchy & Parenting Rules.docx
│   └── 2.4  Common Type Mismatches.docx
│
├── KB-3  Team Conventions/   [TEAM-AUTHORED · BLOCKING] ◄ Knowledge SOURCE 3 (grounds answers + supplies validation lists)
│   ├── 3.1  Area Paths.docx
│   ├── 3.2  Iteration Paths.docx
│   ├── 3.3  Field Reference & Picklists.docx
│   ├── 3.4  Tags & the Requested-By Convention.docx
│   ├── 3.5  Naming Standards.docx
│   └── 3.6  Ownership & Escalation.docx
│
└── KB-4  Using This Agent/   [OPTIONAL]                ◄ Knowledge SOURCE 4 (optional; feeds T3 Help)
    └── 4.1  What This Agent Can and Can't Do (FAQ).docx
```

---

## KB-1 — Work-Item Quality  *(the Gate-3 rubric, in citeable form)*

> **Source purpose:** lets the agent judge whether a title/description/acceptance-criterion is good enough, and answer "how do I write a good X?" These docs are the deep version of what `Backlog_Builder`'s instructions carry in compressed form.

| Doc | Purpose | What it contains | Consumer |
|---|---|---|---|
| **1.1 Definition of Ready** | The pass/fail gate per type | The DoR checklist for Feature, User Story, and Task; when an item is "ready" to create | Parent (cite) + mirrors child Gate 3 |
| **1.2 Writing Great Titles** | Fix vague titles | Specific/outcome-focused title rules; the User-Story user-voice form; good vs bad examples per type | Parent + child Gate 3 |
| **1.3 Testable Acceptance Criteria** | The most-improved field | Given/When/Then structure; testability test; several good vs bad rewrites | Parent + child Gate 3 |
| **1.4 Descriptions that Capture Value** | Outcome over implementation | How to state the value/outcome; context a newcomer needs; examples | Parent + child Gate 3 |
| **1.5 INVEST for User Stories** | Story-shaping heuristic | Independent/Negotiable/Valuable/Estimable/Small/Testable, each with a one-line check | Parent + child Gate 1/3 |
| **1.6 Eliciting a Child from its Parent** | Ask the right gap-questions | Inheritance rules (Epic→Feature, Feature→Story); per-scenario question banks; alignment & sibling-dedupe checks; worked dialogues | Parent + child Gate 0/3 |

## KB-2 — Leveling & Hierarchy  *(the Gate-1 right-sizing rubric)*

> **Source purpose:** lets the agent decide the *correct* work-item type and refuse Epic-sized/Epic requests gracefully. This is what makes "that's really a Feature, not a Story" possible.

| Doc | Purpose | What it contains | Consumer |
|---|---|---|---|
| **2.1 Work Item Type Definitions** | Shared vocabulary | What an Epic, Feature, User Story, and Task each are (size, horizon, value) | Parent + child Gate 1 |
| **2.2 Right-Sizing Signals** | Detect too-big/too-small | The split/merge signals; "fits one iteration?" test; when to decompose a Feature into Stories | Child Gate 1 (primary) |
| **2.3 Hierarchy & Parenting Rules** | Correct linking | Feature→Story→Task rule; linking a new Feature under an existing Epic; **Epics are read-only** | Parent + child |
| **2.4 Common Type Mismatches** | Worked right-sizing cases | Task-that's-a-Story, Story-that's-a-Feature, Epic-sized request — each with the corrective move | Child Gate 1 |

## KB-3 — Team Conventions  *(team-authored; the blocking dependency)*

> **Source purpose:** the only project-specific source. It grounds "how do we do it here" answers **and** supplies the exact values the child agent's required-input validation enforces and the write flows target. Until this is authored, right-sizing/placement quality and custom-field writes are degraded.

| Doc | Purpose | What it contains | Consumer |
|---|---|---|---|
| **3.1 Area Paths** | Correct placement | Every valid area path; the default when unspecified; which area maps to which team/component | Parent + child validation list (`AreaPath`) |
| **3.2 Iteration Paths** | Correct scheduling | Active/current iterations; default iteration policy | Parent + child validation list (`Iteration`) |
| **3.3 Field Reference & Picklists** | Make writes land on the right fields | ADO **reference names** for every field (`System.*`, `Microsoft.VSTS.*`) incl. custom Release/Deploy/Feature-flag notes; Value Area picklist values ("enabler" mapping); whether Story Points/Effort are exposed on each type; the Team field's nature | Write flows + child validation (`ValueArea`, `Team`) |
| **3.4 Tags & the Requested-By Convention** | Audit + taxonomy | Standard tags; the `requested-by:<UPN>` stamp format the write flows apply | Parent + write flows |
| **3.5 Naming Standards** | Consistency | Title prefixes, ticket-number conventions, casing rules | Parent + child Gate 3 |
| **3.6 Ownership & Escalation** | Routing & the "out" | Who owns/creates Epics; the `[ORG: contact]` for fallback/help | Parent (T2, T5) |

## KB-4 — Using This Agent  *(optional)*

> **Source purpose:** a plain-language FAQ to back Topic T3 (Help). Informational only — no directives. Skip if T3's authored message is enough.

| Doc | Purpose | What it contains | Consumer |
|---|---|---|---|
| **4.1 What This Agent Can and Can't Do (FAQ)** | Set expectations | What it does (find/create/update/comment), what it won't (Epics, delete), how to phrase requests, what fields it asks for | Parent (T3) |

---

## Knowledge-vs-instructions boundary (so nothing lands in the wrong place)

| Content | Lives in | NOT in |
|---|---|---|
| "What makes a good acceptance criterion" (reference + examples) | KB-1 (citeable) | — |
| "Push back on a vague AC and rewrite it" (behavior) | `Backlog_Builder` instructions | knowledge |
| Valid area paths / iterations / picklist values (data) | KB-3 | instructions (don't hard-code lists in prompts) |
| "Never create Epics" (hard rule) | instructions + tool surface + server validation | knowledge |
| Field reference names for writes | KB-3.3 (human reference) + the flow config | agent instructions |

---

## Authoring sequence & status

1. **KB-2 and KB-1** — author from the drafts already in the build plan (Tasks 1.2–1.3 give KB-1/KB-2 starter content). Mostly general best-practice; quick to write.
2. **KB-3** — **team-authored, blocking.** Use the build-plan Task 1.4 skeleton. Confirm every field reference name (and which fields are custom) — this is Open Item §7.8 in the architecture doc.
3. **KB-4** — optional; author only if T3's message proves insufficient.

**Source count check:** 3 required sources (+1 optional) — far under the 25-source pre-filter limit, so every source is always searched. ~17 docs total, each single-topic and small — optimal for the 15-snippet retrieval budget.

---

## Open questions for your review

1. **KB-4 in or out?** Do you want the FAQ as knowledge, or is the T3 authored message enough?
2. **Estimation guidance** — do you want an additional KB-1 doc (e.g. 1.7) on how the team sizes Story Points / Effort / Risk, or is that out of scope for the agent? *(Note: 1.6 is now "Eliciting a Child from its Parent".)*
3. **Workflow states** — should KB-3 include a doc on your states and when each applies (e.g., New → Active → Resolved), so the agent can answer state questions and the Update tool can set states? (Currently not planned.)
4. **Granularity** — happy with ~17 small docs, or would you prefer fewer, slightly larger docs per source?
