# ADO Backlog Agent — Parent-Aware Elicitation Design

> **Version:** 1.0 · **Date:** 2026-06-11 · **Status:** For review
> **Pairs with:** `ADO-Backlog-Agent-Architecture.md` (v1.4 — extends §3.4 the quality engine and §4.6 `Backlog_Builder`) · `ADO-Backlog-Agent-CopilotStudio-Setup.md` (§3 orchestrator instructions, §6 child agent) · `ADO-Backlog-Agent-Knowledge-Plan.md` / `ADO-Backlog-Agent-Knowledge-Acquisition-Plan.md` (registers the new KB-1.6) · `knowledge/KB-1-Work-Item-Quality/`, `knowledge/KB-2-Leveling-Hierarchy/` (the rubrics this playbook builds on).

This spec adds **parent-aware elicitation** to the agent: when a user asks to create a child item ("make me a Story that adds X"), the agent reads the **parent** it will live under (a Feature for a Story, an Epic for a Feature), and lets that context drive sharper, fewer, better questions — inheriting what flows down, asking only the gaps, checking alignment, and avoiding sibling duplicates.

**Approach (chosen):** a new **Gate 0 — Parent Grounding** stage plus enhancements to the existing Gates 1–3. The **orchestrator** performs the reads and passes a structured **`ParentContext`** packet into `Backlog_Builder`; the child runs the (now context-aware) interview. No new tools or flows — it reuses `Get_Work_Item_Details` and `Search_Work_Items`.

---

## 1. Design principles

1. **Ask fewer, ask sharper.** Every field the parent supplies is a question the agent must *not* ask. The conversation budget goes to the one thing only the human knows: which slice of the parent's value this child delivers.
2. **The parent's facts become a typed object, not a vibe.** `ParentContext` is an explicit structured input the gates *consume* — so "inherit Area Path" and "check alignment" are mechanical, not hopeful.
3. **Reuse the tool surface.** Parent and sibling reads use the existing read tools. No new flow, no new Epic exposure — Epics are only ever *read* here.
4. **Keep the gate model.** Parent grounding is a new, well-bounded stage feeding the existing three gates; the gates are enhanced, not rewritten.
5. **Knowledge ≠ instructions, preserved.** The deep elicitation playbook is citeable reference knowledge (KB-1.6); the *behavior* of asking lives in instructions.

---

## 2. End-to-end conversation flow

```
User: "make me a story that adds <X> to my app"
  │
  ▼  Orchestrator classifies → CREATE path
┌─ GATE 0 · Parent Grounding (orchestrator) ──────────────────────────┐
│ 1. Ask the user to name the parent:                                 │
│    "Which Feature should this Story go under? An ID or name works."  │
│ 2. /Get_Work_Item_Details(parentId)  → parent fields, scope, AC      │
│ 3. /Search_Work_Items(children of parentId) → siblings               │
│ 4. Validate the hierarchy level (Story→Feature, Feature→Epic)        │
│ 5. Assemble ParentContext (see §3)                                   │
│ 6. Hand off to /Backlog_Builder, passing ParentContext               │
└────────────────────────────┬─────────────────────────────────────────┘
                             ▼
   Backlog_Builder runs ENHANCED Gates 1–3 driven by ParentContext (§4)
                             ▼
   topic T4 preview (with inherited fields + any sibling/dup flags)
                             ▼
        Confirm → /Create_Backlog_Tree → report IDs + URLs
```

Per the design decision, the agent **always asks the user to name the parent** rather than auto-searching. Once named, it reads the parent and its children before interviewing.

---

## 3. The `ParentContext` packet (the interface)

The orchestrator assembles this from the two read calls and passes it into `Backlog_Builder` as a **single structured input** (`ParentContext`, `Should prompt user = OFF` — the orchestrator fills it, not the user):

```jsonc
ParentContext {
  ParentId,                       // the named parent's ID
  ParentType,                     // "Epic" | "Feature"
  ParentTitle,
  ParentDescription,              // for slice/alignment questions
  ParentAcceptanceCriteria,       // for coverage questions (may be empty)
  InheritedFields {               // DEFAULTS to confirm, never hard-set
    AreaPath, IterationPath, ValueArea, Team
  },
  Children [ { Id, Type, Title, State } ]   // siblings, for dedupe + gap
}
```

If a field is empty on the parent (e.g. a Feature with no Acceptance Criteria), the corresponding gap-question is asked of the user instead of inherited.

---

## 4. Gate-by-gate behavior

### Gate 0 — Parent Grounding *(new; orchestrator)*
- Ask the user to name the parent (Feature for a Story, Epic for a Feature).
- Read it (`Get_Work_Item_Details`) and its children (`Search_Work_Items`).
- **Hierarchy guard:** a Story's parent must be a Feature; a Feature's parent must be an Epic. If the user names the wrong level — e.g. an **Epic** as a **Story's** parent — explain the hierarchy and offer to create the intervening **Feature** as part of the tree (multi-level create), then the Story under it.
- Emit `ParentContext`.

### Gate 1 — Type-fit + Alignment *(enhanced)*
- Existing right-sizing (KB-2) **plus** an **alignment check** against `ParentContext`:
  - *Advances the parent?* Does this child move the parent's outcome forward, or is it unrelated/setup? If it doesn't fit the parent's scope at all, ask whether the named parent is correct.
  - *Right level under this parent?* A "Story" that's really a second Feature → propose re-leveling; a "Feature" that's really one Story → propose a Story.

### Gate 2 — Completeness *(enhanced — subtractive)*
- **Pre-fill** `AreaPath`, `IterationPath`, `ValueArea`, `Team` from `InheritedFields` and **confirm in one line** rather than asking four questions:
  > "I'll put this in area **`<X>`**, iteration **`<Y>`**, value area **`<Z>`**, team **`<T>`** (inherited from the Feature). Change any of these?"
- Still collect the child-specific required fields that never inherit: **Title, Description, Acceptance Criteria** (Feature/Story).

### Gate 3 — Readiness + gap-targeted questions *(enhanced)*
Ask questions only the parent makes possible (full banks in §5 / KB-1.6):
- **Slice:** "The Feature's goal is `<parent outcome>`; which part of that does this Story deliver?"
- **Coverage:** "The Feature's acceptance criteria mention `<X>` — does this Story cover that, and how will we know it's done?"
- **Sibling dedupe:** "There's already a sibling Story `<Y>`. How is this one different?"
- **Gap (optional):** "The Feature describes `<Z>` but no Story covers it yet — want one too?"
- Plus the existing Gate-3 quality loop (testable AC, outcome-focused title, the "so that…").

---

## 5. New knowledge document — `KB-1.6 Eliciting a Child from its Parent`

The deep, citeable playbook. Lives in the KB-1 (Work-Item Quality) source as doc **1.6** (default placement; could be promoted to its own source if it grows). Format per the contract (H1, `## Summary` first, "Also known as", < ~36,000 chars, dated footer). Drafted later through the same research → draft → Ralph-refine pipeline as the other generatable docs, then grounded in a `_research/KB-1.6-elicitation.md` note.

**Contents:**

### 5.1 Inheritance rules (what flows down, what never does)
| Field | Epic → Feature | Feature → Story | Notes |
|---|---|---|---|
| Area Path | inherit (confirm) | inherit (confirm) | Child defaults to parent's area |
| Iteration Path | optional default | inherit/current (confirm) | Features may span iterations; Tasks inherit the Story's automatically in ADO |
| Value Area | inherit (confirm) | inherit (confirm) | Default to parent's Business/Architectural |
| Team | inherit (confirm) | inherit (confirm) | Per KB-3 team mapping |
| **Title** | **never** | **never** | Each item is distinct |
| **Description** | **never** | **never** | Each item is distinct |
| **Acceptance Criteria** | **never** | **never** | Each item is distinct |

### 5.2 Scenario question banks
**Story under a Feature**
- *Slice:* which part of the Feature's outcome does this Story deliver?
- *User-voice:* As a `<role>`, I want `<capability>`, so that `<value>`?
- *Acceptance:* one testable check (→ Given/When/Then)?
- *Alignment:* does this advance the Feature directly, or is it enabler/setup?
- *Sibling dedupe:* how is this different from existing sibling Stories `<list>`?
- *Size:* fits one sprint, or does it span several outcomes (split)?
- *Inherited confirm:* area / iteration / value area / team from the Feature — ok?

**Feature under an Epic**
- *Capability:* which concrete capability of the Epic's initiative does this Feature deliver?
- *Scope boundary:* what's in scope vs explicitly left to other Features?
- *Value:* Business or Architectural (enabler)? what user outcome?
- *Decomposability:* roughly what Stories would sit under it? (confirms Feature-sized)
- *Alignment:* how does it move the Epic forward?
- *Sibling dedupe/gap:* distinct from sibling Features `<list>`? fills a gap in the Epic?
- *Inherited confirm:* area / value area / team from the Epic — ok?

### 5.3 Alignment & sibling checks
- **Advances parent** — if the child doesn't move the parent's outcome, question the parent choice.
- **Right level under parent** — re-level a child that's really the parent's level (or higher/lower).
- **Hierarchy valid** — Story↔Feature, Feature↔Epic only.
- **Dedupe** — compare proposed title/scope to siblings; on high overlap, surface and ask the difference.
- **Gap** — parent AC/description items no sibling covers → optional suggestion.

### 5.4 Worked dialogues (one per scenario)
A vague request → parent read → inherited-field confirm → one or two sharp gap questions → a well-formed, aligned child. Grounded in KB-1 (INVEST/DoR/AC) and KB-2 (leveling/SPIDR).

---

## 6. Compressed playbook in `Backlog_Builder` instructions

Add to the child's instructions (its 8,000-char budget; currently ~2,200, ample room). Ready-to-paste block:

```markdown
# Gate 0 — Ground in the parent (you receive ParentContext)
You are given ParentContext (the parent item this child lives under, its scope,
acceptance criteria, inheritable fields, and existing children). Use it:
- INHERIT, don't ask: default AreaPath, IterationPath, ValueArea, and Team from
  ParentContext.InheritedFields. Confirm them in ONE line; only ask if the user changes them.
- Titles, Descriptions, and Acceptance Criteria NEVER inherit — collect them fresh.

# Parent-aware questions (ask one at a time, only what the parent leaves open)
- Story under a Feature: which slice of the Feature's outcome is this? user-voice
  (As a <role>, I want <capability>, so that <value>)? one testable acceptance check?
- Feature under an Epic: which capability of the Epic is this? what's in/out of scope?
  Business or Architectural value? roughly which Stories sit under it?

# Alignment & siblings (use ParentContext.Children)
- Confirm this child advances the parent's outcome and is the right level under it;
  if it's really the parent's own level, propose re-leveling.
- If a sibling already covers this, surface it and ask how this one differs.

# Mini-example
Parent Feature "Self-service password reset". Request: "story for the reset email."
Inherit area/iteration/value area from the Feature (confirm). Ask: "Which slice — sending
the email, or validating the link?" → shape one testable Story, not the whole Feature.
```

---

## 7. Orchestrator instruction addition (create path)

Add to the create-path steps in the agent instructions (Setup §3):

```markdown
- When the user wants to create a child item, first ask which parent it belongs under
  (a Feature for a User Story, an Epic for a Feature). Read the parent with
  /Get_Work_Item_Details and its children with /Search_Work_Items, then hand off to
  /Backlog_Builder with a ParentContext containing the parent's scope, acceptance
  criteria, inheritable fields (area path, iteration, value area, team), and its existing
  children. If the user names the wrong level, explain the hierarchy and offer to create
  the missing Feature in between.
```

---

## 8. `Backlog_Builder` input addition (Setup §6.3)

| Input | Required? | Source | Notes |
|---|---|---|---|
| `ParentContext` | Yes (orchestrator-filled) | Orchestrator (`Should prompt user = OFF`) | Structured packet from §3; if absent, Backlog_Builder asks the orchestrator path to supply a parent before interviewing |

The existing `ParentReference` input stays for in-tree parenting (Task→Story within a multi-level create); `ParentContext` is the richer grounding object for the named existing parent.

---

## 9. Edge cases & error handling

| Case | Behavior |
|---|---|
| Unknown/invalid parent ID | Re-ask for a valid parent (ID or name). |
| Wrong-level parent (Epic named as a Story's parent) | Explain hierarchy; offer to create the intervening Feature as a multi-level tree, Story beneath it. |
| Creating a Feature under an Epic | Read the Epic (read-only — allowed); create the Feature; the Epic is never modified. |
| Sparse parent (no Description/AC to inherit from) | Say so; ask the user the gap questions directly; optionally offer to improve the **Feature** parent via `Update_Work_Item` (never the Epic). |
| Many siblings returned | Summarize the closest matches in the question; don't dump the full list. |
| Inherited-field override | User can change any pre-filled value; treat like any field edit and reflect it in the preview. |
| User insists on a standalone child with no parent | Explain a Story needs a Feature parent (Gate 2); offer to create the parent too, or to pick an existing one. |

---

## 10. Evaluation tests (add to Architecture §5.1)

- **Story-under-Feature happy path:** vague request → agent asks parent → reads it → confirms inherited area/iteration/value area → asks the slice question → produces an aligned, testable Story parented correctly.
- **Feature-under-Epic happy path:** same shape, Feature scoped to one capability of the Epic.
- **Wrong-level parent:** Epic named for a Story → agent corrects and offers the in-between Feature.
- **Sibling duplicate:** proposed Story overlaps an existing sibling → flagged before preview.
- **Coverage gap:** parent AC item no sibling covers → agent offers an additional Story.
- **Sparse parent:** Feature with no AC → agent inherits what it can, asks the rest, doesn't fabricate.
- **Inherited override:** user changes the inherited Area Path → reflected in the preview and the create.

---

## 11. Consistency with the existing architecture

- **No-Epic guarantee intact** — Epics are only ever *read* in Gate 0; no write path touches them.
- **Confirm-before-write unchanged** — Gate 0 adds reads only; the T4 preview/confirm gate is untouched.
- **Knowledge ≠ instructions** — KB-1.6 is reference (citeable, team-refinable); the asking behavior lives in instructions.
- **Tool surface unchanged** — reuses `Get_Work_Item_Details` + `Search_Work_Items`; no new flow, no new credits beyond ~1–2 read calls per create.
- **Child stays a non-responder** — `Backlog_Builder` still returns to the orchestrator for the T4 preview; it never replies to the user as the final agent.

---

## 12. Deliverables checklist (for the implementation plan)

- [ ] `knowledge/KB-1-Work-Item-Quality/1.6-eliciting-a-child-from-its-parent.md` + `_research/KB-1.6-elicitation.md` (research → draft → Ralph-refine).
- [ ] `Backlog_Builder` instructions: add Gate 0 + enhanced gates + compressed playbook (Setup §6.4).
- [ ] `Backlog_Builder` inputs: add `ParentContext` (Setup §6.3).
- [ ] Orchestrator instructions: add create-path parent-grounding steps (Setup §3).
- [ ] `ADO-Backlog-Agent-Architecture.md`: new sub-section (§3.4.x Parent-Aware Elicitation / Gate 0); update §4.6 `Backlog_Builder` I/O.
- [ ] Knowledge Plan + Knowledge Acquisition Plan: register KB-1.6 (counts toward KB-1).
- [ ] Architecture §5.1: add the §10 evaluation tests.
- [ ] Re-run `convert-to-docx.ps1` to ship KB-1.6 once drafted.

---

## 13. Open decisions (defaults chosen; change if needed)

1. **KB-1.6 placement** — default: a new doc inside the existing KB-1 source. Alternative: its own knowledge source (only if it grows large enough to warrant the extra source slot).
2. **`ParentContext` shape** — default: one structured input. Alternative: several flat inputs (`ParentId`, `ParentScope`, …) if the portal makes a single structured input awkward to populate from a flow.
3. **Coverage-gap suggestions** — default: ON but optional/non-blocking (the agent offers, never insists). Confirm this isn't too chatty for your team.

---

## 14. Traceability

| Decision | Source |
|---|---|
| Gate 0 as a new stage feeding Gates 1–3; orchestrator owns the reads | This session's design; Architecture §3.4 (gate model), §4.6 (child = interviewer, parent owns tools) |
| Inherit-don't-re-ask; subtractive Gate 2 | This session (all four parent-aware behaviors selected) |
| Always ask the user to name the parent | This session (missing-parent decision) |
| Playbook in KB **and** child instructions | This session (knowledge-home decision); mirrors Architecture §3.4 (deep rubric in KB, compressed in child) |
| Reuse read tools; Epics read-only | Architecture §3.3 (no-Epic guarantee), §4.4/§4.5 (read tools) |
| Inheritance rules, INVEST/DoR/SPIDR grounding | `knowledge/KB-1-*`, `knowledge/KB-2-*` |

*Review this design when the gate model or `Backlog_Builder` I/O changes, and when KB-1.6 is authored.*
