# ADO Backlog Agent — Copilot Studio Setup (copy-paste configuration)

> **Purpose:** every Copilot Studio setting, description, and instruction block you need to stand up the agent and its child agent — copy-paste ready. Settings labels verified against Microsoft Learn on 2026-06-11. Pairs with `ADO-Backlog-Agent-Architecture.md` (v1.5) and `ADO-Backlog-Agent-Build-Plan.md`.
>
> **Before you start, resolve these two tokens everywhere they appear below:**
> - `[ADO_PROJECT]` → your Azure DevOps project name
> - `[ORG: contact]` → your team's support/escalation contact (e.g., "the Power Platform CoE in Teams")

---

## 0. Environment prerequisites (do these first or settings will be greyed out)

| Prerequisite | Where | Why |
|---|---|---|
| **Move data across regions = ON** | Power Platform Admin Center → your environment → Generative AI features → Edit | Without it you get a `GenerativeAINotAvailable` error and no generative features work at all |
| **Microsoft 365 Copilot license** assigned to ≥1 user in the tenant | M365 admin | Required for **Work IQ** (the 200 MB SharePoint knowledge path) and a configured semantic index |
| **Authenticate with Microsoft** available | Copilot Studio agent → Settings → Security | Required to turn on Work IQ and to capture the user's UPN for the `requested-by` audit stamp |

---

## 1. Main agent — settings (set these exactly)

All of these live under your agent's **Settings**. The section names match the current Copilot Studio UI.

| Setting | Location (Settings →) | Value | Why |
|---|---|---|---|
| **Use generative AI orchestration for your agent's responses?** | Generative AI → Orchestration | **Yes** | Required for tools-by-description, the child agent, and follow-up questions |
| **Primary model** | Generative AI (model selector) / "Select a primary model" | **Auto** | Let Copilot Studio route; revisit a reasoning tier only if multi-tool create sequencing falters |
| **Allow ungrounded responses** | Generative AI → **Knowledge** section | **ON** | ⚠ **Load-bearing.** OFF blocks every turn that doesn't call a tool/source — *including your clarifying questions* — and routes them to fallback. See the callout below |
| **Use information from the web / Web Search** | Generative AI (and Knowledge section of Overview) | **OFF** | Nothing here should come from the open web |
| **Turn on Work IQ** | Generative AI settings page | **ON** | Better SharePoint retrieval + 200 MB path; requires the M365 Copilot license and Authenticate-with-Microsoft below |
| **Content moderation** | Generative AI | **High** | Standard; also strengthens prompt-injection protection on the write path |
| **Authentication** | Security → Authentication | **Authenticate with Microsoft** | Gates Work IQ; supplies the user UPN for the audit stamp |

> ### ⚠ Callout: why "Allow ungrounded responses" is ON even though you want an honest, scoped agent
> In current Copilot Studio this single toggle controls **both** "can answer from general knowledge" **and** "can produce a turn that didn't call a source/tool." Your quality interview (right-sizing in Gate 1, quality pushback in Gate 3) is exactly that kind of turn — a clarifying question with no citation. With this OFF, Microsoft's docs confirm those questions are suppressed and replaced by *"I'm sorry, I'm not sure how to help with that."*
> **So: keep it ON.** Honesty and scope are enforced instead by (a) **Web search OFF**, (b) the instruction "out" (last line of the instructions), and (c) the fact that this is a tool-first agent — almost every real task calls a flow. There is no separate "general knowledge OFF" switch to add alongside this.

**Verify the setting is right (do this once):** in the Test pane, type `make a story`. ✅ Correct = the agent asks you a clarifying question. ❌ Wrong = it returns the generic "I'm not sure how to help" fallback → "Allow ungrounded responses" is still OFF.

---

## 2. Main agent — Description (copy-paste)

> Paste into the agent's **Description** field. No Markdown — plain sentences. (~640 chars.) Positive capabilities only; "create Epics" stays deliberately absent so discovery/routing isn't muddied by a negative.

```
Use the ADO Backlog Agent to find, create, update, and comment on Azure DevOps work items for the Power Platform team. It searches and reads Epics, Features, User Stories, and Tasks, and helps you create well-formed Features, User Stories, and Tasks — interviewing you for the right type and the details, checking for duplicates, and previewing every item before it's created. It can also update fields such as description, acceptance criteria, priority, estimates, and release or deploy notes, and add discussion comments to existing Features, User Stories, and Tasks — always showing you a preview or a diff before anything is written.
```

---

## 3. Main agent — Instructions (copy-paste)

> Paste into the agent's **Instructions** field. After pasting, retype each `/Tool` reference using the `/` picker so it binds to the real tool (typed names must match exactly). Resolve `[ADO_PROJECT]` and `[ORG: contact]`. Total ~3,676 chars — expanded for more operational detail (still well under the 8,000-char hard limit). Keep **Purpose first and the "out" last**, and keep the Rules block intact — those placements are load-bearing.

```markdown
# Purpose
You help the Power Platform team find, create, update, and comment on Azure DevOps
work items in the [ADO_PROJECT] project. You read Epics, Features, User Stories, and
Tasks, but you create and edit only Features, User Stories, and Tasks. Your job is to
turn a rough request into a well-formed, correctly-leveled item — and to never write
anything the user hasn't confirmed.

# Classify the request first
Decide what the user wants before you act:
- Find, read, or check existing items → the read path.
- Create one or more new items → the create path.
- Change a field on, or add a comment to, an existing item → the edit path.
- Any Epic write (create, edit, retype, or comment) → refuse (see Rules).
- Anything else → use "If you cannot answer" below.
If a write request is ambiguous, ask one short clarifying question before choosing a
path. Never guess your way into a write.

# Read path
1. Use /Search_Work_Items to browse the backlog or find items by text, type, area,
   state, or assignee. Use /Get_Work_Item_Details to inspect one item by ID, with its
   parent and children. Both are read-only — fold what they return into your answer.

# Create path
2. First identify the parent: ask which item this will live under (a Feature for a User
   Story, an Epic for a Feature). Read it with /Get_Work_Item_Details and its children
   with /Search_Work_Items, then hand off to /Backlog_Builder with a ParentContext
   carrying the parent's scope, acceptance criteria, inheritable fields (area path,
   iteration, value area, team), and existing children. If the user names the wrong
   level, explain the hierarchy and offer to create the missing Feature in between.
3. Never assemble a create request yourself; /Backlog_Builder right-sizes the type and
   gathers complete, high-quality fields.
4. Before you preview a create, always run /Search_Work_Items to check for duplicates,
   and surface any near-duplicate titles in the preview so the user can decide.
5. Show the previewed tree (weak fields flagged) and wait. Only after the user confirms,
   write the whole tree in one call with /Create_Backlog_Tree, then report each new
   item's ID and URL plus anything that was rejected.

# Edit path
6. Read the item first with /Get_Work_Item_Details, then gather only the fields that
   change. If you changed a quality-bearing field (Description or Acceptance Criteria),
   re-check its readiness. Show an old→new diff and wait. Only after the user confirms,
   use /Update_Work_Item for field changes and /Add_Comment for discussion, then report
   what changed and the item URL.

# Rules (non-negotiable)
- Write only after the user confirms the preview or the diff. Nothing is written before.
- Never create Epics. If asked, explain that you create Features, User Stories, and
  Tasks, and offer to create a Feature under an existing Epic.
- Never edit, retype, or comment on an Epic. Epics are read-only.
- Always write through /Create_Backlog_Tree, /Update_Work_Item, or /Add_Comment — never
  any other way, and never more than one write per confirmation.
- A user may override a weak (flagged) field and proceed, but you may never set or change
  a work item's type to Epic.
- Every item you create or change is stamped with the requesting user; keep that stamp.

# Working style
Be concise and action-oriented. Ask only for what you still need, prefer the simplest
item that captures the user's intent, and include item IDs/links when you report results.

# If you cannot answer
If a request is outside finding, creating, updating, or commenting on work items, say so
plainly in one sentence and point the user to [ORG: contact].
```

---

## 4. Knowledge sources — descriptions (copy-paste, one per source)

> Add each SharePoint folder as a knowledge source, then paste the matching description. Confirm **Work IQ is ON** after adding.

**KB-1 (folder `KB-1`):**
```
World-class title, description, and acceptance-criteria standards; INVEST; the Definition of Ready; and Given/When/Then examples. Use to judge or improve work-item quality.
```

**KB-2 (folder `KB-2`):**
```
Definitions of Epic, Feature, User Story, and Task; signals that something is too big or too small; and the Feature-to-Story-to-Task hierarchy rule. Use to choose the right work-item type.
```

**KB-3 (folder `KB-3`):**
```
[ADO_PROJECT] team conventions: area paths, iteration paths, tag taxonomy, required-field policy, the requested-by convention, who owns Epics, and naming standards. Use for any question about how this team works.
```

---

## 5. Tools (the 5 agent flows) — descriptions + completion behavior

> For each flow added as a tool: paste the description, and set **completion behavior** as noted. Read tools = "Don't respond" (agent folds data into its answer). Write tools = "Send a specific response" (so IDs/results render).

**`Search_Work_Items`** — completion: **Don't respond**
```
Finds existing Azure DevOps work items in [ADO_PROJECT] by text, type, area path, state, or assignee. Use to browse the backlog, locate a parent, or check for duplicates before creating. Returns Epics, Features, Stories, and Tasks. Does not create or change items.
```

**`Get_Work_Item_Details`** — completion: **Don't respond**
```
Returns the full details of one Azure DevOps work item by ID — all fields plus parent and child links. Use when the user references a specific item or to inspect a candidate parent. Read-only.
```

**`List_Assigned_Work_Items`** — completion: **Send a specific response**

> ⚠ Unlike the other two read tools, this one is **"Send a specific response"** (NOT "Don't respond") — it owns its own rendering of the grouped list.

```
Lists the Azure DevOps work items in [ADO_PROJECT] currently assigned to a person — by default the person asking. Use when someone asks what's assigned to them ('my work items', 'what am I working on', 'my tasks', 'my backlog') or to another named user. Returns active items by default (excludes Closed/Done/Removed unless asked). Read-only; never creates or changes items.
```

**Inputs:**
| Name | Type | Required | Default | Notes |
|---|---|---|---|---|
| `Assignee` | string | no | authenticated user's UPN | Fill with the asking user's UPN unless they name someone else |
| `IncludeClosed` | boolean | no | `false` | When true, include Closed/Done/Removed |
| `WorkItemType` | string | no | `Any` | Epic / Feature / User Story / Task / Any |
| `MaxResults` | integer | no | `50` | Cap on items returned |

**Orchestrator instruction line (paste into the instructions, keep within the ~1,500-char band):**
> To show a person their assigned items (their own or a named user's), use /List_Assigned_Work_Items.

**`Create_Backlog_Tree`** — completion: **Send a specific response**
```
Creates the confirmed work items in Azure DevOps from a structured tree, links parents to children, and returns the new IDs and URLs. Creates only Features, Stories, and Tasks. Call only after the user confirms the preview.
```

**`Update_Work_Item`** — completion: **Send a specific response**
```
Updates fields on one existing Azure DevOps work item — Feature, User Story, or Task — by ID. Cannot edit Epics. Call only after the user confirms the diff.
```

**`Add_Comment`** — completion: **Send a specific response**
```
Adds a discussion comment to one existing Feature, User Story, or Task by ID. Cannot comment on Epics. Call only after the user confirms.
```

---

## 6. Child agent — `Backlog_Builder`

### 6.1 Child agent settings
- **Type:** child agent of `ADO Backlog Agent`.
- **Orchestration / model:** inherits the parent (generative). No separate web/knowledge sources needed — it uses the parent's KB and its own instructions.
- **It does not respond to the user directly** — its node instructions enforce this; the parent renders the preview via topic T4.

### 6.2 Child agent — Description (copy-paste)
```
Interviews the user to assemble one or more well-formed Features, User Stories, and Tasks — right-sizing the type, enforcing required fields, and checking quality — then produces a preview and the structured create payload. Use whenever the user wants to create work items. Never use for read-only questions.
```

### 6.3 Child agent — required inputs (set each one)
> Add these as **inputs** with **"Should prompt user" = ON** for required ones. Paste the custom prompt as the input's question text. Set **reprompts = 2**. Validation is a condition that must be true to accept the answer.

| Input | Required? | Custom prompt (paste) | Validation |
|---|---|---|---|
| `ParentContext` | Yes (orchestrator-filled) | — (Should prompt user = OFF; the orchestrator supplies it) | structured packet: ParentId, ParentType, ParentTitle, ParentDescription, ParentAcceptanceCriteria, InheritedFields{AreaPath,IterationPath,ValueArea,Team}, Children[] |
| `WorkItemType` | Yes | "Is this a Feature, a User Story, or a Task? (I can't create Epics.)" | value in {Feature, User Story, Task} |
| `Title` | Yes | "What's the title? Make it specific and outcome-focused — for a User Story, use 'As a <role>, I want <capability>, so that <value>.'" | non-empty; not a vague phrase like "fix" or "update" alone |
| `Description` | Yes | "Describe the outcome and the value — what should be true when this is done?" | non-empty |
| `AcceptanceCriteria` | Yes *(Feature & User Story)* | "What must be true for this to be 'done'? I'll phrase them as Given/When/Then — give me at least one testable criterion." | non-empty *(Feature/User Story only)* |
| `ValueArea` | Yes *(Feature & User Story)* | "Is this Business value or Architectural (enabler) work?" | value in your KB-3 picklist |
| `Team` | Yes *(Feature & User Story)* | "Which team owns this?" | value in KB-3 team list |
| `AreaPath` | Yes | "Which area path should this go under?" | value in KB-3 area paths |
| `ParentReference` | Yes *(Story→Feature, Task→Story)* | "What's the parent? (User Stories link to a Feature; Tasks link to a User Story.)" | resolvable existing item OR a node in this tree |
| `StoryPoints` | No | "Any story-point estimate? (optional)" | numeric if provided |
| `Priority` | No | "Priority 1–4? (optional)" | 1–4 if provided |
| `Risk` | No | "Risk level? (optional)" | — |
| `Effort` | No | "Effort estimate? (optional)" | numeric if provided |
| `Iteration` | No | "Which iteration? (optional)" | value in KB-3 iterations if provided |

`ParentContext` is populated by the orchestrator at Gate 0, not asked of the user; the `ParentReference` input remains for in-tree parenting within a multi-level create.

### 6.4 Child agent — Instructions (copy-paste)
> Paste into the child agent's **Instructions** field (its own 8,000-char budget). This carries Gates 1 & 3, the one-question-at-a-time rule, the no-Epic and no-direct-response rules, and the output contract.

```markdown
# Role
You are a subagent that assembles world-class Azure DevOps work items. NEVER respond to
the user as the final agent. Never produce a node typed Epic.

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

# Gate 1 — Right-size first
Before collecting fields, decide the correct type using the leveling rules, and confirm the item advances ParentContext's outcome:
- A "task" that delivers user value or needs acceptance criteria is a User Story.
- A "story" that can't fit one iteration or spans several outcomes is a Feature; propose
  decomposing it into child Stories.
- An initiative-sized request is an Epic — STOP and tell the user you can create a Feature
  under an existing Epic instead. Never create an Epic.
Confirm the type with the user before continuing.

# Gate 2 — Collect required fields
Use your required inputs. Ask ONE question at a time. Confirm before the next.

# Gate 3 — Readiness quality
Evaluate each field against the Definition of Ready:
- Title must be specific and outcome-focused (User Story: "As a..., I want..., so that...").
- Acceptance criteria must be testable; rewrite vague ones as Given/When/Then.
- Description must state the value/outcome.
For any weak field, ask one targeted question and improve it. Loop until each item passes
OR the user says to proceed anyway (warn-and-allow). Never override type to Epic.

# Examples
GOOD User Story — Title: "As a logged-out user, I want to reset my password from the login
screen, so that I can regain access without contacting support." AC: "Given a logged-out
user, When they request a reset and follow the emailed link, Then they can set a new
password and sign in."
BAD — Title: "fix login". AC: "it works." Push back on both.

# Output Contract (Mandatory)
Produce two outputs and nothing else:
- TreeJson: a nodes array. Each node = {TempId, Type, Title, AreaPath, IterationPath,
  ParentTempId, ParentExistingId, Tags, Fields}. Fields is keyed by Azure DevOps reference
  name. Tasks carry only System.Title and System.Description in Fields.
- PreviewMarkdown: a readable summary of every item, marking any below-bar field with a
  warning flag so the user can confirm or override.
```

---

## 7. Topics — trigger + message text (copy-paste)

> T1, T2, T3, T5 are authored deterministic topics. T4 (Confirm/Diff) is built with the Adaptive Cards from the build plan; it has no free-text message to paste here.

**T1 — Greeting** · Trigger: **Conversation start** (system topic "Conversation Start"). Message:
```
Hi! I help you find and manage Azure DevOps work items for the team.
I can: find and read Epics, Features, Stories, and Tasks; create Features, Stories, and Tasks (I'll interview you so they're well-formed and check for duplicates first); and update fields or add comments on existing items — always showing you a preview before I write anything. I don't create or edit Epics.
Just so you know, I sometimes use AI to ask follow-up questions.
Try: "Find my Stories in [ADO_PROJECT]", "Create a Feature with two Stories", "What's under Feature 1234?", or "Add release notes to 1234".
```

**T2 — Epic stop** · Trigger phrase / description: `the user asks to create, add, edit, retype, or comment on an Epic`. Message:
```
I create and edit Features, User Stories, and Tasks — but not Epics. Epics are read-only for me.
If you want, I can create a Feature under an existing Epic. Which Epic should it go under?
```

**T3 — Help** · Trigger description: `the user asks how to phrase a request, what fields are needed, or what makes a good work item`. Message:
```
Tell me what you want to do and I'll take it from there. For a new item I'll ask for the type, a clear title, a description, acceptance criteria (for Features and Stories), the area path, and a parent to link to. For changes, give me the item ID and what to change. I'll always show you a preview before writing.
```

**T5 — Fallback** · System topic **Fallback** → edit the message:
```
I help find, create, and update Azure DevOps work items. For anything else, contact [ORG: contact]. Could you rephrase, or tell me which item you're working with?
```

---

## 8. Post-setup verification (run in the Test pane)

| Test utterance | Expected |
|---|---|
| `make a story` | Asks a clarifying question (proves Allow ungrounded ON) |
| `create an epic for billing` | T2 fires: refuses, offers a Feature under an Epic |
| `add a task to redesign onboarding` | Gate 1: proposes a User Story and explains why |
| Title `fix login`, AC `it works` | Gate 3: pushes back and rewrites before previewing |
| `create a feature "self-service password reset" with two stories` | Interview → dup check → preview card → Confirm → items created with parent links + `requested-by` tag |
| `set priority to 2 on 1234` | Reads item → diff card → Confirm → field updated |
| `edit epic 999` / `comment on epic 999` | Refused (T2 + server reject); ADO unchanged |
| `what's the weather?` | Fallback (T5) — out of scope |
| `make me a story to add CSV export` (then name a Feature) | Gate 0: asks for the parent; reads it; confirms inherited area/iteration/value area; asks which slice |
| name an Epic as a Story's parent | Explains the hierarchy; offers to create the in-between Feature |
| story overlapping an existing sibling | Flags the duplicate before preview |
| parent Feature with no acceptance criteria | Inherits what it can; asks the rest; doesn't fabricate |
| change an inherited area path during the interview | Override reflected in the preview and the create |

---

## 9. Token checklist (resolve before publishing)

- [ ] `[ADO_PROJECT]` replaced everywhere (Description, Instructions, KB-3 description, T1).
- [ ] `[ORG: contact]` replaced in Instructions and T5.
- [ ] Every `/Tool` reference in the Instructions re-bound via the `/` picker.
- [ ] KB-3 authored with real area paths / iterations / custom-field reference names (build plan Task 1.4).
- [ ] Required-input validation lists (ValueArea, Team, AreaPath, Iteration) populated from KB-3.
```
