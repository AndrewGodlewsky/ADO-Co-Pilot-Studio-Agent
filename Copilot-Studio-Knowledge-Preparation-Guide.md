# Copilot Studio Knowledge Preparation — How Much, and In What Format

**Researched:** 2026-06-03 · All links verified live via web search and Microsoft Learn docs search this session.

This document answers two questions for anyone preparing knowledge sources for a Microsoft Copilot Studio agent:

1. **How much knowledge should you feed an agent?** (limits, quotas, and the quality-vs-quantity guidance)
2. **What format does Copilot Studio absorb best?** (file types, document structure, and known gotchas)

It ends with a checklist applied to this project's 94-document knowledge base.

---

## Part 1 — Key findings (the short version)

### Format: what Copilot Studio actually retrieves

| Finding | Detail | Source |
|---|---|---|
| **Supported formats (SharePoint knowledge)** | Modern SharePoint pages, **.docx**, **.pptx**, **.pdf** only | [Generative answers — supported content](https://learn.microsoft.com/en-us/microsoft-copilot-studio/nlu-boost-node) |
| **Markdown (.md) does NOT work** | .md files in SharePoint libraries are not retrievable or citable as knowledge | [TechCommunity confirmation](https://techcommunity.microsoft.com/discussions/copilot-studio/copilot-studio--sharepoint-markdown--md-files-in-doc-libraries-supported-as-know/4517314) |
| **JSON/TXT/CSV don't work either** | Structured/raw data files produce no results or non-clickable citations; convert to doc-style content or serve via Azure AI Search / custom knowledge | [Microsoft Q&A](https://learn.microsoft.com/en-us/answers/questions/5840273/copilot-studio-local-json-text-knowledge-sources-r) |
| **Heading hierarchy matters** | Clear H1/H2/H3 structure helps the agent identify sections, understand topic relationships, and retrieve the right chunk | [Optimize content retrieval](https://learn.microsoft.com/en-us/microsoft-365-copilot/extensibility/optimize-sharepoint-content) |
| **Size guidance per file** | Keep files to ~36,000 characters (~15–20 pages) for optimal retrieval | [Optimize content retrieval](https://learn.microsoft.com/en-us/microsoft-365-copilot/extensibility/optimize-sharepoint-content) |
| **One topic per document** | Scannable, topic-focused content with the answer up front retrieves and summarizes best | [Employee Self-Service optimization](https://learn.microsoft.com/en-us/microsoft-365/copilot/employee-self-service/optimization-sharepoint) |
| **Tables caveat** | The M365 Copilot retrieval-optimization guidance warns table parsing can be weak in some retrieval paths — pair tables with prose equivalents | [Optimize content retrieval](https://learn.microsoft.com/en-us/microsoft-365-copilot/extensibility/optimize-sharepoint-content) |
| **Metadata helps** | Rich, consistent SharePoint metadata (document type, owner, review date) improves filtering and grounding precision | [Employee Self-Service optimization](https://learn.microsoft.com/en-us/microsoft-365/copilot/employee-self-service/optimization-sharepoint) |

### Amount: how much knowledge an agent can (and should) hold

| Finding | Detail | Source |
|---|---|---|
| **Hard cap: 500 knowledge objects** per agent (files, folders, sites, articles) | This is the ceiling, not the target | [Quotas and limits](https://learn.microsoft.com/en-us/microsoft-copilot-studio/requirements-quotas) |
| **The 7 MB / 200 MB trap** | Without an M365 Copilot license in the tenant, generative answers silently use only SharePoint files **under 7 MB**; with the license + **Enhanced search results (Work IQ) turned ON**, files up to **200 MB** work | [SharePoint no-response troubleshooting](https://learn.microsoft.com/en-us/microsoft-copilot-studio/generative-answers-sharepoint-no-response) |
| **Direct upload: 512 MB/file** | Uploaded files are chunked and vector-indexed in Dataverse; storage counts against Dataverse capacity | [Uploaded files with generative answers](https://learn.microsoft.com/en-us/microsoft-copilot-studio/nlu-documents) |
| **No control over chunking** | Dataverse applies undocumented default chunking parameters — you tune retrieval through document structure, not chunking settings | [Knowledge limitations guide (community)](https://github.com/Rickcau/Copilot-Studio/blob/main/Knowledge_Source_Limitations_Solutions/copilot-studio-knowledge-limitations-guide.md) |
| **~15-snippet answer budget** | Generative answers use up to 15 snippets (across ALL knowledge topics combined) to compose a response — precision beats volume | [Custom knowledge sources](https://learn.microsoft.com/en-us/microsoft-copilot-studio/guidance/custom-knowledge-sources) |
| **Custom data nodes: first 3 records only** | When passing custom data tables to a generative answers node, only the first three records are used | [Custom data sources](https://learn.microsoft.com/en-us/microsoft-copilot-studio/nlu-generative-answers-custom-data) |
| **Quality over quantity** | Microsoft's clearest statement: curate the most relevant, authoritative content; sample quality matters more than raw volume | [Copilot Tuning knowledge selection](https://learn.microsoft.com/en-us/copilot/microsoft-365/copilot-tuning-knowledge-selection) |

**The practical "ideal amount" formula that emerges from these sources:** there is no magic number of documents — the constraints are *500 objects max*, *~36k characters per file*, and *15 retrieved snippets per answer*. The optimum is therefore **many small, single-topic, well-headed documents** (so the right chunk wins retrieval) rather than few large ones (where the right answer competes with unrelated content inside the same file). Curate ruthlessly: stale or near-duplicate content actively degrades answers because it competes for those 15 snippet slots.

---

## Part 2 — Annotated link library

### Official Microsoft documentation — format & structure

- [Knowledge sources summary](https://learn.microsoft.com/en-us/microsoft-copilot-studio/knowledge-copilot-studio) — the canonical overview: all supported source types, how knowledge is selected at answer time, content moderation.
- [Use generative answers in a topic](https://learn.microsoft.com/en-us/microsoft-copilot-studio/nlu-boost-node) — the definitive supported-format list for SharePoint sources (modern pages, docx, pptx, pdf) plus moderation settings.
- [Unstructured data as a knowledge source](https://learn.microsoft.com/en-us/microsoft-copilot-studio/knowledge-unstructured-data) — how files are chunked, vector-indexed in Dataverse, and semantically matched; explains *why* structure drives retrieval quality.
- [Optimize Content Retrieval in Your Agent](https://learn.microsoft.com/en-us/microsoft-365-copilot/extensibility/optimize-sharepoint-content) — the most concrete official formatting guidance: heading hierarchy, ~36,000-character file size, scannability, the tables warning.
- [Optimizing SharePoint content for Employee Self-Service agents](https://learn.microsoft.com/en-us/microsoft-365/copilot/employee-self-service/optimization-sharepoint) — heading consistency, metadata tagging, and information architecture for agent grounding.
- [Add SharePoint as a knowledge source](https://learn.microsoft.com/en-us/microsoft-copilot-studio/knowledge-add-sharepoint) — mechanics: site vs folder vs file URL scoping.
- [Use SharePoint content for generative answers](https://learn.microsoft.com/en-us/microsoft-copilot-studio/nlu-generative-answers-sharepoint-onedrive) — authentication requirements and how SharePoint content is searched.
- [Upload files as knowledge / use uploaded files](https://learn.microsoft.com/en-us/microsoft-copilot-studio/nlu-documents) — the direct-upload alternative: 512 MB/file, stored in Dataverse, unsupported file types listed.

### Official Microsoft documentation — amounts, limits & quotas

- [Quotas and limits](https://learn.microsoft.com/en-us/microsoft-copilot-studio/requirements-quotas) — the hard numbers: 500 knowledge objects/agent, SharePoint web-app limits, rate limits.
- [Generative answers pointing to SharePoint don't return results](https://learn.microsoft.com/en-us/microsoft-copilot-studio/generative-answers-sharepoint-no-response) — the 7 MB vs 200 MB licensing-dependent file limit and the Enhanced search results toggle; the #1 silent failure.
- [FAQ for generative answers](https://learn.microsoft.com/en-us/microsoft-copilot-studio/faqs-generative-answers) — official answers on citation behavior, freshness/indexing delay, and source priority.
- [Custom knowledge sources](https://learn.microsoft.com/en-us/microsoft-copilot-studio/guidance/custom-knowledge-sources) — the 15-snippet answer budget (shared across all knowledge topics) and the OnKnowledgeRequested trigger for bring-your-own-search.
- [Custom data for generative answers nodes](https://learn.microsoft.com/en-us/microsoft-copilot-studio/nlu-generative-answers-custom-data) — only the first 3 records of a custom data table are used; node-level sources override agent-level sources.

### Official Microsoft guidance — instructions & answer quality (knowledge's other half)

- [Write agent instructions](https://learn.microsoft.com/en-us/microsoft-copilot-studio/authoring-instructions) — official instruction-writing guidance, including the rule to never reference "citations" in instructions.
- [Configure high-quality instructions for generative orchestration](https://learn.microsoft.com/en-us/microsoft-copilot-studio/guidance/generative-mode-guidance) — how instructions steer when/which knowledge gets consulted.
- [Optimize prompts and topic configuration](https://learn.microsoft.com/en-us/microsoft-copilot-studio/guidance/optimize-prompts-topic-configuration) — guardrails and configuration practices that reduce wrong answers.
- [Knowledge in Microsoft Copilot Studio (Power Platform blog, Mar 2025)](https://www.microsoft.com/en-us/power-platform/blog/2025/03/27/knowledge-in-microsoft-copilot-studio/) — Microsoft's own architectural explainer of the knowledge system.
- [Selecting knowledge for Microsoft 365 Copilot Tuning](https://learn.microsoft.com/en-us/copilot/microsoft-365/copilot-tuning-knowledge-selection) — the quality-over-quantity curation principle (written for Copilot Tuning; the curation logic carries over).

### Community & practitioner articles — what works in practice

- [Copilot Studio knowledge limitations guide (Rick Caudle, GitHub)](https://github.com/Rickcau/Copilot-Studio/blob/main/Knowledge_Source_Limitations_Solutions/copilot-studio-knowledge-limitations-guide.md) — the best independent technical deep-dive: undocumented chunking defaults, limitation workarounds, when to graduate to Azure AI Search.
- [Markdown files in SharePoint as knowledge — not supported (TechCommunity)](https://techcommunity.microsoft.com/discussions/copilot-studio/copilot-studio--sharepoint-markdown--md-files-in-doc-libraries-supported-as-know/4517314) — community confirmation that .md is not retrievable/citable from SharePoint.
- [JSON/text knowledge → non-clickable citations (Microsoft Q&A)](https://learn.microsoft.com/en-us/answers/questions/5840273/copilot-studio-local-json-text-knowledge-sources-r) — why doc-style formats hosted in SharePoint/OneDrive are required for proper citations, with production workarounds.
- [Why SharePoint Knowledge in Copilot Studio Isn't Working (HubSite 365)](https://www.hubsite365.com/en-ww/crm-pages/why-sharepoint-knowledge-in-copilot-studio-isnt-working-and-how-to-fix-it.htm) — practitioner troubleshooting checklist for the common retrieval failures.
- [Knowledge Sources vs Tools in Copilot Studio (Low-code Power)](https://lowcodepower.com/2025/11/10/knowledge-sources-vs-tools-in-copilot-studio-understanding-the-fundamental-difference/) — when knowledge (read/cite) is the wrong mechanism and a tool (act/query) is the right one.
- [How to Create an FAQ Copilot in Copilot Studio (Citizen Developer 365)](https://citizendeveloper365.com/how-to-create-a-frequently-asked-questions-copilot-in-copilot-studio/) — walkthrough of heading-structured FAQ documents that answer well.
- [Crafting Effective Instructions for Copilot Studio Agents (CIAOPS)](https://blog.ciaops.com/2025/08/06/crafting-effective-instructions-for-copilot-studio-agents/) — practitioner instruction patterns that pair with knowledge design.
- [Guide to Writing Effective Copilot Studio Agent Instructions (LinkedIn, P-Y Delacôte)](https://www.linkedin.com/pulse/guide-writing-effective-copilot-studio-agent-pierre-yves-delac%C3%B4te-sdcye) — independent instruction-writing guide.
- [How to Limit Copilot Studio Knowledge to Specific SharePoint Folders (ippu-biz)](https://ippu-biz.com/en/development/powerplatform/copilot-studio/knowledge-spo-document-library/) — folder-level scoping for retrieval precision.
- [How To Add Copilot Studio Knowledge Files Using Power Automate (Matthew Devaney)](https://www.matthewdevaney.com/how-to-add-copilot-studio-knowledge-files-using-power-automate/) — automating knowledge upload/refresh (useful for scheduled licensing-doc updates).
- [Azure AI Search in Copilot Studio: custom knowledge sources done right (Medium, Cédric Mendelin)](https://medium.com/data-science-collective/azure-ai-search-in-copilot-studio-the-right-way-with-custom-knowledge-sources-ff0f62ffccc2) — the escalation path when built-in knowledge limits become blocking.
- [Copilot Studio FAQ (official PDF, adoption.microsoft.com)](https://adoption.microsoft.com/files/copilot-studio/Microsoft-Copilot-Studio_FAQ.pdf) — official FAQ rollup including knowledge behavior.

---

## Part 3 — Checklist applied to this project's knowledge base (94 docs)

| Practice (from sources above) | This KB | Status |
|---|---|---|
| .docx format hosted in SharePoint | All 94 docs delivered as .docx | ✅ |
| One topic per document | One doc per D-* map entry | ✅ |
| Under ~36,000 characters per file | 600–1,200 words (~4–8 KB) each | ✅ |
| Clear H1/H2 heading hierarchy | Enforced format contract, QA-verified | ✅ |
| Answer-first structure | "## Summary" answers directly in every doc | ✅ |
| Synonyms/aliases embedded | "Also known as" line in every doc | ✅ |
| Under 500 knowledge objects | 94 now; ~236 at full build-out | ✅ |
| Date-stamped for freshness curation | Footer with verified-as-of + review-by date | ✅ |
| **Enhanced search results (Work IQ) ON** | Must be enabled when adding the SharePoint source — tenant has M365 Copilot | ⚠️ Action at setup |
| **Tables paired with prose** | Docs pair tables with IF/THEN prose; test 2–3 table-heavy docs (licensing rate cards) for citation quality after upload | ⚠️ Test after upload |
| SharePoint metadata tagging | Optional improvement: add document-type / pillar / review-date columns to the library | ◻ Optional |
| Folder-scoped knowledge sources | Keep the per-section folders; scope the agent to the library or per-folder URLs | ✅ Plan |

*Facts and links verified as of June 3, 2026. The 7 MB/200 MB licensing-dependent limits and Enhanced search behavior are High volatility — re-verify quarterly.*
