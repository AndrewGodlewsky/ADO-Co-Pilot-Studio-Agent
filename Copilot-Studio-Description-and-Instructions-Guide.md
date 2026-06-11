# Copilot Studio Agent Description & Instructions — Format, Limits, and Best Practices

**Researched:** 2026-06-03 · Sources: Microsoft Learn (official guidance current to April 2026) + practitioner research. All links verified live this session.

## Summary

A Copilot Studio agent has two authored text surfaces that do very different jobs. The **Description** tells the *orchestrator and users* what the agent is for — it drives discovery and (for connected/child agents) routing decisions, and should be a concise, capability-focused paragraph (≤ ~1,000 characters). The **Instructions** tell the *agent itself* how to behave — they are treated "similar to code," capped at **8,000 characters**, but with a practical performance ceiling far lower (~1,000–2,500 characters works best). The biggest wins come from: structured Markdown with imperative directives, exact `/Tool` references, well-written *tool/topic/knowledge descriptions* (which do more orchestration work than the instructions themselves), and knowing the list of things instructions **cannot** change.

---

## Part 1 — The two fields and their different jobs

| | **Description** | **Instructions** |
|---|---|---|
| Audience | Users (store/discovery), admins, and the orchestrator of any *parent* agent calling this one | The agent's own orchestrator/model on every turn |
| Job | What the agent is for; when to invoke it | How to behave: which tools/knowledge when, response format, guardrails |
| Limit | ≤ ~1,000 characters guidance (M365 declarative agents); Copilot Studio field reported 1,024 — verify in product | **8,000 characters (hard)**; ~1,000–2,500 practical optimum |
| Used in orchestration? | Yes — for agent-to-agent routing and M365 Copilot invocation decisions | Yes — every turn: tool choice, input filling, response generation |
| Markdown? | No — plain sentences | Yes — explicitly supported and recommended |

**The third surface people forget:** every **tool, topic, knowledge source, and child agent** also has a name + description, and the orchestrator uses *those* — not your instructions — as its primary signal for what to call. Microsoft's guidance is explicit: write those descriptions well first; use instructions only to resolve ambiguity between them.

---

## Part 2 — The Description field

### Rules and format
- **Length:** a few sentences; ≤ 1,000 characters per Microsoft's declarative-agent best practices.
- **State purpose + domain + audience** in plain language: *"Use the Path-Finder Agent to choose the right Microsoft automation or AI tool, check what your license allows, and plan your automation project."*
- **Describe what the agent DOES, not what it doesn't do** — Microsoft explicitly recommends limiting the description to positive capability statements (negative scoping belongs in instructions).
- Active voice, present tense, keyword-rich: include the words users will actually type ("automation", "flow", "agent", "license", "Power Automate", "Copilot").
- No Markdown, no instructions-style directives — it's a summary, not a prompt.

### Why it matters more than it looks
1. **Discovery:** in Teams/M365 Copilot the description is how users decide to try the agent.
2. **Agent-to-agent routing:** if this agent is ever added as a connected/child agent, the *parent's* orchestrator chooses it (or doesn't) based on this description — same mechanics as tool descriptions.
3. **Disambiguation:** specific beats generic. "Routes employees to the right Microsoft automation tool and produces an automation brief" routes better than "Helps with automation questions."

---

## Part 3 — The Instructions field

### Hard limits and the real-world ceiling

| Threshold | What happens | Source |
|---|---|---|
| **8,000 characters** | Hard cap (UI-enforced; some pro-code paths can exceed it, which then misbehaves — don't) | Microsoft Learn (multiple pages) |
| ~2,000 characters | Orchestration precision measurably starts degrading | Practitioner research (Zen Chong) |
| ~4,000+ characters | Well into the degradation zone — "lost in the middle" attention loss + signal dilution | Practitioner research |
| **1,000–1,500 characters** | Reported sweet spot — these agents consistently outperform 6,000+ character versions | Practitioner research |

Microsoft's own wording: *"Keep it brief: instructions that are too long can lead to latency, timeouts, or issues handling the prompt."* And critically: *"The system treats agent instructions similar to code. The wrong code might break your system."* If a complex instruction set produces no responses, Microsoft's debugging advice is: remove all instructions, re-add them one at a time, testing between each.

### Recommended structure (Microsoft's component model)

Organize with Markdown headings — Markdown "isn't just for looks; it helps the AI parse your intent":

```markdown
# Purpose
One or two sentences: role and goal.

# General guidelines
- Tone and audience (only if non-default — professional/polite is already the default)
- Restrictions / out-of-scope behavior and the redirect for each

# Skills (what the agent does)
1. Numbered, ordered task definitions — atomic, one job per line

# Tool & knowledge guidance (only where ambiguous)
- IF <situation> THEN use /ToolName
- Use the FAQ knowledge only if the question is not about X or Y

# Response format
- Structure rules ("present comparisons as a table", "end with a next-step question")

# Error handling
- The "out": what to say when the answer isn't found — prevents fabrication
```

Formatting rules from Microsoft's guidance:
- `#` headings to label sections ("Objective", "Steps", "Guidelines"); **bold** for critical rules; backticks for system names; bullets for unordered rules, numbers for sequences; separate topics into separate paragraphs/list items.
- **Imperative directive style** — "When X → do Y" — beats narrative prose.
- Controlled vocabulary that the orchestrator parses well: *when, if, ensure* (conditions) · *from, include, exclude, identify* (filtering) · *get, retrieve, use, analyze, extract* (data) · *notify, direct, ask, assign* (tools).

### Referencing tools, topics, variables, and child agents
- Type **`/`** in the instructions editor to insert an exact reference (`/Purchase_Order`, a topic, a variable, a Power Fx expression). **Exact names matter** — "slight differences in naming can negatively affect results."
- Don't enumerate all tools/knowledge in instructions — the orchestrator already knows them. Add guidance **only** where choice is ambiguous, or when there are many tools (>5) and sequencing matters.
- The heavy lifting belongs in each tool/topic/knowledge **description**: short (1–2 sentences), specific, keyword-rich, unique vs siblings, and stating what it *doesn't* do if it gets called wrongly ("Provides current weather. It doesn't get forecasts for future days.").

### What instructions CANNOT do (don't waste characters trying)

| Can't change | Do this instead |
|---|---|
| Default fallback message | Edit Topics → System → Fallback |
| Adaptive Card triggering/behavior | Edit the card and its trigger phrases directly |
| Search/document retrieval logic | Remove any such instructions — they do nothing |
| How retrieved documents are shared | System-controlled |
| **Citation format or behavior** | Never use the words "citation"/"reference" in instructions — interfering breaks answer display |
| Reliable multilingual behavior | Use the multilingual feature, not instructions |
| Hard topic bans (reliably) | Create a topic with a manually authored response for that subject |

### Security and anti-patterns
- **Never offload instructions into knowledge documents** to dodge the 8,000-character limit. Microsoft's warning is explicit: knowledge content is untrusted, runs through cross-prompt-injection (XPIA) classifiers that can block or sanitize directive-like language, and anyone with edit rights to the document can change agent behavior, bypassing versioning/governance. *(Note: some community articles recommend moving tone/personality text into knowledge docs — Microsoft's official guidance contradicts this; follow Microsoft.)*
- For agents with **event triggers**: trigger payloads are a jailbreak surface. Constrain in instructions which tools may act on knowledge-derived content and which parameter values are allowed (e.g., "only email addresses from the approved list"); trim trigger payloads to the minimum fields in Power Automate.
- Give the agent an **"out"** ("respond 'not found' if the answer isn't present") — the single most effective anti-hallucination instruction.
- Guardrail pattern for scope: *"Only respond to messages relevant to <domain>. Otherwise, tell the user you can't help with their inquiry."*
- Avoid vague phrases ("the typing box") and undefined acronyms — define non-standard terms in a dedicated instructions section if users will use them.

### Per-node custom instructions (separate budget)
Generative answers nodes support **prompt modification / custom instructions** with their **own 8,000-character limit**, plus variables and Power Fx. Use node-level instructions for topic-specific formatting ("list products with Name, SKU, Price") instead of burning agent-level characters.

---

## Part 4 — Skeleton for the Path-Finder Agent (applying all of the above)

**Description (draft, ~340 chars):**
> Use the Path-Finder Agent to find the right Microsoft tool for your automation or AI idea — Microsoft 365 Copilot, Copilot Studio, Power Automate, Power Apps, or Azure AI Foundry. It explains capabilities, limits, and licensing, checks which licenses you hold, and helps you produce an automation brief ready to hand to a builder.

**Instructions budget plan (target ≤ 2,500 chars total):**

| Section | Budget | Content source |
|---|---|---|
| Purpose | ~150 | Scope doc §1 mission sentence |
| Elicitation rule | ~300 | "Ask up to 3 clarifying questions (trigger, data, output, volume, sensitivity, license) before recommending" |
| Skills (route → explain → brief → handoff) | ~600 | Scope doc §3, compressed to one line per skill |
| Tool guidance | ~250 | "To check the user's licenses, use /License_Check. If it fails, explain how to check manually — do not block." |
| Guardrails + redirects | ~600 | Scope doc §4 table, compressed to "Never X — instead Y" lines (top 6 only) |
| Response format | ~200 | "Front-load the recommendation; cite knowledge sources; end with next step" |
| Error handling / out | ~200 | "If the knowledge base doesn't cover it, say so and route to <intake>" |

Everything else (the full out-of-scope list, persona detail, deep methodology) stays in the **knowledge base** where it belongs — retrieved when relevant instead of taxing every turn.

## Part 5 — Test-and-iterate loop (Microsoft's recommended process)

1. Draft instructions → test in the test pane against expected *and* off-script questions.
2. Verify the agent actually follows each instruction; check citations render.
3. If behavior breaks: strip instructions, re-add one at a time, test between each.
4. Compare with/without each section — delete anything that doesn't change behavior (practitioner heuristic: cut 20% per iteration and re-test).
5. Watch analytics after launch and refine; treat instruction edits like code changes (version them in your solution/ALM).

## Sources

- [Write agent instructions (official)](https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-instructions) — `/` references, object types, links to deeper guidance
- [Configure high-quality instructions for generative orchestration (official, Apr 2026)](https://learn.microsoft.com/en-us/microsoft-copilot-studio/guidance/generative-mode-guidance) — the core page: vocabulary, grounding, tool sequencing, what instructions can't do, trigger security
- [Orchestrate agent behavior with generative AI — authoring descriptions](https://learn.microsoft.com/en-us/microsoft-copilot-studio/advanced-generative-actions) — tool/topic/knowledge description best practices with good/bad examples
- [Best practices for building declarative agents](https://learn.microsoft.com/microsoft-365/copilot/extensibility/declarative-agent-best-practices) — name/description/instruction limits table (30-char name, ≤1,000-char description, 8,000-char instructions)
- [Write effective instructions for declarative agents](https://learn.microsoft.com/microsoft-365/copilot/extensibility/declarative-agent-instructions) — component model, the XPIA warning against offloading instructions to knowledge
- [Use prompt modification (custom instructions on generative answers nodes)](https://learn.microsoft.com/microsoft-copilot-studio/nlu-generative-answers-prompt-modification) — node-level 8,000-char budget, variables, Power Fx, "give the agent an out"
- [Optimize prompts with custom instructions](https://learn.microsoft.com/en-us/microsoft-copilot-studio/guidance/optimize-prompts-custom-instructions) — role, format, audience, refinement practices
- [Employee Self-Service design best practices](https://learn.microsoft.com/microsoft-365/copilot/employee-self-service/design-best-practices) — Markdown-in-instructions rationale, tone-by-scenario examples
- [Quotas and limits](https://learn.microsoft.com/en-us/microsoft-copilot-studio/requirements-quotas) — authoritative limits reference
- [Your agent's instructions are 4,200 characters — performance is degrading (Zen Chong)](https://zenchong.substack.com/p/your-copilot-studio-agents-instructions) — practitioner degradation thresholds and restructuring method *(community source; its "move tone to knowledge docs" advice conflicts with Microsoft's XPIA guidance — follow Microsoft on that point)*
- [Agent Instruction Lab (Copilot Developer Camp)](https://microsoft.github.io/copilot-camp/pages/copilot-instructions/beginner-agent/) — official hands-on instruction-writing lab

*Facts verified as of June 3, 2026. Volatility: Medium — re-verify limits and guidance semi-annually (the guidance page was updated April 2026; orchestration models change).*
