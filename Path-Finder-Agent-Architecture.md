# Path-Finder Agent — Architecture Design Document

**Version:** 1.0 · **Date:** 2026-06-04 · **Status:** Design for build
**Derived from:** Agent-Scope-Definition v1.1 · Copilot-Studio-Description-and-Instructions-Guide · Copilot-Studio-Instruction-Formats-Deep-Dive · Copilot-Studio-Multi-Agent-Architecture-Guide · Copilot-Studio-Knowledge-Preparation-Guide · Knowledge-Base Document Map (~250 docs)

---

## 1. Design principles (from the research)

1. **Knowledge-heavy, instruction-light.** The agent's "deep understanding of the tech stack" lives in the ~250-document knowledge base, not in instructions. Agent-level instructions stay **under 1,500 characters** (the empirically best-performing band); every high-stakes behavior is enforced on a surface with its own budget.
2. **Single agent now, split by evidence later.** The profile (≤16 knowledge sources, 2 tools + 1 child agent, ~5 topics ≈ **~24 total "choices"**) sits inside every ceiling (25–30 recommended actions, 25 always-searched knowledge sources). Splitting is a Phase-2/3 decision triggered by measured mis-routing or ownership boundaries — never anticipation.
3. **Descriptions do the orchestration work.** Tool names/descriptions and knowledge-source descriptions are the primary routing signals; instructions only break ambiguity (with exact `/Tool` references).
4. **Deterministic where it matters.** Licensing answers (pinned knowledge), the automation brief (typed-input elicitation + output contract), and escalation handoffs (authored topics) are deterministic. The LLM handles understanding, reasoning, and conversation.
5. **Grounding stays in the user-facing agent** (citations don't survive agent boundaries), and the agent says "I don't know — here's who to ask" rather than guessing.

---

## 2. HIGH-LEVEL ARCHITECTURE

### 2.1 Component view (Phase 1 — single agent)

```
                            ┌─ CHANNELS ────────────────────────────┐
                            │  Teams (primary) · M365 Copilot · Web │
                            └───────────────┬───────────────────────┘
                                            │
┌───────────────────────── PATH-FINDER AGENT (Copilot Studio) ─────────────────────────┐
│                                                                                      │
│  GENERATIVE ORCHESTRATOR  (model: Auto / GPT-5.x · generative orchestration ON)      │
│  Instructions ≤1,500 chars: purpose · elicitation rule · skills ·                    │
│  tool ambiguity-breakers · guardrails · response format · the "out"                  │
│                                                                                      │
│  ├── KNOWLEDGE (16 sources, all .docx in SharePoint, Enhanced search/Work IQ ON)     │
│  │     KB-01 M365 Copilot          KB-09 Agent platform (MCP/A2A/SDK)                │
│  │     KB-02 Copilot Studio        KB-10 Governance & security                       │
│  │     KB-03 Power Automate        KB-11 Licensing & pricing  ◄─ pinned by topic     │
│  │     KB-04 Power Apps & Pages    KB-12 Strengths & weaknesses                      │
│  │     KB-05 AI Builder/Dataverse  KB-13 Decisions & patterns (X-vs-Y)               │
│  │     KB-06 Power BI & Fabric     KB-14 Routing, personas & scenarios               │
│  │     KB-07 GitHub Copilot        KB-15 Enablement & planning                       │
│  │     KB-08 Microsoft Foundry     KB-16 OUR COMPANY (org-specific B-docs)           │
│  │                                                                                   │
│  ├── TOOLS                                                                           │
│  │     /Check_User_Licenses  ── Power Automate agent flow → Graph (read-only)        │
│  │                                                                                   │
│  ├── CHILD AGENT                                                                     │
│  │     /Brief_Builder ── typed required inputs = free elicitation interview;         │
│  │                       outputs the one-page automation brief                       │
│  │                                                                                   │
│  └── TOPICS (deterministic islands)                                                  │
│        T1 Greeting & expectations      T4 Escalation & handoff (authored contacts)   │
│        T2 Licensing answers (pinned    T5 Fallback (edited message)                  │
│           KB-11 + node instruction)                                                  │
│        T3 Security-incident stop                                                     │
└──────────────────────────────────────────────────────────────────────────────────────┘
            │                                   │
   SharePoint document library          Microsoft Graph (licenseDetails,
   (15 section folders + org folder)    read-only, IT-reviewed connection)
```

### 2.2 The conversation lifecycle (how it functions)

```
UNDERSTAND ──► ELICIT ──► GROUND ──► RECOMMEND ──► BRIEF ──► HANDOFF
```

1. **Understand.** Orchestrator classifies the request: product question, routing/"which tool" question, licensing question, planning help, troubleshooting, or out-of-scope.
2. **Elicit.** If material facts are missing for a routing question, the agent asks up to 3 clarifying questions (trigger type, data sources, output surface, volume, sensitivity). *Mechanics:* LLM follow-ups (requires **Allow ungrounded responses = ON**) for light cases; the Brief_Builder child agent's **required inputs** auto-ask deterministically for the full interview.
3. **Ground.** Knowledge retrieval across the 16 sources (orchestrator picks sources by description; licensing questions are pinned to KB-11 via topic T2). `/Check_User_Licenses` fires when entitlements affect the answer.
4. **Recommend.** The agent recommends the **simplest path that works** (existing feature → template → low-code → pro-code), explains *why*, and *why not* the alternatives, citing knowledge docs.
5. **Brief.** When the user is ready to act, `/Brief_Builder` assembles the one-page automation brief from the conversation + its required inputs.
6. **Handoff.** Topic T4 delivers the org-specific next step (intake link, CoE contact) deterministically. Out-of-scope requests route per the Scope Definition's "instead" column.

### 2.3 Evolution path (when one agent becomes several)

| Phase | Trigger | Change |
|---|---|---|
| **1 (build now)** | — | Single agent as above (~24 choices — headroom of ~6–16 actions) |
| **1.5** | Teams table-rendering complaints | Add Adaptive Card (ColumnSet) comparison topic |
| **2a** | Users ask "what does our usage data show?" | Add **Fabric data agent** as connected agent (own governance; not topic-redirectable; doesn't work if parent deployed to M365 Copilot — keep Teams primary then) |
| **2b** | Brief interview wanted by other teams' agents | Promote Brief_Builder from child to **connected agent** (reusable) |
| **2c** | Activity map shows licensing mis-routing OR actions approach ~25–30 | Carve a **licensing specialist child** with its own tools/knowledge |
| **3** | Remit grows beyond automation advice | Convert to **router + domain specialists**; router keeps nothing but child descriptions; accept latency/credit/citation costs knowingly; consider **Workflows** (once GA) for intake→check→brief→submit pipelines |

**Standing rules at every phase:** grounding stays in the user-facing agent; typed I/O over natural-language handoffs; subagent instructions include "NEVER respond to the user directly"; every new agent = a new Agent 365 registry approval.

---

## 3. LOW-LEVEL DESIGN

### 3.1 Agent settings

| Setting | Value | Why (source) |
|---|---|---|
| Orchestration | **Generative** | Required for tools-by-description, child agents, follow-ups |
| Model | **Auto** (GPT-5.x routing) | Mixed-intent advisory load; revisit reasoning-tier per-step only if multi-tool sequencing falters (credit premium) |
| **Allow ungrounded responses** | **ON** | OFF silently suppresses LLM clarifying questions (the #1 gotcha). Honesty is enforced via the instruction "out" instead |
| General knowledge | **OFF** | Answers must come from the KB; the KB has its own AI glossary doc for novice questions |
| Web search | **OFF** | Microsoft-stack questions answered from curated KB with citations |
| **Enhanced search results / Work IQ** | **ON** | Tenant has M365 Copilot; unlocks 200 MB file path + better retrieval. Misconfiguration = "agent ignores my files" |
| Content moderation | High (default) | Monitor; lower only if legitimate answers are suppressed |
| Authentication | Microsoft Entra ID (Authenticate with Microsoft) | Required for Work IQ, SharePoint permission trimming, license flow user context |

### 3.2 Description (the field — final draft, ~360 chars)

> Use the Path-Finder Agent to find the right Microsoft tool for your automation or AI idea — Microsoft 365 Copilot, Copilot Studio, Power Automate, Power Apps, Power BI, or Azure AI Foundry. It explains capabilities, limits, and licensing, checks which licenses you hold, helps you judge business value, and produces an automation brief ready to hand to a builder.

*Format rules applied:* positive capabilities only, active voice, keyword-rich (the words users type), no Markdown, well under 1,000 chars.

### 3.3 Instructions (the field — final draft, ~1,460 chars)

```markdown
# Purpose
You are the Path-Finder Agent. You help employees choose the right Microsoft
automation or AI tool, judge whether their idea is realistic and valuable, and
plan how to build it. You advise and route — you never build, execute, or
administer anything.

# How to work
1. Understand the request. If key facts are missing, ask up to 3 clarifying
   questions (trigger type, data sources, output surface, volume, data
   sensitivity) before recommending.
2. When license context affects a recommendation, use /Check_User_Licenses.
   If it fails or returns nothing, explain how to check manually and continue.
3. Ground every recommendation in your knowledge sources. Recommend the
   simplest path that works: existing product feature, then template, then
   low-code, then pro-code.
4. Explain why your recommendation fits and why not the closest alternatives.
5. When the user is ready to act, use /Brief_Builder to assemble their
   automation brief.

# Rules
- Never recommend non-Microsoft platforms; explain the company standard.
- For admin actions, compliance rulings, security incidents, or hands-on
  support: name the right contact and stop.
- State prices only from the licensing documents, with their as-of date.

# Response format
- Lead with the recommendation, then the reasoning.
- Present option comparisons as short bulleted lists with bold option names.
- End with one relevant follow-up question or concrete next step.

# If you cannot answer
If your knowledge does not cover the question, say so plainly and direct the
user to [ORG: intake/support contact].
```

*Format decisions applied:* Markdown component model (format A) + numbered true sequence + IF/THEN-style rules; purpose first / "out" last (lost-in-the-middle placement); bullets for parallel rules, numbers only for the genuine sequence; bold-list comparisons instead of tables (Teams renders no Markdown tables); no use of the word "citation"; ~1,460 chars — inside the 1,000–1,500 sweet spot. `[ORG: …]` placeholders come from org-specific doc B-2/B-6 at deployment.

### 3.4 Knowledge sources (16 — each a SharePoint folder of .docx)

Naming + description pattern: *what it covers · what it does NOT cover (negative steering) · synonyms.* All under the 25-source pre-filter cap with room for growth.

| # | Source name | Description (draft) |
|---|---|---|
| KB-01 | M365 Copilot & Extensibility | "Microsoft 365 Copilot in Word/Excel/PowerPoint/Outlook/Teams, Copilot Chat, declarative and custom engine agents, agent builder, Copilot connectors. Not for pricing (Licensing) or build-vs-buy decisions (Decisions)." |
| KB-02 | Copilot Studio | "Copilot Studio agent building: orchestration, knowledge, tools, topics, autonomous agents, channels, quotas, ALM. Not for licensing rates (Licensing)." |
| KB-03 | Power Automate | "Cloud flows, desktop flows/RPA, process mining, agent flows, connectors, limits and throttling, error handling. Not for app building (Power Apps) or pricing (Licensing)." |
| KB-04 | Power Apps & Power Pages | "Canvas and model-driven apps, Power Fx, delegation, external sites with Power Pages. Not for flows (Power Automate) or pricing (Licensing)." |
| KB-05 | AI Builder & Dataverse | "AI Builder models and prompts, document processing, Dataverse tables, security, storage, API limits, Fabric link. Not for credit prices (Licensing)." |
| KB-06 | Power BI & Fabric | "Reports, semantic models, Copilot in Power BI, Fabric, OneLake, data agents — analyzing data. Not for automating processes (Power Automate) or building agents (Copilot Studio)." |
| KB-07 | GitHub Copilot | "AI coding assistance: completions, agent mode, coding agent, plans and admin controls — for writing software. Not for business-process automation." |
| KB-08 | Microsoft Foundry | "Azure AI Foundry: model catalog, Agent Service, Agent Framework, evaluation, content safety — pro-code AI. Not for low-code agents (Copilot Studio)." |
| KB-09 | Agent Platform & Protocols | "MCP, A2A, Agents SDK and Toolkit, Entra Agent ID, Agent 365 — how agents connect and are governed across platforms." |
| KB-10 | Governance & Security | "Admin centers, environments, DLP, Purview, sensitivity labels, oversharing controls, agent approval — how the company governs AI. Not a substitute for company policy rulings." |
| KB-11 | **Licensing & Pricing** | "The canonical home of all license tiers, prices, Copilot Credits rates, capacity packs, and what each license includes, with as-of dates. Use for every cost or 'what do I need to buy' question." |
| KB-12 | Strengths & Weaknesses | "Honest community-sourced strengths, weaknesses, and limitations of each product — for setting realistic expectations." |
| KB-13 | Decisions & Patterns | "X-vs-Y decision guides (flow vs agent, Copilot Studio vs Foundry, Dataverse vs SharePoint) and proven product-combination architectures. Use for 'which tool should I use' questions." |
| KB-14 | Routing, Personas & Scenarios | "The three build altitudes, requirement elicitation, persona playbooks, and the symptom-to-path scenario catalogs by department." |
| KB-15 | Enablement & Planning | "Templates and accelerators, project planning method, ROI measurement, case studies, AI glossary, learning paths, troubleshooting first aid, roadmap discipline." |
| KB-16 | Our Company *(org-authored B-docs)* | "[ORG] licenses owned, intake process, environments, data rules, existing solutions, support paths, standards, costs, champions, AI policy. Use for every 'can I do this here' question." |

*Hygiene rules:* SharePoint advanced filter `Modified ≥ <last refresh>` per source once refresh cycles begin; no near-duplicate docs; review descriptions whenever a new source is added (collision check).

### 3.5 Tool: `Check_User_Licenses` (Power Automate agent flow)

| Aspect | Specification |
|---|---|
| Name | `Check_User_Licenses` (verb phrase — names outweigh descriptions) |
| Description | "Returns the Microsoft licenses the asking user currently holds (Microsoft 365 Copilot, Power Apps, Power Automate, Power BI, Copilot Studio access). Use when license context affects a recommendation or the user asks what they can build with what they have. Never use for general product or pricing questions." |
| Trigger | When an agent calls the flow · async OFF · respond <100s · published |
| Inputs | None (resolves the authenticated user; self-only by design per Scope §3.8) |
| Outputs (named + described — the agent only *uses* what's described) | `HasM365Copilot` (boolean), `PowerAppsPlan` (string), `PowerAutomatePlan` (string), `PowerBIPlan` (string), `HasCopilotStudioAccess` (boolean), `RetrievedOn` (string) |
| Response shape | Keyed JSON object (never bare arrays) via **Respond to the agent** |
| After running | **Don't respond** — orchestrator folds entitlements into its answer |
| Failure behavior | Instruction line 2 (fallback to manual-check guidance; never block) |
| Security | Graph `licenseDetails` read; admin-consented app permission or user-context connection per IT review; DLP-compliant connector set (Scope §3.8 rules) |

### 3.6 Child agent: `Brief_Builder`

| Aspect | Specification |
|---|---|
| Type | Child agent (Phase 1) — promotable to connected agent if reuse emerges |
| Trigger | The agent chooses (description-based) |
| Description | "Assembles the user's one-page automation brief once a recommended path exists. Use when the user wants to proceed, hand off, or submit their idea. Never use during initial exploration." |
| **Inputs (all required → free deterministic elicitation)** | `ProblemStatement` · `TriggerType` ("user-initiated, event, schedule, or autonomous") · `DataSources` · `OutputSurface` · `VolumeFrequency` · `DataSensitivity` · `Owner` — each with Should-prompt-user ON, custom prompt wording, 2 reprompts, validation conditions where applicable |
| Instructions (child's own budget) | "You are a subagent. NEVER respond to the user directly. Produce the automation brief exactly in the Output Contract format using the inputs and the conversation's recommended path. ## Output Contract (Mandatory): [the 10-field brief template from D-enablement-12: Problem · Trigger · Data sources · Output surface · Volume/frequency · Sensitivity · Owner · Recommended path + why · License check result · Next steps]. One compact worked example included." |
| Output | `BriefMarkdown` (string) |
| After running | **Send specific response** — the brief renders verbatim (deterministic), followed by the orchestrator suggesting the T4 handoff |

### 3.7 Topics (deterministic islands)

| Topic | Trigger | Behavior |
|---|---|---|
| **T1 Greeting** | Conversation start | Authored message: what the agent can/can't do (2 lines from Scope §1), 4–6 conversation starters ("Which tool should I use to…", "What licenses do I have?", "Is my idea worth automating?", "Help me write an automation brief") |
| **T2 Licensing answers** | The agent chooses — description: "Answers questions about licensing, pricing, costs, credits, and what a license includes" | Generative answers node with **pinned source KB-11** (deterministic scoping; agent-level knowledge becomes fallback). Node-level custom instruction (own 8,000-char budget): "Answer only from the licensing documents. State every price with its as-of date. If tenant-specific entitlements matter, suggest checking current licenses. One worked example of a correctly formatted licensing answer." |
| **T3 Security-incident stop** | The agent chooses — description: "User reports a suspected data leak, breach, oversharing discovery, or security incident" | Authored message: stop + [ORG: security contact] (Scope §4.7 — deterministic, no LLM) |
| **T4 Escalation & handoff** | The agent chooses + referenced after briefs | Authored message: [ORG: intake link, CoE contact, helpdesk] from B-2/B-6 |
| **T5 Fallback** | System | Edit default message: "I couldn't find that in my knowledge. I cover Microsoft automation and AI tools — for anything else, [ORG: contact]. Could you rephrase, or tell me what you're trying to accomplish?" |

### 3.8 Cross-cutting specifics

- **Channel formatting:** Teams is primary → comparison rule uses **bold names + bullets** (Markdown tables don't render in Teams text). Web chat gets tables for free where the model chooses them. Adaptive Cards (ColumnSet) reserved for Phase 1.5.
- **Credits:** generative answers ≈2 credits, agent actions ≈5, graph grounding 10, agent flows 13/100 actions; M365 Copilot-licensed users consume none interactively. Set a **per-agent monthly credit cap** in PPAC at launch; review Analytics → consumption monthly.
- **Governance:** register/approve via Agent 365 registry; DLP check on the Graph connector; agent + flow + KB live in one **solution** for ALM (note: knowledge isn't auto-reprocessed on import — re-verify after deploy).

### 3.9 Build sequence

1. SharePoint library: upload 15 section folders (.docx) + create KB-16 org folder (B-docs from IT/CoE — **blocking dependency** for "can I do this here" answers).
2. Create agent → settings per §3.1 → description §3.2 → instructions §3.3 (with [ORG] placeholders resolved).
3. Add 16 knowledge sources with §3.4 names/descriptions; verify **Enhanced search ON**; test retrieval per source (test pane: "what do you know about X?").
4. Build + connect `Check_User_Licenses` flow (IT review of Graph permission first); test the failure path explicitly.
5. Build `Brief_Builder` child agent; test the required-input interview end to end.
6. Author topics T1–T5.
7. **Evaluation baseline:** build an Agent Evaluation test set — ≥40 routing questions across all 15 domains + 10 out-of-scope + 10 cross-domain ambiguity + 5 domain-mismatch ("graceful no-answer beats wrong answer") — run before/after every description or instruction change.
8. Pilot with one team → review activity map (wrong-source diagnosis: "sources searched but not used") and analytics → publish to Teams org-wide → Agent 365 approval.

---

## 4. Traceability

| Decision | Source document |
|---|---|
| Single agent, 30–40 choice ceiling, evolution triggers | Multi-Agent Architecture Guide Parts 1, 5, 6 |
| ≤1,500-char instructions, component format, placement | Description & Instructions Guide Part 3; Formats Deep-Dive Part 1 |
| Tool name/description primacy, /references, flow response design | Formats Deep-Dive Part 2 |
| 16 sources < 25 cap, negative-steering descriptions, T2 pinning | Formats Deep-Dive Part 3 |
| Ungrounded-responses ON, required-input elicitation, channel table rules | Formats Deep-Dive Part 4 |
| Read-only flow rules, self-only data, fallback behavior | Agent-Scope-Definition v1.1 §3.8, §5 |
| .docx format, Enhanced search, one-topic-per-doc KB | Knowledge-Preparation-Guide |

*Review this architecture quarterly with the High-volatility knowledge refresh, and at every phase transition.*
