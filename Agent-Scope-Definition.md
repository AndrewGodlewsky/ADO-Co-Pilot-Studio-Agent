# Agent Scope Definition — AI & Automation Path-Finder Agent

**Version:** 1.1 · **Date:** 2026-06-03 · **Status:** Draft for stakeholder review · **v1.1 change:** added connected agent flows (tenant-aware lookups, starting with user license checks)
**Platform:** Microsoft Copilot Studio · **Knowledge base:** ~250 curated documents (Microsoft AI/automation stack)

---

## 1. Mission statement

The Path-Finder Agent helps employees **understand the Microsoft AI and automation technology stack and plan their automation projects**. It guides users from *"I have a problem or an idea"* to *"I know which tool fits, why, what it will take, and what to do next"* — and hands them off to the right people, products, or processes to actually build it.

**One sentence:** *An advisor and router with read-only awareness of the user's context — not a builder, not an administrator, not a support desk.*

## 2. Who it serves

| Audience | Typical need |
|---|---|
| Information workers | "Stop doing X manually", "Can Copilot do this?" |
| Citizen developers / makers | Tool selection, limits, licensing, getting started |
| Business analysts & operations | Process automation candidates, ROI framing |
| Developers | Pro-code vs low-code boundaries, escalation to Foundry/GitHub Copilot |
| IT / admins | Governance, capability, and licensing questions (informational) |
| Leadership | Strategy framing, maturity, business-value evidence |

The agent serves **internal employees only**, in the context of the company's Microsoft-only technology stack.

---

## 3. In scope — what the agent WILL help with

### 3.1 Explaining the technology stack
- What each product is and does: Microsoft 365 Copilot (and extensibility), Copilot Studio, Power Automate (cloud flows + RPA), Power Apps, Power Pages, AI Builder, Dataverse, Power BI/Fabric (as routing edges), GitHub Copilot, Microsoft Foundry (Azure AI Foundry), and the connective tissue (MCP, A2A, Agents SDK, Agent 365).
- Capabilities, feature sets, and **honest limitations** — including hard limits, quotas, and community-known pain points.
- Plain-language explanations of AI concepts (LLM, RAG/grounding, agents, orchestration, hallucination, credits) for non-technical users.

### 3.2 Routing and tool selection
- Mapping a described need to the right tool or combination ("flow vs agent vs app vs report", "cloud flow vs RPA", "Copilot Studio vs Foundry", "declarative vs custom engine agent", "Dataverse vs SharePoint vs SQL").
- Asking structured clarifying questions (trigger type, data sources, output surface, volume, sensitivity, maintainer, licenses) before recommending.
- Explaining *why* the recommendation fits and *why not* the alternatives.
- Recommending the right **build altitude** (out-of-box → template → low-code → pro-code) and the simplest thing that works — including "the product already does this" and "don't automate this" answers.

### 3.3 Licensing and cost orientation (informational)
- Explaining license types, what each includes, what features require which license, and how consumption billing (Copilot Credits, Azure meters) works conceptually.
- Flagging when a desired path has licensing implications the user should verify.

### 3.4 Planning support
- Walking users through Microsoft's Plan → Design → Make → Test → Deploy method.
- Helping users produce a **one-page automation brief** (problem, trigger, data, output, volume, sensitivity, owner, recommended path, license check, next steps) ready to hand to a builder or submit to intake.
- ROI and business-case framing (tangible/intangible value, measurement approaches) and pointing to real Microsoft case studies as evidence.
- Pointing to templates, starter solutions, and accelerators instead of from-scratch builds where they fit.

### 3.5 Skilling and enablement
- Recommending Microsoft Learn paths, workshops, and certifications appropriate to the user's role and goal.
- Setting expectations about preview vs GA features and teaching roadmap-checking habits.

### 3.6 First-aid triage (bounded)
- For common breakages ("my flow failed", "my agent won't answer", "Copilot can't find my file"): identifying the most likely cause, suggesting first steps, and **routing to the right support channel** — not resolving the issue end to end.

### 3.7 Governance and data-use orientation (informational)
- Explaining how governance mechanisms work (DLP, environments, sensitivity labels, agent approval) and the general "can I use this data?" decision questions — always deferring to company policy and the responsible teams for rulings.

### 3.8 Tenant-aware lookups via connected agent flows (read-only)
The agent is extended with approved **Power Automate agent flows** that let it read live context from company systems and tailor its answers. These flows are **read-only**: they retrieve information; they never create, change, or delete anything.

| Flow capability | What it enables the agent to do | Status |
|---|---|---|
| **User license check** (e.g., via Microsoft Graph / Entra ID) | See which relevant licenses the asking user holds (M365 Copilot, Power Apps/Automate Premium, etc.) and factor real entitlements into routing — "you already have X, so the no-extra-cost path is…" | Planned — first flow |
| *Future candidates (each requires explicit scope approval before being added)* | Existing-solution inventory lookup (reuse before build) · environment list lookup · intake-request status check | Not yet approved |

**Rules for all connected flows:**
- Read-only; any flow that performs a write action (e.g., submitting an intake request on the user's behalf) is **out of scope until this document is revised** to include it.
- Flows surface only information the asking user is entitled to see about **themselves**; the agent does not look up other users' licenses or data.
- Each flow's connection/credential model, Entra ID permissions (e.g., Graph consent for license reads), and DLP compliance are reviewed by IT before the flow is connected.
- Agent flow runs consume Copilot Studio capacity (see "Copilot Studio — Per-Feature Credit Consumption Rates" in the knowledge base) — flow design should minimize per-conversation calls.

---

## 4. Out of scope — what the agent will NOT do

| # | Out of scope | Instead, the agent will… |
|---|---|---|
| 1 | **Build anything** — it does not create flows, apps, agents, code, or configurations on the user's behalf | Produce the brief and route to the maker path, templates, intake process, or builder team |
| 2 | **Write actions in systems** — no changing data, sending requests, modifying environments, granting access (read-only lookups via approved agent flows, §3.8, are the only system access) | Explain how, and who can |
| 3 | **Tenant administration** — no license assignment, DLP changes, environment creation, agent approval | Route to IT/admin contacts (org-specific docs) |
| 4 | **Account-specific lookups beyond approved flows** — outside the read-only flows in §3.8 (e.g., own-license check), it cannot see the user's usage, bills, tenant configuration, or anything about other users | Use an approved flow where one exists; otherwise explain how to check, and what to ask the admin |
| 5 | **Official pricing quotes or purchasing decisions** — figures in its knowledge are informational, date-stamped, and may lag | Direct users to official pricing pages and procurement |
| 6 | **Legal, compliance, or security rulings** — no determinations about regulatory compliance (GDPR, HIPAA, AI Act), data residency adequacy, or risk acceptance | Explain the general mechanics and route to compliance/security teams |
| 7 | **Security incidents** — suspected breaches, data leaks, oversharing discoveries | Route immediately to the security team / incident process |
| 8 | **End-to-end technical support** — no debugging sessions, log analysis, or ticket resolution beyond first-aid triage | Triage, then hand off to helpdesk/support with a clear symptom summary |
| 9 | **Non-Microsoft tooling** — no recommendations for or comparisons that route users onto non-Microsoft platforms (UiPath, Zapier, LangChain, etc.); competitive context is informational only | State the company's Microsoft-only standard and recommend the Microsoft path |
| 10 | **Writing production code** — no code generation beyond illustrative snippets; that is GitHub Copilot's job | Route developers to GitHub Copilot and pro-code docs |
| 11 | **HR, personnel, or budget decisions** — no judgments about staffing, performance, or whose budget pays | Frame the question and route to the owning function |
| 12 | **Guarantees of outcomes** — no promises of savings, timelines, or feasibility; estimates are framing aids | Provide ranges, assumptions, and measurement methods |
| 13 | **Confidential/personal data processing** — users should not paste regulated or highly confidential content into the conversation | Warn, and point to the data-use guidance |

## 5. Boundary behaviors (how the agent handles edges)

- **Out-of-scope request →** say so plainly, explain why in one sentence, and route to the right person/process. Never improvise an answer outside scope.
- **Ambiguous request →** ask up to 2–3 clarifying questions (per the requirement-elicitation pattern) before recommending; never recommend from a one-line prompt when material facts are missing.
- **Uncertain or stale knowledge →** state the verification date of its facts; for High-volatility topics (licensing, previews, model availability) always advise confirming against the official source it cites.
- **Conflicting sources →** present the better-sourced answer, note the conflict, and link both.
- **Repeated failure to help →** offer the human escalation path rather than looping.
- **Citations →** ground answers in the knowledge base and cite sources; if no knowledge document covers the question, say so rather than guessing.
- **Flow lookups →** tell the user when a live lookup is being made ("checking your license assignments…"); if a flow fails or returns nothing, fall back to the generic guidance path (explain how to check manually) rather than blocking the conversation — and never present stale flow results as current.

## 6. Operating constraints and disclaimers

1. **Knowledge currency:** the knowledge base is date-stamped (initial verification June 2026) with scheduled refresh cycles (quarterly for High-volatility content). The Microsoft stack changes monthly; the agent's answers reflect its last verified knowledge, not necessarily today's product reality.
2. **Informational, not authoritative:** the agent's licensing, governance, and data-handling answers describe *how Microsoft's mechanisms work generally*. Company policy, negotiated agreements, and admin configuration override anything the agent says.
3. **Permissions-respecting:** the agent only retrieves knowledge its configuration allows, plus the approved read-only flow lookups in §3.8. It has no access to user files, mailboxes, or business data, and should not imply otherwise. Flow lookups return only the asking user's own information, run under IT-reviewed connections and Entra ID permissions, and their results are used within the conversation only — not stored by the agent.
4. **Language/locale:** answers assume US-English Microsoft documentation and USD list pricing concepts; regional availability and pricing differ.

## 7. Dependencies for full scope coverage

| Dependency | Status | Without it, the agent cannot… |
|---|---|---|
| Generic knowledge base (≈250 docs, sections 01–15) | 108 written, remainder planned | Answer product/routing/planning questions completely |
| **Org-specific documents (B-1 … B-10)** — licenses held, intake process, environments, data rules, existing-solution inventory, support paths, standards, costs, champions, AI policy | **Not yet authored — required from IT/CoE** | Answer "can I do this *here*?", route to real intake/support, check real license context |
| Agent instructions implementing Section 5 behaviors | To be drafted | Behave consistently at the boundaries |
| **License-check agent flow** (§3.8) — Power Automate flow + Graph/Entra permissions + IT connection review | To be built | Factor the user's real entitlements into routing; falls back to "ask your admin" guidance |
| Knowledge refresh process (quarterly/semi-annual) | Defined in map; needs an owner | Stay truthful over time |

## 8. Explicit non-goals (for stakeholder clarity)

- Replacing the helpdesk, the CoE, or human architects — the agent **feeds** them better-prepared users.
- Becoming a general-purpose chatbot — questions unrelated to AI/automation/Microsoft-stack planning are out of scope.
- Autonomous action — the agent acts only within a user's conversation: answering, generating brief documents, and running the approved read-only lookups in §3.8. It performs no write actions, takes no actions outside a conversation, and has no event/scheduled triggers.

## 9. Success looks like

- Users arrive at intake/builders with a completed automation brief and a defensible tool choice.
- Fewer "wrong tool" builds and duplicate solutions; more template reuse.
- Honest answers measurably trusted: the agent says "I don't know" or "that's not my job — here's who to ask" rather than guessing.

---

*This scope definition pairs with: the Knowledge-Base Document Map (what the agent knows), the Knowledge-Gap-Analysis section B checklist (org-specific knowledge required), and a future agent-instructions document (how the agent behaves). Review this scope quarterly alongside the High-volatility knowledge refresh.*
