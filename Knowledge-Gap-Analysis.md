# Knowledge Gap Analysis — What the Path-Finder Agent Still Needs

**Researched:** 2026-06-03 · Compared against the 236-entry Knowledge-Base-Document-Map and the 94 written Tier-1 documents.

## Summary

The existing map covers products, licensing, limits, strengths/weaknesses, integration patterns, decisions, governance, and scenarios thoroughly. Research against Microsoft's own enablement resources and industry "AI enablement agent" patterns found gaps in **three categories**:

- **A. Researchable generic knowledge** (~14 new documents) — Microsoft assets the map missed: template galleries, the Automation Kit, official project-planning methodology, ROI toolkits, case studies, an AI glossary, learning paths, troubleshooting first-aid, and roadmap-checking habits.
- **B. Organization-specific knowledge** (~10 documents **only your company can write**) — the agent can't answer "can I do this *here*?" without tenant facts: your licenses, DLP policies, intake process, environment strategy, existing automation inventory. Industry guidance is unanimous that this is what turns a generic advisor into a useful one.
- **C. Agent-behavior content** — conversation patterns that belong in the agent's *instructions*, not knowledge documents (noted briefly so they aren't mistakenly written as docs).

---

## A. Researchable gaps — proposed new map entries (Section 15: Enablement & Planning)

### D-enablement-01: Start From a Template — Copilot Studio Agent Templates and M365 Agent Gallery
- **Scope:** What prebuilt agent templates exist (Copilot Studio template gallery + adoption.microsoft.com agent examples), what each does, and how starting from a template changes the build path. Routing value: many "I want to build an agent" requests should start from a template, not from scratch.
- **Key facts:** Template gallery in Copilot Studio (incl. lite/agent builder experience); named examples (Microsoft Expert, Job Description, Travel Planner, Team Engagement); templates ship with sample instructions, starter knowledge, trigger phrases.
- **Sources:** https://adoption.microsoft.com/en-us/ai-agents/templates-and-examples/ · https://learn.microsoft.com/en-us/microsoft-365/copilot/extensibility/agent-templates-overview · https://learn.microsoft.com/en-us/microsoft-copilot-studio/guidance/agent-samples
- **Volatility:** Medium

### D-enablement-02: Power Platform Starter Solutions — Enterprise Templates, Power Automate Templates, Solution Accelerators
- **Scope:** The non-agent template landscape: Power Automate template gallery, Power Apps starter templates, and Enterprise Templates for Power Platform (full packaged solutions for HR/IT/finance use cases; require premium licensing).
- **Key facts:** Enterprise templates are install-extend-deploy solutions for central teams; premium licensing required; component-library reuse pattern.
- **Sources:** https://learn.microsoft.com/power-platform/enterprise-templates/overview
- **Volatility:** Medium

### D-enablement-03: The Automation Kit and HEAT — Managing an Automation Portfolio
- **Scope:** Microsoft's Automation Kit (distinct from the CoE Starter Kit): the Automation Project app for idea intake and approval, automatic complexity/ROI scoring, the portfolio Power BI dashboard; and HEAT (Holistic Enterprise Automation Techniques) lifecycle: Discover & plan → Design → Make → Test → Deploy → Monitor.
- **Key facts:** Automation Project app calculates complexity score + money saved on submission; business-owner approval gate before development; scatter-plot dashboard for candidate selection; verify the kit's current maintenance status (the CoE Starter Kit ceased active development Feb 2026 — confirm whether the Automation Kit followed).
- **Sources:** https://learn.microsoft.com/power-automate/guidance/automation-kit/overview/introduction · https://learn.microsoft.com/power-automate/guidance/automation-coe/heat
- **Volatility:** Medium (verify kit maintenance status)

### D-enablement-04: Planning an Automation Project — Microsoft's Official Plan/Design/Make/Test/Deploy Method
- **Scope:** The official Power Automate project-planning guidance: identify who/what/when/why, design on paper first, the make→test→deploy-and-refine loop; companion Power Apps planning-phase guidance. The agent should walk users through this when they're past "which tool" and into "how do I start."
- **Key facts:** "Solve the problem, not automate the process" trap; the 5-phase sequence with links per phase.
- **Sources:** https://learn.microsoft.com/power-automate/guidance/planning/introduction · https://learn.microsoft.com/power-automate/guidance/planning/planning-phase
- **Volatility:** Low

### D-enablement-05: Measuring Automation ROI — Business Value Toolkit, Tangible vs Intangible Value
- **Scope:** How to build the business case and measure results: time/cost savings, error reduction, productivity metrics; tangible vs intangible value framework; cost attribution/chargeback models; the Power Platform Business Value Toolkit.
- **Key facts:** Tangible/intangible examples table; before/after measurement method; chargeback guidance from the adoption docs.
- **Sources:** https://learn.microsoft.com/power-platform/guidance/adoption/business-value · https://learn.microsoft.com/power-platform/guidance/coe/business-value-toolkit · https://learn.microsoft.com/power-platform/guidance/adoption/common-vision/realize-value
- **Volatility:** Low

### D-enablement-06: Real-World Case Studies — Proof Points by Scenario
- **Scope:** A curated index of Microsoft's published case studies (Power Platform + Copilot Studio + Power Automate AI), organized by scenario type, so the agent can offer "here's a company that did what you're describing" evidence for business cases.
- **Key facts:** Cineplex generative-AI automation study (pilot → expand → CoE → Automation Kit pattern); the Learn case-studies hub; adoption.microsoft.com customer stories.
- **Sources:** https://learn.microsoft.com/power-platform/guidance/case-studies/ · https://learn.microsoft.com/power-platform/guidance/case-studies/automate-business-processes
- **Volatility:** Low

### D-enablement-07: Plain-Language AI Glossary — LLM, RAG, Agent, Grounding, Hallucination, Token, Credit
- **Scope:** A novice-friendly glossary mapping general AI vocabulary to Microsoft-specific terms (grounding = knowledge sources; orchestration = the agent's planner; Copilot Credits = the usage meter, etc.). Many users will open conversations with vocabulary confusion; the agent needs this to answer "what even is an agent vs Copilot?"
- **Key facts:** Define: LLM, generative AI, prompt, token, context window, RAG/grounding, embedding/vector, hallucination, agent vs assistant vs chatbot, orchestration, MCP, autonomous agent, human-in-the-loop, fine-tuning vs RAG.
- **Sources:** Microsoft AI Fluency learning path (https://learn.microsoft.com/training/paths/ai-fluency/) + general glossaries for cross-checking; write definitions in Microsoft-stack terms.
- **Volatility:** Low

### D-enablement-08: Learning Paths and Certifications — Skilling Map by Persona
- **Scope:** Where to send users who want to learn: per-persona Microsoft Learn paths and certifications, in-a-day workshops, and adoption training. Routing value: "I want to learn to build this myself" is a common ask.
- **Key facts:** Business user → AI Fluency, Work Smarter with AI, Copilot prompt training; Maker → Get Started with Copilot for Power Platform, App in a Day, PL-100/PL-200; Developer → PL-400, PL-500 (RPA), AI-102 (Azure AI), extensibility learning paths; Admin/adoption lead → MS-4007 enablement path, Prepare your org for M365 Copilot; architecture → PL-600.
- **Sources:** https://learn.microsoft.com/training/paths/ai-fluency/ · https://learn.microsoft.com/training/paths/copilot-power-platform/ · https://learn.microsoft.com/training/paths/explore-how-drive-adoption-microsoft-copilot-m365/ · https://learn.microsoft.com/training/paths/prepare-microsoft-365-copilot-extensibility/ · certification pages (PL-100/200/400/500/600, AI-102)
- **Volatility:** Medium

### D-enablement-09: Troubleshooting First Aid — "My Flow Failed / My Agent Won't Answer / Copilot Can't Find My File"
- **Scope:** First-response triage knowledge for the most common breakage questions users will bring to a routing agent, plus where to escalate (product support, community forums, internal admin). Not deep troubleshooting — symptom → most likely cause → first steps → who to contact.
- **Key facts:** Flow failures (connection auth expiry, throttling 429s, run-after misconfig, 14-day auto-off); agent answer failures (knowledge not indexed, 7MB/Enhanced-search trap, content moderation blocks, permission trimming); M365 Copilot "can't find" (semantic index, permissions, file location); links to official troubleshooting docs per symptom.
- **Sources:** https://learn.microsoft.com/en-us/microsoft-copilot-studio/generative-answers-sharepoint-no-response · troubleshoot.power-platform docs · Power Automate run-analytics docs
- **Volatility:** Medium

### D-enablement-10: "Can I Use This Data?" — A User-Facing Data Classification Guide
- **Scope:** The user-facing (not admin-facing) version of data governance: questions to ask about data sensitivity before automating, what sensitivity labels mean for Copilot/agents, what generally belongs in which tool, when to ask the data owner/compliance. The governance section (10) covers admin mechanics; this is the employee-decision version.
- **Key facts:** Sensitivity label inheritance basics; agents only see what the user can see (and the autonomous-agent exception); customer PII / regulated data escalation rule; generic decision questions (who owns it, classification, residency, retention).
- **Sources:** Section 10 governance entries + Purview sensitivity-label docs; tailor to company policy at deployment (overlaps with org-specific checklist B-4).
- **Volatility:** Medium

### D-enablement-11: Check the Roadmap Before You Build — Release Waves, Message Center, and Preview Discipline
- **Scope:** Teach users (and the agent) the habit of checking what's coming before building: Power Platform release planner/waves, Microsoft 365 roadmap, message center; how to treat preview features (don't build production on preview); how renames/deprecations propagate.
- **Key facts:** Release wave cadence (wave 1: Apr–Sep, wave 2: Oct–Mar); release planner tool; preview vs GA policy guidance; recent rename history as cautionary examples.
- **Sources:** https://learn.microsoft.com/power-platform/release-plan/ · roadmap.microsoft.com · admin message center docs
- **Volatility:** Low (the habit; the content refreshes itself)

### D-enablement-12: How to Brief a Builder — Turning a Routing Conversation Into an Automation Spec
- **Scope:** A template for the artifact the agent should help users produce at the end of a successful routing conversation: a one-page automation brief (problem, trigger, data sources, output surface, volume, owner, sensitivity, recommended path, license check, next steps). Bridges "I know which tool now" → "I can hand this to a maker/developer or build it myself."
- **Key facts:** Field-by-field template; maps to the requirement-elicitation doc (D-routing-02) and the Automation Project app intake fields for consistency.
- **Sources:** Derived from D-routing-02 + Automation Kit project-app fields + CAF business-strategy plan.
- **Volatility:** Low

### D-enablement-13: SharePoint Knowledge Agent and In-Product AI Helpers — the "Free" Layer Users Forget
- **Scope:** The in-product AI helpers that solve problems without any build: SharePoint Knowledge agent (preview), Copilot in the products themselves (Power Automate NL authoring, Power Apps plan designer), Microsoft Expert template agents. Routing value: sometimes the answer is "the product already does this."
- **Key facts:** SharePoint Knowledge agent capabilities/status; the existing in-product Copilots inventory; when these suffice vs a custom build.
- **Sources:** https://learn.microsoft.com/en-us/sharepoint/knowledge-agent-get-started + in-product Copilot docs already in the map (cross-reference)
- **Volatility:** High (preview features)

### D-enablement-14: Agentic AI Maturity Model — Where Is Your Team, and What Should You Attempt?
- **Scope:** Microsoft's agent adoption maturity model (learn.microsoft.com/agents) as a routing input: teams at low maturity should be steered to templates/M365 Copilot; high maturity unlocks autonomous/multi-agent recommendations. Complements D-routing-08 (which covers Power Platform adoption maturity).
- **Key facts:** The maturity stages and readiness dimensions (organization/culture, business process); how recommendations should differ by stage.
- **Sources:** https://learn.microsoft.com/en-us/agents/adoption-maturity-model/maturity-model-readiness · https://learn.microsoft.com/azure/cloud-adoption-framework/ai-agents/governance-security-across-organization
- **Volatility:** Medium

---

## B. Organization-specific knowledge — only your company can write these (template checklist)

Industry guidance (InfoWorld's "anatomy of an AI agent knowledge base," CAF governance docs, agentic KB patterns) is unanimous: **organizational context is what turns a generic advisor into a trusted one**. The agent cannot research these — they must come from your IT/CoE team. Recommended documents (one each):

| # | Document | What it must contain |
|---|---|---|
| B-1 | **Our licenses — what you already have** | Which user groups hold M365 Copilot, Power Apps/Automate Premium, Copilot Studio capacity; how to check your own entitlements; who to ask for a license |
| B-2 | **Our intake process — how to request an automation or agent** | The actual request form/channel, approval steps, SLAs, who decides; maps to D-enablement-12's brief template |
| B-3 | **Our environments — where you're allowed to build** | Default environment rules, dev/test/prod strategy, how to request an environment, managed environment policies |
| B-4 | **Our data rules — what data may go where** | Company data classification levels mapped to allowed tools/connectors; DLP policies in plain language (which connectors are blocked); regulated-data escalation contacts |
| B-5 | **Our existing automations and agents — check before you build** | Inventory/catalog of deployed solutions so users reuse instead of duplicate; where the catalog lives |
| B-6 | **Our support paths — who helps when things break** | Helpdesk vs CoE vs community channels; what each handles; how to escalate to Microsoft |
| B-7 | **Our standards — naming, ALM, ownership** | Naming conventions, solution/ALM requirements, ownership and continuity rules (what happens when a flow owner leaves) |
| B-8 | **Our costs — who pays for what** | Chargeback/cost-allocation model, budget approval thresholds for capacity packs/Azure resources |
| B-9 | **Our champions and training calendar** | Internal champions network, office hours, scheduled App-in-a-Day style events |
| B-10 | **Our AI policy — what's allowed** | Acceptable-use policy for AI, approved/blocked external AI tools, review requirements for customer-facing AI |

> **Freshness warning** (from the research): "freshness is the silent killer of AI knowledge systems." Org-specific docs go stale faster than product docs — assign each B-doc an owner and a review cadence at creation.

## C. Belongs in agent *instructions*, not knowledge documents

- Conversation flow (greet → elicit → recommend → brief → handoff), clarifying-question discipline, when to admit uncertainty, when to hand off to a human (the CoE/intake from B-2), tone, and citation behavior. The knowledge for these exists (D-routing-02, D-enablement-12); the *behavior* is instruction work — recommend drafting the agent's instruction set as a separate task.

---

## Verdict

| Category | Count | Action |
|---|---|---|
| Already covered by the 236-entry map | — | No action |
| **A. New researchable docs (Section 15)** | **14** | Add to map; write with Tier-2 batch |
| **B. Org-specific docs** | **10** | Template checklist for your IT/CoE team to fill in |
| C. Instruction-layer items | — | Draft as agent instructions, not knowledge |

New projected total: **236 + 14 = 250 generic documents**, plus 10 company-authored documents.

*Facts verified as of June 3, 2026.*
