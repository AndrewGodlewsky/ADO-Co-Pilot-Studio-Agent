# ADO Backlog Agent — Build & Implementation Plan

> **For builders:** This implements `ADO-Backlog-Agent-Architecture.md` (v1.5). It is a **Copilot Studio + Power Automate** build, not a code repo. Tasks use checkbox (`- [ ]`) syntax for tracking. Work the phases in order — later phases depend on earlier artifacts. The deployment-canonical Description, Instructions, child-agent instructions, and inputs live in `ADO-Backlog-Agent-CopilotStudio-Setup.md` — paste from there. The knowledge base is the multi-document set under `knowledge/` (see `ADO-Backlog-Agent-Knowledge-Plan.md` / `-Knowledge-Acquisition-Plan.md`). Parent-aware elicitation (Gate 0) is specified in `ADO-Backlog-Agent-Parent-Aware-Elicitation-Design.md`.

**Goal:** Stand up a Copilot Studio agent that lets the Power Platform team find, create, update, and comment on Azure DevOps work items (Features, User Stories, Tasks — never Epics) through a quality-gated, confirm-before-write conversation.

**Architecture:** A single generative-orchestration agent with **three** read flows, three write flows, one child agent (the quality interviewer), and five topics. All Azure DevOps access runs through Power Automate agent flows on a single service-account connection (Approach A). Hard rules (no Epic writes, confirm-before-write) are enforced by tool surface + server-side validation, not by prompt text.

**Tech stack:** Microsoft Copilot Studio (generative orchestration) · Power Automate agent flows · Azure DevOps connector + "Send an HTTP request to Azure DevOps" (REST, api-version 7.1) · SharePoint document library (`.docx` knowledge) · Microsoft Entra ID (user auth) · Adaptive Cards (Teams previews) · a Power Platform **solution** for ALM.

---

## Verification model in this stack (read first)

There is no pytest. Each task's "test" is one of these, and you do it **before** building (define the expected result) and **after** (confirm it):

| Code-TDD concept | This build's equivalent |
|---|---|
| Write a failing test | Write the **expected behavior**: a flow test input + expected output, or a test-pane utterance + expected agent response |
| Run test, see it fail | Run the flow/utterance against the not-yet-built or partial artifact; confirm it does **not** yet behave |
| Implement minimal | Build the flow action / agent setting / topic node with the **exact** config given |
| Run test, see it pass | Re-run the same flow test / utterance; confirm the **exact expected output** |
| Commit | **Save** the artifact and **add it to the `ADO Backlog Agent` solution**; **Publish** the agent/flow where the change must go live |

**Golden rule:** never wire a flow into the agent until that flow passes its own Power Automate test run in isolation. Never test the agent's create path until every write flow rejects Epics in isolation.

---

## Artifact map (what gets built, and its one responsibility)

| Artifact | Type | Responsibility |
|---|---|---|
| `ADO Backlog Agent` | Solution | ALM container for everything below |
| KB-1 Work-Item Quality (6 single-topic .docx, incl. KB-1.6 elicitation playbook) | SharePoint docs | Quality rubric + parent-aware elicitation the agent cites |
| KB-2 Leveling & Hierarchy (4 single-topic .docx) | SharePoint docs | Epic/Feature/Story/Task definitions + right-sizing |
| KB-3 Team Conventions (6 team-authored .docx) | SharePoint docs | This team's area/iteration/tags/field policy (blocking) |
| KB-4 Using This Agent (optional, 1 .docx) | SharePoint doc | Plain-language FAQ backing Topic T3 |
| `Search_Work_Items` | Agent flow | Read: query backlog + duplicate check |
| `Get_Work_Item_Details` | Agent flow | Read: one item's full fields + links |
| `Create_Backlog_Tree` | Agent flow | Write: build & link a Feature→Story→Task tree, reject Epics |
| `Update_Work_Item` | Agent flow | Write: field edits on an existing non-Epic item |
| `Add_Comment` | Agent flow | Write: post a discussion comment on a non-Epic item |
| `Backlog_Builder` | Child agent | The 3-gate quality interview → `TreeJson` + preview |
| ADO Backlog Agent | Copilot Studio agent | Orchestrator: settings, description, instructions, topics, knowledge |
| Topics T1–T5 | Agent topics | Greeting, Epic-stop, Help, Confirm/Diff, Fallback |
| `WorkItemPreview` / `WorkItemDiff` | Adaptive Cards | Teams-safe create preview + edit diff |
| Agent Evaluation test set | Copilot Studio eval | Regression baseline across all behaviors |

---

## Phase 0 — Prerequisites & solution scaffold

### Task 0.1: Confirm environment access & gather config values
**Artifacts:** none (gather inputs the later tasks need)

- [ ] **Step 1 — Confirm you have:** Copilot Studio author rights in the target Power Platform environment; Power Automate maker rights; an Azure DevOps org + the single target **project name**; rights to create a SharePoint document library.
- [ ] **Step 2 — Record these values** in a scratch note (used verbatim later):
  - `ADO_ORG` = the Azure DevOps organization name
  - `ADO_PROJECT` = the single target project name
  - `[ORG: contact]` = the support/escalation contact string for fallback messages
- [ ] **Step 3 — Verify** the tenant has Microsoft 365 Copilot (required for the 200 MB / Work IQ knowledge path). Confirm in the Copilot Studio environment that "Enhanced search results" is available.
- [ ] **Step 4 — Checkpoint:** none (no artifact yet).

### Task 0.2: Create the ALM solution
**Artifacts:** Create solution `ADO Backlog Agent`

- [ ] **Step 1 — Expected:** a solution exists that will contain the agent, 5 flows, and connection references.
- [ ] **Step 2 — Build:** In Power Apps maker portal → Solutions → **New solution** → Name `ADO Backlog Agent`, set a publisher with a recognizable prefix.
- [ ] **Step 3 — Verify:** the empty solution opens and shows 0 objects.
- [ ] **Step 4 — Checkpoint:** solution saved. All subsequent artifacts are created **inside** this solution.

---

## Phase 1 — Knowledge base

> KB-1, KB-2, and KB-4 are **pre-authored** as single-topic `.md` under `knowledge/` and converted to `.docx` in `knowledge/dist/` — you upload them, you don't re-author them here (see `ADO-Backlog-Agent-Knowledge-Plan.md`). KB-3 is the one team-specific source, filled from the templates + `_INTERVIEW.md` under `knowledge/KB-3-Team-Conventions/`. Format rules (from the Knowledge-Preparation-Guide): `.docx`, one topic per doc, clear H1/H2, answer-first, under ~36,000 chars.

### Task 1.1: Create the SharePoint library
**Artifacts:** Create SharePoint document library `ADO-Backlog-Agent-Knowledge`

- [ ] **Step 1 — Expected:** a SharePoint document library with four folders: `KB-1`, `KB-2`, `KB-3`, and (optional) `KB-4`.
- [ ] **Step 2 — Build:** Create the library; add the folders.
- [ ] **Step 3 — Verify:** all folders open and are empty.
- [ ] **Step 4 — Checkpoint:** record the library URL (Phase 6 needs it).

### Task 1.2: Upload the pre-authored knowledge docs
**Artifacts:** Upload KB-1, KB-2, and KB-4 `.docx` into their SharePoint folders

> The KB-1, KB-2, and KB-4 docs are already authored as single-topic `.md` files under `knowledge/` and converted to `.docx` in `knowledge/dist/`. Do not re-author them inline here — run `knowledge/convert-to-docx.ps1` to regenerate the `.docx` set if the source `.md` changes.

- [ ] **Step 1 — Expected:** each pre-authored `.docx` lives in its matching SharePoint folder (KB-1 docs → `KB-1`, KB-2 docs → `KB-2`, KB-4 doc → `KB-4`).
- [ ] **Step 2 — Build:** if needed, run `knowledge/convert-to-docx.ps1` to (re)produce `knowledge/dist/`. Upload each `.docx` from `knowledge/dist/` into its matching SharePoint folder — KB-1 set into the `KB-1` folder, KB-2 set into `KB-2`, the optional KB-4 doc into `KB-4`.
- [ ] **Step 3 — Verify:** the expected files are present in each folder. (Retrieval/grounding is checked end-to-end in Phase 6.)
- [ ] **Step 4 — Checkpoint:** all KB-1/KB-2/KB-4 docs uploaded and present in their folders.

### Task 1.3: Author KB-3 — Team Conventions (team-authored from the interview)
**Artifacts:** Create the KB-3 `.docx` set from the templates under `knowledge/KB-3-Team-Conventions/`

> KB-3 is the one genuinely team-specific source and a **blocking dependency** for correct right-sizing and field placement. It is pre-templated: `knowledge/KB-3-Team-Conventions/` holds 6 single-topic templates plus `_INTERVIEW.md`.

- [ ] **Step 1 — Expected:** the 6 KB-3 templates filled with this team's real conventions and converted to `.docx`.
- [ ] **Step 2 — Build:** the builder fills `knowledge/KB-3-Team-Conventions/_INTERVIEW.md`, which populates the 6 templates (`3.1-area-paths.md` … `3.6-ownership-and-escalation.md`); then run `knowledge/convert-to-docx.ps1` to produce the KB-3 `.docx` set.
- [ ] **Step 3 — Verify:** no placeholders remain; every custom field reference name is filled (these feed the catalog confirmations and the write flows).
- [ ] **Step 4 — Checkpoint:** upload the KB-3 `.docx` set to the `KB-3` folder. **Record the confirmed reference names** — Phase 4 write flows use them verbatim.

---

## Phase 2 — Identity & Azure DevOps connection

### Task 2.1: Provision the service identity
**Artifacts:** service account + ADO access (no Power Platform artifact yet)

- [ ] **Step 1 — Expected:** a single identity with **Work Items: Read & Write** on `ADO_PROJECT` only.
- [ ] **Step 2 — Build:** create/designate a service account; grant it Contributor on the project's work items (least privilege — no project admin). If a PAT must be used instead, create a PAT scoped to **Work Items (Read & Write)**, set an expiry, and **assign a named rotation owner**.
- [ ] **Step 3 — Verify:** sign in as the service account (or use the PAT in a REST call) and `GET https://dev.azure.com/{ADO_ORG}/{ADO_PROJECT}/_apis/wit/fields?api-version=7.1` returns 200.
- [ ] **Step 4 — Checkpoint:** record the rotation owner + expiry in KB-3 ownership section.

### Task 2.2: Create the ADO connection reference in the solution
**Artifacts:** Create connection reference `ADO Service Connection` in the `ADO Backlog Agent` solution

- [ ] **Step 1 — Expected:** a reusable Azure DevOps connection authenticated as the service account, usable by all flows.
- [ ] **Step 2 — Build:** In the solution → New → More → Connection reference → Azure DevOps → authenticate as the service account. DLP-classify the Azure DevOps connector per org policy.
- [ ] **Step 3 — Verify:** the connection reference shows "Connected".
- [ ] **Step 4 — Checkpoint:** connection reference saved in the solution.

---

## Phase 3 — Read flows

### Task 3.1: Build `Search_Work_Items`
**Artifacts:** Create agent flow `Search_Work_Items` (in solution)

- [ ] **Step 1 — Expected behavior (the test):** given input `SearchText="password reset"`, `WorkItemType="User Story"`, the flow returns `Items[]` of matching stories in `ADO_PROJECT`, each with `{Id, Type, Title, State, AreaPath, IterationPath, Parent, Url}`.
- [ ] **Step 2 — Build trigger & inputs:** Trigger **"When an agent calls the flow"**. Add text inputs: `SearchText`, `WorkItemType`, `AreaPath`, `State`, and number `MaxResults`.
- [ ] **Step 3 — Build the WIQL query (Compose action `wiqlQuery`):** build this string, appending the optional clauses only when the matching input is non-empty:

```
SELECT [System.Id],[System.WorkItemType],[System.Title],[System.State],[System.AreaPath],[System.IterationPath],[System.Parent]
FROM workitems
WHERE [System.TeamProject] = '@{outputs('Compose_project')}'
AND [System.Title] CONTAINS '@{triggerBody()?['SearchText']}'
-- append when WorkItemType not empty and not 'Any':  AND [System.WorkItemType] = '<type>'
-- append when AreaPath not empty:                    AND [System.AreaPath] UNDER '<area>'
-- append when State not empty:                       AND [System.State] = '<state>'
ORDER BY [System.ChangedDate] DESC
```

- [ ] **Step 4 — Run WIQL:** action **"Send an HTTP request to Azure DevOps"** → `POST {ADO_ORG}/{ADO_PROJECT}/_apis/wit/wiql?api-version=7.1`, body `{ "query": @{outputs('wiqlQuery')} }`. This returns `workItems:[{id,url}]`.
- [ ] **Step 5 — Batch-fetch fields:** take up to `MaxResults` ids; action **"Send an HTTP request to Azure DevOps"** → `POST .../_apis/wit/workitemsbatch?api-version=7.1` with `{ "ids":[...], "fields":["System.Id","System.WorkItemType","System.Title","System.State","System.AreaPath","System.IterationPath","System.Parent"] }`.
- [ ] **Step 6 — Shape output:** **Select** action mapping each result to `{Id, Type, Title, State, AreaPath, IterationPath, Parent, Url}`. Add **"Respond to the agent"** with a single output `Items` (array). Keyed object, never a bare array.
- [ ] **Step 7 — Test (run it):** Power Automate → Test → manual → enter `SearchText="password"`, others blank, `MaxResults=10`. **Expected:** run succeeds; `Items` contains matching items with all 8 keys populated.
- [ ] **Step 8 — Description:** set the flow/tool description exactly: *"Finds existing Azure DevOps work items in [ADO_PROJECT] by text, type, area path, state, or assignee. Use to browse the backlog, locate a parent, or check for duplicates before creating. Returns Epics, Features, Stories, and Tasks. Does not create or change items."*
- [ ] **Step 9 — Checkpoint:** Save; ensure it's in the solution; mark "completion = Don't respond" when later added to the agent.

### Task 3.2: Build `Get_Work_Item_Details`
**Artifacts:** Create agent flow `Get_Work_Item_Details` (in solution)

- [ ] **Step 1 — Expected:** given `WorkItemId=1234`, returns full fields + parent + children + Url.
- [ ] **Step 2 — Build:** Trigger "When an agent calls the flow"; input number `WorkItemId`. Action "Send an HTTP request to Azure DevOps" → `GET .../_apis/wit/workitems/@{triggerBody()?['WorkItemId']}?$expand=relations&api-version=7.1`.
- [ ] **Step 3 — Shape output:** map fields to `{Id, Type, Title, Description, AcceptanceCriteria, State, AreaPath, IterationPath, AssignedTo, Parent, Children[], Url}` (derive Parent/Children from `relations` by link type). "Respond to the agent" with those keys.
- [ ] **Step 4 — Test:** run with a real `WorkItemId`. **Expected:** all keys populated; `Children[]` lists child links when present.
- [ ] **Step 5 — Description:** *"Returns the full details of one Azure DevOps work item by ID — all fields plus parent and child links. Use when the user references a specific item or to inspect a candidate parent. Read-only."*
- [ ] **Step 6 — Checkpoint:** Save into the solution.

### Task 3.3: Build `List_Assigned_Work_Items`
**Artifacts:** Create agent flow `List_Assigned_Work_Items` (in solution)

- [ ] **Step 1 — Expected behavior (the test):** given `Assignee="<a real UPN with active items>"`, the flow returns `Items[]` (each `{Id, Type, Title, State, Priority, IterationPath, AreaPath, AssignedTo, Url}`), plus `ResolvedAssignee` and `Count`, excluding Closed/Done/Removed.
- [ ] **Step 2 — Build:** see `ADO-Backlog-Agent-Assigned-Items-Build-Plan.md` Phase B (Task B1) for the full WIQL + connector steps. Filter on `[System.AssignedTo] = @Assignee` (literal UPN, never `@me`); state filter unless `IncludeClosed`; optional `WorkItemType`; `ORDER BY Priority ASC, ChangedDate DESC`; cap at `MaxResults`.
- [ ] **Step 3 — Verify:** run the Task B4 verification matrix (self / named other / empty / IncludeClosed / type filter / cap / @me regression / bad name).
- [ ] **Step 4 — Checkpoint:** Publish the flow.

---

## Phase 4 — Write flows (each rejects Epics in isolation before it is ever wired to the agent)

### Task 4.1: Build `Create_Backlog_Tree`
**Artifacts:** Create agent flow `Create_Backlog_Tree` (in solution)

- [ ] **Step 1 — Expected behavior (3 tests):**
  - (a) Input tree = 1 Feature with 2 child Stories, each Story with 1 Task → returns `Created[]` with 5 items, each child's parent link set, each with real `Id` + `Url`.
  - (b) Input tree containing a node `Type="Epic"` → that node appears in `Rejected[]` with a reason and **is not created**; valid siblings still create.
  - (c) Every created item carries the tag `requested-by:<UPN>`.
- [ ] **Step 2 — Build trigger & input:** Trigger "When an agent calls the flow"; input text `TreeJson` (the agent passes the structured tree as JSON string) and text `RequestedByUpn`.
- [ ] **Step 3 — Parse:** **Parse JSON** action on `TreeJson` with this schema (array of nodes): `{TempId, Type, Title, AreaPath, IterationPath, ParentTempId, ParentExistingId, Tags, Fields}` where `Fields` is an object keyed by ADO reference name.
- [ ] **Step 4 — Init state:** Initialize array variable `Created = []`, array variable `Rejected = []`, array variable `IdMap = []` (entries `{TempId, Url}`).
- [ ] **Step 5 — Epic guard (pre-pass):** **Filter array** on parsed nodes where `Type == "Epic"`; **Apply to each** match → append `{TempId, Reason:"Epic creation is not allowed"}` to `Rejected`. Remove Epic nodes from the working set (Filter where `Type != "Epic"`).
- [ ] **Step 6 — Pass 1 (Features):** Filter working set where `Type == "Feature"`. Apply to each: call the **create helper** (Step 9) with parent resolved from `ParentExistingId` only (Features may parent to an existing Epic by URL, never create one); append result to `Created` and `{TempId, Url}` to `IdMap`.
- [ ] **Step 7 — Pass 2 (User Stories):** Filter where `Type == "User Story"`. Apply to each: resolve parent URL — if `ParentExistingId` set, build its URL; else look up `ParentTempId` in `IdMap` (Filter array). Call create helper; append to `Created`/`IdMap`.
- [ ] **Step 8 — Pass 3 (Tasks):** Filter where `Type == "Task"`. Resolve parent from `IdMap`/`ParentExistingId`. For Tasks, send only `System.Title` + `System.Description` from `Fields`. Call create helper; append to `Created`.
- [ ] **Step 9 — Create helper (the HTTP call used by passes 1–3):** "Send an HTTP request to Azure DevOps" → `POST .../_apis/wit/workitems/$@{item()?['Type']}?api-version=7.1`, header `Content-Type: application/json-patch+json`, body = a JSON-Patch array built from: every `Fields` entry as `{op:add, path:/fields/<refName>, value:<v>}`; `System.Title`, `System.AreaPath`, `System.IterationPath`; the audit tag `{op:add, path:/fields/System.Tags, value: "requested-by:@{triggerBody()?['RequestedByUpn']}"}`; and, when a parent URL exists, `{op:add, path:/relations/-, value:{rel:"System.LinkTypes.Hierarchy-Reverse", url:"<parentUrl>"}}`. Capture response `id` and `url`.
- [ ] **Step 10 — Respond:** "Respond to the agent" with `Created` (array of `{TempId, Id, Type, Title, Url}`), `Rejected` (array of `{TempId, Reason}`), and a `Summary` string.
- [ ] **Step 11 — Test (a):** run with the 1-Feature/2-Story/2-Task tree JSON. **Expected:** `Created` has 5 entries; in ADO the Stories' parent = the Feature, the Tasks' parent = their Story.
- [ ] **Step 12 — Test (b):** run with a tree containing an Epic node. **Expected:** Epic in `Rejected`, nothing of type Epic created, siblings created.
- [ ] **Step 13 — Test (c):** open any created item in ADO. **Expected:** tag `requested-by:<the UPN you passed>` present.
- [ ] **Step 14 — Description:** *"Creates the confirmed work items in Azure DevOps from a structured tree, links parents to children, and returns the new IDs and URLs. Creates only Features, Stories, and Tasks. Call only after the user confirms the preview."*
- [ ] **Step 15 — Checkpoint:** Save into the solution.

### Task 4.2: Build `Update_Work_Item`
**Artifacts:** Create agent flow `Update_Work_Item` (in solution)

- [ ] **Step 1 — Expected (2 tests):** (a) `WorkItemId` of a Story + `Fields={"Microsoft.VSTS.Common.Priority":2}` → priority becomes 2, returns `Updated`. (b) `WorkItemId` of an **Epic** → returns `Rejected{Reason:"Epics are read-only"}`, nothing changes.
- [ ] **Step 2 — Build trigger & inputs:** "When an agent calls the flow"; inputs number `WorkItemId`, text `FieldsJson` (object keyed by ref name), text `RequestedByUpn`, optional `AreaPath`, `IterationPath`.
- [ ] **Step 3 — Epic guard:** "Send an HTTP request to Azure DevOps" → `GET .../workitems/{WorkItemId}?fields=System.WorkItemType`. **Condition:** if type == "Epic" → "Respond to the agent" with `Rejected{Id, Reason:"Epics are read-only"}` and **terminate**.
- [ ] **Step 4 — Reject retype:** Parse `FieldsJson`; **Condition:** if it contains `System.WorkItemType == "Epic"` → respond `Rejected{Reason:"Cannot retype to Epic"}` and terminate.
- [ ] **Step 5 — Patch:** build a JSON-Patch array from each `Fields` entry + optional area/iteration + append audit note to `System.History` (`requested-by:<UPN>`). `PATCH .../workitems/{WorkItemId}?api-version=7.1`, `Content-Type: application/json-patch+json`.
- [ ] **Step 6 — Respond:** "Respond to the agent" with `Updated{Id, Type, Title, ChangedFields[], Url}`.
- [ ] **Step 7 — Test (a) and (b):** run both. **Expected:** (a) field changed in ADO; (b) Epic untouched, `Rejected` returned.
- [ ] **Step 8 — Description:** *"Updates fields on one existing Azure DevOps work item — Feature, User Story, or Task — by ID. Cannot edit Epics. Call only after the user confirms the diff."*
- [ ] **Step 9 — Checkpoint:** Save into the solution.

### Task 4.3: Build `Add_Comment`
**Artifacts:** Create agent flow `Add_Comment` (in solution)

- [ ] **Step 1 — Expected (2 tests):** (a) `WorkItemId` of a Task + `CommentText="Blocked on API key"` → comment appears in the item's Discussion. (b) `WorkItemId` of an Epic → `Rejected`, no comment.
- [ ] **Step 2 — Build:** "When an agent calls the flow"; inputs number `WorkItemId`, text `CommentText`, text `RequestedByUpn`.
- [ ] **Step 3 — Epic guard:** same GET-type + Condition as Task 4.2 Step 3; reject Epics.
- [ ] **Step 4 — Post comment:** "Send an HTTP request to Azure DevOps" → `POST .../workItems/{WorkItemId}/comments?api-version=7.1-preview.3`, body `{ "text": "requested-by:@{...UPN}\n@{...CommentText}" }`.
- [ ] **Step 5 — Respond:** "Respond to the agent" with `{CommentId, Id, Url}` or `Rejected{Id, Reason}`.
- [ ] **Step 6 — Test (a) and (b):** **Expected:** (a) comment visible in Discussion; (b) Epic rejected.
- [ ] **Step 7 — Description:** *"Adds a discussion comment to one existing Feature, User Story, or Task by ID. Cannot comment on Epics. Call only after the user confirms."*
- [ ] **Step 8 — Checkpoint:** Save into the solution.

---

## Phase 5 — Agent shell

### Task 5.1: Create the agent and apply settings
**Artifacts:** Create Copilot Studio agent `ADO Backlog Agent` (in solution)

- [ ] **Step 1 — Expected:** an agent whose settings match §4.1 of the spec exactly — especially **Allow ungrounded responses = ON** and **Entra ID auth**.
- [ ] **Step 2 — Build:** create the agent inside the solution. Set: Orchestration = **Generative**; Model = **Auto**; **Allow ungrounded responses = ON** (this single toggle governs general-knowledge use — there is no separate general-knowledge off switch; keep it ON so clarifying questions survive); Web search = OFF; **Enhanced search / Work IQ = ON**; Authentication = **Microsoft Entra ID**; Content moderation = High.
- [ ] **Step 3 — Verify (the ungrounded test):** in the test pane, ask a deliberately under-specified create request ("make a story"). **Expected:** the agent asks a clarifying question rather than returning the generic fallback. (If it falls back, ungrounded responses is still OFF — fix before proceeding.)
- [ ] **Step 4 — Checkpoint:** Publish; confirm in solution.

### Task 5.2: Set description and instructions
**Artifacts:** Modify agent `ADO Backlog Agent` (description + instructions)

- [ ] **Step 1 — Expected:** description and instructions match spec §4.2/§4.3 with `[PROJECT]`/`[ORG: contact]` resolved.
- [ ] **Step 2 — Build description:** Paste the agent **Description** from **CopilotStudio-Setup §2** (current, expanded — covers find/create/update/comment, ~640 chars). Resolve `[ADO_PROJECT]`.
- [ ] **Step 3 — Build instructions:** Paste the agent **Instructions** from **CopilotStudio-Setup §3** (current, expanded — includes the create-path **parent-grounding** step, the read/create/edit path split, and the Rules block). Resolve `[ADO_PROJECT]`/`[ORG: contact]`, then re-bind each `/Tool` via the `/` picker.
- [ ] **Step 4 — Verify:** instruction character count is ~3,676 (the expanded Setup §3 text) — well under the 8,000-char limit. Test pane: "what can you do?" → response reflects find + create + update, never offers Epic creation.
- [ ] **Step 5 — Checkpoint:** Publish.

---

## Phase 6 — Wire knowledge + read tools

### Task 6.1: Add the knowledge sources (KB-1, KB-2, KB-3, + optional KB-4)
**Artifacts:** Modify agent — add KB-1, KB-2, KB-3, and (optional) KB-4 SharePoint sources

- [ ] **Step 1 — Expected:** three required knowledge sources (plus the optional KB-4 FAQ, if you uploaded it), each with the §4.9 description; Enhanced search ON.
- [ ] **Step 2 — Build:** add each SharePoint folder as a knowledge source with these descriptions: KB-1 "World-class title/description/acceptance-criteria standards; INVEST; Definition of Ready; Given/When/Then examples."; KB-2 "Epic/Feature/Story/Task definitions; too-big/too-small signals; the Feature→Story→Task rule."; KB-3 "[ADO_PROJECT] area paths, iteration paths, tags, required-field policy, requested-by convention, Epic owner, naming standards."; and (optional) KB-4 "Plain-language FAQ — what the agent can and can't do, how to phrase requests, and what fields it asks for; backs Topic T3 (Help)."
- [ ] **Step 3 — Verify retrieval:** test pane → "what makes a good acceptance criterion?" cites KB-1; "what's the difference between a feature and an epic?" cites KB-2; "what area paths do we use?" cites KB-3.
- [ ] **Step 4 — Checkpoint:** Publish.

### Task 6.2: Add the read tools
**Artifacts:** Modify agent — add `Search_Work_Items`, `Get_Work_Item_Details` as tools

- [ ] **Step 1 — Expected:** agent can search and fetch items; both tools set to "Don't respond" so the agent folds results into its answer.
- [ ] **Step 2 — Build:** add both flows as tools; confirm each tool's description matches Phase 3; set completion behavior **Don't respond**.
- [ ] **Step 3 — Verify:** test pane → "find stories about login in our backlog" → agent calls `Search_Work_Items`, lists results with IDs/links. "Show me details of 1234" → calls `Get_Work_Item_Details`.
- [ ] **Step 4 — Checkpoint:** Publish.
- [ ] **Step 5 — Add `List_Assigned_Work_Items`:** add the flow as a tool; paste its description from Setup; set completion behavior **Send specific response** (NOT "Don't respond"); add the orchestrator instruction line. Verify in the test pane: "show me my work items" → agent calls the tool and renders a grouped list.

---

## Phase 7 — `Backlog_Builder` child agent (the quality engine)

### Task 7.1: Create the child agent with required inputs
**Artifacts:** Create child agent `Backlog_Builder` (in solution)

- [ ] **Step 1 — Expected:** a child agent that collects the per-type required fields (spec §3.4) via required inputs with validation + 2 reprompts, and cannot finish without them.
- [ ] **Step 2 — Build description:** *"Interviews the user to assemble one or more well-formed Features, User Stories, and Tasks — right-sizing the type, enforcing required fields, and checking quality — then produces a preview and the structured create payload. Use whenever the user wants to create work items. Never use for read-only questions."*
- [ ] **Step 3 — Build required inputs:** add inputs covering the §4.11 at-create fields. For Feature/User Story: `Title`, `Description`, `AcceptanceCriteria`, `ValueArea`, `Team`, `AreaPath` (required); `StoryPoints`, `Priority`, `Risk`, `Effort`, `Iteration` (optional). For Task: `Title`, `Description` (required) + parent reference. Mark required ones `Should-prompt-user ON`, add custom prompt wording, **validation conditions** (e.g., AcceptanceCriteria non-empty), 2 reprompts. Also add the **`ParentContext`** input (orchestrator-filled, *Should prompt user = OFF*) exactly as in **CopilotStudio-Setup §6.3** — it carries the parent's scope, acceptance criteria, inheritable fields, and existing children for Gate 0.
- [ ] **Step 4 — Verify (Gate 2):** test pane → "create a story for password reset" with no other detail → agent asks, one at a time, for the missing required fields; cannot finish until they're supplied.
- [ ] **Step 5 — Checkpoint:** Publish.

### Task 7.2: Author the child agent's node instructions (Gates 1 & 3 + output contract)
**Artifacts:** Modify `Backlog_Builder` instructions (its own 8,000-char budget)

- [ ] **Step 1 — Expected:** the child agent right-sizes (Gate 1), pushes back on weak fields (Gate 3), asks one question at a time, never emits an Epic, and outputs `TreeJson` + `PreviewMarkdown`.
- [ ] **Step 2 — Build instructions:** Paste the `Backlog_Builder` **Instructions** from **CopilotStudio-Setup §6.4** — the current version adds **Gate 0 (parent grounding)**, the inherit-don't-re-ask rule, the per-scenario parent-aware question banks, and the alignment/sibling checks, on top of Gates 1 & 3 and the output contract.
- [ ] **Step 3 — Verify (Gate 0):** supply a parent Feature → the agent inherits area/iteration/value area and asks which slice of the Feature this delivers.
- [ ] **Step 4 — Verify (Gate 1):** "add a task to redesign onboarding" → agent proposes a User Story (or Feature) and explains why. "create an epic for billing" → stops, offers a Feature.
- [ ] **Step 5 — Verify (Gate 3):** supply title "fix login" and AC "it works" → agent pushes back and rewrites both before producing the preview.
- [ ] **Step 6 — Checkpoint:** Publish.

### Task 7.3: Add `Backlog_Builder` to the orchestrator + dup-check wiring
**Artifacts:** Modify agent — add child agent; confirm dup-check instruction

- [ ] **Step 1 — Expected:** orchestrator hands create requests to `Backlog_Builder`, and runs `Search_Work_Items` for duplicates before previewing.
- [ ] **Step 2 — Build:** add `Backlog_Builder` as a connected child agent. Confirm instruction step 3 ("Before previewing a create, always run /Search_Work_Items to check duplicates") references the exact tool.
- [ ] **Step 3 — Build (Gate 0):** Ensure the orchestrator runs **Gate 0** before handoff: on a create request it asks for the parent, calls `/Get_Work_Item_Details` (plus `/Search_Work_Items` for the parent's children), and passes the assembled `ParentContext` into `/Backlog_Builder`.
- [ ] **Step 4 — Verify:** "create a story for password reset" → agent runs the interview, then a dup search, surfacing any near-duplicate. (Preview rendering comes in Phase 8.)
- [ ] **Step 5 — Checkpoint:** Publish.

---

## Phase 8 — Topics + Adaptive Card preview/diff

### Task 8.1: Author T1 Greeting, T2 Epic-stop, T3 Help, T5 Fallback
**Artifacts:** Create/modify topics T1, T2, T3, T5

- [ ] **Step 1 — Expected:** four deterministic topics per spec §4.8.
- [ ] **Step 2 — Build T1 (Greeting, trigger = conversation start):** message describing find/create/update; starters: "Find my Stories in area X", "Create a Feature with some Stories", "What's under Feature 1234?", "Check if a Story already exists for…".
- [ ] **Step 3 — Build T2 (Epic-stop, trigger description = "user asks to create, add, edit, or comment on an Epic"):** authored message: "I create and edit Features, Stories, and Tasks — not Epics, which are read-only here. I can create a Feature under an existing Epic; which Epic is it?" No LLM, no tool.
- [ ] **Step 4 — Build T3 (Help):** trigger "user asks how to phrase a request or what makes a good work item"; brief guidance, pulls KB on demand.
- [ ] **Step 5 — Build T5 (Fallback, System topic):** edit message: "I help find, create, and update Azure DevOps work items. For anything else, [ORG: contact]. Could you rephrase?"
- [ ] **Step 6 — Verify:** "create an epic" → T2 fires deterministically (no tool call). New conversation → T1 greeting shows.
- [ ] **Step 7 — Checkpoint:** Publish.

### Task 8.2: Build the Adaptive Cards (create preview + edit diff)
**Artifacts:** Create Adaptive Card payloads `WorkItemPreview`, `WorkItemDiff`

- [ ] **Step 1 — Expected:** Teams-safe cards (ColumnSet, no Markdown tables): create-preview renders the tree with warning flags + duplicate notices; diff renders old→new per changed field.
- [ ] **Step 2 — Build `WorkItemPreview`:** a card with a `Container` per node showing Type, Title, and key fields in `ColumnSet`/`FactSet`; a warning `TextBlock` (attention color) for any below-bar field; a "Possible duplicates" section bound to `Search_Work_Items` results; **Confirm** and **Cancel** `Action.Submit` buttons.
- [ ] **Step 3 — Build `WorkItemDiff`:** a `FactSet`/`ColumnSet` per changed field with two columns "Current" and "New"; Confirm/Cancel buttons.
- [ ] **Step 4 — Verify:** render each card in the test pane with sample data. **Expected:** renders cleanly (no raw Markdown); buttons present.
- [ ] **Step 5 — Checkpoint:** save card JSON in the solution.

### Task 8.3: Build T4 Confirm-or-Cancel (the write gate)
**Artifacts:** Create topic T4 wiring the cards to the write flows

- [ ] **Step 1 — Expected:** after `Backlog_Builder` returns (create) OR the edit path assembles a change set, T4 shows the right card; **Confirm** calls the matching write flow; **Cancel** discards. Nothing writes before Confirm.
- [ ] **Step 2 — Build (create branch):** when `Backlog_Builder` output exists → render `WorkItemPreview` from `TreeJson`+dup results → on Confirm, call `/Create_Backlog_Tree` passing `TreeJson` and the user's Entra UPN as `RequestedByUpn` → report `Created[]` IDs/URLs + any `Rejected[]`.
- [ ] **Step 3 — Build (edit branch):** when a change set exists → render `WorkItemDiff` → on Confirm, call `/Update_Work_Item` or `/Add_Comment` with the UPN → report result.
- [ ] **Step 4 — Verify (full create path):** "create a feature 'self-service password reset' with two stories" → interview → dup check → preview card → Confirm → items appear in ADO with parent links + `requested-by` tag; agent returns clickable URLs.
- [ ] **Step 5 — Verify (cancel):** repeat and click **Cancel** → nothing is created in ADO.
- [ ] **Step 6 — Checkpoint:** Publish.

---

## Phase 9 — Edit path wiring

### Task 9.1: Wire the edit/comment flow into the orchestrator
**Artifacts:** Modify agent — add `Update_Work_Item`, `Add_Comment`; confirm edit-path instructions

- [ ] **Step 1 — Expected:** orchestrator handles "change/edit/add note" requests: reads the item, gathers only changed fields, quality-checks edited quality-bearing fields, shows the diff (T4 edit branch), writes on Confirm. Epics are refused.
- [ ] **Step 2 — Build:** add both write flows as tools (descriptions per Phase 4); confirm instruction step 4 references `/Update_Work_Item` and `/Add_Comment`; ensure the orchestrator runs `Get_Work_Item_Details` first.
- [ ] **Step 3 — Verify (field edit):** "set priority to 2 on 1234 and add release notes 'shipped in 2.3'" → reads item → diff card (Current→New for Priority and Release notes) → Confirm → fields updated in ADO.
- [ ] **Step 4 — Verify (quality on edit):** "change the acceptance criteria of 1234 to 'it works'" → Gate-3 pushback before the diff.
- [ ] **Step 5 — Verify (comment):** "add a comment to 1234: blocked on API key" → diff/preview → Confirm → comment in Discussion.
- [ ] **Step 6 — Verify (Epic refusal):** "edit epic 999 description" and "comment on epic 999" → both refused (T2 / server reject); ADO unchanged.
- [ ] **Step 7 — Checkpoint:** Publish.

---

## Phase 10 — Evaluation baseline

### Task 10.1: Build the Agent Evaluation test set
**Artifacts:** Create Copilot Studio evaluation set (spec §5.1)

- [ ] **Step 1 — Expected:** a saved test set covering every behavior, runnable before/after any description or instruction change.
- [ ] **Step 2 — Build cases:**
  - Parent-aware (Gate 0): create a Story without naming a parent → agent asks for the Feature, reads it, confirms inherited fields, asks the slice; Feature-under-Epic; wrong-level parent (Epic named for a Story) → offers the in-between Feature; sibling-duplicate flagged; sparse parent (no AC) → asks rather than fabricates; inherited-field override reflected.
  - Right-sizing (Gate 1): task-that's-a-story; story-that's-a-feature; epic-sized request.
  - Completeness (Gate 2): missing acceptance criteria; missing parent; missing area path.
  - Quality (Gate 3): vague title; untestable AC; missing "so that".
  - Epic-stop: "create an epic"; "edit epic"; "comment on epic" → all refused.
  - Duplicate detection: near-duplicate title already present → surfaced in preview.
  - Read queries: by text; by type; by area; single-item by ID with children.
  - Edit path: field change → diff → update; edit AC → Gate-3; add comment; set release/deploy/feature-flag notes.
  - Out-of-scope: delete request; non-ADO request → graceful redirect.
- [ ] **Step 3 — Verify:** run the set; record the baseline pass rate. Investigate any wrong-source answers via the **activity map** ("sources searched but not used" → fix descriptions, not prompts).
- [ ] **Step 4 — Checkpoint:** save the test set; treat instruction edits as code — re-run before/after each change.

---

## Phase 11 — Pilot, governance, publish

### Task 11.1: Set guardrails and publish to a pilot group
**Artifacts:** Modify agent — credit cap, channel, governance

- [ ] **Step 1 — Expected:** a monthly credit cap in PPAC; Teams channel enabled; agent registered/approved per org governance.
- [ ] **Step 2 — Build:** set a per-agent monthly credit cap (PPAC); enable the Teams channel; complete the org's agent registration/approval; export the solution as a backup.
- [ ] **Step 3 — Verify:** a pilot user in Teams can find, create (with preview/confirm), update, and comment; cannot create/edit/comment on Epics; sees `requested-by` stamps on created items.
- [ ] **Step 4 — Checkpoint:** review the activity map + analytics after the pilot; then publish org-wide.

---

## Self-review — spec coverage

| Spec section | Covered by |
|---|---|
| §2.3 decisions (connector-via-flows, service account, confirm-before-create, single project, quality template, multi-level, warn-and-allow, update-in-v1) | Phases 2–9 |
| §3.3 no-Epic guarantee (4 layers) | 4.1/4.2/4.3 (server), 5.2 (instruction), 8.1 T2 (topic), tool surface (no Epic tool exists) |
| §3.4 quality engine (Gates 1–3) | 7.1 (Gate 2), 7.2 (Gates 1 & 3) |
| §3.4 Gate 0 / parent-aware elicitation (ParentContext) | 5.2 (instructions via Setup §3), 7.1 (ParentContext input), 7.2 (Gate 0 in child instructions), 7.3 (orchestrator Gate 0), 10.1 (eval) |
| §4.1 settings (esp. ungrounded ON, Entra) | 5.1 (with the ungrounded test) |
| §4.2/§4.3 description/instructions | 5.2 |
| §4.4–4.7.2 the six flows | 3.1, 3.2, 3.3, 4.1, 4.2, 4.3 |
| §4.8 topics + T4 cards | 8.1, 8.2, 8.3 |
| §4.9 knowledge | 1.2 (upload pre-authored), 1.3 (KB-3), 6.1 (wire) |
| §4.10 identity/audit/credits/ALM | 2.1, 2.2, 4.x (stamp), 11.1 (cap), 0.2 (solution) |
| §4.11 field catalogs | 7.1 (required inputs), 4.1 (create payload), 4.2 (update) |
| §5.1 evaluation | 10.1 |
| §7 open items | 0.1, 1.3, 2.1 capture the confirmations (reference names, rotation owner); §7.10 Epic-write policy currently implemented as fully read-only |

**Note on the one external dependency:** KB-3 (Task 1.3) and the §7.8 reference-name confirmations are team-supplied. Until KB-3 is authored, Phases 6–9 will function but right-sizing/placement quality and custom-field writes (Release/Deploy/Feature-flag notes) are degraded — KB-3 is the gating input for those.
