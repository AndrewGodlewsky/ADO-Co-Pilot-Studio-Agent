# Parent-Aware Elicitation — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add parent-aware elicitation — a new "Gate 0: Parent Grounding" stage plus context-driven enhancements to Gates 1–3 — so the agent reads the parent (Feature/Epic) a new item will live under and asks fewer, sharper questions.

**Architecture:** The orchestrator reads the named parent (`Get_Work_Item_Details`) and its children (`Search_Work_Items`), assembles a structured `ParentContext` packet, and passes it into `Backlog_Builder`, which runs the enhanced interview. A new citeable KB doc (`KB-1.6`) holds the deep elicitation playbook; a compressed copy lives in `Backlog_Builder`'s instructions. No new tools/flows.

**Tech stack:** Microsoft Copilot Studio (generative orchestration, child agent, inputs), Azure DevOps connector via existing Power Automate read flows, SharePoint `.docx` knowledge, Markdown drafts + pandoc. Source of truth: `ADO-Backlog-Agent-Architecture.md` (v1.4). Design spec: `ADO-Backlog-Agent-Parent-Aware-Elicitation-Design.md` (v1.0).

> **Note on verification:** this is a docs/config project — there is no test runner. Each task's "verify" step is a concrete check (rubric pass, character count, consistency, or a Test-pane utterance). The repo is **not** a git repo; "Checkpoint" steps replace commits. If you ran `git init`, commit at each checkpoint.

> **Sequencing:** Tasks 1–2 (author + register the knowledge) and Tasks 3–7 (design/config doc updates) are independent and can be done in either order. Task 8 (ship) depends on Task 1. Task 9 (portal build) depends on all of 1–8.

---

## Task 1: Author the KB-1.6 elicitation playbook

**Files:**
- Create: `knowledge/_research/KB-1.6-elicitation.md`
- Create: `knowledge/KB-1-Work-Item-Quality/1.6-eliciting-a-child-from-its-parent.md`
- Modify: `knowledge/_SCORECARD.md` (add one row)

- [ ] **Step 1: Research grounding.** Gather authoritative sources for the playbook's load-bearing claims, reusing the existing pipeline tools (Microsoft Learn MCP `microsoft_docs_search`/`microsoft_docs_fetch`; WebSearch). Topics: ADO field inheritance (Tasks inherit parent Area/Iteration Path), portfolio parent/child rules, story-splitting (SPIDR, vertical slicing). Cross-reference the already-grounded `knowledge/_research/KB-1-quality.md` and `KB-2-leveling.md` (INVEST, DoR, leveling) rather than re-sourcing them. Write `knowledge/_research/KB-1.6-elicitation.md` — one bullet per claim with source title + URL + date 2026-06-11.

  Verify: file exists; every claim the draft will rely on has a sourced bullet (or is cross-referenced to KB-1/KB-2 research).

- [ ] **Step 2: Draft the doc** at `knowledge/KB-1-Work-Item-Quality/1.6-eliciting-a-child-from-its-parent.md`, following the format contract (H1; `## Summary` first; `**Also known as:**` line; < ~36,000 chars; one topic; footer `*Verified 2026-06-11 · review quarterly.*`). Content = spec §5: the inheritance table (§5.1), the two scenario question banks (§5.2 — Story-under-Feature, Feature-under-Epic), the alignment & sibling checks (§5.3), and one worked dialogue per scenario (§5.4). Keep it reference-only — **no agent directives** ("never create Epics" etc. must not appear as rules).

  Verify: doc opens with `## Summary`; both scenario banks present; inheritance table matches Architecture §4.11 field names; no imperative agent rules.

- [ ] **Step 3: Add the scorecard row.** In `knowledge/_SCORECARD.md`, add a row `KB-1.6 Eliciting a Child from its Parent` with all four checks `❌`, and append an iteration-log line noting it was drafted and awaits grading.

  Verify: row present; 11 rows total.

- [ ] **Step 4: Grade against the rubric (Ralph 4-check).** Grade KB-1.6 against `knowledge/_RUBRIC.md`: C1 Format, C2 Accuracy+Examples (both banks + worked dialogues correct), C3 Consistency (agrees with KB-1/KB-2 and Architecture §3.4/§4.11; no directives; no cross-doc contradiction — esp. inheritance vs §4.11), C4 Grounding (every claim traces to `_research/`). Fix the smallest thing that moves any ❌/⚠️ to ✅. Update the scorecard.

  Verify: KB-1.6 row is `✅ ✅ ✅ ✅`.

- [ ] **Step 5: Checkpoint.** Re-read the doc once for tone against a sibling (e.g. `1.5-invest-for-user-stories.md`). (If git initialized: commit `knowledge/` with message `docs(kb): add KB-1.6 elicitation playbook`.)

---

## Task 2: Register KB-1.6 in the knowledge-planning docs

**Files:**
- Modify: `ADO-Backlog-Agent-Knowledge-Plan.md` (KB-1 table + folder tree)
- Modify: `ADO-Backlog-Agent-Knowledge-Acquisition-Plan.md` (doc counts + folder layout)

- [ ] **Step 1:** In `ADO-Backlog-Agent-Knowledge-Plan.md`, add to the KB-1 table:

  `| **1.6 Eliciting a Child from its Parent** | Ask the right gap-questions | Inheritance rules (Epic→Feature, Feature→Story); per-scenario question banks; alignment & sibling-dedupe checks; worked dialogues | Parent + child Gate 0/3 |`

  …and add `│   └── 1.6  Eliciting a Child from its Parent.docx` under `KB-1 Work-Item Quality/` in the folder tree.

  Verify: KB-1 now lists 6 docs; tree matches.

- [ ] **Step 2:** In `ADO-Backlog-Agent-Knowledge-Acquisition-Plan.md`, update the generatable count from **10** to **11** docs (KB-1 ×6) wherever it appears (§1 table, §2 layout comment, the scorecard reference in §3/§9), and add `1.6-eliciting-a-child-from-its-parent.md` to the KB-1 folder listing.

  Verify: every "10 generatable" reference now reads 11; KB-1 listing shows 1.1–1.6.

- [ ] **Step 3: Checkpoint.** Skim both files for any stale "10". (Git: commit with `docs(plan): register KB-1.6`.)

---

## Task 3: Update the Architecture (source of truth) for Gate 0

**Files:**
- Modify: `ADO-Backlog-Agent-Architecture.md` (header changelog; §3.4; §4.6; §5.1)

- [ ] **Step 1:** Bump the header — add to the version line: `· v1.5 change: added Gate 0 (Parent Grounding) and parent-aware enhancements to Gates 1–3; Backlog_Builder gains a ParentContext input (see Parent-Aware-Elicitation-Design)`. Change `**Version:** 1.4` to `1.5`.

- [ ] **Step 2:** In **§3.4**, after the three-gate diagram, add a `Gate 0 — Parent grounding` paragraph: the orchestrator asks the user to name the parent, reads it and its children, and passes `ParentContext` (parent scope, AC, inheritable fields, siblings) into `Backlog_Builder`; Gate 1 adds an alignment/right-level check against the parent, Gate 2 pre-fills inherited Area Path / Iteration / Value Area / Team (confirm-not-ask), Gate 3 asks gap-targeted slice/coverage/sibling questions. Cross-reference `ADO-Backlog-Agent-Parent-Aware-Elicitation-Design.md`.

  Verify: §3.4 mentions Gate 0 and all three enhancements.

- [ ] **Step 3:** In **§4.6** (`Backlog_Builder`), add `ParentContext` to its inputs (orchestrator-filled; structured packet per the design §3) and add a line to "Node instructions" noting the compressed parent-grounding playbook.

  Verify: §4.6 lists `ParentContext`.

- [ ] **Step 4:** In **§5.1** (evaluation test set), add a "Parent-aware elicitation" bullet group with the seven tests from the design §10.

  Verify: §5.1 contains the parent-aware tests.

- [ ] **Step 5: Checkpoint.** Confirm no other section contradicts the new Gate 0 (search for "three gates" / "Gates 1" phrasing and reconcile). (Git: commit `docs(arch): v1.5 parent-aware elicitation`.)

---

## Task 4: Orchestrator create-path instruction (Setup §3)

**Files:**
- Modify: `ADO-Backlog-Agent-CopilotStudio-Setup.md` (§3 instructions block + the char-count note)

- [ ] **Step 1:** In the §3 instructions code block, under `# Create path` (currently steps 2–4), insert a new first create-path step:

```markdown
0. First identify the parent: ask which item this will live under (a Feature for a
   User Story, an Epic for a Feature). Read it with /Get_Work_Item_Details and its
   children with /Search_Work_Items, and pass the parent's scope, acceptance criteria,
   inheritable fields (area path, iteration, value area, team), and existing children to
   /Backlog_Builder as ParentContext. If the user names the wrong level, explain the
   hierarchy and offer to create the missing Feature in between.
```

  Verify: the create path now begins with parent identification; `/Get_Work_Item_Details`, `/Search_Work_Items`, `/Backlog_Builder` referenced.

- [ ] **Step 2: Char-count check.** Run:

```powershell
$txt = Get-Content -Raw "A:\Claude\Ado Agent\ADO-Backlog-Agent-CopilotStudio-Setup.md"
$b = [regex]::Matches($txt,'(?s)```(?:markdown)?\r?\n(.*?)\r?\n```')
"Instructions block: {0} chars" -f $b[1].Groups[1].Value.Length
```

  Expected: under 8,000 (the hard limit). If it pushes much past ~3,500, trim the "Working style" section first. Update the §3 note's "~3,000 chars" figure to the measured value.

- [ ] **Step 3: Checkpoint.** Re-bind reminder still accurate (the `/Tool` picker note). (Git: commit `docs(setup): orchestrator parent-grounding step`.)

---

## Task 5: Backlog_Builder instructions — Gate 0 + compressed playbook (Setup §6.4)

**Files:**
- Modify: `ADO-Backlog-Agent-CopilotStudio-Setup.md` (§6.4 child instructions block)

- [ ] **Step 1:** Insert the compressed playbook (design §6) into the §6.4 child instructions block, immediately after `# Role` and before `# Gate 1 — Right-size first`:

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
```

  Also extend the existing `# Gate 1` line so it references the alignment check ("…and confirm it advances ParentContext's outcome").

  Verify: §6.4 block contains Gate 0 and the parent-aware questions; Gate 1 mentions alignment.

- [ ] **Step 2: Char-count check.** Re-run the script from Task 4 Step 2 but read block index `[3]` (the §6.4 child block — count the fenced blocks: 0=Description, 1=Instructions, then KB/tool blocks; locate the child markdown block by searching for `# Role`). Confirm under **8,000** chars.

  Expected: well under 8,000 (was ~2,200; ~+900 added).

- [ ] **Step 3: Checkpoint.** (Git: commit `docs(setup): Backlog_Builder Gate 0 playbook`.)

---

## Task 6: Backlog_Builder ParentContext input (Setup §6.3)

**Files:**
- Modify: `ADO-Backlog-Agent-CopilotStudio-Setup.md` (§6.3 required-inputs table)

- [ ] **Step 1:** Add a row to the §6.3 inputs table (top of the table, since it's filled before the interview):

```
| `ParentContext` | Yes (orchestrator-filled) | — (Should prompt user = OFF; the orchestrator supplies it) | structured packet: ParentId, ParentType, ParentTitle, ParentDescription, ParentAcceptanceCriteria, InheritedFields{AreaPath,IterationPath,ValueArea,Team}, Children[] |
```

  Add a sentence under the table: "`ParentContext` is populated by the orchestrator (Gate 0), not asked of the user; `ParentReference` remains for in-tree parenting within a multi-level create."

  Verify: row present; `Should prompt user = OFF`; the ParentContext-vs-ParentReference note exists.

- [ ] **Step 2: Checkpoint.** (Git: commit `docs(setup): add ParentContext input`.)

---

## Task 7: Evaluation tests (Setup §8 + cross-check Architecture §5.1)

**Files:**
- Modify: `ADO-Backlog-Agent-CopilotStudio-Setup.md` (§8 post-setup verification table)

- [ ] **Step 1:** Add these rows to the §8 Test-pane table:

```
| `make me a story to add CSV export` (then name a Feature) | Asks for the parent; reads it; confirms inherited area/iteration/value area; asks which slice |
| name an Epic as a Story's parent | Explains hierarchy; offers to create the in-between Feature |
| story overlapping an existing sibling | Flags the duplicate before preview |
| parent Feature with no acceptance criteria | Inherits what it can; asks the rest; doesn't fabricate |
| change an inherited area path during the interview | Override reflected in the preview and the create |
```

  Verify: §8 contains the five parent-aware utterances; they match the design §10 tests already added to Architecture §5.1 in Task 3.

- [ ] **Step 2: Checkpoint.** (Git: commit `docs(setup): parent-aware eval utterances`.)

---

## Task 8: Ship KB-1.6 to .docx

**Files:**
- Modify: `knowledge/convert-to-docx.ps1` (add the 1.6 mapping)

- [ ] **Step 1:** In `convert-to-docx.ps1`, add to the `$docs` array (KB-1 group):

```powershell
@{ Src = 'KB-1-Work-Item-Quality\1.6-eliciting-a-child-from-its-parent.md'; Out = 'KB-1 Work-Item Quality\1.6 Eliciting a Child from its Parent.docx' }
```

- [ ] **Step 2: Run + verify.**

```powershell
& "A:\Claude\Ado Agent\knowledge\convert-to-docx.ps1"
pandoc "A:\Claude\Ado Agent\knowledge\dist\KB-1 Work-Item Quality\1.6 Eliciting a Child from its Parent.docx" -t markdown | Select-String '^#' | Select-Object -First 4
```

  Expected: "Converted 11 / 11"; the round-trip shows the H1 + `## Summary` + first H2.

- [ ] **Step 3: Checkpoint.** (Git: commit `chore: ship KB-1.6 docx`.)

---

## Task 9: Portal implementation (manual — Copilot Studio)

> Requires authenticated Copilot Studio access. Not executable from this workspace; this is the build checklist.

- [ ] **Step 1:** Upload the new `dist/KB-1 Work-Item Quality/1.6 …docx` to the KB-1 SharePoint folder; reprocess the KB-1 source.
- [ ] **Step 2:** Paste the updated **orchestrator Instructions** (Setup §3) into the agent; re-bind every `/Tool` via the `/` picker.
- [ ] **Step 3:** Paste the updated **Backlog_Builder Instructions** (Setup §6.4).
- [ ] **Step 4:** Add the **`ParentContext`** input to `Backlog_Builder` (Setup §6.3) with `Should prompt user = OFF`.
- [ ] **Step 5:** Verify the orchestrator passes `ParentContext` on handoff (map the read-tool outputs into the child input).
- [ ] **Step 6:** Run the §8 Test-pane utterances (incl. the five new parent-aware ones). All must pass.

  Verify: each new utterance behaves as its Expected column states; Epics remain unmodified throughout.

---

## Self-review (completed by plan author)

- **Spec coverage:** every design §12 deliverable maps to a task — KB-1.6 (T1), register (T2), Architecture (T3), orchestrator instr (T4), child instr (T5), ParentContext input (T6), eval (T7), ship (T8), portal (T9). ✅
- **Placeholders:** the `<role>/<capability>/<value>` tokens are intentional prompt templates inside instruction text, not plan gaps. ✅
- **Consistency:** `ParentContext` field names are identical across T3/T5/T6 and the design §3; `ParentContext` (grounding) vs `ParentReference` (in-tree) distinguished in T6. ✅

---

*Plan derived from `ADO-Backlog-Agent-Parent-Aware-Elicitation-Design.md` v1.0, 2026-06-11.*
