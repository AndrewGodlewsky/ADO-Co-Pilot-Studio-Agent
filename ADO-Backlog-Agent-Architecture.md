# ADO Backlog Agent — Architecture Design Document

**Version:** 1.6 · **Date:** 2026-06-11 · **Status:** Design for build · **v1.6 change:** added `List_Assigned_Work_Items` (§4.5b) — a third read tool that lists the items assigned to the asking user (or a named teammate); see `ADO-Backlog-Agent-Assigned-Items-Design.md` · **v1.5 change:** added Gate 0 (Parent Grounding) and parent-aware enhancements to Gates 1–3; `Backlog_Builder` gains a `ParentContext` input — see `ADO-Backlog-Agent-Parent-Aware-Elicitation-Design.md` · **v1.4 change:** corrected §4.1 settings against Microsoft Learn — "Allow ungrounded responses" is the single general-knowledge toggle (kept ON for clarifying questions; no separate general-knowledge off-switch), and Work IQ requires Authenticate-with-Microsoft; see `ADO-Backlog-Agent-CopilotStudio-Setup.md` for copy-paste config · **v1.3 change:** added Title to the catalog; User Story field set = Feature field set; Task field set = Title + Description only (§4.11, §3.4) · **v1.2 change:** pulled Update + comments into v1 — added `Update_Work_Item` (§4.7.1) and `Add_Comment` (§4.7.2), the edit path (§3.2), diff-preview confirmation (§4.8 T4); Epics kept fully read-only pending §7.10 · **v1.1 change:** added the Feature field catalog (§4.11), wired it into the create payload (§4.7) and the Gate-2 floor (§3.4)
**Platform:** Microsoft Copilot Studio · **Target system:** Azure DevOps (single project)
**Derived from:** stakeholder design decisions (this session) · Copilot-Studio-Description-and-Instructions-Guide · Copilot-Studio-Instruction-Formats-Deep-Dive · Copilot-Studio-Knowledge-Preparation-Guide · Path-Finder-Agent-Architecture (precedent for house conventions)

---

## 1. Design principles

1. **Tool-heavy, knowledge-light — the inverse of Path-Finder.** This agent's value lives in a small set of well-named Azure DevOps action tools, not in a large knowledge base. The KB shrinks to "how to write a world-class work item" plus the team's own conventions.
2. **Reading is easy; writing is the architecture.** Creating Features, User Stories, and Tasks is team-visible and effectively irreversible, so the spine of the design is *identity* (who authors the item), *guardrails* (confirm-before-create), and the **hard "never create Epics" rule**.
3. **Enforce hard rules with tool surface, not prose.** "Never create Epics" is guaranteed primarily by **never building an Epic-create tool** and by **server-side type validation**, with the instruction line and a deterministic topic as backups — never by asking the model to behave.
4. **Deterministic where it matters.** Field completeness (required inputs + validation), the preview→confirm gate (Adaptive Card topic), and the actual write (one flow) are deterministic. The LLM owns understanding, right-sizing, and the quality interview.
5. **Descriptions do the orchestration work.** Verb-phrase tool names + when-to-use/when-not descriptions are the primary routing signals; agent-level instructions stay in the ~1,500-character band and only break ambiguity with exact `/Tool` references.

---

## 2. Scope and the decisions that shaped it

### 2.1 What the agent will do
- **Read** Epics, Features, User Stories, and Tasks (search the backlog, locate a parent, inspect one item, check for duplicates).
- **List a person's assigned items** — the asking user's own active items by default, or a named teammate's, via `List_Assigned_Work_Items` (read-only).
- **Create** Features, User Stories, and Tasks — single items or a multi-level Feature→Story→Task tree — through a structured quality interview, a duplicate check, and a previewed, confirmed write.
- **Update** existing Features, User Stories, and Tasks (field edits — including the post-create fields in §4.11) and **add discussion comments**, each through a confirmed diff preview.

### 2.2 What the agent will NOT do
- **Create Epics** (read-only for Epics). Enforced in depth — see §3.3.
- **Edit or comment on Epics** — Epics are fully read-only in the write path by default (§7.10 confirms this policy).
- **Delete** any item (no delete tool exists).
- Operate outside the single configured project (v1).

### 2.3 Anchoring decisions (this session)

| # | Decision | Choice | Consequence |
|---|---|---|---|
| 1 | Connectivity | **ADO connector via Power Automate agent flows** | Governed, DLP-aware, full control over input shaping/validation; matches Path-Finder's flow pattern |
| 2 | Identity | **Service account / PAT** | Single bot author; per-user ADO permissions are NOT in play → Copilot-Studio-side guardrails are the only safety layer; requires `requested-by` audit stamp + PAT rotation owner |
| 3 | Write safety | **Confirm a preview, then create** | Nothing is written before explicit user confirmation |
| 4 | ADO scope | **Single project** | Simplest area-path/iteration handling; multi-project is a later phase |
| 5 | Create quality | **Enforce a quality template** | Drives the `Backlog_Builder` child agent + required inputs; conventions live in the KB |
| 6 | Hierarchy | **Multi-level in one request** | One `Create_Backlog_Tree` flow builds and links the whole tree server-side |
| 7 | Below-bar override | **Warn-and-allow** | Preview flags weak/missing fields with ⚠; user may override and create anyway — except Epic, which is never satisfiable |
| 8 | Update + comments | **In v1** | Adds `Update_Work_Item` + `Add_Comment` so post-create fields (§4.11) are serviceable; each repeats the no-Epic guard + confirm gate; Epics stay read-only |

---

## 3. High-level architecture

### 3.1 Component view (Phase 1 — single agent)

```
                    ┌─ CHANNELS ───────────────────────────┐
                    │  Teams (primary) · Web · M365 Copilot │
                    └──────────────┬────────────────────────┘
                                   │   (user is Entra-authenticated →
                                   │    agent KNOWS who is asking)
┌──────────────── ADO BACKLOG AGENT (Copilot Studio) ────────────────────────┐
│                                                                            │
│  GENERATIVE ORCHESTRATOR  (model: Auto · generative orchestration ON)      │
│  Instructions ≤~1,500 chars: purpose · read-vs-create rule · no-Epics      │
│  guardrail · confirm-before-create rule · audit-stamp · the "out"          │
│                                                                            │
│  ├── TOOLS (Power Automate agent flows → ADO connector, service-account)   │
│  │     /Search_Work_Items      ── read: query by text/type/area + DUP check│
│  │     /Get_Work_Item_Details  ── read: full fields + parent/child links   │
│  │     /List_Assigned_Work_Items ─ read: items assigned to a user (self    │
│  │                                 by default, or a named teammate)        │
│  │     /Create_Backlog_Tree    ── WRITE: builds Feature→Story→Task tree,    │
│  │                                 links them, REJECTS Epic, stamps         │
│  │                                 requested-by, returns IDs + URLs         │
│  │     /Update_Work_Item       ── WRITE: field edits on an existing item;   │
│  │                                 REJECTS Epic targets + type→Epic         │
│  │     /Add_Comment            ── WRITE: posts a discussion comment         │
│  │                                 (Comments API); REJECTS Epic targets     │
│  │                                                                         │
│  ├── CHILD AGENT                                                            │
│  │     /Backlog_Builder ── required-input interview enforces the quality    │
│  │                          template (Gates 1–3); emits TreeJson + preview  │
│  │                                                                         │
│  └── TOPICS (deterministic islands)                                        │
│        T1 Greeting & what-I-can-do      T4 Confirm-or-Cancel (Adaptive      │
│        T2 Epic request → STOP + reroute     Card: create preview OR edit    │
│        T3 Help / how-to-phrase-requests     diff → Confirm = call the       │
│        T5 Fallback                          matching write tool)            │
└────────────────────────────────────────────────────────────────────────────┘
            │                                          │
   Azure DevOps (single project)            Service-account / PAT connection
   Work Items: Epic(read) · Feature ·       (Work Items R/W) — DLP-classified
   User Story · Task  via REST connector    connector, rotation owner assigned
```

### 3.2 Conversation lifecycle

```
UNDERSTAND ─► [READ path]   SEARCH / GET ─────────────────────────────────► ANSWER
           ├─► [CREATE path] ELICIT ─► DUP-CHECK ─► PREVIEW ─► CONFIRM ─► CREATE ─► REPORT
           └─► [EDIT path]   IDENTIFY ─► GATHER CHANGES ─► [quality-check edited fields]
                                       ─► DIFF-PREVIEW ─► CONFIRM ─► UPDATE / COMMENT ─► REPORT
```

1. **Understand** — orchestrator classifies: *read/search* vs *create* vs *edit/comment* vs *Epic request or Epic-write (stop)* vs *out-of-scope*.
2. **Elicit** — for a create, `Backlog_Builder` runs the three-gate quality interview (§3.4).
3. **Dup-check** — `Search_Work_Items` looks for similar titles in the project; matches surface in the preview.
4. **Preview** — `Backlog_Builder` emits the tree; topic T4 renders it as an Adaptive Card with ⚠ on weak fields and duplicate flags.
5. **Confirm** — Confirm / Cancel buttons. *Nothing is written before this.*
6. **Create** — on Confirm, `Create_Backlog_Tree` runs once, server-side: creates, links, rejects Epics, stamps `requested-by:<UPN>`.
7. **Report** — agent returns each new item's ID + clickable URL, plus any rejections.

**Edit path (Update / comment).** When the user wants to change an existing item: *identify* it (`Get_Work_Item_Details`, rejecting Epics), *gather* only the fields being changed, run the Gate-3 quality check on any edited quality-bearing field (Description, Acceptance Criteria), render a **diff preview** (old → new) in topic T4, and on Confirm call `Update_Work_Item` (field edits) or `Add_Comment` (discussion). Same stamp, same no-Epic guard, same confirm gate as create.

### 3.3 The "never create Epics" guarantee (defense in depth)

| Layer | Mechanism | Why it's there |
|---|---|---|
| 1 — **No tool** | No Epic-create capability exists anywhere in the agent | The only *structural* guarantee — the model can't call what doesn't exist |
| 2 — **Server validation** | `Create_Backlog_Tree` rejects any node typed `Epic` and returns it in `Rejected[]` | The over-powered service-account PAT could otherwise write an Epic; this closes the gap |
| 3 — **Topic T2** | "Create an Epic" → deterministic stop + reroute (offer a Feature under an existing Epic) | Graceful, on-brand refusal instead of a confusing failure |
| 4 — **Instruction** | One line: "Never create Epics; you create only Features, User Stories, and Tasks." | Cheapest nudge; backs up the above |

**Asymmetry note:** Epics are fully present in the *read* tools (so the agent can find a Feature's parent or browse) and have **zero presence** in the *write* path. The asymmetry is enforced by tool surface, not by model behavior.

**Applies to every write tool.** The same four layers cover `Update_Work_Item` and `Add_Comment`: there is no tool that creates an Epic; `Update_Work_Item` rejects an Epic *target* and any field change that would set `Type = Epic`; `Add_Comment` rejects an Epic target; topic T2 catches Epic-write requests; and the instruction line forbids them. Editing/commenting on Epics is off by default — see §7.10.

### 3.4 The quality engine (how the agent forces a world-class item)

"Doesn't meet the needs of a work item" is three distinct failures, each with its own mechanism. All three gates run inside `Backlog_Builder`, **before the preview**.

```
request ─► GATE 1: TYPE-FIT ─► GATE 2: COMPLETENESS ─► GATE 3: READINESS ─► preview
           (right shape?)        (all required fields?)   (each field good enough?)
              │ wrong                │ missing               │ weak
              ▼                      ▼                       ▼
        propose correct        required-input          targeted follow-up,
        type / re-level        auto-asks (det.)        loop until it passes
```

**Gate 0 — Parent grounding** *(orchestrator, before the three gates).* When the user creates a child item, the orchestrator first asks which parent it belongs under (a Feature for a User Story, an Epic for a Feature), reads that parent with /Get_Work_Item_Details and its children with /Search_Work_Items, and passes a structured **ParentContext** (parent scope, acceptance criteria, inheritable fields — Area Path, Iteration, Value Area, Team — and existing children) into Backlog_Builder. This sharpens the gates: **Gate 1** adds an alignment/right-level check against the parent; **Gate 2** pre-fills the inherited fields (confirm-not-ask); **Gate 3** asks gap-targeted slice/coverage/sibling questions. Epics are only read here — the no-Epic guarantee is unaffected. Full design: ADO-Backlog-Agent-Parent-Aware-Elicitation-Design.md.

**Gate 1 — Type-fit & right-sizing** *(LLM judgment vs the team's leveling rules in KB-2).* Catches the classic mismatches:
- a "task" that actually delivers user value → propose a **User Story**;
- a "story" that is broad enough to be a **Feature** with child Stories;
- an **Epic**-sized request → hard stop (topic T2) + offer to build a Feature.

**Gate 2 — Completeness** *(deterministic floor — required inputs + validation conditions, 2 reprompts).* The agent cannot finish the interview without the per-type required set:

| Type | Required (agent must collect) | Optional / nudged |
|---|---|---|
| **Feature** | Title, Description (outcome/value), **Acceptance Criteria**, Value Area, Team, Area Path, parent Epic link *if one applies* | Story Points, Priority, Risk, Effort, Iteration *(post-create fields — Discussion, Release/Deploy/Feature-flag notes — are not collected at create; see §4.11)* |
| **User Story** | Title (user-voice), Description, **Acceptance Criteria**, Value Area, Team, Area Path, parent **Feature** link | Story Points, Priority, Risk, Effort, Iteration *(same post-create fields as Feature; see §4.11)* |
| **Task** | Title (actionable verb), Description, parent **User Story** link *(relation)* | — *(Tasks carry only Title + Description as fields; see §4.11)* |

*The columns above are summarized; the full field sets, ADO reference names, and required/optional/post-create classification live in the **field catalogs (§4.11)**. **User Story = Feature** field set; **Task = Title + Description** only.*

**Gate 3 — Readiness quality** *(LLM rubric loop vs the Definition of Ready in KB-1).* A field can be present but bad; the agent asks one targeted question per weakness and loops until it passes or the user overrides:
- title `"fix the thing"` → ask for a specific, outcome-focused title;
- acceptance criteria `"it works"` → not testable; reframe as Given/When/Then;
- story missing the *"so that…"* → ask for the user value.

**Where the rubric lives:** the deep rubric (INVEST, DoR, leveling, examples) lives in the **KB** (citable, team-refinable); a compressed version with **one good + one bad worked example per type** lives in `Backlog_Builder`'s **node-level instructions** (its own 8,000-char budget — zero cost to agent-level instructions). The interview asks **one question at a time**.

**Override:** below-bar fields are flagged ⚠ in the preview and may be overridden (warn-and-allow). **Type is never overridable to Epic.**

---

## 4. Low-level design

### 4.1 Agent settings

| Setting | Value | Why |
|---|---|---|
| Orchestration | **Generative** | Required for tools-by-description, child agent, follow-ups |
| Model | **Auto** (escalate create path to a reasoning tier if tree assembly/sequencing falters) | Reasoning models improve multi-tool selection |
| **Allow ungrounded responses** | **ON** | Non-negotiable — OFF blocks any turn that doesn't call a tool/source, suppressing Gate 1 & 3 clarifying questions and routing them to fallback (the #1 silent failure). In current Copilot Studio this *same* toggle governs general-knowledge use — there is **no** separate "general knowledge OFF" switch. Honesty/scope is enforced by Web search OFF + the instruction "out" + the tool-first design |
| Web search ("Use information from the web") | **OFF** | Nothing here needs the open web |
| Turn on Work IQ (Enhanced search) | **ON** | Tenant has M365 Copilot; better KB retrieval; **requires Authentication = Authenticate with Microsoft** |
| Authentication | **Authenticate with Microsoft** (Entra ID) | Gates Work IQ; supplies the asking user's UPN for the `requested-by` stamp — even though the *write* runs as the service account |
| Content moderation | High (default) | Standard |

**Two identities coexist by design:** the *agent* authenticates the human via Entra (identity context for the audit stamp); the *flow* authenticates to ADO via the service-account connection (the actual write). The Entra login does **not** grant the agent the user's ADO permissions — which is exactly why Layer-2 server validation, not ADO permissions, enforces "no Epics."

### 4.2 Description (the field — ~300 chars)

> Use the ADO Backlog Agent to find and create Azure DevOps work items for the Power Platform team. It searches and reads Epics, Features, User Stories, and Tasks, and helps you create well-formed Features, User Stories, and Tasks — interviewing you for the details, checking for duplicates, and previewing every item before it's created.

*Positive capabilities only; "create Epics" deliberately absent; keyword-rich (the words users type).*

### 4.3 Agent-level instructions (target ≤~1,500 chars)

```markdown
# Purpose
You help the Power Platform team find and create Azure DevOps work items in the
[PROJECT] project. You create only Features, User Stories, and Tasks.

# How to work
1. To find, read, or check existing items, use /Search_Work_Items and
   /Get_Work_Item_Details.
2. To create anything, hand off to /Backlog_Builder to gather a complete,
   high-quality item. Never assemble a create request yourself.
3. Before previewing a create, always run /Search_Work_Items to check duplicates.
4. To change an item, read it first, gather only the changed fields, then show a
   diff. Use /Update_Work_Item for fields and /Add_Comment for discussion.
5. Write only after the user confirms the preview or diff.

# Rules
- Never create Epics. If asked, explain you create Features, Stories, and Tasks,
  and offer to create a Feature under an existing Epic.
- Never edit or comment on an Epic. Epics are read-only.
- Always write through /Create_Backlog_Tree, /Update_Work_Item, or /Add_Comment.
  Never write any other way.
- Stamp the requesting user on every item you create or change.

# If you cannot answer
If a request is outside finding or creating work items, say so and point the
user to [ORG: contact].
```

*Placement: purpose first, the "out" last (lost-in-the-middle discipline). `[PROJECT]` and `[ORG: contact]` resolved at deployment.*

### 4.4 Tool: `Search_Work_Items` (read + duplicate check)

| Aspect | Spec |
|---|---|
| Description | "Finds existing Azure DevOps work items in [PROJECT] by text, type, area path, state, or assignee. Use to browse the backlog, locate a parent, or check for duplicates before creating. Returns Epics, Features, Stories, and Tasks. Does not create or change items." |
| Inputs | `SearchText`, `WorkItemType` (Epic/Feature/User Story/Task/Any), `AreaPath`, `State`, `MaxResults` |
| Outputs (keyed JSON) | `Items[]` → `{Id, Type, Title, State, AreaPath, IterationPath, Parent, Url}` |
| Flow internals | ADO connector WIQL query / "Get query results"; service-account connection; respond <100s; published |
| After running | **Don't respond** — orchestrator folds results into its answer / the dup warning |

### 4.5 Tool: `Get_Work_Item_Details` (read one)

| Aspect | Spec |
|---|---|
| Description | "Returns the full details of one Azure DevOps work item by ID — all fields plus parent and child links. Use when the user references a specific item or to inspect a candidate parent. Read-only." |
| Inputs | `WorkItemId` |
| Outputs (keyed JSON) | `Id, Type, Title, Description, AcceptanceCriteria, State, AreaPath, IterationPath, AssignedTo, Parent, Children[], Url` |
| After running | **Don't respond** |

### 4.5b Tool: `List_Assigned_Work_Items` (read — assigned items)

| Aspect | Spec |
|---|---|
| Description | "Lists the Azure DevOps work items in [PROJECT] currently assigned to a person — by default the person asking. Use when someone asks what's assigned to them ('my work items', 'what am I working on', 'my tasks', 'my backlog') or to another named user. Returns active items by default (excludes Closed/Done/Removed unless asked). Read-only; never creates or changes items." |
| Inputs | `Assignee` (optional UPN/email; **default = authenticated user UPN**), `IncludeClosed` (bool, default false), `WorkItemType` (Epic/Feature/User Story/Task/Any, default Any), `MaxResults` (default 50) |
| Outputs (keyed JSON) | `Items[]` → `{Id, Type, Title, State, Priority, IterationPath, AreaPath, AssignedTo, Url}` · `ResolvedAssignee` · `Count` |
| Flow internals | WIQL filtered on `[System.AssignedTo] = @assignee` (literal end-user UPN, **never `@me`**); excludes terminal states unless `IncludeClosed`; optional type filter; `ORDER BY Priority ASC, ChangedDate DESC`; expand IDs→fields; service-account connection; async OFF, respond <100s; published |
| Identity | Orchestrator fills `Assignee` from the authenticated user's UPN system variable unless the user names someone else |
| After running | **Send specific response** — agent renders the grouped list (by State, then Priority). Different from `Search_Work_Items`' "Don't respond" rule. |

### 4.6 Child agent: `Backlog_Builder` (the quality engine)

| Aspect | Spec |
|---|---|
| Type | Child agent (promotable to connected agent if another team reuses it — §6) |
| Description | "Interviews the user to assemble one or more well-formed Features, User Stories, and Tasks — right-sizing the type, enforcing required fields, and checking quality — then produces a preview and the structured create payload. Use whenever the user wants to create work items. Never use for read-only questions." |
| Required inputs (Gate 2 floor, §3.4) | Per-type required fields, each with `Should-prompt-user ON`, custom wording, **validation conditions**, 2 reprompts. Plus ParentContext (orchestrator-filled structured packet: ParentId, ParentType, ParentTitle, ParentDescription, ParentAcceptanceCriteria, InheritedFields{AreaPath, IterationPath, ValueArea, Team}, Children[]) — supplies Gate 0 grounding. |
| Node instructions (own 8,000-char budget) | Compressed quality rubric: leveling rules (Gate 1), Definition of Ready (Gate 3), "ask one question at a time", and **one good + one bad worked example per type**. Ends with: *"You are a subagent. NEVER respond to the user as the final agent. Never produce a node typed Epic. Before preview, flag any below-bar field with ⚠ and let the user override — except type, which you never override to Epic."* Plus the compressed parent-grounding playbook (Gate 0): inherit-don't-re-ask, per-scenario gap questions, alignment & sibling checks. |
| Output | `TreeJson` (structured Feature→Story→Task payload) + `PreviewMarkdown` |
| After running | Returns to orchestrator → topic T4 renders the Adaptive Card preview |

### 4.7 Tool: `Create_Backlog_Tree` (the only writer)

| Aspect | Spec |
|---|---|
| Description | "Creates the confirmed work items in Azure DevOps from a structured tree, links parents to children, and returns the new IDs and URLs. Creates only Features, Stories, and Tasks. Call only after the user confirms the preview." |
| Input | `TreeJson` — array of nodes `{TempId, Type, Title, AreaPath, IterationPath, ParentTempId, ParentExistingId, Tags, Fields{}}`. `Fields{}` is a typed map keyed by ADO reference name. **Feature & User Story** accept the §4.11.1 at-create set (`System.Description`, `Microsoft.VSTS.Common.AcceptanceCriteria`, `Microsoft.VSTS.Common.ValueArea`, `Microsoft.VSTS.Scheduling.StoryPoints`, `Microsoft.VSTS.Common.Priority`, `Microsoft.VSTS.Common.Risk`, `Microsoft.VSTS.Scheduling.Effort`, Team); **Task** accepts only `System.Description`. Post-create fields (§4.11) are ignored here — set them later via `Update_Work_Item` |
| Flow internals | Create parents→children in topological order (`Apply to each`); map each `TempId`→real ID; set `System.Parent` links; **reject any node where `Type = Epic`** (return in `Rejected[]`, create nothing for it); append `requested-by:<UPN>` to a tag and/or the description; set a `RequestedBy` field if one exists |
| Outputs (keyed JSON) | `Created[]` → `{TempId, Id, Type, Title, Url}` · `Rejected[]` → `{TempId, Reason}` · `Summary` |
| Async | OFF, respond <100s |
| After running | **Send specific response** — agent reports each created item's ID + URL and any rejections |

### 4.7.1 Tool: `Update_Work_Item` (edit an existing item)

| Aspect | Spec |
|---|---|
| Description | "Updates fields on one existing Azure DevOps work item — Feature, User Story, or Task — by ID. Use to change description, acceptance criteria, priority, estimates, value area, release/deploy/feature-flag notes, etc. Cannot edit Epics. Call only after the user confirms the diff." |
| Inputs | `WorkItemId`, `Fields{}` (map of ADO reference name → new value), optional `AreaPath`, `IterationPath` |
| Flow internals | Read the item's `Type` first; **reject if `Type = Epic`** and **reject any `Fields` entry that sets `System.WorkItemType = Epic`** (return `Rejected`); otherwise PATCH the supplied fields; append `requested-by:<UPN>` to the history/tag; return the updated field set |
| Outputs (keyed JSON) | `Updated` → `{Id, Type, Title, ChangedFields[], Url}` · `Rejected` → `{Id, Reason}` |
| Async | OFF, respond <100s, published |
| After running | **Send specific response** — agent reports what changed + the URL, or the rejection reason |

### 4.7.2 Tool: `Add_Comment` (post a discussion comment)

| Aspect | Spec |
|---|---|
| Description | "Adds a discussion comment to one existing Feature, User Story, or Task by ID. Use when the user wants to record a note or discussion entry. Cannot comment on Epics. Call only after the user confirms." |
| Inputs | `WorkItemId`, `CommentText` |
| Flow internals | Read the item's `Type`; **reject if `Type = Epic`**; otherwise post via the work-item **Comments API** (not a field PATCH); prefix or stamp `requested-by:<UPN>` |
| Outputs (keyed JSON) | `CommentId, Id, Url` · `Rejected` → `{Id, Reason}` |
| Async | OFF, respond <100s, published |
| After running | **Send specific response** — agent confirms the comment + the URL |

*Discussion is the one Feature field (§4.11) that is not a normal field write — it requires the Comments API, which is why it has its own tool rather than riding on `Update_Work_Item`.*

### 4.8 Topics (deterministic islands)

| Topic | Trigger | Behavior |
|---|---|---|
| **T1 Greeting** | Conversation start | What it can do; starters: "Find my Stories in area X", "Create a Feature with some Stories", "What's under Feature 1234?", "Check if a Story already exists for…" |
| **T2 Epic stop** | Description: "user asks to create, add, or open an Epic" | Authored message: "I create Features, Stories, and Tasks — not Epics. I can create a Feature under an existing Epic; which Epic is it?" (no LLM, no tool) |
| **T3 Help** | Description: "user asks how to phrase a request or what makes a good work item" | Brief guidance; pulls from KB on demand |
| **T4 Confirm-or-Cancel** | After `Backlog_Builder` returns (create) **or** after the edit path assembles a change set | **Adaptive Card** (ColumnSet). *Create:* tree preview with ⚠ on weak fields + duplicate flags → **Confirm** = `Create_Backlog_Tree`. *Edit:* old→new **diff** of changed fields (or the pending comment) → **Confirm** = `Update_Work_Item` / `Add_Comment`. **Cancel** → discard |
| **T5 Fallback** | System | "I help find and create Azure DevOps work items. For anything else, [ORG: contact]. Could you rephrase?" |

### 4.9 Knowledge base (small — the inverse of Path-Finder)

| # | Source | Contents | Status |
|---|---|---|---|
| KB-1 | **Work-item quality & Definition of Ready** | World-class title/description/acceptance-criteria standards; INVEST; DoR; Given/When/Then examples | To author |
| KB-2 | **Leveling & hierarchy rules** | Epic vs Feature vs Story vs Task definitions; too-big/too-small signals; the Feature→Story→Task rule | To author |
| KB-3 | **[ORG] team conventions** | Area paths, iteration paths, tag taxonomy, required-field policy, `requested-by` convention, who owns Epics, naming standards | **Blocking dependency — you author** |

*Format per the Knowledge-Preparation-Guide: `.docx` in SharePoint, one topic per doc, clear H1/H2, answer-first, under ~36,000 chars, Enhanced search ON.*

### 4.10 Identity, audit & governance

- **Connection:** one **service account** (preferred over a personal PAT) with **Work Items: Read & Write**, scoped to the single project; DLP-classify the Azure DevOps connector; assign a **rotation owner** if a PAT is used.
- **Audit stamp:** agent passes the Entra UPN into every create; flow writes `requested-by:<UPN>` as a tag + a description line. Optional `RequestedBy` custom field if you want it queryable/reportable.
- **Credits:** agent flows ≈13 credits/100 actions; set a per-agent monthly cap in PPAC; a multi-level create is **one** flow call.
- **ALM:** agent + flows + child agent + KB in **one solution**; re-verify knowledge after import (it isn't auto-reprocessed).

### 4.11 Work-item field catalogs

The fields the agent reads, sets at creation, and/or updates per work-item type. ADO reference names and which fields are custom must be confirmed against the team's process template and recorded in KB-3; the classification below is the proposed default. **User Stories carry the same field set as Features; Tasks carry only Title + Description.**

#### 4.11.1 Feature & User Story (identical field sets)

| Field (team term) | ADO reference field *(confirm vs your template)* | Agent handling | Notes |
|---|---|---|---|
| Title | `System.Title` | **At create — required** | A specific, outcome-focused title; quality-gated (Gate 3). User Story uses the user-voice form |
| Description | `System.Description` | **At create — required** | Rich text; the outcome/value |
| Acceptance criteria | `Microsoft.VSTS.Common.AcceptanceCriteria` | **At create — required** | Quality-gated (Gate 3); phrase as Given/When/Then |
| Value area, enabler | `Microsoft.VSTS.Common.ValueArea` | **At create — required** | Business vs Architectural; "enabler" ≈ Architectural — confirm the picklist values |
| Team | area-path-derived *or* custom field | **At create — required** | ADO has no default "Team" work-item field — usually derived from Area Path or a custom field; confirm which |
| Story points | `Microsoft.VSTS.Scheduling.StoryPoints` | At create — optional/nudged | Often set in grooming; native on User Story — confirm it's exposed on Feature in your template |
| Priority | `Microsoft.VSTS.Common.Priority` | At create — optional/nudged | Typically 1–4 |
| Risk | `Microsoft.VSTS.Common.Risk` | At create — optional/nudged | e.g., 1-High / 2-Medium / 3-Low |
| Effort | `Microsoft.VSTS.Scheduling.Effort` | At create — optional/nudged | Estimate — confirm it's exposed on User Story in your template |
| Discussion | work-item **Comments** (`System.History`) | **Post-create only** | Added via the dedicated work-item Comments API — *not* a normal field PATCH; uses `Add_Comment` (§4.7.2) |
| Release notes | custom field *(confirm name)* | **Post-create only** | Filled after build/release |
| Deploy notes | custom field *(confirm name)* | **Post-create only** | Filled near deployment |
| Feature flag notes | custom field *(confirm name)* | **Post-create only** | Filled during rollout |

#### 4.11.2 Task

| Field (team term) | ADO reference field *(confirm vs your template)* | Agent handling | Notes |
|---|---|---|---|
| Title | `System.Title` | **At create — required** | Actionable, verb-led; quality-gated (Gate 3) |
| Description | `System.Description` | **At create — required** | What "done" means for the task |

*Tasks have no other data fields. The parent **User Story** link is applied as a structural relation (via the create tree's `ParentTempId`/`ParentExistingId`, §4.7), not as a field.*

**Resolved (v1.2):** the post-create fields (Feature & User Story) are served by `Update_Work_Item` (§4.7.1), and Discussion by `Add_Comment` (§4.7.2) via the Comments API — both **now in v1**. Each repeats the no-Epic guard and the confirm-before-write (diff) gate.

---

## 5. Build sequence

1. **Author KB-1, KB-2, KB-3** (`.docx`, SharePoint). KB-3 is a **blocking dependency** for correct right-sizing and placement.
2. **Provision identity:** service account + ADO connection (Work Items R/W), DLP classification, rotation owner.
3. **Build read flows** `Search_Work_Items`, `Get_Work_Item_Details`; test queries and keyed-JSON outputs.
4. **Build `Create_Backlog_Tree`:** tree creation, topological parent linking, **Epic rejection**, `requested-by` stamp, keyed outputs. Test the Epic-rejection path and partial-failure behavior explicitly.
4b. **Build `Update_Work_Item` + `Add_Comment`:** field PATCH with Epic-target rejection and type→Epic rejection; comment via the Comments API with Epic-target rejection; `requested-by` stamp on both. Test the Epic-target rejection path for each.
5. **Create agent** → settings per §4.1 (verify **Allow ungrounded ON** and **Entra auth**) → description §4.2 → instructions §4.3 (`[PROJECT]`/`[ORG]` resolved).
6. **Add KB sources** with §4.9 names/descriptions; verify Enhanced search ON; test retrieval per source.
7. **Build `Backlog_Builder`:** required inputs + validation conditions + node-instruction rubric with worked examples; test the three gates end to end (right-size, complete, quality pushback).
7b. **Wire the edit path:** identify item → gather changed fields → Gate-3 check on edited quality fields → diff preview (T4) → `Update_Work_Item` / `Add_Comment`. Test that editing/commenting on an Epic is refused.
8. **Author topics T1–T5;** build the T4 Adaptive Card preview (Teams-safe ColumnSet).
9. **Evaluation baseline** (§5.1) — run before/after every description or instruction change.
10. **Pilot** with a subset of the team → review activity map + analytics → publish to Teams → governance approval.

### 5.1 Evaluation test set (build before launch)
- **Right-sizing (Gate 1):** mislabeled task-that's-a-story, story-that's-a-feature, epic-sized request.
- **Completeness (Gate 2):** missing acceptance criteria, missing parent link, missing area path.
- **Quality (Gate 3):** vague title, untestable AC, missing "so that".
- **Epic-stop:** explicit "create an Epic" → deterministic refuse + reroute; **edit/comment an Epic** → refused.
- **Duplicate detection:** near-duplicate title already in backlog → surfaced in preview.
- **Read queries:** by text, by type, by area; single-item by ID with children.
- **Edit path:** change a field on an existing Story → diff preview → confirmed update; edit acceptance criteria → Gate-3 quality check fires; add a discussion comment; set release/deploy/feature-flag notes on a Feature.
- **Out-of-scope:** delete request, non-ADO request → graceful redirect.
- **Parent-aware elicitation (Gate 0):** create a Story without naming a parent → agent asks for the Feature, reads it, confirms inherited area/iteration/value area, asks which slice; create a Feature under an Epic → reads the Epic (read-only), scopes to one capability; name an Epic as a Story's parent → agent explains the hierarchy and offers the in-between Feature; proposed Story duplicates a sibling → flagged before preview; parent Feature has no acceptance criteria → agent inherits what it can and asks the rest without fabricating; user changes an inherited area path → reflected in the preview and the create.

---

## 6. Evolution path

| Phase | Trigger | Change |
|---|---|---|
| **1 (build now)** | — | Single agent as above (~11 choices — wide headroom under the 25–30 ceiling) |
| **1.5** | Assignment/triage wanted | Add `Assign_Work_Item` (and other targeted write tools), each with its own confirm gate and Epic guard |
| **2a** | Another team wants the interviewer | Promote `Backlog_Builder` from child to **connected agent** (reusable; own governance) |
| **2b** | Backlog spans projects | Add **multi-project scope**: a project-selector step + per-project area/iteration metadata (consider a `Get_Project_Metadata` flow feeding valid values) |
| **2c** | Per-user authorship/permissions required | Move to **delegated identity** (act-as-user) so ADO's own permission model backstops writes and authorship is honest |
| **3** | Hands-off creation wanted | Event/triggered creation (e.g., from an intake form or Teams message) — **note:** trigger payloads are a jailbreak surface; constrain allowed parameter values and trim payloads |

**Standing rules at every phase:** every new write tool repeats the no-Epic guard + confirm gate; typed I/O over natural-language handoffs; subagent instructions keep "NEVER respond to the user directly"; every new agent = a governance/registry approval.

---

## 7. Open items / decisions still needed

1. **KB-3 content** — area paths, iteration paths, tags, naming, Epic owner. *(Blocking — you author.)*
2. **Service account vs PAT** — recommend a managed service account; if PAT, name the rotation owner and expiry policy.
3. **Valid-value source for Area/Iteration** — start with KB-3 (static), graduate to a `Get_Project_Metadata` flow if paths change often.
4. **`RequestedBy` field** — tag/description line only, or also a queryable custom field?
5. **Large-tree timeout** — confirm the worst-case tree fits the 100s synchronous response; define behavior if not (chunked create / continuation).
6. **`[PROJECT]` and `[ORG: contact]`** — resolve at deployment.
7. **Update + comments in v1 or 1.5?** — **Resolved (v1.2): in v1.** `Update_Work_Item` (§4.7.1) and `Add_Comment` (§4.7.2) are part of the v1 build.
8. **Field reference names & custom fields** — confirm every §4.11 reference name against the process template, identify which are custom (Release/Deploy/Feature-flag notes, possibly Team), confirm `ValueArea` picklist values, and confirm Story Points/Effort exposure on Feature. Record all in KB-3.
9. **User Story & Task field catalogs** — **Resolved (v1.3):** User Story = Feature field set; Task = Title + Description only (§4.11.1, §4.11.2). Still confirm reference names/custom fields per §7.8.
10. **Epic write policy** — current default: Epics are **fully read-only** (no edit, no comment). Confirm this is correct, or decide whether the agent may *comment on* (but still never create/retype) Epics. The constraint you stated was only "never create Epics"; this extends it conservatively to all Epic writes.

---

## 8. Traceability

| Decision | Source |
|---|---|
| Connector-via-flows, keyed-JSON outputs, "Don't respond" completion, flow design rules | Instruction-Formats-Deep-Dive Part 2 |
| ≤1,500-char instructions, component model, purpose-first/out-last placement | Description-and-Instructions-Guide Part 3; Formats Deep-Dive Part 1 |
| Child-agent required inputs = free deterministic elicitation; node-level 8,000-char budget; "never respond directly" | Formats Deep-Dive Part 4; Description-and-Instructions-Guide Part 3 |
| `Allow ungrounded responses = ON` to keep clarifying questions alive | Formats Deep-Dive Part 4 (the #1 silent failure) |
| Adaptive Card (ColumnSet) preview because Teams renders no Markdown tables | Formats Deep-Dive Part 4 (channel rendering) |
| ≤25 knowledge sources, `.docx`/SharePoint, one-topic-per-doc, Enhanced search ON | Knowledge-Preparation-Guide |
| Tool-surface enforcement of hard rules; layered guardrails; evolution triggers | Path-Finder-Agent-Architecture (precedent) |

*Review this architecture when ADO conventions change, at every phase transition, and whenever the Copilot Studio orchestration model is upgraded.*
