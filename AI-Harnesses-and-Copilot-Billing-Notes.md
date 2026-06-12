# Understanding AI Harnesses, Context Windows & GitHub Copilot Billing

A personal reference covering how LLM-based AI systems actually work under the hood, and how GitHub Copilot's usage billing converts tokens into the "units" (AI Credits) you spend.

*Compiled June 2026.*

---

## Table of Contents

1. [Part 1 — How AI Systems Work](#part-1--how-ai-systems-work)
   - [The four pieces and what kind of thing each is](#the-four-pieces-and-what-kind-of-thing-each-is)
   - [The model](#1-the-model-a-frozen-stateless-function)
   - [The context window](#2-the-context-window-the-finite-slot)
   - [Context engineering](#3-context-engineering-the-discipline-of-filling-the-window)
   - [The AI harness](#4-the-ai-harness-the-program-that-runs-everything)
   - [How a question flows through the whole system](#how-a-question-flows-through-the-whole-system)
2. [Part 2 — GitHub Copilot Billing](#part-2--github-copilot-billing)
   - [The two billing eras](#the-two-billing-eras)
   - [What your "units" actually are](#what-your-units-actually-are)
   - [The token-to-credits formula](#the-token-to-credits-formula)
   - [The per-model rate table](#the-per-model-rate-table)
   - [Reading the VS Code hover](#reading-the-vs-code-hover)
   - [Worked examples](#worked-examples)
   - [Input vs cached tokens](#input-vs-cached-input-tokens)
3. [Quick-reference cheat sheet](#quick-reference-cheat-sheet)
4. [Sources](#sources)

---

# Part 1 — How AI Systems Work

When you ask a question to a tool like GitHub Copilot, Claude Code, or ChatGPT, four distinct things cooperate. They're often lumped together as "the AI," but they're different kinds of things.

## The four pieces and what kind of thing each is

| Thing | What kind of thing | One-line definition |
|---|---|---|
| **The model** | A trained artifact (frozen weights) | A function: tokens in → next-token prediction out |
| **The context window** | A container (a fixed-size slot) | The finite buffer of tokens the model can see in one call |
| **Context engineering** | A discipline / set of techniques | Deciding *what* to put in that container |
| **The harness** | A running program | The orchestrator that does the engineering and runs the loop |

The relationship in one sentence: **the harness practices context engineering to pack the right tokens into the finite context window, then runs the stateless model on that window — and loops.**

---

## 1. The model: a frozen, stateless function

The model is the neural network — billions of fixed numbers (weights) set at training time. When people say "Claude" or "GPT," they usually mean this.

- **Stateless** — it has no memory of your last message. Every call starts from a blank slate.
- **Frozen** — it does not learn from your conversation; the weights don't change as you talk.
- Its only knowledge of *the present* is the text handed to it right now. Everything else is baked-in training knowledge from months/years earlier.
- It does exactly one thing: read a sequence of tokens and predict what comes next.

```
        tokens in                    one token out
  [The capital of France is] ──▶ MODEL ──▶ [Paris]
```

That's the whole model. No files, no memory, no tools, no loop.

**Key consequence:** the illusion of memory in a conversation is manufactured by *replaying the whole history* into the model every turn. The model never remembers — it re-reads. Because it's frozen, the only runtime lever on its behavior is the input. That single fact is why context engineering exists.

---

## 2. The context window: the finite slot

The context window is the **container** the model reads on each call. It has a hard size limit measured in **tokens** (e.g. 128K–200K for many models; up to ~1M for large-context models).

If a fact isn't in the window, the model literally cannot see it — it wasn't "forgotten," it was never there. Everything competes for the same fixed space:

```
┌─ CONTEXT WINDOW (finite token budget) ──────────────┐
│ System prompt (identity, rules, available tools)     │
│ Tool definitions / schemas                           │
│ Injected memories & reminders                        │
│ Conversation history (every prior turn, replayed)    │
│ Files read, command outputs, retrieved documents     │
│ ◀── the current question ──▶                         │
│ ...remaining free space...                           │
└──────────────────────────────────────────────────────┘
                        │
                        ▼
                     MODEL  ──▶  response
```

The window is a **passive container**. It doesn't decide what goes in it. When it fills up, something must be dropped or summarized. *Who decides?* The harness, following context-engineering strategy.

---

## 3. Context engineering: the discipline of filling the window

Context engineering is the **craft of deciding what occupies that finite window** to get the best output. It's the successor to "prompt engineering":

- **Prompt engineering** = wording one clever instruction.
- **Context engineering** = curating the *entire* window (instructions, history, retrieved docs, tool results, examples, memory) under a token budget.

It answers questions like:

- What instructions does the model need, and how should they be phrased?
- Which prior turns matter; which can be dropped or summarized?
- Which files/docs should I retrieve and inject *right now* for *this* question? (This is what **RAG** — retrieval-augmented generation — is.)
- When the window is nearly full, what gets compressed and what stays verbatim?
- Which tools should even be visible? (Showing hundreds of tool schemas wastes budget; good harnesses load schemas on demand.)

Context engineering is a **practice, not a piece of software**. It is *implemented by* the harness (and partly by you, when you write a good prompt). The harness is the agent that *does* context engineering; context engineering is the *strategy* it follows.

**Why it matters:** a frozen model's output quality is bounded by what's in the window — garbage in, garbage out. Two harnesses using the *identical* model can produce wildly different results purely from how well they engineer context. Context is a *budget*: every token spent on stale data is a token not available for reasoning.

---

## 4. The AI harness: the program that runs everything

The harness is the actual running software (e.g. Claude Code, the Copilot backend). It is the *agent* that assembles the window, calls the model, and acts on the output. Its responsibilities:

### a) The agent loop (the heart of it)

The single most important thing a harness does:

```
┌─────────────────────────────────────────────┐
│ 1. Assemble context (prompt + history +      │
│    tool results + injected reminders)         │
│ 2. Call the model                             │
│ 3. Model replies with text and/or tool calls  │
│ 4. Harness EXECUTES the tool calls            │
│ 5. Feed results back as new context           │
│ 6. Repeat until model stops calling tools     │
└─────────────────────────────────────────────┘
```

The model *proposes*; the harness *disposes*. The model never touches your filesystem directly — it emits a structured request, and the harness decides whether/how to honor it. This separation is what makes permissions and sandboxing possible. The **loop** is what turns a one-shot text function into something "agentic" — a single model call can't iterate.

### b) Tools

- **Defines** tool schemas (names, parameters) and tells the model what's available.
- **Parses & validates** the model's tool-call output.
- **Executes** the actual side-effecting code (shell, API call, file edit).
- **Mediates** via permissions — a denied call returns as feedback, not a crash.
- **Manages** dynamic tool loading (load schemas only when needed, to save context).

### c) Memory & context management

- Stores **conversation history** and replays it (the model can't remember).
- **Compacts** the window when it gets too long (summarize old turns, start fresh).
- Maintains **persistent memory** and injects relevant pieces back into context.
- **Assembles** what goes into each model call.

### d) Orchestration

- Spawns **subagents** with isolated context for parallel/independent work.
- Runs **workflows** — deterministic multi-agent scripts (loops, conditionals, fan-out).
- Handles **scheduling** — cron jobs, recurring tasks, background work.

### e) Failure handling

- **Retries** on transient errors, **timeouts** on long tools.
- Routes **permission denials** back as feedback.
- Runs **hooks** that intercept/validate tool calls.
- **Surfaces errors** (turns a crashed command's stderr into something the model can react to).

---

## How a question flows through the whole system

Tracing a single question end-to-end shows the lines between all four pieces:

```
  YOU              HARNESS                        MODEL
   │                  │                             │
   │── question ─────▶│                             │
   │                  │ context-engineering:        │
   │                  │  gather sys prompt,         │
   │                  │  history, memories,         │
   │                  │  tools, your Q              │
   │                  │                             │
   │                  │── assembled window ────────▶│  (one call)
   │                  │                             │ predict
   │                  │◀──── text + tool calls ─────│  next
   │                  │                             │  tokens
   │                  │ execute tools, append       │
   │                  │ results, loop if needed     │
   │◀── answer ───────│                             │
```

1. **You type a question.** It goes to the *harness*, not the model. The model isn't running yet.
2. **The harness does context engineering** — it builds the window: system prompt, tool definitions, injected memories, the full conversation history (replayed verbatim, because the model doesn't remember it), and your new question.
3. **The model runs once.** It sees the whole window as a flat token sequence, has no concept of "a conversation," and predicts a continuation — possibly with tool calls.
4. **The harness acts.** If a tool was requested, it executes it, appends the result to the window, and loops back to step 2. Otherwise it streams the text back to you.
5. **You see the answer.** Next turn, the harness replays this whole exchange into the window again.

**The takeaway:** none of the intelligence-plus-continuity you experience is the model alone. The *intelligence* is in the model; the *continuity, memory, and agency* are an illusion expertly maintained by the harness repeatedly engineering a fresh context window and re-running the frozen, stateless model in a loop.

### The clean dividing lines

- **Model vs. everything else** — the model is the only thing that "thinks," but it's frozen, stateless, and sees nothing but the window.
- **Context window vs. context engineering** — the window is the *container* (a noun); context engineering is the *act of choosing what fills it* (a verb).
- **Context engineering vs. harness** — context engineering is the *strategy*; the harness is the *program that executes it* (plus tools, the loop, failure handling).

| Concern | Model | Harness |
|---|:---:|:---:|
| Reasoning, language, deciding *what* to do | ✅ | |
| Actually running tools / touching the world | | ✅ |
| Holding state between calls | | ✅ |
| The loop / iteration | | ✅ |
| Context assembly & compaction | | ✅ |
| Permissions, sandboxing, safety gates | | ✅ |
| Multi-agent orchestration | | ✅ |
| Knowing facts, writing code, planning | ✅ | |

**Mental model:** the LLM is the *brain* — pure cognition, stateless, no hands. The harness is the *body and nervous system* — hands (tools), memory, a heartbeat (the loop), reflexes (failure handling), and coordination (orchestration). Neither is useful alone.

---

# Part 2 — GitHub Copilot Billing

## The two billing eras

GitHub switched billing systems on **June 1, 2026**. The two systems convert work into "units" in **opposite** ways — this is the source of most confusion.

| | **Legacy (before June 1, 2026)** | **Current (June 1, 2026 onward)** |
|---|---|---|
| Unit name | **Premium Request (PRU)** | **AI Credit** |
| Based on | 1 user action × **model multiplier** | **Token usage** (input + cached + output) |
| Tokens relevant? | ❌ No — tokens ignored entirely | ✅ Yes — tokens are the fundamental unit |
| Example cost driver | Which model you picked | How many tokens you actually used |

**Legacy math:** `premium requests = (1 action) × model multiplier`. Cheap models ≈ 0.33×, mid models ≈ 6–9×, top models (Opus) ≈ 15–27×, a PR code review was a flat 13×. A quick chat and a multi-hour agent run on the same model cost *the same*. Standard Enterprise allowance was **1,000 premium requests/month**.

**Current math:** every plan includes a monthly allotment of **AI Credits**, consumed by actual token usage at each model's published API rate.

---

## What your "units" actually are

Under the current system, a "unit" is an **AI Credit**, and:

> **1 AI Credit = $0.01 USD**

Plan allotments (the included credits equal the dollar value of the plan ÷ $0.01):

| Plan | Monthly $ included | = AI Credits | Promo (Jun–Aug 2026) |
|---|---|---|---|
| Copilot Pro | $10 | 1,000 | — |
| Copilot Pro+ | $39 | 3,900 | — |
| Copilot Business | $19 | 1,900 | $30 → 3,000 |
| Copilot Enterprise | $39 | **3,900** | $70 → 7,000 |

> **A 3,900-credit Enterprise allowance = $39 ÷ $0.01.** This is the tell that you're on the *new* usage-based system, not premium requests (whose Enterprise allowance was 1,000).

> **Caveat:** an org may negotiate a *custom* allotment, so always confirm against your enterprise billing dashboard. But $39 → 3,900 strongly indicates the standard credit grant.

---

## The token-to-credits formula

The conversion is a two-step chain: **tokens → dollars → credits.**

```
            ┌─ input tokens   × model input rate  ┐
  dollars = │  cached tokens  × model cached rate │ ÷ 1,000,000
            └─ output tokens  × model output rate ┘

  credits = dollars ÷ $0.01   (i.e. dollars × 100)
```

As a single expression (with dollar rates `r`):

```
            (I × r_I) + (C × r_C) + (O × r_O)
credits  =  ─────────────────────────────────  × 100
                       1,000,000
```

Where **I, C, O** = input, cached, and output token counts.

**Shortcut:** if you already have the rates *in credits* (as VS Code shows them), skip the `× 100`:

```
            (I × credit_rate_I) + (C × credit_rate_C) + (O × credit_rate_O)
credits  =  ──────────────────────────────────────────────────────────────
                                  1,000,000
```

---

## The per-model rate table

Rates mirror each model's published API pricing. **Output ≈ 5× input; cached input ≈ 1/10× input.** The ratio is roughly **input : cached : output ≈ 10 : 1 : 50** for every model.

| Model | Input ($/1M) | Cached ($/1M) | Output ($/1M) | Input (cr/1M) | Cached (cr/1M) | Output (cr/1M) |
|---|---|---|---|---|---|---|
| GPT-5 mini | $0.25 | $0.025 | $2.00 | 25 | 2.5 | 200 |
| Gemini 2.5 Pro | $1.25 | $0.125 | $10.00 | 125 | 12.5 | 1,000 |
| **Claude Sonnet 4.x** | **$3.00** | **$0.30** | **$15.00** | **300** | **30** | **1,500** |
| **Claude Opus 4.x** | **$5.00** | **$0.50** | **$25.00** | **500** | **50** | **2,500** |
| GPT-5.5 | $5.00 | $0.50 | $30.00 | 500 | 50 | 3,000 |

> **Code completions and next-edit suggestions are NOT billed** — they remain unlimited on all paid plans. Only chat / agent model calls draw down credits.

---

## Reading the VS Code hover

When you hover over a model in VS Code, it shows the **per-1-million-token price denominated directly in AI credits** — the same rates above, pre-converted so you don't have to do the dollar math.

Example — **Claude Sonnet 4.6** hover:

| Hover shows | Credits / 1M | × $0.01 = $/1M |
|---|---|---|
| Input | 300 | $3.00 |
| Cached input | 30 | $0.30 |
| Output | 1,500 | $15.00 |

This is the cleanest way to budget: read the three credit numbers off the hover, divide each by 1,000,000 to get "credits per token," and you have the cost of any session directly in the same units as your allowance — no dollars in the middle.

---

## Worked examples

### Example A — Opus 4.6, no caching

Tokens: **119,119 input · 2,226 output · 0 cached**. Opus rates: input $5, output $25 / 1M.

```
Input cost  = 119,119 × $5.00  / 1,000,000 = $0.595595
Output cost =   2,226 × $25.00 / 1,000,000 = $0.055650
                                             ───────────
Total                                       = $0.651245

Credits = $0.651245 × 100 ≈ 65.1 credits
```

→ **≈ 65 credits** (~60 such interactions would exhaust a 3,900 allowance).

### Example B — same call, with 47,621 cached tokens

The result depends on how your dashboard reports the numbers:

**Interpretation A — cached is a *separate* bucket** (the Anthropic/OpenAI usage convention; `input` means *fresh/uncached*, cache reads reported separately). Most likely:

```
Fresh input = 119,119 × $5.00  / 1,000,000 = $0.595595
Cached      =  47,621 × $0.50  / 1,000,000 = $0.023811
Output      =   2,226 × $25.00 / 1,000,000 = $0.055650
                                             ───────────
Total                                       = $0.675056
Credits = ≈ 67.5 credits
```

**Interpretation B — cached is *part of* the 119,119** (so fresh = 119,119 − 47,621 = 71,498):

```
Fresh input = 71,498 × $5.00  / 1,000,000 = $0.357490
Cached      = 47,621 × $0.50  / 1,000,000 = $0.023811
Output      =  2,226 × $25.00 / 1,000,000 = $0.055650
                                            ───────────
Total                                      = $0.436951
Credits = ≈ 43.7 credits
```

**How to tell which is yours:** if the tool lists `input`, `cached`, `output` as three side-by-side numbers → **Interpretation A (67.5)**. If it shows a total input with cached as an "of which cached" breakdown → **Interpretation B (43.7)**. When in doubt, A is the standard.

### Example C — Sonnet, credit-native math

Tokens: 50,000 input · 10,000 cached · 3,000 output, using hover credit rates (300/30/1,500):

```
(50,000 × 300 + 10,000 × 30 + 3,000 × 1,500) / 1,000,000
= (15,000,000 + 300,000 + 4,500,000) / 1,000,000
= 19,800,000 / 1,000,000
= 19.8 credits
```

---

## Input vs cached input tokens

Both are content sent *to* the model. The difference is whether the model has **already processed** that exact content before.

### Why caching exists

Because the model is **stateless**, the harness replays the entire context window every turn. Turn after turn, the front of the window (system prompt, tools, files already read, earlier conversation) is **identical**. Without caching you'd pay full input price to re-process those same tokens every turn.

The expensive step in processing input is **"prefill"** — converting tokens into the model's internal numeric state (the KV cache). Caching **saves that processed state** for a stable prefix and **reuses** it next turn if the prefix matches exactly.

```
Turn 2:  [system + tools + history(1)]   +   [history(2) + new msg]
         └─ CACHED, billed at 30 cr/M ─┘     └─ FRESH, billed at 300 cr/M ─┘
```

| | Fresh **input tokens** | **Cached input tokens** |
|---|---|---|
| Meaning | Content the model processes **for the first time** | Content from a **repeated, identical prefix** already processed |
| Price (Sonnet) | 300 cr/M (full) | 30 cr/M (~10× cheaper) |
| Why cheaper | — | Skips the compute (prefill), just reloads saved state |

### What lands in each bucket

| Typically **cached** (stable prefix) | Typically **fresh** (new tail) |
|---|---|
| System prompt, rules | Your newest message |
| Tool/function definitions | Latest tool result this turn |
| Files read earlier in the session | A newly-read file |
| Earlier conversation turns | The pending response → becomes *output* |

### Three things to know

- **Prefix-based & order-sensitive.** The cache only hits on an unbroken, identical run of tokens from the very start. Change one token early (edit the system prompt, reorder tools) and everything after becomes a cache *miss* at full price. This is why harnesses keep stable content at the front and append volatile content at the end.
- **Long sessions get *cheaper* per turn.** As a session grows, more of the window is unchanged prefix, so a larger share shifts into the cheap cached bucket. A 119K-token fresh call (~67 credits) could cost ~10 credits if most were cache hits.
- **Caches expire.** Providers hold the prefix for a short TTL (often ~5 minutes). Idle past it and the next turn re-pays full input price to rewarm the cache — which is why both responsiveness and cost worsen after a pause.

---

# Quick-reference cheat sheet

```
1 AI Credit = $0.01 USD
Enterprise allowance = $39 = 3,900 credits/month  (Jun–Aug 2026 promo: $70 = 7,000)

CREDITS FORMULA (dollar rates):
  credits = [ (I × r_I) + (C × r_C) + (O × r_O) ] / 1,000,000 × 100

CREDITS FORMULA (credit rates, e.g. from VS Code hover):
  credits = [ (I × cr_I) + (C × cr_C) + (O × cr_O) ] / 1,000,000

RATE SHAPE (every model):   input : cached : output  ≈  10 : 1 : 50
  - output  ≈ 5× input
  - cached  ≈ 1/10× input

OPUS 4.x quick math:  input-K × 0.5  +  output-K × 2.5  ≈ credits
SONNET 4.x rates (credits/1M):  300 input / 30 cached / 1,500 output

FREE: code completions & next-edit suggestions (never billed)
BILLED: chat + agent model calls only
```

---

# Sources

- [Models and pricing for GitHub Copilot — GitHub Docs](https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing)
- [GitHub Copilot is moving to usage-based billing — The GitHub Blog](https://github.blog/news-insights/company-news/github-copilot-is-moving-to-usage-based-billing/)
- [Model multipliers for annual plans (legacy) — GitHub Docs](https://docs.github.com/en/copilot/reference/copilot-billing/model-multipliers-for-annual-plans)
- [Overview of request-based / premium request billing — GitHub Docs](https://docs.github.com/en/billing/concepts/product-billing/github-copilot-premium-requests)

*Note: pricing, model names, and rates reflect figures current as of June 2026 and may change — verify against the live GitHub docs and your billing dashboard.*
