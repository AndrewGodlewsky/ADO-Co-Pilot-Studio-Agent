# Assigned-Items Listing — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let a user ask the agent to list the Azure DevOps work items assigned to them (or to a named teammate) via one new read-only Power Automate flow, `List_Assigned_Work_Items`.

**Architecture:** A new dedicated read flow filters work items by the end user's UPN (threaded from the authenticated chat session, never `@me`) and returns them as keyed JSON; the orchestrator renders a list grouped by state then priority. The flow sits alongside `Search_Work_Items` and `Get_Work_Item_Details` and is the one read tool whose completion behavior is **"Send specific response."** No write path, no Epic guardrails, no new topic.

**Tech stack:** Microsoft Copilot Studio (generative orchestration) · Power Automate agent flow · Azure DevOps "Send an HTTP request to Azure DevOps" (REST WIQL, api-version 7.1) · service-account connection · Microsoft Entra ID (authenticated user UPN) · the existing Power Platform solution for ALM.

**Source spec:** `ADO-Backlog-Agent-Assigned-Items-Design.md` (v1.0).

**Two-phase shape:**
- **Phase A — repo edits** (done in this workspace): update the design/config/KB docs so the portal build has copy-paste material and the specs stay consistent. These produce no running behavior on their own.
- **Phase B — portal build** (done in Copilot Studio / Power Automate, using Phase A's output): build the flow, wire the tool, confirm identity, run the verification matrix.

Do Phase A first — Phase B tasks paste from the docs Phase A writes.

---

## Phase A — Repository edits

### Task A1: Add the tool spec to the Architecture

**Files:**
- Modify: `ADO-Backlog-Agent-Architecture.md` (add a new read-tool subsection after §4.5 `Get_Work_Item_Details`; update §2.1 scope; update the §3.1 component-diagram tool list; bump version + changelog header line)

- [ ] **Step 1 — Add the tool subsection.** Immediately after the §4.5 `Get_Work_Item_Details` table, insert a new subsection `### 4.5b Tool: List_Assigned_Work_Items (read — assigned items)` with this table:

```markdown
### 4.5b Tool: `List_Assigned_Work_Items` (read — assigned items)

| Aspect | Spec |
|---|---|
| Description | "Lists the Azure DevOps work items in [PROJECT] currently assigned to a person — by default the person asking. Use when someone asks what's assigned to them ('my work items', 'what am I working on', 'my tasks', 'my backlog') or to another named user. Returns active items by default (excludes Closed/Done/Removed unless asked). Read-only; never creates or changes items." |
| Inputs | `Assignee` (optional UPN/email; **default = authenticated user UPN**), `IncludeClosed` (bool, default false), `WorkItemType` (Epic/Feature/User Story/Task/Any, default Any), `MaxResults` (default 50) |
| Outputs (keyed JSON) | `Items[]` → `{Id, Type, Title, State, Priority, IterationPath, AreaPath, AssignedTo, Url}` · `ResolvedAssignee` · `Count` |
| Flow internals | WIQL filtered on `[System.AssignedTo] = @assignee` (literal end-user UPN, **never `@me`**); excludes terminal states unless `IncludeClosed`; optional type filter; `ORDER BY Priority ASC, ChangedDate DESC`; expand IDs→fields; service-account connection; async OFF, respond <100s; published |
| Identity | Orchestrator fills `Assignee` from the authenticated user's UPN system variable unless the user names someone else |
| After running | **Send specific response** — agent renders the grouped list (by State, then Priority). Different from `Search_Work_Items`' "Don't respond" rule. |
```

- [ ] **Step 2 — Update §2.1 scope.** In §2.1 "What the agent will do", append a bullet under the Read line:

```markdown
- **List a person's assigned items** — the asking user's own active items by default, or a named teammate's, via `List_Assigned_Work_Items` (read-only).
```

- [ ] **Step 3 — Update the §3.1 component diagram.** In the TOOLS list inside the ASCII component diagram, add a line under `/Get_Work_Item_Details`:

```
│  │     /List_Assigned_Work_Items ─ read: items assigned to a user (self     │
│  │                                 by default, or a named teammate)         │
```

- [ ] **Step 4 — Bump version + changelog.** In the header line, change the version to **v1.6** and prepend a changelog clause:

```
**v1.6 change:** added `List_Assigned_Work_Items` (§4.5b) — a third read tool that lists the items assigned to the asking user (or a named teammate); see `ADO-Backlog-Agent-Assigned-Items-Design.md`
```

- [ ] **Step 5 — Verify (consistency check).** Re-read §2.1, §3.1, and §4.5b. Confirm: the tool name is spelled identically in all three places; the diagram lists three read tools; the version header reads v1.6 with the new changelog clause. No other section contradicts (search the file for "two read flows" / "read flows" and confirm none now under-count — note any for Task A3).

- [ ] **Step 6 — Commit.**

```bash
git add ADO-Backlog-Agent-Architecture.md
git commit -m "Architecture v1.6: add List_Assigned_Work_Items read tool"
```

---

### Task A2: Add copy-paste config to the Setup doc

**Files:**
- Modify: `ADO-Backlog-Agent-CopilotStudio-Setup.md` (add a paste block for the new tool's Description, Inputs, the orchestrator instruction line, and the flow build notes — mirror how `Search_Work_Items` is presented there)

- [ ] **Step 1 — Locate the read-tools section.** Find where `Search_Work_Items` / `Get_Work_Item_Details` copy-paste descriptions live. Add a sibling block for `List_Assigned_Work_Items`.

- [ ] **Step 2 — Add the paste block.** Insert:

````markdown
#### Tool: `List_Assigned_Work_Items` (read)

**Tool description (paste):**
> Lists the Azure DevOps work items in [PROJECT] currently assigned to a person — by default the person asking. Use when someone asks what's assigned to them ("my work items", "what am I working on", "my tasks", "my backlog") or to another named user. Returns active items by default (excludes Closed/Done/Removed unless asked). Read-only; never creates or changes items.

**Inputs:**
| Name | Type | Required | Default | Notes |
|---|---|---|---|---|
| `Assignee` | string | no | authenticated user's UPN | Fill with the asking user's UPN unless they name someone else |
| `IncludeClosed` | boolean | no | `false` | When true, include Closed/Done/Removed |
| `WorkItemType` | string | no | `Any` | Epic / Feature / User Story / Task / Any |
| `MaxResults` | integer | no | `50` | Cap on items returned |

**Completion behavior:** **Send specific response** (NOT "Don't respond" — this tool owns its rendering).

**Orchestrator instruction line (paste into the instructions, keep within the ~1,500-char band):**
> To show a person their assigned items (their own or a named user's), use /List_Assigned_Work_Items.
````

- [ ] **Step 3 — Verify.** Confirm the description text is byte-identical to Architecture §4.5b Step 1, and the completion behavior explicitly says "Send specific response."

- [ ] **Step 4 — Commit.**

```bash
git add ADO-Backlog-Agent-CopilotStudio-Setup.md
git commit -m "Setup: copy-paste config for List_Assigned_Work_Items"
```

---

### Task A3: Add the build task to the main Build-Plan

**Files:**
- Modify: `ADO-Backlog-Agent-Build-Plan.md` (add a new read-flow task in Phase 3; add a tool-wiring step in Phase 6; correct any "two read flows" counts to three)

- [ ] **Step 1 — Correct the architecture summary.** In the top "**Architecture:**" line, change "two read flows, three write flows" to "**three** read flows, three write flows."

- [ ] **Step 2 — Add the flow build task.** After `Task 3.2` (the last read-flow task in Phase 3), add:

````markdown
### Task 3.3: Build `List_Assigned_Work_Items`
**Artifacts:** Create agent flow `List_Assigned_Work_Items` (in solution)

- [ ] **Step 1 — Expected behavior (the test):** given `Assignee="<a real UPN with active items>"`, the flow returns `Items[]` (each `{Id, Type, Title, State, Priority, IterationPath, AreaPath, AssignedTo, Url}`), plus `ResolvedAssignee` and `Count`, excluding Closed/Done/Removed.
- [ ] **Step 2 — Build:** see `ADO-Backlog-Agent-Assigned-Items-Build-Plan.md` Phase B (Task B1) for the full WIQL + connector steps. Filter on `[System.AssignedTo] = @Assignee` (literal UPN, never `@me`); state filter unless `IncludeClosed`; optional `WorkItemType`; `ORDER BY Priority ASC, ChangedDate DESC`; cap at `MaxResults`.
- [ ] **Step 3 — Verify:** run the Task B4 verification matrix (self / named other / empty / IncludeClosed / type filter / cap / @me regression / bad name).
- [ ] **Step 4 — Checkpoint:** Publish the flow.
````

- [ ] **Step 3 — Add the tool-wiring step.** In `Task 6.2: Add the two read tools`, rename it to "Add the read tools" and add a step:

```markdown
- [ ] **Step 5 — Add `List_Assigned_Work_Items`:** add the flow as a tool; paste its description from Setup; set completion behavior **Send specific response** (NOT "Don't respond"); add the orchestrator instruction line. Verify in the test pane: "show me my work items" → agent calls the tool and renders a grouped list.
```

- [ ] **Step 4 — Verify.** Re-read Phase 3 and Phase 6: the new flow task exists, the count says three read flows, and the wiring step specifies "Send specific response."

- [ ] **Step 5 — Commit.**

```bash
git add ADO-Backlog-Agent-Build-Plan.md
git commit -m "Build-Plan: add List_Assigned_Work_Items flow + tool wiring"
```

---

### Task A4: Update the KB-4 FAQ and re-export the .docx

**Files:**
- Modify: `knowledge/KB-4-Using-This-Agent/4.1-what-this-agent-can-and-cant-do.md`
- Regenerate: `knowledge/dist/KB-4 Using This Agent/4.1 What This Agent Can and Can't Do (FAQ).docx` (via `knowledge/convert-to-docx.ps1`)

- [ ] **Step 1 — Add a capability bullet.** In "## What it can do", after the "Find and read" bullet, add:

```markdown
- **List what's assigned to you** — ask "show me my work items" (or name a teammate, e.g. "what's assigned to jane@org.com?"). Shows active items by default, grouped by state; ask for closed items or a specific type to narrow.
```

- [ ] **Step 2 — Add phrasing examples.** Under "## How to phrase a request", add a line to the patterns list:

```markdown
- *My items:* "Show me my work items", "What am I working on?", "List my open tasks", "What's assigned to jane@org.com?"
```

- [ ] **Step 3 — Re-export the .docx.** Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\knowledge\convert-to-docx.ps1
```

Expected: console prints `OK   KB-4 Using This Agent\4.1 What This Agent Can and Can't Do (FAQ).docx` and a final `Converted N / N docs`. (Requires `pandoc` on PATH — if absent, install it or skip this step and note the `.docx` needs regeneration before SharePoint upload.)

- [ ] **Step 4 — Verify.** Confirm the `.md` shows both new entries and the `.docx` modified time just updated.

- [ ] **Step 5 — Commit.**

```bash
git add "knowledge/KB-4-Using-This-Agent/4.1-what-this-agent-can-and-cant-do.md" "knowledge/dist/KB-4 Using This Agent/"
git commit -m "KB-4 FAQ: document the assigned-items listing capability"
```

---

### Task A5: Add the terminal-states question to the KB-3 interview

**Files:**
- Modify: `knowledge/KB-3-Team-Conventions/_INTERVIEW.md` (§3.3)

- [ ] **Step 1 — Add the question.** In section "## 3.3 Field Reference & Picklists", add a bullet:

```markdown
- Which States count as "closed/done" and should be EXCLUDED by default from a person's "active assigned items" list? (e.g. Agile: Closed, Removed · Scrum: Done, Removed)
  (Find in ADO: Org Settings > Process > [your process] > [work item type] > States)
```

- [ ] **Step 2 — Verify.** Confirm the bullet renders under §3.3 and references where to find the states.

- [ ] **Step 3 — Commit.**

```bash
git add "knowledge/KB-3-Team-Conventions/_INTERVIEW.md"
git commit -m "KB-3 interview: ask for the terminal states to exclude by default"
```

---

### Task A6: Register the feature in the README

**Files:**
- Modify: `README.md` (document index + status map)

- [ ] **Step 1 — Add to the ADO document index table.** In the "🟢 ADO Backlog Agent" index table, add a row:

```markdown
| **`ADO-Backlog-Agent-Assigned-Items-Design.md`** *(v1.0)* | **Design spec — assigned-items listing.** The `List_Assigned_Work_Items` read tool: self-or-named-teammate scope, active-by-default state filtering, grouped presentation, and the `@me`/identity wiring. | You want the agent to list items assigned to a user. |
```

- [ ] **Step 2 — Note it in the status map.** Under the CAPABILITY area of the ASCII status map, add:

```
        └─ CAPABILITY ▸ Assigned-Items-Design ─► …-Build-Plan
                        ⏳ designed; portal build pending (3rd read tool)
```

- [ ] **Step 3 — Verify.** Confirm the new row and status line render and the tool name matches the other docs.

- [ ] **Step 4 — Commit.**

```bash
git add README.md
git commit -m "README: index the assigned-items listing design + build plan"
```

---

## Phase B — Copilot Studio / Power Automate build

> Performed in the portals, pasting from the Phase A docs. Each task ends by publishing so it's testable.

### Task B1: Build the `List_Assigned_Work_Items` agent flow

**Artifacts:** New Power Automate agent flow in the existing solution, on the service-account connection.

- [ ] **Step 1 — Expected behavior (the test):** trigger input `Assignee` = a real UPN that has active items → the flow returns `Items[]` with the §4.5b fields, `ResolvedAssignee` = that UPN, `Count` = the number of items, and **no** Closed/Done/Removed rows.

- [ ] **Step 2 — Create the flow + inputs.** New agent flow `List_Assigned_Work_Items` (clone `Search_Work_Items` to inherit the connection + response shape if convenient). Define trigger inputs: `Assignee` (text), `IncludeClosed` (boolean), `WorkItemType` (text), `MaxResults` (number).

- [ ] **Step 3 — Build the WIQL query.** Add a **"Send an HTTP request to Azure DevOps"** action (api-version 7.1), `POST {org}/{project}/_apis/wit/wiql?api-version=7.1`, body:

```json
{
  "query": "SELECT [System.Id] FROM workitems WHERE [System.TeamProject] = @project AND [System.AssignedTo] = '@{triggerBody()?['Assignee']}' @{if(equals(triggerBody()?['IncludeClosed'], true), '', 'AND [System.State] NOT IN (''Closed'',''Removed'',''Done'',''Resolved'')')} @{if(equals(triggerBody()?['WorkItemType'], 'Any'), '', concat('AND [System.WorkItemType] = ''', triggerBody()?['WorkItemType'], ''''))} ORDER BY [Microsoft.VSTS.Common.Priority] ASC, [System.ChangedDate] DESC"
}
```

> **Critical:** filter on the literal `Assignee` UPN string — do **not** use the WIQL `@me` macro (it resolves to the service-account PAT, returning the bot's items, not the user's). The default state-exclusion list (`Closed, Removed, Done, Resolved`) is provisional until KB-3 §3.3 confirms the process template's real terminal states.

- [ ] **Step 4 — Expand IDs to fields.** Take the WIQL response `workItems[].id`, cap at `MaxResults`, and batch-fetch fields via `GET {org}/_apis/wit/workitemsbatch?api-version=7.1` (or "Get work item details") requesting: `System.Id, System.WorkItemType, System.Title, System.State, Microsoft.VSTS.Common.Priority, System.IterationPath, System.AreaPath, System.AssignedTo`.

- [ ] **Step 5 — Shape the outputs.** Build `Items[]` = `{Id, Type, Title, State, Priority, IterationPath, AreaPath, AssignedTo, Url}` (Url = the item's `_links.html.href` or `{org}/{project}/_workitems/edit/{id}`). Set `ResolvedAssignee` = the `Assignee` input; `Count` = length of `Items`. Respond with these as the flow's keyed outputs; async OFF, respond <100s.

- [ ] **Step 6 — Verify (flow test pane):** run with a known UPN → returns that person's active items only; run with `IncludeClosed=true` → closed items appear; run with `WorkItemType="Task"` → only Tasks. Confirm a query with the **service account's own** UPN does NOT silently return for `@me`.

- [ ] **Step 7 — Checkpoint:** Publish the flow; add it to the solution.

---

### Task B2: Wire the tool into the agent

**Artifacts:** Modify the agent — add `List_Assigned_Work_Items` as a tool + the instruction line.

- [ ] **Step 1 — Expected:** in the test pane, "show me my work items" makes the agent call `List_Assigned_Work_Items` with the caller's UPN and render a grouped list.

- [ ] **Step 2 — Add the tool.** Add the published flow as a tool. Paste the **description** from `ADO-Backlog-Agent-CopilotStudio-Setup.md` (Task A2). Set completion behavior **Send specific response** (NOT "Don't respond").

- [ ] **Step 3 — Add the instruction line.** Add to the orchestrator instructions: *"To show a person their assigned items (their own or a named user's), use /List_Assigned_Work_Items."* Confirm the instructions stay within the ~1,500-character band (trim adjacent filler only if needed).

- [ ] **Step 4 — Verify.** Test pane: "show me my work items" → tool called, grouped list rendered (by state, then priority) with IDs + links. "what's assigned to <teammate UPN>?" → lists their items.

- [ ] **Step 5 — Checkpoint:** Publish the agent.

---

### Task B3: Confirm the identity (UPN) wiring

**Artifacts:** Modify the agent — bind the `Assignee` input to the authenticated user's UPN.

- [ ] **Step 1 — Expected:** when the user names no one, `Assignee` is populated with the asking user's UPN automatically (no prompt for their email).

- [ ] **Step 2 — Confirm the variable.** Identify the Copilot Studio system variable carrying the authenticated user's UPN (the same value backing the `requested-by` stamp — e.g. `System.User.PrincipalName`, or the authenticated `User.Email` from "Authenticate with Microsoft"). Bind it as the default for the tool's `Assignee` input.

- [ ] **Step 3 — Verify.** Test pane as an authenticated user: "show me my work items" (naming no one) → results are the *caller's* items, and the agent never asks for an email. Confirm it is the end user's UPN, not the service account's.

- [ ] **Step 4 — Checkpoint:** Publish.

---

### Task B4: Run the verification matrix

**Artifacts:** No build — acceptance test of the live feature (spec §10).

- [ ] **Step 1 — Run all eight scenarios** in the test pane (or a Teams test channel):

| # | Scenario | Expected |
|---|---|---|
| 1 | "show me my work items" (caller has items) | Caller's active items, grouped by state, sorted by priority; `ResolvedAssignee` = caller UPN |
| 2 | "what's assigned to <teammate UPN>?" | Teammate's active items; `ResolvedAssignee` = their UPN |
| 3 | Caller with no active items | Empty-state message, no error |
| 4 | "show me my closed items too" | Includes Closed/Done/Removed |
| 5 | "show me my tasks" | Only Tasks |
| 6 | Result count > `MaxResults` | First N + narrow-it-down hint |
| 7 | `@me` regression | Never resolves to the service account |
| 8 | Bare display name, no match | "try their email" message |

- [ ] **Step 2 — Record results** against each row; fix and re-publish on any failure, then re-run that row.

- [ ] **Step 3 — Checkpoint:** all eight pass → feature complete. Merge `feature/assigned-items-listing` (see the finishing-a-development-branch skill for merge/PR options).

---

## Self-review (coverage of the spec)

| Spec section | Covered by |
|---|---|
| §3 Tool spec | A1, A2, B1, B2 |
| §4 WIQL + `@me` trap | B1 (Steps 3, 6) |
| §4.2 KB-3 terminal states | A5, B1 (Step 3 note) |
| §5 Identity flow | B3 |
| §6 Presentation (grouped) | B2 (Step 4), B4 (#1) |
| §7 Instructions / no topic | A2, B2 (Step 3) |
| §8 Doc + KB updates | A1, A2, A3, A4, A5, A6 |
| §9 Scope guardrails | B1 (read-only WIQL, single project), B4 (#7, #8) |
| §10 Verification matrix | B4 |
| §11 Out of scope | (intentionally not built) |
