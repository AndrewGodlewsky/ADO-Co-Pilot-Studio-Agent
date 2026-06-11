# ADO Backlog Agent — Assigned-Items Listing Design

> **Version:** 1.0 · **Date:** 2026-06-11 · **Status:** For review
> **Pairs with:** `ADO-Backlog-Agent-Architecture.md` (v1.5 — adds a third read tool alongside §4.4 `Search_Work_Items` and §4.5 `Get_Work_Item_Details`; extends §2.1 scope) · `ADO-Backlog-Agent-CopilotStudio-Setup.md` (tool description, inputs, the orchestrator instruction line) · `ADO-Backlog-Agent-Build-Plan.md` (a new task under "Build read flows") · `knowledge/KB-4-Using-This-Agent/4.1` (FAQ entry) · `knowledge/KB-3-Team-Conventions/_INTERVIEW.md` (§3.3 — terminal-state list).

This spec adds the ability for a user to ask the agent **"show me the work items assigned to me"** — and, by extension, to a named teammate. It introduces one new read-only Power Automate agent flow, `List_Assigned_Work_Items`, that filters Azure DevOps work items by assignee and returns them grouped for display. It is a pure read feature: no write path, no Epic-creation concerns, no change to the existing quality/gate engine.

**Approach (chosen):** a **new dedicated flow** (Option A), built by cloning `Search_Work_Items` as a starting point. A dedicated tool keeps generative-orchestration routing crisp, carries its own output shape, and uses a "send specific response" post-run behavior distinct from Search's "don't respond / fold into answer." The existing `Search_Work_Items` and `Get_Work_Item_Details` flows are left untouched.

---

## 1. Design principles

1. **Identity is threaded explicitly, never assumed.** The query filters on the *end user's* UPN, sourced from the authenticated chat session — not the connection identity. WIQL's `@me` macro is deliberately **not** used (it would resolve to the service-account PAT).
2. **Default to self, allow named others.** With no qualifier, the agent lists the asking user's items. A named teammate is an optional override. Azure DevOps assignments are already team-visible, so exposing a teammate's queue introduces no new disclosure.
3. **Active by default, complete on request.** The unqualified result set is the user's *active/open* work — what's on their plate now. Closed/Done/Removed items are reachable only when explicitly asked for.
4. **Dedicated tool, dedicated job.** Listing-by-assignee is a different routing intent and a different output contract than browse/dup-check search; it gets its own flow rather than overloading `Search_Work_Items`.
5. **Read-only, no Epic special-casing.** Reading Epics is already permitted, so assigned Epics appear in results like any other type. No write guardrails apply.

---

## 2. End-to-end flow

```
User: "show me my work items"   (or "what's assigned to jane@org.com?")
  │
  ▼  Orchestrator classifies → READ / assigned-items path
┌─ Identity resolution (orchestrator) ───────────────────────────────┐
│ • No name given      → Assignee = authenticated user's UPN          │
│ • Named teammate     → Assignee = that person's UPN/email           │
└─────────────────────────────────────────────────────────────────────┘
  │
  ▼  Call /List_Assigned_Work_Items { Assignee, IncludeClosed, WorkItemType, MaxResults }
┌─ Flow (Power Automate, service-account connection) ─────────────────┐
│ • WIQL: filter [System.AssignedTo] = @assignee (literal UPN)        │
│ • Exclude terminal states unless IncludeClosed                       │
│ • Optional type filter; ORDER BY Priority ASC, ChangedDate DESC      │
│ • Expand IDs → fields; return keyed JSON                             │
└─────────────────────────────────────────────────────────────────────┘
  │
  ▼  Orchestrator renders a grouped list (by State, then Priority)
     and SENDS a specific response (empty / capped messages handled)
```

---

## 3. Tool: `List_Assigned_Work_Items` (read — assigned items)

| Aspect | Spec |
|---|---|
| **Description** (routing signal) | "Lists the Azure DevOps work items in [PROJECT] currently assigned to a person — by default the person asking. Use when someone asks what's assigned to them ('my work items', 'what am I working on', 'my tasks', 'my backlog') or to another named user. Returns active items by default (excludes Closed/Done/Removed unless asked). Read-only; never creates or changes items." |
| **Inputs** | `Assignee` (optional UPN/email — **default = the authenticated user's UPN**), `IncludeClosed` (boolean, default `false`), `WorkItemType` (Epic / Feature / User Story / Task / Any, default `Any`), `MaxResults` (integer, default `50`) |
| **Outputs (keyed JSON)** | `Items[]` → `{Id, Type, Title, State, Priority, IterationPath, AreaPath, AssignedTo, Url}` · `ResolvedAssignee` (the UPN actually queried) · `Count` |
| **Flow internals** | ADO connector WIQL query (see §4); service-account connection; expand returned IDs to fields; async OFF, respond <100s; published |
| **After running** | **Send specific response** — the agent renders the grouped list (see §6). This is intentionally different from `Search_Work_Items`' "don't respond" rule. |

---

## 4. Flow internals (WIQL)

```sql
SELECT [System.Id] FROM workitems
WHERE [System.TeamProject] = @project
  AND [System.AssignedTo]  = @assignee            -- literal end-user UPN, NOT @me
  -- when IncludeClosed = false:
  AND [System.State] NOT IN ('Closed', 'Removed', 'Done', 'Resolved')
  -- when WorkItemType <> Any:
  AND [System.WorkItemType] = @type
ORDER BY [Microsoft.VSTS.Common.Priority] ASC, [System.ChangedDate] DESC
```

Then expand the returned IDs (connector "Get work item details" / batch) to populate the output fields. Cap the expansion at `MaxResults`.

### 4.1 The `@me` trap (why this feature is non-trivial)

WIQL provides a built-in `@me` macro, but it resolves to **the connection's identity** — here the **service-account PAT**, not the end user. Using `@me` would return the bot's own assigned items. The flow must therefore receive and filter on the **end user's literal UPN string** passed in as `@assignee`. Threading that identity from the chat session into the query is the core of this design.

### 4.2 Terminal-state list (KB-3 dependency)

The default exclude-set (`Closed, Removed, Done, Resolved`) depends on the project's **process template** (Agile / Scrum / CMMI / custom). The authoritative list comes from **KB-3 §3.3**. Until KB-3 is confirmed, the flow ships with the default above and is tuned once the team supplies the real states. This adds one line to the KB-3 interview (§8).

---

## 5. Identity flow (the "who is me" wiring)

The orchestrator fills the `Assignee` input from the **authenticated user's UPN system variable** — the same Entra identity already used to stamp `requested-by:<UPN>` on writes (Architecture — Identity & audit; "Authenticate with Microsoft" supplies the asking user's UPN). Source precedence:

1. **User names no one** → pass the authenticated user's UPN.
2. **User names a teammate** (email/UPN) → pass that value verbatim.

> **Build-time confirmation:** the exact Copilot Studio variable name for the authenticated user's UPN (e.g. `System.User.PrincipalName`, or the authenticated `User.Email` from "Authenticate with Microsoft") is verified in the portal during implementation. The mechanism is known to exist (it backs `requested-by`); only the precise reference token is confirmed at build.

---

## 6. Presentation (grouped by state, then priority)

The agent groups results by **State**, and within each group sorts by **Priority** (then most-recently-changed). Each line shows **Title**, **ID**, **Type**, **Priority**, **Iteration**, and a clickable link.

```
You have 7 active items assigned (jane@org.com):

**Active**
- **Wire up retry on the sync job** (#4821 · Task) — P1 · Sprint 24 · [open ↗]
- **Harden the import validator** (#4805 · User Story) — P2 · Sprint 24 · [open ↗]

**New**
- **Customer export feature** (#4790 · Feature) — P2 · Sprint 25 · [open ↗]
```

**Edge messages:**
- **Empty** → "Nothing active is assigned to `<ResolvedAssignee>` right now."
- **Over `MaxResults`** → show the first N, then "Showing the first 50 — narrow by type or iteration to see more."
- **Named person, no items / unresolved name** → "I couldn't find items assigned to that name. If you used a display name, try their email address." (See §9 — display-name resolution is out of scope for v1.)

---

## 7. Agent & topic wiring

- **Orchestrator instructions (~1,500-char budget):** add one concise routing line —
  *"To show a person their assigned items (their own or a named user's), use /List_Assigned_Work_Items."*
  Verify the addition stays within the character band; trim adjacent wording only if needed.
- **No new topic.** Like `Search_Work_Items` and `Get_Work_Item_Details`, this is a pure generative-orchestration tool call. The deterministic topics stay reserved for greeting, Epic-stop, help, confirm/diff, and fallback.

---

## 8. Knowledge & documentation updates

| Artifact | Change |
|---|---|
| `ADO-Backlog-Agent-Architecture.md` | Add the new tool spec (new §4.x); update §2.1 scope ("…and **list the items assigned to a person**"); add the tool to the §3.1 component diagram's tool list; note it in the read data-flow. Bump version + changelog line. |
| `ADO-Backlog-Agent-CopilotStudio-Setup.md` | Add copy-paste tool **Description**, **Inputs**, and the orchestrator **instruction line**; add flow build steps. |
| `ADO-Backlog-Agent-Build-Plan.md` | Add a task under "Build read flows": build + publish `List_Assigned_Work_Items` with the verification matrix (§10). |
| `knowledge/KB-4-Using-This-Agent/4.1-what-this-agent-can-and-cant-do.md` | Add a Q&A: "Can it show me my work items?" → yes, plus the named-teammate form; re-export the `.docx`. |
| `knowledge/KB-3-Team-Conventions/_INTERVIEW.md` (§3.3) | Add one line: *"Which states count as closed/done (to exclude from 'my active items' by default)?"* |
| `README.md` | Add this design to the ADO document index and the status map. |

---

## 9. Scope guardrails (v1)

- **Pure read.** No write path, no Epic-creation guardrails; assigned Epics surface like any other type (reading Epics is already allowed).
- **Others by UPN/email only.** v1 expects a UPN/email for a named teammate. A bare display name that yields nothing prompts "try their email." Name→UPN resolution (e.g. via a directory lookup) is a deferred enhancement.
- **Privacy: accepted.** Listing a teammate's items is allowed by design — ADO assignments are already team-visible — so no extra confirmation gate is added.
- **Single project (v1).** Consistent with the rest of the agent; the query is scoped to the one configured `[PROJECT]`.

---

## 10. Verification matrix (for the build)

| # | Scenario | Expected |
|---|---|---|
| 1 | "show me my work items" (caller has active items) | Returns caller's active items, grouped by state, sorted by priority; `ResolvedAssignee` = caller UPN |
| 2 | "what's assigned to jane@org.com?" | Returns Jane's active items; `ResolvedAssignee` = Jane's UPN |
| 3 | Caller has no active items | Empty-state message, no error |
| 4 | "show me my closed items too" → `IncludeClosed = true` | Includes Closed/Done/Removed |
| 5 | "show me my tasks" → `WorkItemType = Task` | Only Tasks returned |
| 6 | Result count exceeds `MaxResults` | First N shown + narrow-it-down hint |
| 7 | `@me` regression check | Query never resolves to the service account; results reflect the passed UPN, not the bot |
| 8 | Named bare display name with no match | Friendly "try their email" message |

---

## 11. Out of scope (possible later)

- Display-name → UPN directory resolution for named teammates.
- Cross-project / multi-project assigned views.
- Saved/parameterized views ("my P1s this sprint") beyond the inline `WorkItemType` / `IncludeClosed` filters.
- An Adaptive Card rendering of the list (v1 uses grouped markdown).
