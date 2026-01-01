# PM Thought Partner 🥊

> 🔱 **Forked from [breethomas/pm-thought-partner](https://github.com/breethomas/pm-thought-partner)**

**Your sparring partner, not your assistant.**

A Claude Code plugin that helps product teams make better decisions by combining proven PM frameworks with institutional memory.

---

## The Problem

**Product decisions don't compound.**

When Sarah leaves the team, her hard-won insights about what worked (and what didn't) leave with her. When Jordan joins, they repeat the same mistakes Sarah already learned from. Every PM starts from scratch.

Meanwhile, you're in back-to-back meetings, context-switching between projects, trying to remember: "Didn't we try something like this before? How did it go?"

**The result:** Teams keep stepping on the same rakes.

## The North Star

**Decisions should compound across your team, not evaporate when people change.**

Imagine if:
- New PMs inherited 6 months of institutional knowledge on Day 1
- Strategy sessions referenced what your team already learned
- You could see patterns: "We validated 8 features with prototypes—85% shipped. We validated 5 with just interviews—20% shipped."
- Cross-team learning happened automatically: "Platform team learned this 3 months ago..."

That's what we're building.

## How It Works

**Two systems working together:**

### 1. Strategic Thinking Partner (Proven PM Frameworks)

Built on publicly available frameworks from Marty Cagan, Teresa Torres, Brian Balfour, and other leading product thinkers. Challenges your assumptions. Pushes toward prototypes over docs. Applies frameworks naturally in conversation.

**Commands:** `/strategy-session`, `/reflect`, `/four-risks`, `/now-next-later`, etc.

### 2. Product Memory (Team Institutional Knowledge)

Git-based decision tracking that captures what you decided, why, and what happened. Automatically surfaces relevant past decisions during strategy sessions. Cross-PM learning built in.

**Commands:** `/memory-init` (Phase 1 ✅), decision capture in sessions (Phase 2 ✅), memory surfacing (Phase 3 ✅)

**Together:** Get both strategic frameworks AND your team's lived experience in every decision.

---

## Implementation Status

### ✅ Phase 1: Multi-Tenant Foundation
**Command:** `/memory-init`

Initialize team decision memory with multi-tenant structure:
- One product can have multiple areas (e.g., Intersight → Monitoring, Foundation, Automation)
- Each area has its own team and decisions
- Git-based for collaboration and version control
- Simple, local-first (no database, no server)

**Status:** Complete

---

### ✅ Phase 2: Team Decision Capture
**Integration:** `/strategy-session` enhancement

Automatically capture decisions during strategy sessions:
- AI detects concrete decisions in conversation
- Guided 4-question Q&A captures context (assumptions, trade-offs, timeline, success criteria)
- Generates decision files with YAML frontmatter
- Auto-commits to team git repo
- Multi-tenant attribution (product, area, PM)

**What gets saved:**
```yaml
decision: "Build AI email assistant with domain templates"
pm_name: "Sara Chen"
date: 2024-12-01
status: "success"
assumptions: ["Users want domain-aware AI"]
trade_offs: "Delayed mobile app 1 month"
outcome: "40% adoption (exceeded 30% goal)"
```

**Status:** Complete

---

### ✅ Phase 3: Team-Wide Memory Surfacing
**Integration:** `/strategy-session` enhancement

Before starting a new session, Claude automatically:
1. Syncs with team decision repository
2. Searches for relevant past decisions (keyword-based)
3. Surfaces top 3 with full context:
   - Who made it (PM name, email)
   - When (relative time)
   - Outcome (success/pending/failed)
   - Key learnings (assumptions, trade-offs, results)
4. References these patterns during exploration

**Cross-PM learning enabled:**
- Platform PMs see Product PM decisions
- Same product, different areas share learnings
- "We tried this before" intelligence built-in

**Example output:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RELEVANT HISTORY (from team memory)

📌 Build AI email assistant (Sara Chen, Dec 1)
   Outcome: ✅ Success - 40% adoption
   Learning: Domain-specific AI > Generic (73% lift)
```

**Status:** Complete (MVP - keyword search, simple ranking, < 10s performance)

---

### ⏳ Next: Phase 4 - Outcome Tracking

Follow-up prompts when decisions mature:
- "How did that AI feature work out?"
- Update status: pending → success/failed
- Capture what actually happened
- Build pattern recognition: "Prototypes work 85% of the time for us"

**Timeline:** 1 week

---

### Future Phases
- **Phase 5:** Weekly decision journal
- **Phase 6:** Pattern recognition across decisions
- **Post-MVP:** Semantic search, decision graphs, analytics

---

## Thought Leaders Included

The PM Thought Partner synthesizes publicly available frameworks from:

- **Marty Cagan** - Product discovery, four risks, empowered teams
- **Teresa Torres** - Continuous discovery habits, opportunity solution trees
- **Elena Verna** - Growth loops, product-led growth
- **Brian Balfour** - Four fits, focus wins, growth strategy
- **Chip Huyen** - Production AI systems, ML engineering, data quality
- **Aman Khan** - AI evals, vibe-driven development, AI-native products
- **Janna Bastow** - Now-Next-Later roadmapping, cone of uncertainty
- **Aakash Gupta** - Visual frameworks, stakeholder communication
- **Rahul Vohra** - PMF survey, high-expectation customers
- **Ravi Mehta** - Product Strategy Stack, AI integration framework
- **Linear** - Issues not stories, direction → building → quality
- **Reforge** - Practitioner wisdom, monetization, growth frameworks

**[→ Read detailed profiles](thought-leaders/)**

---

## Core Commands

### `/strategy-session` - Strategic Thinking Partner

Work through product problems conversationally. Claude gathers context proactively, applies PM frameworks naturally, and now surfaces your team's past decisions.

**Features:**
- Proactive context gathering (README, commits, architecture)
- Framework-driven exploration (Four Risks, Continuous Discovery, etc.)
- Decision capture with guided Q&A (Phase 2 ✅)
- Team memory surfacing before each session (Phase 3 ✅)
- Structured output: decisions, risks, prototypes, questions
- Optional Linear issue creation

**Start:** `/strategy-session` or `/strategy-session "recommendation engine"`

---

### `/memory-init` - Initialize Team Decision Memory

One-time setup to create your team's decision repository (Phase 1 ✅).

Creates multi-tenant git structure:
```
team-product-memory/
└── products/
    └── intersight/              # Your product
        ├── config.yml
        └── areas/               # Product areas
            ├── monitoring/      # Area 1 (PM team)
            ├── foundation/      # Area 2 (PM team)
            └── automation/      # Area 3 (PM team)
```

**Start:** `/memory-init`

---

### Strategic Reflection

**`/reflect` - Pattern recognition across your decisions**

See patterns in your strategic thinking over time:
- Analyze decision-making trends across multiple sessions
- Track which frameworks you use most
- Identify unresolved questions blocking progress
- Weekly/monthly reflection ritual

Sessions are saved locally (gitignored by default for privacy).

**Start:** `/reflect` or `/reflect "this month"`

### Linear Workspace Analysis

A drill-down hierarchy for understanding workspace health at different levels:

```
/linear-calibrate        → Workspace-wide health (30,000 ft view)
         ↓
    ┌────┴────┐
    ↓         ↓
/project-health       /issue-audit
[project]             [team]
(execution health)    (organization patterns)
```

Each command is standalone but designed to work together. Run calibrate first to spot problems, then drill into project execution or team conventions.

---

**`/linear-calibrate` - Workspace health check with explicit thresholds**

Analyze your entire Linear workspace against Linear methodology best practices. Produces a structured report with pass/fail ratings:

- Team structure (4-15 teams = 🟢, 31+ = 🔴)
- Project ownership and dates
- Backlog staleness and label hygiene
- Issue quality trends (improving / persistent / declining)

**What you get:**
- Health indicators table with 🟢/🟡/🔴 ratings
- Issue quality trend analysis (time-bucketed)
- Red flags with "Ask Claude" follow-up prompts
- Specific recommendations (Immediate / Near-Term / Maintenance)

**Start:** `/linear-calibrate`

---

**`/project-health [project-name]` - Single project deep-dive**

When calibrate flags project issues, drill down on a specific project:

- Ownership, timeline, and progress tracking
- Scope clarity and issue distribution
- Blockers and staleness detection

**Output:** On Track / At Risk / Stalled assessment with specific actions.

---

**`/issue-audit [team-name]` - Understand how a team organizes work**

Helps PMs onboarding to new teams learn conventions fast:

- Workflow states (team's process from triage to done)
- Label taxonomy (what categories exist)
- Cycle cadence (sprint structure)
- 9 sample issues (active, completed, backlog)

**Output:** Organization patterns, conventions to follow, and drill-down prompts for exploration.

### Backlog Automation

**Connect Linear or GitHub to auto-analyze your backlog in seconds.**

- **`/lno-prioritize`** - Categorize 50+ issues by impact (Leverage/Neutral/Overhead)
- **`/four-risks [issue-id]`** - Pull issue, assess risks, add analysis as comment
- **`/now-next-later`** - Generate roadmap from Linear projects, send back categorized

**Setup (2 min):** [Get Linear API key](https://linear.app/docs/api-and-webhooks) (Settings > Account > Security & Access) → Ask Claude "Set up the Linear MCP server"

**No MCP?** All commands work with manual input. Paste issues or describe context directly.

### Strategic Commands

Applied through conversation, not lectures:

- **AI-Era Growth:** `/four-fits` (modernized for ChatGPT discovery, AI costs, TAM shifts)
- **AI Products:** `/ai-cost-check`, `/ai-health-check`, `/start-evals`
- **Growth Mechanics:** `/growth-loops`
- **Measurement:** `/pmf-survey`

**[→ See all commands](commands/)** | **[→ Browse frameworks](frameworks/)**

Plus comprehensive framework library covering discovery, growth, AI, planning, and measurement.

### Skills (Auto-Invoked)

These skills are automatically invoked by Claude when relevant to your task:

| Skill | What it does | When Claude uses it |
|-------|--------------|---------------------|
| **workspace-calibration** | Provides Linear workspace context; directs to `/linear-calibrate` for formal analysis | When joining a new team or asking "how is this org using Linear?" |
| **pm-frameworks** | Surfaces PM frameworks for discovery, growth, planning, measurement, and AI | When discussing product strategy, prioritization, user research, growth, or roadmapping |
| **agent-workflow** | Designs AI agent architectures using Meta's 9-step process and 8-layer framework | When building AI agents, designing agent workflows, or architecting agentic systems |
| **prd-writer** | Creates modern, decision-focused PRDs for the AI era | When writing PRDs, spec documents, or feature specifications |
| **prompt-engineering** | Optimizes prompts using the 6-step framework | When creating, analyzing, or improving AI prompts |

**How skills differ from commands:**
- **Commands** (`/prd`, `/prompt-engineering`) - You invoke explicitly
- **Skills** - Claude invokes automatically based on context

Both `/prd` and `/prompt-engineering` commands are available as shortcuts to explicitly invoke their corresponding skills.

**[→ Browse skills](skills/)**

---

## Installation

Ask Claude Code:
```
Install the PM Thought Partner plugin from
https://github.com/breethomas/pm-thought-partner
```

**[→ Full guide with Linear/GitHub setup](INSTALL_PLUGIN.md)**

### Privacy Note

By default, `/strategy-session` outputs and `/reflect` summaries are saved locally but gitignored.

**If you want to commit your strategic thinking:**
1. Remove `sessions/` and `reflections/` from `.gitignore`
2. Commit to your repo (or team repo)
3. Now your product thinking is version-controlled and searchable

**Why gitignore by default?** Sessions contain company strategy, competitive insights, and product decisions that most PMs won't want in their git history.

---

## How It Works

**You:** "Should I build AI recommendations or improve search first?"

**PM Thought Partner:**
- Reads your codebase context
- "What evidence do you have that discovery is the problem?"
- "Can you prototype both and test with 10 users this week?"
- Applies Four Risks framework, suggests evals strategy
- Creates Linear issues with next steps

**It pushes back.** Won't just agree with your idea. Will ask for evidence, suggest prototypes over PRDs, and challenge you to talk to users.

---

## Contributing

This is a living repository. PM frameworks evolve.

**How to contribute:**
1. Open an issue to discuss proposed changes
2. Submit a pull request with framework updates or new thought leaders
3. Include sources - all frameworks must link to publicly available content

**Quality standards:**
- ✅ Reference publicly available content (articles, podcasts, books)
- ✅ Provide attribution to original thinkers
- ✅ Focus on frameworks and mental models (not just tactics)
- ✅ Maintain AI-era first perspective

**[→ See sources.yml for complete attribution](sources.yml)**

---

## Ideas & Future Directions

Exploring what PM Thought Partner could become. These aren't commitments—they're concepts to discuss and evolve with the community.

**[→ Browse ideas](ideas/)** - Potential features like PM onboarding intelligence, analytics integration, responsible vibe coding workflows

**Want to discuss an idea?** Open an issue. **Have your own idea?** Check the ideas directory for the template.

---

## License & Attribution

MIT License. All frameworks attributed to original creators in [sources.yml](sources.yml).

Built with Claude Code by [Bree Thomas](https://github.com/breethomas).
Fork maintained by [abhixz13](https://github.com/abhixz13).
