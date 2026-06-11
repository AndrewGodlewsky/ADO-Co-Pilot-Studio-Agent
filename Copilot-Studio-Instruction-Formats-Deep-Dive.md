# Copilot Studio Instructions — Format Variations, Tool & Knowledge Steering, and Format Control on a Budget

**Researched:** 2026-06-03 · Method: 4 parallel research agents over Microsoft Learn (official guidance current to April 2026), Microsoft agent templates, and practitioner sources. All URLs verified live.

## TL;DR — the three answers

1. **Telling the agent when to use Power Automate flows:** the orchestrator picks tools by **name first, description second, parameter descriptions third — instructions are only a fourth-layer tiebreaker**. The optimal pattern is: verb-phrase tool name + a description that says *when to use it and when not to* + instructions that only resolve ambiguity using exact `/Tool_Name` references. Below ~5 well-named tools, you barely need instruction-side steering at all.
2. **Guiding to the correct knowledge:** there are **two separate decision layers** — the orchestrator picks *which source* by its name/description; semantic search then ranks *content* inside it (and instructions **cannot** influence that inner ranking — Microsoft says to delete any that try). Steer with source names/descriptions, stay at/under **25 sources** (above that, a description-only GPT pre-filter decides what's even searched), and **pin** high-stakes question types to specific sources with a generative-answers node inside a topic.
3. **Semi-formatted responses without burning instruction budget:** distribute format rules across surfaces that have **their own budgets** — per-node custom instructions (8,000 chars *each*), topics with deterministic message nodes/Adaptive Cards, required tool inputs (free clarifying questions), and tool "After running" templated responses. Keep agent-level instructions to ~3 short global format rules. One gotcha can silently kill clarifying questions entirely (see Part 4).

---

## Part 1 — Instruction format variations (the catalog)

### The format families and who endorses them

| # | Format | Endorsement | Best for | Caveat |
|---|---|---|---|---|
| A | **Markdown component model** — `# Purpose / # Guidelines / # Skills` (+ optional Steps, Error handling, Examples, Terms) | Microsoft's canonical model; used in Copilot Developer Camp labs | Default for most agents | Verbose if undisciplined |
| B | **Constraints / Response-format / Guidance triad** | Microsoft's prescribed pattern for conversational Q&A agents | Knowledge-heavy Q&A agents | Less suited to multi-step workflows |
| C | **Numbered step lists** (each step = Goal/Action/Transition) | Microsoft, for sequential/autonomous agents | True sequences only | Numbering *forces* ordering under GPT-5.1 — use bullets for parallel rules |
| D | **IF/THEN imperative directives** ("When X → do Y", ≤10–15 words each) | Microsoft "explicit decision rules" pattern + practitioner consensus | Branching decisions, guardrails | Brittle for fuzzy intents |
| E | **ALL-CAPS plain-text sections** (ROLE DEFINITION → TOOL USAGE GUIDELINES → RESPONSE FORMATTING) | Microsoft's shipping process-mining agent template | Tool-rich agents; headers survive model upgrades | Cosmetically equivalent to Markdown headings |
| F | **Output contract block** — a `## Output Contract (Mandatory)` section: Goal/Format/Include/Exclude | Microsoft pattern | Locking response shape across model versions | Costs ~200–400 chars |
| G | **Few-shot example blocks** (one Valid + one Invalid exchange) | Microsoft's IT-support example; CIAOPS ("examples beat abstract rules") | Complex/edge-case formats | 1–3 compact examples max; watch verbatim-phrase reuse |
| H | XML-style tags | **Not** endorsed for Copilot Studio instructions (general prompt-engineering practice only) | — | Low evidence on this platform; voice agents use JSON instead |
| I | "When user says X" tables | Weak first-party support | — | Microsoft steers per-utterance handling into **Topics**, not instructions |

### What Microsoft's own templates actually look like

**Process-mining template** (tool-heavy agent): `ROLE DEFINITION → PRIMARY OBJECTIVE → DATA SOURCES AND GROUNDING RULE → TOOL USAGE GUIDELINES → ANALYSIS PRINCIPLES → BEHAVIOR AND TONE → RESPONSE FORMATTING` — and when trimming for the 8,000-char limit, Microsoft says keep **TOOL USAGE** and **DATA SOURCES** and cut tone first. That's an explicit priority ranking of section value.

**IT-support example** (Markdown): `# OBJECTIVE → # RESPONSE RULES (one clarifying question at a time; confirm before next step) → # WORKFLOW (## Step 1..4, each Goal/Action/Transition) → # OUTPUT FORMATTING RULES → # EXAMPLES (## Valid / ## Invalid)`.

**Benefits agent** (triad): Constraints ("only respond to…benefits…tabular format") + Response format (columns, enrollment link) + Guidance ("search only within the employee's country folder").

### Model-generation effects and placement strategy

- **GPT-5.0-era models are literal-first** (honor structure exactly); **GPT-5.1+ are intent-first** (may reorder steps, fuse tasks, drift tone). Formatting is itself a control signal: explicit/complete structure → strict execution; goal-only prose → adaptive planning.
- If an upgrade destabilizes behavior, add a **literal-execution header at the very top**: "Interpret instructions literally. Never infer intent or fill missing steps. Follow step order exactly. Do not call tools unless a step says so."
- **Placement ("lost in the middle"):** primary directives **first**; output contract and a **self-evaluation gate** ("before finalizing, confirm the response includes everything in Output Contract") **last**; the middle is the lowest-attention zone — never put critical guardrails there.
- No rigorous public A/B of format families exists; the closest first-party method is **Agent Evaluation** test sets — baseline, change one thing, re-score. The practitioner heuristic stands: 1,000–1,500 chars outperforms 6,000+.

---

## Part 2 — Steering Power Automate flows (tools)

### The signal priority (what actually drives tool choice)

1. **Tool NAME** — "names carry more weight than descriptions." `Check_User_Licenses` beats `Flow1` before you write a word of instructions.
2. **Tool DESCRIPTION** — the main intent-matching signal; also used to decide what *not* to call and to auto-generate input-collection questions.
3. **Input/output parameter names + descriptions** — drive slot-filling and whether the agent uses returned data.
4. **Agent instructions** — disambiguation, sequencing, input-filling hints, guardrails. The planner also sees the **last 10 conversation turns**.

Microsoft's threshold: instruction-side `/Tool` steering becomes valuable at **>5 tools**; selection accuracy degrades from **30–40 total "choices"** (tools + topics + connected agents combined); recommended ceiling **25–30 tools** (hard max 128). *(The "~70 tools" figure circulating in community posts could not be verified.)* When you approach the threshold: tighten descriptions first, then split into child agents.

### The pattern library (verbatim-style, from Microsoft guidance)

| Goal | Pattern |
|---|---|
| Force a tool at the right moment | "When the user asks what they can build or what it will cost, check their entitlements using **/Check_User_Licenses**." |
| Scope negatively | "Use **/Check_User_Licenses** only when license context affects the recommendation. Never call it for general product questions." |
| Sequence tools | Numbered steps + "follow these steps in order": "1. Identify the need. 2. **/Check_User_Licenses**. 3. Search knowledge for the matching path. 4. Recommend." |
| Stop interrogation | "Don't ask the user for any details." |
| Fill inputs from context | "Use the user's UPN from the conversation context as the userId input." |
| Failure fallback | "If **/Check_User_Licenses** fails or returns nothing, explain how to check licenses manually and continue — do not block the conversation." |

Rules: exact name match (slight differences "negatively affect results"), always use the `/` mechanic, and don't enumerate tools the agent already knows — only add lines that resolve real ambiguity.

### Failure → fix table

| Symptom | Cause | Fix |
|---|---|---|
| Never calls the flow | Generic name/description; "allow agent to decide dynamically" unchecked | Verb-phrase name; description with *when to use*; enable dynamic use; add `/Tool` instruction |
| Calls wrong/multiple tools | **Overlapping descriptions** | Differentiate; add "only when…/never when…"; remove redundant tools |
| Invents inputs | Undescribed inputs | Name + describe every input; for known values set **Fill using = Custom value** so it never asks or guesses |
| Asks users for things it shouldn't | Default AI slot-filling | "Don't ask the user for details" + Custom value fills |
| Ignores flow results in the answer | Unnamed outputs; wrong completion mode; bare JSON arrays | Named, described outputs in **Respond to the agent**; completion = "Don't respond" (agent folds data into answer); keyed JSON objects only (`[{"f":"v"}]` works, `["v"]` doesn't) |
| Schema errors (`FlowActionBadRequest`) | Flow edited but not refreshed | Republish flow, refresh in Copilot Studio |

### Flow-side design rules (for your license-check flow)

- Trigger **When an agent calls the flow** + **Respond to the agent**, async OFF, respond within **100 seconds**, published.
- Output names are part of the steering surface: `HasM365Copilot`, `PowerAppsPlan`, `CopilotStudioAccess` — each with a description — not `Output1`.
- Model choice matters: **Deep/reasoning-tier models** (GPT-5.x Reasoning, Claude Sonnet) measurably improve multi-tool selection; deep reasoning can be forced per-step with the keyword `reason` but costs more credits and latency.

---

## Part 3 — Steering knowledge selection

### The two-layer mental model (most "wrong source" problems come from conflating these)

- **Layer 1 — source selection (orchestrator, description-driven):** which knowledge sources get searched. Signals: source **name + description**. Above **25 sources**, an internal GPT pre-filter ranks sources *by description alone* and shortlists — a badly described source silently stops being searched. (Uploaded files don't count toward the 25.)
- **Layer 2 — retrieval inside a source (semantic, content-driven):** which chunks come back. Driven by document content/titles/headings. **Instructions cannot touch this layer** — Microsoft: "Remove any instructions that attempt to influence document retrieval." Custom SharePoint metadata columns are **not indexed** (built-in Title/Author/Modified are); Azure AI Search is the workaround for metadata-filtered retrieval.

**Consequence:** you fix Layer-1 problems with names/descriptions and instructions; you fix Layer-2 problems with document structure and source scoping — never with prompts.

### The scoping pattern menu

| Pattern | Strength | Use when |
|---|---|---|
| **Agent-level sources** with crisp, non-overlapping descriptions | Probabilistic | Default; ≤~25 sources; cross-domain questions |
| **Topic + generative answers node with pinned sources** (node sources OVERRIDE agent level; agent level becomes fallback) | **Deterministic** | High-stakes intents that must answer only from specific sources (e.g., licensing questions → licensing folder only). Trigger the topic by description ("the agent chooses") |
| **File groups** (GA from 2025 wave 2): up to 25 groups × 500 files, each group has name + description + its own **Instructions field**; two-stage retrieval (instructions pick the file, then chunks within it) | Semi-deterministic | Many *uploaded* files varying by a known factor (region/tier). **Uploaded files only — no SharePoint**; needs Dataverse search |
| **Instruction steering** ("Search <source> for <topic>"; "Use the FAQ documents only if not about Hours, Appointments, or Billing") | Light nudge | Routing is mostly right, occasionally off; numerous documents |

### Structuring a 100+ document KB (directly applicable to your ~250-doc library)

- **Split, don't dump:** add specific SharePoint **folders** as separate knowledge sources (your per-section folders → one source per section), each with a distinguishing description including what it does **not** cover. Community testing consistently shows scoped folder sources beat one whole-site source on accuracy and noise.
- **Stay at/under ~25 sources** so every source is always considered without the description pre-filter. (Your 15 section folders fit comfortably.)
- **Turn on Work IQ / Enhanced search** (M365 Copilot license in tenant) — "significantly better knowledge retrieval."
- Use SharePoint **advanced filters** (e.g., Modified ≥ date) to stop stale versions winning retrieval; avoid near-duplicate docs — they split citations and compete.
- To force honest "not found" behavior: disable Web Search + agent-level and node-level general knowledge.

### Diagnosing wrong-knowledge answers

The **activity map** (test pane + Activity page) is the tool: select the knowledge node to see the **rewritten query** the agent actually searched, which sources it cited, and — crucially — **"other sources searched but not used."** That distinguishes *wrong source selected* (fix descriptions) from *selected but outranked* (fix content/scoping). Reasoning models also expose a **Rationale/chain-of-thought** for why a source or tool was chosen.

---

## Part 4 — Formatted responses & clarifying questions without burning the budget

### The menu of format-control surfaces (each with its OWN budget)

| Surface | Budget | Deterministic? | Best for |
|---|---|---|---|
| Agent instructions | 8,000 chars total | No | 2–4 global style rules only |
| **Generative answers node custom instructions** | **8,000 chars per node** | No | Per-topic answer shaping; supports variables + Power Fx |
| **Topic Message nodes** | Per node | **Yes** | Fixed wording, Power Fx-formatted strings, variable insertion |
| **Adaptive Cards** | JSON per card | **Yes** (layout) | Rich layouts, buttons, structured intake |
| **Question nodes + entities** | Per node | **Yes** | Multiple-choice clarifying questions, validation, 2 reprompts |
| **Required tool inputs** | Per input | Semi | **Free elicitation** — agent auto-asks for missing required inputs |
| Tool descriptions | Short | No | Embedded format hints ("send emails using rich text formatting") |
| Tool "After running" = Send specific response / adaptive card | Per tool | **Yes** | Templated tool-result output |
| Per-trigger instructions | Per trigger | No | Use-case-specific behavior for event triggers |

### Clarifying questions — three mechanisms, one killer gotcha

1. **LLM follow-ups via instructions** (cheapest): "End each response with one relevant follow-up question based on your available tools." Listing tools in instructions measurably improves follow-up relevance.
   ⚠️ **THE GOTCHA:** if **"Allow ungrounded responses" is OFF**, the orchestrator suppresses citation-less clarifying questions and replaces them with the generic fallback ("I'm sorry, I'm not sure how to help with that"). Consistent LLM-asked clarifying questions effectively **require that setting ON**. If policy forces it off, use mechanisms 2–3.
2. **Required tool/child-agent inputs** (free + semi-deterministic): mark elicitation fields (trigger type, data source, volume…) as required inputs on a tool/child agent — the agent auto-asks for whatever context can't fill, with customizable wording, validation conditions, and 2 reprompts. **Zero instruction characters.**
3. **Authored Question nodes with entities** (fully deterministic): buttons, entity validation, synonyms, proactive multi-slot filling. Use for high-stakes structured intake (your automation-brief interview).

### Channel rendering — the trap in "respond as a table"

- **Web chat:** full Markdown (tables, headings) renders fine.
- **Teams text messages:** **Markdown tables are NOT supported**; lists render inconsistently on mobile.
- **Adaptive Card TextBlock:** bold/italic/lists/links only — **no tables or headers**; tables need `ColumnSet`/`FactSet` layouts.
- Implication: "format comparisons as a table" looks great in the test pane and **degrades in Teams**. If Teams is your main channel, enforce comparisons via Adaptive Cards (ColumnSet) in a topic, or instruct bold-label bullet lists instead of tables.

### Few-shot economics

Official guidance and practitioner consensus agree: **one compact worked example beats several abstract rules**, but keep it to 1–3 and put each example **where the output is produced** — in the node-level custom instruction for topic-specific formats; agent-level only for a global pattern. Negative constraints boost adherence: *"Format as steps starting 'Step 1:'… Don't use a numbered list."*

### The hybrid architecture (Microsoft's own recommendation)

> Small global instruction layer + deterministic enforcement for everything high-stakes.

- Agent instructions carry ~3 lines: follow-up-question rule, comparison-format rule, honesty/"out" rule.
- Each high-stakes output (automation brief, licensing comparison) gets a **topic**: description-triggered, with pinned knowledge sources, a node-level custom instruction (its own 8,000 chars), and/or an Adaptive Card.
- Elicitation rides on **required inputs** instead of instruction text.
- Cost to the 8,000-char agent budget: **near zero**.

---

## Part 5 — Recommended architecture for the Path-Finder Agent

| Concern | Mechanism | Instruction-budget cost |
|---|---|---|
| When to call the license-check flow | Tool name `Check_User_Licenses` + description "Returns the asking user's Microsoft licenses. Use when license context affects a recommendation; never for general product questions." | 1 line: failure fallback only |
| Right knowledge per question type | 15 section folders = ~15 sources with non-overlapping descriptions (under the 25 pre-filter cap); licensing + scenario topics pin their sources via generative answers nodes | 1–2 lines of negative steering |
| Clarifying-question interview | Required inputs on the brief-builder tool/child agent (trigger, data, output, volume, sensitivity) → auto-elicitation | 0 chars |
| Automation-brief output format | Dedicated topic; node-level custom instruction with ONE worked example (uses the node's own 8,000 chars) | 0 chars |
| Comparison formatting | Global rule + Adaptive Card ColumnSet in comparison topics if Teams is primary | ~80 chars |
| Honesty/"out" | Last line of instructions (high-attention end position): "If your knowledge doesn't cover it, say so and route to <intake>." | ~90 chars |
| Format stability across model upgrades | Output-contract section + optional literal-execution header after upgrades; baseline with Agent Evaluation before/after changes | ~300 chars |

Projected agent-level instructions: **well under 1,500 characters** — inside the empirically best-performing band — with every high-stakes behavior enforced deterministically elsewhere.

## Sources

**Official (Microsoft Learn):** [Configure high-quality instructions for generative orchestration](https://learn.microsoft.com/microsoft-copilot-studio/guidance/generative-mode-guidance) · [Orchestrate agent behavior / authoring descriptions](https://learn.microsoft.com/microsoft-copilot-studio/advanced-generative-actions) · [Write agent instructions](https://learn.microsoft.com/microsoft-copilot-studio/authoring-instructions) · [Add tools to custom agents](https://learn.microsoft.com/microsoft-copilot-studio/add-tools-custom-agent) · [Create/call agent flows](https://learn.microsoft.com/microsoft-copilot-studio/advanced-flow-create) · [Generative orchestration FAQ](https://learn.microsoft.com/microsoft-copilot-studio/faqs-generative-orchestration) · [Add other agents (30–40 choices threshold)](https://learn.microsoft.com/microsoft-copilot-studio/authoring-add-other-agents) · [Select a primary AI model](https://learn.microsoft.com/microsoft-copilot-studio/authoring-select-agent-model) · [Deep reasoning models](https://learn.microsoft.com/microsoft-copilot-studio/authoring-reasoning-models) · [Knowledge sources summary (25-source filter, Work IQ, ungrounded setting)](https://learn.microsoft.com/microsoft-copilot-studio/knowledge-copilot-studio) · [File groups](https://learn.microsoft.com/microsoft-copilot-studio/knowledge-file-groups) · [Add SharePoint knowledge (filters)](https://learn.microsoft.com/microsoft-copilot-studio/knowledge-add-sharepoint) · [Review agent activity (activity map)](https://learn.microsoft.com/microsoft-copilot-studio/authoring-review-activity) · [Prompt modification (node custom instructions)](https://learn.microsoft.com/microsoft-copilot-studio/nlu-generative-answers-prompt-modification) · [Slot-filling best practices](https://learn.microsoft.com/microsoft-copilot-studio/guidance/slot-filling-best-practices) · [Add a child agent (required inputs)](https://learn.microsoft.com/microsoft-copilot-studio/add-agent-child-agent) · [Publish channels (rendering table)](https://learn.microsoft.com/microsoft-copilot-studio/publication-fundamentals-publish-channels) · [Adaptive Cards text features](https://learn.microsoft.com/adaptive-cards/authoring-cards/text-features) · [Process-mining agent template (system prompt)](https://learn.microsoft.com/power-automate/process-mining-mcp-create-cps-agent) · [Declarative agent instructions](https://learn.microsoft.com/microsoft-365/copilot/extensibility/declarative-agent-instructions) · [JSON output for flows](https://learn.microsoft.com/microsoft-copilot-studio/process-responses-json-output)

**Practitioner/community:** [Copilot Developer Camp — Agent Instruction Lab](https://microsoft.github.io/copilot-camp/pages/copilot-instructions/beginner-agent/) · [CIAOPS — Crafting Effective Instructions](https://blog.ciaops.com/2025/08/06/crafting-effective-instructions-for-copilot-studio-agents/) · [Zen Chong — instruction length degradation](https://zenchong.substack.com/p/your-copilot-studio-agents-instructions) · [Lee Ford — SharePoint metadata not indexed](https://www.lee-ford.co.uk/posts/sharepoint-knowledge-sources-in-copilot-studio-the-metadata-problem/) · [GPT-5 in Copilot Studio (official blog)](https://www.microsoft.com/en-us/microsoft-copilot/blog/copilot-studio/available-today-gpt-5-in-microsoft-copilot-studio/)

*Facts verified as of June 3, 2026. Volatility: Medium-High — orchestration models and thresholds change; re-verify quarterly alongside the KB licensing refresh.*
