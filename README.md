# Project Overview — Copilot Studio Agents for the Power Platform Team

> **New here? Read this page first.** It explains everything in this folder, what each document is for, and where to start depending on what you need to do.

---

## What this folder is

This is the **design and build workspace** for Microsoft **Copilot Studio** agents built for the Power Platform team. It contains design specs, build plans, and the underlying research — not the running agents themselves (those live in Copilot Studio / Power Platform).

There are **two separate agents** here, plus a shared **methodology library** that informs both:

| Body of work | What it is | Status |
|---|---|---|
| 🟢 **ADO Backlog Agent** | A **read + write** agent that lets the team find, create, update, and comment on **Azure DevOps** work items (Features, User Stories, Tasks — never Epics) through a quality-gated, confirm-before-write conversation. **This is the current build.** | Design complete (v1.5); not yet built. Blocking dependency: the team-authored knowledge doc (KB-3). |
| 🔵 **Path-Finder Agent** | An earlier, **read-only advisory** agent that helps employees choose the right Microsoft AI/automation tool and plan their projects. A different agent for a different job. | Design complete; awaiting org-specific knowledge docs (B-1…B-10). |
| 📚 **Copilot Studio methodology** | Reusable research on how to build *any* Copilot Studio agent well (knowledge prep, instructions, tool/knowledge steering). Written during Path-Finder, applied to the ADO agent. | Reference — verified June 2026; re-verify quarterly. |

> ⚠️ **Don't confuse the two agents.** Path-Finder *advises and never changes anything*. The ADO Backlog Agent *creates and edits work items*. They share build techniques, not scope.

---

## Where to start (reading paths by goal)

- **"I just want to understand the ADO Backlog Agent."** → Read **`ADO-Backlog-Agent-Architecture.md`** (the source of truth). That's enough for a complete mental model.
- **"I'm going to build the ADO agent in Copilot Studio."** → `Architecture` → **`ADO-Backlog-Agent-Build-Plan.md`** (do the phases in order) → keep **`ADO-Backlog-Agent-CopilotStudio-Setup.md`** open for copy-paste settings/text → **`ADO-Backlog-Agent-Knowledge-Plan.md`** when authoring the knowledge docs.
- **"I'm authoring the knowledge/SharePoint docs."** → `ADO-Backlog-Agent-Knowledge-Plan.md` (and the KB-1/KB-2 starter content inside the Build Plan).
- **"I'm learning how to build Copilot Studio agents in general."** → the three **`Copilot-Studio-*`** guides.
- **"I want context on the other (Path-Finder) agent."** → `Agent-Scope-Definition.md` → `Path-Finder-Agent-Architecture.md`.

---

## Document index

### 🟢 ADO Backlog Agent (the current build)

| File | What it is | Read it when… |
|---|---|---|
| **`ADO-Backlog-Agent-Architecture.md`** *(v1.5)* | **The source-of-truth design spec.** Scope, the no-Epics guarantee, the 3-gate quality engine, all 5 tools, the `Backlog_Builder` child agent, topics, the per-type field catalogs, agent settings, identity/audit, and the evolution path. | You want to understand or change *what* the agent is and *why*. |
| **`ADO-Backlog-Agent-Build-Plan.md`** | **The step-by-step build plan.** Phased, dependency-ordered tasks (knowledge → connection → read flows → write flows → agent → child agent → topics → evaluation → pilot), each with build steps and verification. Includes starter content for KB-1 and KB-2. | You're actually building it in the portals. |
| **`ADO-Backlog-Agent-CopilotStudio-Setup.md`** | **Copy-paste configuration.** Every Copilot Studio setting (with exact UI location and value), plus all descriptions, instructions, tool descriptions, child-agent required inputs, and topic message text — ready to paste. | You're configuring the agent/child in Copilot Studio. |
| **`ADO-Backlog-Agent-Knowledge-Plan.md`** *(v1.0)* | **The knowledge-base plan.** The SharePoint folder structure (~17 single-topic docs across 3 sources), each doc's purpose and consumer, and the knowledge-vs-instructions boundary. | You're planning or authoring the agent's knowledge. |
| **`ADO-Backlog-Agent-Knowledge-Acquisition-Plan.md`** *(v1.0)* | **The knowledge-authoring playbook.** How to research → draft → Ralph-refine → ship the KB docs; the two-track (generatable vs team-only) pipeline; the rubric/scorecard/interview artifacts under `knowledge/`. | You're producing the actual knowledge documents. |
| **`ADO-Backlog-Agent-Parent-Aware-Elicitation-Design.md`** *(v1.0)* | **Design spec — parent-aware elicitation.** Gate 0 (parent grounding), the `ParentContext` packet, the inherit-don't-re-ask rule, and the gap-targeted question banks the agent uses to build great children under a Feature/Epic. | You want to understand or change *how the agent interviews* using the parent's context. |
| **`ADO-Backlog-Agent-Parent-Aware-Elicitation-Build-Plan.md`** | **Implementation plan — parent-aware elicitation.** The 9 task-by-task steps (author KB-1.6 → update Architecture/Setup → ship → portal build), each with exact content and verification. | You're implementing the parent-aware capability. |
| **`ADO-Backlog-Agent-Assigned-Items-Design.md`** *(v1.0)* | **Design spec — assigned-items listing.** The `List_Assigned_Work_Items` read tool: self-or-named-teammate scope, active-by-default state filtering, grouped presentation, and the `@me`/identity wiring. | You want the agent to list the items assigned to a user. |
| **`ADO-Backlog-Agent-Assigned-Items-Build-Plan.md`** | **Implementation plan — assigned-items listing.** Phase A repo edits (Architecture/Setup/Build-Plan/KB) and Phase B portal build (the flow, tool wiring, identity, verification matrix). | You're implementing the assigned-items capability. |

### 🔵 Path-Finder Agent (separate, earlier agent — context)

| File | What it is | Read it when… |
|---|---|---|
| **`Agent-Scope-Definition.md`** *(v1.1)* | Path-Finder's scope: what the advisory agent will/won't do, boundary behaviors, operating constraints, dependencies. | You need to know what Path-Finder is for. |
| **`Path-Finder-Agent-Architecture.md`** *(v1.0)* | Path-Finder's full architecture: single agent, ~250-doc knowledge base, a read-only license-check flow, a brief-builder child agent, topics, and its evolution path. | You're building or reviewing Path-Finder. |
| **`Knowledge-Gap-Analysis.md`** | Analysis of what Path-Finder's knowledge base still needs: ~14 researchable docs + 10 organization-specific docs (B-1…B-10) only the company can write. | You're filling out Path-Finder's knowledge. |

### 📚 Copilot Studio methodology & research (shared — applies to both agents)

| File | What it is | Read it when… |
|---|---|---|
| **`Copilot-Studio-Knowledge-Preparation-Guide.md`** | Research on knowledge: how much to feed an agent, what formats Copilot Studio actually retrieves (`.docx` yes, `.md` no), the 7 MB vs 200 MB / Work IQ trap, the 15-snippet budget, one-topic-per-doc. | Designing any agent's knowledge base. |
| **`Copilot-Studio-Description-and-Instructions-Guide.md`** | Research on the two authored text surfaces: the **Description** (discovery/routing) vs the **Instructions** (behavior), their limits, and best practices. | Writing an agent's description or instructions. |
| **`Copilot-Studio-Instruction-Formats-Deep-Dive.md`** | Deep research on instruction format families, steering Power Automate **tools** and **knowledge** by name/description, format control on a budget, and the critical **"Allow ungrounded responses" gotcha**. | Tuning tool/knowledge selection or instruction format. |

---

## How the documents relate

```
        ┌─────────────────────────────────────────────────────┐
        │  Copilot Studio methodology (the 3 research guides)  │
        │  — reusable "how to build a good agent" knowledge    │
        └───────────────┬─────────────────────┬───────────────┘
                        │ informs             │ informs
            ┌───────────▼──────────┐  ┌───────▼─────────────────────────┐
            │  PATH-FINDER AGENT   │  │  ADO BACKLOG AGENT (current)     │
            │  (read-only advisor) │  │  (read + write work items)       │
            ├──────────────────────┤  ├──────────────────────────────────┤
            │ Agent-Scope-Definition│  │ Architecture (source of truth)   │
            │ Path-Finder-Architecture│ │   → Build-Plan (how to build)   │
            │ Knowledge-Gap-Analysis │  │   → CopilotStudio-Setup (paste)  │
            │                       │  │   → Knowledge-Plan (the KB)       │
            └──────────────────────┘  └──────────────────────────────────┘

ADO BACKLOG AGENT — full document set & how each feeds the next (current status):

  ★ Architecture (v1.5) ── source of truth: scope, no-Epics, the gates, 5 tools, fields   ✅
        │
        ├─ BUILD ▸ Build-Plan ─► CopilotStudio-Setup   ✅  (Setup = the file you paste from)
        │
        ├─ KNOWLEDGE ▸ Knowledge-Plan ─► Knowledge-Acquisition-Plan ─► knowledge/ drafts
        │              ✅ 11/11 generatable docs written, reviewed, shipped to .docx
        │              ⛔ KB-3 "Team Conventions" ── you author (fill _INTERVIEW.md)
        │
        ├─ CAPABILITY ▸ Parent-Aware-Elicitation-Design ─► …-Build-Plan
        │              ✅ T1–T8 done — Gate 0 + ParentContext, woven into Architecture §3.4 & Setup §3/§6
        │
        └─ CAPABILITY ▸ Assigned-Items-Design ─► …-Build-Plan
                        ⏳ designed; portal build pending (3rd read tool)

Status legend:  ✅ done   ⛔ blocked, needs you   ⏳ pending portal build
  ✅  All design/config docs + the 11 generatable KB drafts (incl. KB-1.6) are written, reviewed, and converted to .docx (knowledge/dist/).
  ⛔  KB-3 "Team Conventions" — fill knowledge/KB-3-Team-Conventions/_INTERVIEW.md to unblock placement & custom-field writes.
  ⏳  Copilot Studio portal build — the agent, 5 flows, the Backlog_Builder child, topics, and the parent-aware wiring are designed but not yet built.
```

---

## Current status & what's outstanding (ADO Backlog Agent)

- ✅ **Design, build plan, setup config, and knowledge plan are complete** and internally consistent (Architecture v1.5).
- ✅ **Knowledge base drafted & refined** — the 11 generatable docs (KB-1 Quality ×6, KB-2 Leveling ×4, KB-4 FAQ ×1) are researched, drafted, and passed the quality rubric, under `knowledge/`. See `ADO-Backlog-Agent-Knowledge-Acquisition-Plan.md` for how they were produced.
- ⛔ **Blocking dependency — KB-3 "Team Conventions":** the team must supply real area paths, iteration paths, custom-field reference names (Release/Deploy/Feature-flag notes), Value Area picklist values, and the Epic owner. This single doc feeds both the write flows and the child agent's input-validation lists. Nothing should go live without it.
  - **👉 YOUR NEXT ACTION:** answer the questions in **`knowledge/KB-3-Team-Conventions/_INTERVIEW.md`** (each has a "where to find it in ADO" hint). Your answers fill the 6 KB-3 templates (`3.1`–`3.6`) in that same folder. This is the one task that unblocks everything downstream.
- 🔲 **Open decisions** still flagged in the Architecture (§7) and Knowledge Plan: whether commenting on Epics is allowed (currently fully read-only), and a few knowledge-granularity choices.
- 🔲 **Not yet built:** the agent, the 5 Power Automate flows, the child agent, topics, and the evaluation set all exist as designs/plans, not as deployed artifacts.

---

## Key terms (quick glossary)

- **Copilot Studio** — Microsoft's low-code platform for building conversational AI agents.
- **Generative orchestration** — the mode where the agent's model decides at runtime which tools, knowledge, topics, and child agents to use (vs scripted "classic" flows).
- **Agent flow** — a Power Automate flow the agent can call as a **tool** (here, all Azure DevOps reads/writes go through these).
- **Child agent** — a sub-agent the main agent hands off to for a focused job (here, `Backlog_Builder` runs the quality interview).
- **Knowledge source** — a body of reference content (a SharePoint folder of `.docx`) the agent searches and cites.
- **Topic** — an authored, deterministic conversation branch (here: greeting, Epic-stop, help, confirm/diff, fallback).
- **Work item types** — Azure DevOps hierarchy: **Epic → Feature → User Story → Task.** The ADO agent reads all four but creates/edits only Feature/Story/Task.

---

*This overview reflects the project as of 2026-06-11. When agent versions change, update the version tags in the document index above.*
