# KB-4 "Using This Agent" — Grounding Notes

KB-4.1 is a user-facing FAQ. By design (Knowledge Acquisition Plan, Phase 1) it is **not** researched from the web — every claim derives from the agent's own design spec, `ADO-Backlog-Agent-Architecture.md` (v1.4). This file maps each load-bearing claim in `4.1-what-this-agent-can-and-cant-do.md` to its Architecture source so Check 4 (grounding) is traceable. Date checked: **2026-06-11**.

| Claim in 4.1 | Architecture source |
|---|---|
| Agent finds, creates, updates, and comments on work items; confirm-before-write | §2.1 (scope) · §3.2 (conversation lifecycle) · §2.3 decision 3 (confirm a preview, then create) |
| Reads all four types (Epic, Feature, User Story, Task) | §2.1 ("Read Epics, Features, User Stories, and Tasks") |
| Creates/edits only Features, User Stories, and Tasks — never Epics | §2.2 ("Create Epics" is out of scope) · §3.3 (the no-Epics guarantee) |
| Edit/comment on Epics not allowed (Epics read-only) | §2.2 · §7.10 (Epic write policy — fully read-only default) |
| Never deletes anything | §2.2 ("Delete any item — no delete tool exists") |
| Operates in a single configured project | §2.2 · §2.3 decision 4 |
| Find/read capabilities (search by text/type/area/state/assignee; inspect one item; duplicate check) | §4.4 (Search_Work_Items) · §4.5 (Get_Work_Item_Details) |
| Create a single item or a Feature → Story → Task tree in one request | §2.1 · §4.7 (Create_Backlog_Tree) |
| Update fields incl. release/deploy/feature-flag notes; add discussion comments | §4.7.1 (Update_Work_Item) · §4.7.2 (Add_Comment) · §4.11 |
| "What it will ask for" per type (required vs nudged fields) | §3.4 Gate 2 table · §4.11.1 (Feature & User Story) · §4.11.2 (Task = Title + Description) |
| Override weak fields except type-to-Epic | §3.4 ("warn-and-allow … Type is never overridable to Epic") |
| Preview/diff then Confirm/Cancel before any write | §3.2 steps 4–6 · §4.8 topic T4 |
| Out-of-scope → points to [ORG: contact] | §4.3 (instructions "If you cannot answer") · §4.8 topic T5 |

No claim in 4.1 goes beyond what the Architecture states; org-specific values ([PROJECT], [ORG: contact]) are left as placeholders for KB-3 / deployment.
