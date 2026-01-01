# Product Memory MVP - Implementation Plan

**Last Updated:** January 6, 2025

---

## North Star

**"Compound your product's decision intelligence so every PM is smarter than the last, and past mistakes never get repeated."**

The key insight: Most "product knowledge" is siloed, undocumented, and lost when PMs leave. We solve this by making **conversation the memory**—capturing decisions + rationale + outcomes automatically through existing workflows.

---

## The Problem We're Solving

**Today's Reality:**
- PMs make decisions in their head, context is lost
- New PMs repeat mistakes previous PMs already learned from
- "Why did we decide X?" gets answered with "I don't remember" or "ask Sara (who left 6 months ago)"
- Decisions documented in Notion/Linear lack the reasoning behind them
- Outcomes never get connected back to original decisions

**What Success Looks Like:**
- Every decision captures: What + Why + Context + Assumptions
- Outcomes automatically tracked and connected to decisions
- New decisions surface relevant history: "We tried this before, here's what happened"
- PMs get smarter over time by learning from product's history
- Institutional knowledge compounds instead of resetting with each PM change

---

## Architecture: Multi-Tenant Team System

**Critical Design Principle:** This is a **centralized, team-wide Product Memory system**, not a single-user tool.

### Why Multi-Tenant?

**The Reality:**
- Products are managed by **teams**, not individuals
- PMs rotate, leave, join—but the product continues
- Decisions need to be **searchable across the entire team**
- New PMs need to **inherit institutional knowledge** from previous PMs
- Teams need **shared context**, not siloed memories

**What This Means:**
- Central storage (not local gitignored files)
- Multiple PMs contributing to the same product's memory
- Team-wide visibility and searchability
- Attribution: Who made which decision
- Products can have multiple PMs over time

---

## Critical Design Questions (RESOLVED)

### Q1: Is Claude CLI Required for All PMs?

**The Problem:**
If this is team-wide memory but requires Claude Code CLI:
- PM Team of 5: Maybe only 2 use Claude Code
- Others use: Notion, Slack, ChatGPT, nothing
- Current plan locks out 60% of team from contributing

**The Solution: Multi-Interface Access Model**

**For MVP:**
```
Primary Interface: Claude Code Plugin
└─ Decision capture via /strategy-session
└─ Memory surfacing automatically
└─ Best experience for PMs who already use Claude Code

Secondary Interface: Simple Web Form (MVP)
└─ Lightweight decision capture
└─ Search historical decisions
└─ Report outcomes
└─ For PMs who don't use Claude Code

Future Interfaces (Post-MVP):
└─ Slack bot (capture from #product threads)
└─ Email capture (forward decisions via email)
└─ API (integrate with Notion, Linear, etc.)
```

**Access Matrix:**

| Feature | Claude CLI | Web Form | Future: Slack | Future: API |
|---------|------------|----------|---------------|-------------|
| Capture Decision | ✅ Rich (conversational) | ✅ Basic (form) | ✅ Thread-based | ✅ Programmatic |
| Search Decisions | ✅ Auto-surfaced | ✅ Manual search | ✅ Query bot | ✅ Query endpoint |
| Report Outcome | ✅ Prompted | ✅ Form-based | ✅ Reply to bot | ✅ Update endpoint |
| View History | ✅ In session | ✅ Browse UI | ✅ Bot query | ✅ Read endpoint |

**MVP Implementation:**

**Week 1-6:** Claude Code plugin (primary interface)
**Week 7:** Add simple web form
- URL: `https://product-memory.company.com/customer-os`
- Features: Capture decision, search, report outcome
- Auth: Company SSO

**Workflow Example:**

**Sara (Claude Code user):**
```bash
/strategy-session "AI features strategy"
[Conversational capture, auto-surfacing, rich experience]
```

**Alex (Non-Claude user):**
```
1. Opens: product-memory.company.com/customer-os
2. Clicks "Add Decision"
3. Fills form:
   - Decision: [text]
   - Why: [text]
   - Assumptions: [bullets]
   - Timeline: [dropdown]
4. Submits → Saved to same git repo
```

**Both decisions visible to entire team.**

**Recommendation:**
- Start with Claude CLI for MVP (Weeks 1-6)
- Add web form Week 7
- This ensures early users (Claude enthusiasts) get great experience
- But doesn't lock out rest of team

---

### Q2: How Do We Handle Conflicting Outcomes?

**The Problem:**
```
Week 4: Sara reports "Real-time collab succeeded, 35% adoption"
Week 8: Alex reports "Actually failed, only 12% adoption now"
```

Who's right? Both could be:
- Sara measured right after launch (early adopters)
- Alex measured 4 weeks later (churn happened)

**The Solution: Versioned Outcome History**

**Decision Schema (Updated):**
```yaml
---
decision_id: "2025-01-06-real-time-collab"
product_id: "customer-os"
pm_email: "sara@company.com"
pm_name: "Sara Chen"
decision: "Build real-time collaboration"
status: "completed"
outcome_history:  # NEW: Track all outcome reports
  - date: 2025-03-01
    reported_by: "sara@company.com"
    outcome_status: "success"
    notes: "35% adoption in first 2 weeks"
    metrics: "350 out of 1000 users adopted"
  - date: 2025-04-01
    reported_by: "alex@company.com"
    outcome_status: "below_expectations"
    notes: "Adoption dropped to 12% by week 8"
    metrics: "120 users still using (68% churned)"
    amendment: true  # This is an update/correction
---
```

**Rules:**
1. **First outcome is baseline** - Initial report sets context
2. **Updates allowed** - Any PM can add outcome amendments
3. **History preserved** - All versions tracked (who, when, what)
4. **Latest is truth** - Most recent outcome shown prominently
5. **Amendments flagged** - Clear when outcome changed over time

**UI Display:**
```
📌 Real-Time Collaboration (Jan 2025) - Sara Chen

Decision: Build real-time collaboration
Initial Outcome: ✅ Success (Sara, March 1)
  └─ 35% adoption in first 2 weeks

Updated Outcome: ⚠️ Below Expectations (Alex, April 1)
  └─ Adoption dropped to 12% by week 8
  └─ 68% of early adopters churned

Learning Evolution:
  Initially: "Users want real-time features"
  Updated: "Users try real-time features but don't stick with them"
  Pattern: Early adoption ≠ sustained usage

[View full outcome history]
```

**Conflict Resolution Process:**

**Scenario: Contradictory outcomes**
```
Sara: "Feature succeeded"
Alex: "Feature failed"
```

**System behavior:**
1. **No blocking** - Both reports accepted
2. **Flagged for review** - "Conflicting outcomes detected"
3. **Team discussion** - Prompts: "Sara and Alex reported different outcomes. What's the truth?"
4. **Resolution captured** - Final consensus added to outcome_history

**For MVP:**
- Allow amendments without restriction
- Track all changes with attribution
- Show latest outcome prominently
- Link to full history for context

**Post-MVP:**
- Add "Request review" feature for conflicts
- Notifications when outcomes updated
- Team voting on final outcome

---

### Q3: User Interaction Model - CLI vs Web vs Hybrid?

**The Decision: Hybrid Multi-Interface**

**Primary Experience (Claude CLI):**
- Best for: PMs who use Claude Code daily
- Capture: Conversational, during strategy sessions
- Search: Automatic memory surfacing
- UX: Seamless, integrated workflow

**Secondary Experience (Web):**
- Best for: PMs who don't use Claude
- Capture: Form-based decision entry
- Search: Manual browse/search UI
- UX: Simple, accessible anywhere

**Why Hybrid?**
1. **Adoption** - Don't force tool change on reluctant PMs
2. **Accessibility** - Web works on any device
3. **Gradual rollout** - Start with Claude enthusiasts, expand later
4. **Flexibility** - Teams choose their workflow

**Data Layer (Shared):**
```
Git Repo (Single Source of Truth)
    ↑
    ├─ Claude CLI writes/reads
    ├─ Web Form writes/reads
    ├─ Future: Slack bot writes/reads
    └─ Future: API writes/reads
```

**All interfaces read/write to same git repo.**

**MVP Architecture:**

```
┌─────────────────────────────────────────────┐
│         Shared Git Repository               │
│   (team-product-memory/products/...)        │
└─────────────────────────────────────────────┘
           ↑                    ↑
           │                    │
    ┌──────┴──────┐      ┌─────┴──────┐
    │  Claude CLI │      │  Web Form  │
    │   (Week 1)  │      │  (Week 7)  │
    └─────────────┘      └────────────┘
         Sara              Alex, Jordan
    (Power user)         (Casual users)
```

**Implementation Priority:**

**Phase 1 (Weeks 1-6): Claude CLI Only**
- Validate concept with early adopters
- Build core features (capture, search, outcome tracking)
- Dogfood with PM Thought Partner enthusiasts

**Phase 2 (Week 7+): Add Web Interface**
- Simple CRUD for decisions
- Browse/search UI
- Outcome reporting
- SSO authentication

**Phase 3 (Future): Additional Interfaces**
- Slack bot: `/memory-search "real-time collab"`
- Email: Forward decision summaries via email
- API: Integrate with Linear, Notion, etc.

**Key Insight:**
Starting with Claude CLI doesn't lock us into CLI-only. The shared git repo backend supports any frontend.

---

## MVP Scope

### ✅ **IN SCOPE (MVP)**

**Core Feature 1: Multi-Tenant Decision Capture**
- Enhance `/strategy-session` to auto-capture decisions at end
- Store in **centralized storage** (shared database or cloud storage)
- Structure: Decision, Rationale, Assumptions, Trade-offs, Context
- Attribution: Track which PM made the decision
- Product scoping: Decisions belong to specific products

**Core Feature 2: Team-Wide Memory Surfacing**
- When any PM starts a `/strategy-session`, search **team's decision history**
- Surface relevant history from any PM (current or former)
- Show: "Sara decided X on [date], outcome was Y"
- Cross-PM learning: Learn from other PMs' decisions

**Core Feature 3: Outcome Tracking (Team Workflow)**
- Automatic follow-up prompts based on decision timelines
- **Any PM** can report outcomes (not just decision maker)
- Update decision record with outcome + learnings
- Extract patterns across team's decisions

**Core Feature 4: Team Decision Journal**
- `/weekly-reflection` for individual PMs
- Feeds into team-wide decision memory
- Searchable by entire team
- Attribution preserved

**Core Feature 5: Basic Access Control**
- Product-level scoping (PMs see their product's decisions)
- Team-level sharing (all PMs on product see all decisions)
- Simple setup: Configure product + team members

### ❌ **OUT OF SCOPE (Post-MVP)**

- Analytics integration (Mixpanel, Amplitude)
- Linear/GitHub retroactive extraction
- Advanced pattern recognition across teams ("Platform team has 80% success rate")
- Fine-grained permissions (view-only, edit, admin roles)
- Visual decision graphs/timelines
- AI-powered decision recommendations
- Multi-product management (MVP = single product)
- Export to other tools (Notion, Confluence)
- Audit logs and version history

---

## Core Features (Detailed)

### Feature 1: Enhanced `/strategy-session` with Decision Capture

**Current State:**
- `/strategy-session` captures conversation to `sessions/YYYY-MM-DD-topic.md`
- Format is unstructured markdown
- No follow-up mechanism

**MVP Changes:**

**1.1 Add Decision Capture Block**

At end of every strategy session, after showing summary, add:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DECISION CAPTURE

I noticed you made these decisions today:
1. [Decision 1 detected from conversation]
2. [Decision 2 detected from conversation]

Should I save these to your product memory? (y/n)

If yes, I'll ask a few quick questions to capture context.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**1.2 Guided Decision Documentation**

For each decision, ask:
```
Decision: [Auto-filled from conversation]

Let me capture the context:

1. What assumptions are you making?
   PM: [Response]

2. What's the main trade-off here?
   PM: [Response]

3. When will we know if this worked? (timeline)
   PM: [Response]

4. What would success look like?
   PM: [Response]
```

**1.3 Save to Structured Format**

Create `decisions/YYYY-MM-DD-decision-slug.md`:

```yaml
---
decision_id: "2025-01-06-real-time-collab"
date: 2025-01-06
decision: "Build real-time collaboration for Q2"
status: "pending"
timeline: "8 weeks"
follow_up_date: 2025-03-01
tags: ["collaboration", "editor", "Q1-2025"]
session: "sessions/2025-01-06-collaboration-strategy.md"
---

# Decision: Build Real-Time Collaboration for Q2

**Date:** January 6, 2025
**Status:** Pending
**Follow-up:** March 1, 2025

## Rationale

- 8/10 customer interviews mentioned version conflicts
- Competitive gap (Notion has this, we don't)
- Sales team says it's blocking enterprise deals

## Assumptions

1. Users will pay for real-time features
2. Version conflicts are #1 editor pain point
3. We can build WebSocket infra in 6-8 weeks without security issues

## Trade-offs

- Delaying mobile app improvements for 2 months
- Engineering resource: 2 engineers full-time
- Risk: Engineering team skeptical about ROI

## Context

- Current editor is single-user only
- Users workaround with "save, send link, wait" flow
- Tech complexity: Need WebSocket infrastructure (don't have this yet)

## Success Criteria

- 30%+ adoption within first month
- Reduction in "version conflict" support tickets
- Enterprise customers able to collaborate in real-time

## Related Decisions

- None yet (this is your first decision!)

---

*Decision captured from strategy session: [Link to session file]*
```

---

### Feature 2: Automatic Outcome Tracking

**2.1 Follow-up Prompt System**

On the `follow_up_date`, Claude proactively asks:

```bash
# When PM runs /strategy-session or /weekly-reflection on/after March 1:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
FOLLOW-UP: Real-Time Collaboration Decision

On January 6, you decided to build real-time collaboration for Q2.
Expected timeline was 8 weeks. It's been 8 weeks.

What happened?

Original assumptions:
  1. Users will pay for real-time features
  2. Version conflicts are #1 editor pain point
  3. WebSocket infra buildable in 6-8 weeks

Success criteria:
  - 30%+ adoption within first month
  - Reduction in "version conflict" support tickets
  - Enterprise customers able to collaborate

What's the outcome?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**2.2 Outcome Capture**

PM responds conversationally:
```
PM: "Feature shipped 2 weeks ago. Adoption is only 12%, way below target.
Turns out version conflicts weren't as big a pain as interviews suggested.
Users wanted it 'just in case' but don't actually use it."
```

Claude updates the decision file:

```yaml
---
decision_id: "2025-01-06-real-time-collab"
status: "completed"
outcome_date: 2025-03-15
outcome_status: "below_expectations"
# ... rest of frontmatter
---

# Decision: Build Real-Time Collaboration for Q2

[Previous content...]

---

## OUTCOME - March 15, 2025

**Status:** ❌ Below Expectations

**Actual Results:**
- Adoption: 12% (target was 30%)
- Version conflict tickets: Reduced by only 15%
- Enterprise usage: 3 teams using it (out of 20)

**What We Learned:**

Assumption #1: ❓ Unclear
- Can't tell if users will pay (feature is free in beta)

Assumption #2: ❌ WRONG
- Version conflicts were not #1 pain point
- Interviews showed "stated preference" not "revealed preference"
- Users wanted feature "just in case" but actual usage low

Assumption #3: ✅ Correct
- WebSocket infra built in 7 weeks (on time)
- No major security issues

**Root Cause Analysis:**
- Interview feedback ≠ actual behavior
- "Nice to have" vs "must have" distinction missed
- Should have prototyped before full build

**Pattern Detected:**
- This is the 3rd time customer interviews misled us
- Previous: AI Lead Scoring (Sep 2024), Smart Notifications (Oct 2024)
- Suggested learning: Prototype + measure behavior, don't just ask

**What to Do Differently Next Time:**
- Before building "interview-validated" features, run prototype test
- Measure actual usage intent, not stated preference
- Look for workarounds users built (signals real pain)

**Related Decisions:**
- AI Email Assistant Pivot (Nov 2024) - Also learned stated ≠ revealed preference
```

---

### Feature 3: Memory Surfacing in New Sessions

**3.1 Automatic Relevance Detection**

When PM starts a new strategy session:

```bash
/strategy-session "Should we add AI-powered smart notifications?"

# BEFORE the session starts, Claude searches decisions/:

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RELEVANT HISTORY FOUND

You're thinking about AI-powered notifications. Here's what we learned before:

📌 Smart Notifications (Oct 2024)
   Decision: Shipped basic smart notifications
   Outcome: ❌ Only 8% adoption, 45% turned them off
   Learning: Generic notifications feel spammy, users want control

📌 AI Email Assistant (Nov 2024)
   Decision: Shipped generic AI email writing
   Outcome: ❌ 15% adoption
   Learning: Generic AI doesn't work, domain-specific AI does

📌 Industry Templates Pivot (Dec 2024)
   Decision: Add domain-specific templates to AI Email Assistant
   Outcome: ✅ Adoption increased to 26% (+73%)
   Learning: Users want domain-aware AI, not generic AI

Pattern: AI features need to be domain-specific to work.

Given this history, what makes AI notifications different?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**3.2 Search Algorithm**

Simple keyword matching for MVP:
- Extract keywords from new session topic
- Search decision files' frontmatter tags + content
- Rank by: Date (recent = more relevant) + Tag overlap
- Show top 3 most relevant decisions

---

### Feature 4: Weekly Decision Journal

**4.1 New Command: `/weekly-reflection`**

Lightweight ritual, runs every Friday (or on-demand):

```bash
/weekly-reflection

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WEEKLY REFLECTION - Friday, Jan 10, 2025

What decisions did you make this week?
(These can be big or small—anything that affects the product)

Examples:
  - "Decided to delay mobile app for real-time collab"
  - "Prioritized bug fixes over new features this sprint"
  - "Said no to enterprise custom reporting request"

Tell me what you decided:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

PM responds:
```
PM: "Decided to pivot AI Email Assistant to use industry templates
instead of adding more AI models. Current adoption is too low to justify
more investment in generic AI."
```

Claude asks follow-up questions (same as strategy session):
```
Why that decision?
PM: "Customer feedback says AI doesn't understand their industry language"

What assumptions are you making?
PM: "That domain-specific AI will have higher adoption than generic AI"

When will you know if it worked?
PM: "4 weeks after we ship industry templates"
```

Saves to `decisions/2025-01-10-ai-email-industry-templates.md` with same structure.

**4.2 Automatic Weekly Prompts**

On Friday, if PM hasn't run `/weekly-reflection`, show reminder:
```
📅 It's Friday! Time for weekly reflection.
Run /weekly-reflection to capture this week's decisions.
(Takes 2 minutes, compounds your product memory)
```

---

## Technical Architecture

### Multi-Tenant System Design

**Core Principle:** Centralized, team-wide decision memory with product-level scoping.

### Storage Options (Pick One for MVP)

**Option 1: Git Repository (Simplest MVP)**
```
team-product-memory/          # Shared git repo for entire team
├── products/
│   └── customer-os/          # Product name
│       ├── config.yml        # Product config (team members, etc.)
│       ├── decisions/        # All decisions for this product
│       │   ├── 2025-01-06-real-time-collab.md
│       │   └── 2025-01-10-ai-email-templates.md
│       └── sessions/         # Strategy sessions (optional)
│           └── 2025-01-06-sara-collaboration-strategy.md
└── README.md
```

**Pros:**
- Simple to implement (just markdown + git)
- Version control built-in
- Easy to browse on GitHub
- No database needed

**Cons:**
- Merge conflicts if multiple PMs edit same decision
- Slower search (need to parse all files)
- Manual git ops (push/pull)

---

**Option 2: Cloud Storage + SQLite (Recommended)**
```
Centralized Storage (S3/Cloud Storage):
└── product-memory/
    └── customer-os/
        ├── decisions.db       # SQLite database
        └── decisions/         # Markdown files (backup)
            ├── 2025-01-06-real-time-collab.md
            └── 2025-01-10-ai-email-templates.md
```

**SQLite Schema:**
```sql
CREATE TABLE products (
  product_id TEXT PRIMARY KEY,
  product_name TEXT,
  created_at TIMESTAMP,
  team_members TEXT  -- JSON array of PM emails
);

CREATE TABLE decisions (
  decision_id TEXT PRIMARY KEY,
  product_id TEXT,
  decision_date DATE,
  decision_summary TEXT,
  status TEXT,  -- pending, in_progress, completed, abandoned
  timeline TEXT,
  follow_up_date DATE,
  outcome_date DATE,
  outcome_status TEXT,  -- success, partial_success, below_expectations, failure
  tags TEXT,  -- JSON array
  pm_email TEXT,  -- Who made the decision
  pm_name TEXT,
  rationale TEXT,
  assumptions TEXT,  -- JSON array
  trade_offs TEXT,
  context TEXT,
  success_criteria TEXT,
  outcome TEXT,
  learnings TEXT,
  related_decisions TEXT,  -- JSON array of decision_ids
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE INDEX idx_decisions_product ON decisions(product_id);
CREATE INDEX idx_decisions_date ON decisions(decision_date);
CREATE INDEX idx_decisions_status ON decisions(status);
CREATE INDEX idx_decisions_follow_up ON decisions(follow_up_date);
```

**Pros:**
- Fast search (SQL queries)
- Structured data (easy to query patterns)
- Concurrent writes (SQLite handles locking)
- Can sync to cloud storage (S3, Google Drive)

**Cons:**
- Requires database setup
- More complex than pure markdown

---

**Option 3: Shared MCP Server (Future)**
```
Product Memory MCP Server (runs centrally)
├── API endpoints:
│   ├── POST /decisions (create decision)
│   ├── GET /decisions?product=X&tags=Y (search)
│   ├── PUT /decisions/:id/outcome (update outcome)
│   └── GET /decisions/:id/related (find related)
└── Storage: PostgreSQL or similar
```

**Pros:**
- True multi-tenant (many teams, many products)
- Real-time collaboration
- Advanced features (permissions, audit logs)
- API-first (integrates with other tools)

**Cons:**
- Requires server deployment
- More infrastructure
- Overkill for MVP

---

### MVP Recommendation: **Option 1 (Git Repository)**

For MVP, use a shared git repository:
- Simple to implement (pure markdown)
- Team already knows git workflow
- Version control built-in
- Can migrate to Option 2/3 later

**Setup:**
1. Create shared git repo: `team-product-memory`
2. PMs clone repo locally
3. PM Thought Partner plugin reads/writes to this repo
4. Auto-commit and push after each decision capture
5. Auto-pull before searching (get latest team decisions)

### Decision File Schema (Multi-Tenant)

**YAML Frontmatter (Structured, Searchable):**
```yaml
---
decision_id: "YYYY-MM-DD-slug"
product_id: "customer-os"
date: YYYY-MM-DD
pm_email: "sara@company.com"
pm_name: "Sara Chen"
decision: "One-sentence summary"
status: "pending" | "in_progress" | "completed" | "abandoned"
timeline: "X weeks/months"
follow_up_date: YYYY-MM-DD
outcome_date: YYYY-MM-DD (if completed)
outcome_status: "success" | "partial_success" | "below_expectations" | "failure"
tags: ["tag1", "tag2", "tag3"]
session: "sessions/2025-01-06-sara-collaboration-strategy.md" (if from strategy session)
related_decisions: ["decision_id_1", "decision_id_2"]
outcome_reported_by: "alex@company.com" (if different from pm_email)
---
```

**Markdown Body (Human-Readable):**
- Rationale
- Assumptions (numbered list)
- Trade-offs
- Context
- Success Criteria
- Related Decisions
- [After outcome] Outcome section with learnings
- Attribution footer (who made decision, who reported outcome)

### Team Setup

**Product Configuration (`products/customer-os/config.yml`):**
```yaml
product_id: "customer-os"
product_name: "CustomerOS"
team_members:
  - email: "sara@company.com"
    name: "Sara Chen"
    role: "Senior PM"
    active: true
  - email: "alex@company.com"
    name: "Alex Johnson"
    role: "PM"
    active: true
  - email: "former-pm@company.com"
    name: "Jordan Lee"
    role: "Former PM"
    active: false  # Left the team, but decisions preserved
created_at: "2024-01-01"
```

### Search & Access

**Search Scope:**
- Default: Search all decisions for current product
- Filter by: PM, date range, status, tags
- Cross-PM visibility: All team members see all decisions

**Example Search:**
```bash
# In PM Thought Partner plugin:
/strategy-session "Should we add real-time collaboration?"

# Plugin does:
1. Identify product: customer-os (from config)
2. Pull latest from git: git pull origin main
3. Search: products/customer-os/decisions/*.md
4. Filter by relevance (keywords: "real-time", "collaboration", "editor")
5. Show top 3 decisions (from any PM, any time)
```

---

## Implementation Phases

### Phase 1: Multi-Tenant Foundation (Week 1) ✅ **COMPLETED**
**Goal:** Set up centralized, team-wide decision storage

**Tasks:**
1. ✅ Create shared git repo structure:
   ```
   team-product-memory/
   ├── products/
   │   └── [product-name]/
   │       ├── config.yml
   │       ├── areas/
   │       │   └── [area-name]/
   │       │       ├── config.yml
   │       │       ├── decisions/
   │       │       └── sessions/
   └── README.md
   ```
2. ✅ Define multi-tenant decision file template (with pm_email, product_id, product_area)
3. ✅ Create setup command: `/memory-init`
   - Prompts for product name
   - Prompts for product area
   - Prompts for team members (emails)
   - Creates product config.yml and area config.yml
   - Initializes git repo (or clones existing)
4. ✅ Test: Initialize a test product with areas, create hierarchical structure

**Deliverable:** Multi-tenant storage + setup flow with product area hierarchy

---

### Phase 2: Team Decision Capture (Week 2) ✅ **COMPLETED**
**Goal:** Enhance `/strategy-session` to capture decisions to team repo

**Tasks:**
1. ✅ Modify `.claude/commands/strategy-session.md`:
   - Detect current PM (from git config or prompt)
   - Add decision detection logic at end of session
   - Add guided Q&A for decision context (4 questions)
   - Generate decision file with multi-tenant YAML (pm_email, product_id, product_area)
   - Save to team repo: `products/[product]/areas/[area]/decisions/`
2. ✅ Implement git auto-commit:
   - After decision captured: `git add`, `git commit -m "Decision: [summary]"`
   - Auto-push to shared repo: `git push origin main`
   - Handle conflicts gracefully (pull --rebase, retry)
3. ✅ Implement product/area detection:
   - Check for team-product-memory repo before session
   - Auto-detect product and area from config files
   - Pull latest team decisions before session starts
4. ✅ Handle edge cases:
   - No decisions made (skip capture)
   - Multiple decisions in one session
   - PM declines to capture
   - Git push fails (graceful error handling with retry)
   - No product memory initialized (backward compatible)

**Deliverable:** `/strategy-session` saves to team repo with attribution, product hierarchy, and full decision context

---

### Phase 3: Team-Wide Memory Surfacing (Week 3) 🚧 **TO BE DEVELOPED**
**Goal:** Surface relevant past decisions from entire team history

**Tasks:**
1. Modify `commands/strategy-session.md`:
   - Before session starts: `git pull origin main` (get latest team decisions)
   - Add pre-session search step
   - Search `products/[product]/decisions/` for relevant history
   - Display top 3 relevant decisions with PM attribution
   - Format: "Sara decided X on Jan 6, outcome was Y"
2. Implement team-wide search:
   - Keyword extraction from session topic
   - Tag matching in decision frontmatter
   - Date-based ranking (recent = more relevant)
   - Cross-PM search (show decisions from any team member)
3. Test:
   - PM #1 makes decision about "real-time collab"
   - PM #2 starts new session about "collaboration features"
   - Verify PM #1's decision is surfaced to PM #2
4. Handle edge cases:
   - No relevant history (skip surfacing)
   - Git pull fails (show warning, use local cache)

**Deliverable:** New sessions show team-wide relevant history with attribution

---

### Phase 4: Team Outcome Tracking (Week 4)
**Goal:** Allow any PM to report outcomes on team decisions

**Tasks:**
1. Modify `commands/strategy-session.md`:
   - On session start: `git pull` + check all decisions with passed `follow_up_date`
   - Prompt current PM for outcome (even if different PM made decision)
   - Update decision file with:
     - Outcome + learnings
     - `outcome_reported_by` field (who reported outcome)
   - Git commit + push updated decision
2. Implement team outcome capture flow:
   - Show original decision (who made it, when, why)
   - Ask what happened
   - Compare to original assumptions
   - Extract learnings
   - Update decision status + attribution
3. Test:
   - PM #1 makes decision with 2-week follow-up
   - PM #2 logs in after 2 weeks
   - Verify PM #2 gets prompted to report outcome
   - Verify decision file shows both PMs (maker + reporter)
4. Handle edge cases:
   - Multiple decisions need follow-up (prompt for each)
   - PM doesn't know outcome (allow "skip for now")
   - Decision maker is no longer on team (any PM can report)

**Deliverable:** Team-wide outcome tracking with attribution

---

### Phase 5: Weekly Decision Journal (Week 5)
**Goal:** Add lightweight weekly reflection

**Tasks:**
1. Create `/weekly-reflection` command in `commands/weekly-reflection.md`
2. Implement same decision capture flow as strategy sessions
3. Add Friday reminder (optional, could be manual for MVP)
4. Test: Run weekly reflection, verify decision saved

**Deliverable:** `/weekly-reflection` command working

---

### Phase 6: Polish & Documentation (Week 6)
**Goal:** Make it usable and documented

**Tasks:**
1. Update README.md with Product Memory features
2. Create example decisions for demo
3. Add troubleshooting guide
4. Test end-to-end workflow
5. Get feedback from 2-3 beta users

**Deliverable:** Documented, tested MVP ready for users

---

## Success Criteria

### MVP Success = Can Answer These Questions:

**1. Decision Capture:**
- ✅ Can PMs capture decisions in < 2 minutes?
- ✅ Does the decision record include rationale + assumptions?
- ✅ Are decisions stored in searchable format?

**2. Outcome Tracking:**
- ✅ Do PMs get prompted for outcomes at the right time?
- ✅ Are learnings connected back to original decisions?
- ✅ Can we see "what we learned" clearly?

**3. Memory Surfacing:**
- ✅ When starting a new decision, does relevant history appear?
- ✅ Does it prevent repeating past mistakes?
- ✅ Can PMs quickly find "what did we decide about X?"

**4. Adoption:**
- ✅ Do PMs use it without being forced?
- ✅ Does it feel like less work, not more?
- ✅ Does product memory compound over 3 months?

### Metrics to Track (Post-Launch):

- Number of decisions captured per month
- % of decisions that get outcome updates
- % of new strategy sessions where history is surfaced
- Time saved on "what did we decide about X?" questions
- Retention: Are PMs still using it after 3 months?

---

## Open Questions & Decisions Needed

### Privacy & Sharing
- **Q:** Should decisions be private or team-shared?
- **MVP Decision:** Team-shared by default (central git repo)
- **Rationale:** Product memory is team asset, not individual
- **Option:** Can fork for sensitive decisions if needed

### Multi-PM Collaboration (RESOLVED)
- **Q:** What if multiple PMs work on same product?
- **MVP:** Team-shared memory (this is the core feature)
- **Any PM can:** Capture decisions, search history, report outcomes
- **Attribution:** Every decision tracks who made it, who reported outcome

### Decision Granularity
- **Q:** What counts as a "decision" worth capturing?
- **Guidance:** If you'd want to remember "why did we do this?" 6 months from now, capture it
- **Examples:** Feature prioritization, tech approach, scope decisions, no-go decisions

### Outcome Tracking Frequency
- **Q:** How often should Claude prompt for outcomes?
- **MVP:** Based on `follow_up_date` in decision (PM sets timeline)
- **Fallback:** If no response, re-prompt weekly for 3 weeks, then mark "outcome_unknown"

### Search Relevance
- **Q:** How to rank decision relevance?
- **MVP:** Simple keyword + tag matching + recency
- **Post-MVP:** Could use embeddings for semantic search

---

## Team Workflow Examples

### Example 1: New PM Joins Team

**Scenario:** Alex joins as PM for CustomerOS. Sara (previous PM) left 3 months ago.

**Day 1:**
```bash
Alex: /memory-init

Claude: "Welcome! Let me set you up with CustomerOS product memory.

I found an existing memory repo for CustomerOS with 47 decisions.
Sara Chen (former PM) and Jordan Lee (current PM) have been contributing.

Should I add you to the team? (y/n)"

Alex: y

Claude: "Added alex@company.com to CustomerOS team.

You now have access to 47 historical decisions. Let's explore:
- 12 decisions about AI features
- 8 decisions about editor improvements
- 5 decisions about growth strategy
- ...

Ready to start a strategy session?"
```

**Day 30:**
```bash
Alex: /strategy-session "Should we rebuild the editor with real-time collab?"

Claude (before session starts):
"RELEVANT HISTORY FOUND

📌 Real-Time Collaboration (Jan 2025) - Sara Chen
   Decision: Build real-time collab for Q2
   Outcome: ❌ Only 12% adoption (target was 30%)
   Learning: Interview feedback ≠ actual behavior
   Lesson: Prototype first, don't just ask

📌 Editor Refactor (Nov 2024) - Sara Chen
   Decision: Hold off on editor refactor, focus on features
   Outcome: ✅ Shipped 3 features instead
   Learning: Refactors are expensive, features add more value

Given Sara tried real-time collab and it failed, what's different now?"

Alex: "Wait, we already tried this? I had no idea."

Claude: "Yes, Sara explored this 6 months ago. The feature exists but low adoption.
Before rebuilding, maybe investigate why adoption is low?"

Alex: "That just saved me 3 months of work. Let's investigate adoption first."
```

**Impact:** Alex inherited 2 years of Sara's product knowledge on Day 1.

---

### Example 2: Team Collaboration on Outcomes

**Scenario:** Sara makes decision, leaves company. Alex reports outcome.

**Week 1 (Sara):**
```bash
Sara: /strategy-session "Add industry templates to AI Email Assistant"

[Makes decision]

Claude: "Decision captured. Follow-up in 4 weeks (March 1)."

Decision file created:
---
pm_email: "sara@company.com"
pm_name: "Sara Chen"
decision: "Add industry-specific AI templates"
follow_up_date: 2025-03-01
---
```

**Week 2:** Sara leaves company.

**Week 6 (Alex):**
```bash
Alex: /strategy-session "Q2 planning"

Claude: "Before we start, outcome follow-up:

Sara decided to add industry templates to AI Email Assistant (Feb 1).
Expected timeline was 4 weeks. It's been 6 weeks.

Sara is no longer on the team. Do you know what happened with this?"

Alex: "Yes! I was working with her before she left. Feature shipped,
adoption went from 15% to 26%. Big win."

Claude: "Great! Let me capture that outcome..."

Decision file updated:
---
pm_email: "sara@company.com"
pm_name: "Sara Chen"
outcome_reported_by: "alex@company.com"
outcome_status: "success"
---

Sara's learning preserved even though she left.
```

**Impact:** Institutional knowledge doesn't walk out the door.

---

### Example 3: Cross-PM Learning

**Scenario:** Jordan (Platform PM) learns from Sara's (Product PM) decisions.

**Week 1 (Sara - Product PM):**
```bash
Sara: /strategy-session "AI Email Assistant adoption is low"

[Decides to add domain-specific templates]

Decision captured for "customer-os" product.
```

**Week 5 (Jordan - Platform PM):**
```bash
Jordan: /strategy-session "Should we add AI-powered API suggestions?"

Claude: "RELEVANT HISTORY FOUND (from other PMs)

📌 AI Email Assistant Pivot (Sara Chen, Product PM)
   Learning: Generic AI had 15% adoption
   Domain-specific AI increased to 26% (+73%)
   Pattern: Users want domain-aware AI, not generic AI

Even though this was Product team, the pattern applies to Platform.
Should your API suggestions be domain-aware?"

Jordan: "Wow, I was about to build generic AI suggestions. Thanks Sara!"
```

**Impact:** Teams learn from each other's decisions across product areas.

---

### Example 4: Pattern Recognition Over Time

**After 6 months:**
```bash
PM: /decision-search "interview" --pattern-analysis

Claude: "Found 15 decisions based on customer interviews.

Outcomes:
- 6 succeeded (40%)
- 9 failed or below expectations (60%)

Compared to decisions based on prototypes:
- 12 succeeded (85%)
- 2 failed (15%)

Your team's data shows: Prototypes > Interviews for validation.

Should this change how you approach the current decision?"
```

**Impact:** Team gets smarter about what works for THEIR product.

---

## What Comes After MVP

### Phase 2 Features (Post-MVP):
1. **Pattern Recognition:** "Features you validated with prototypes: 85% success rate"
2. **Decision Graph:** Visualize decision dependencies and evolution
3. **Retroactive Extraction:** Import decisions from old Slack/Linear/Notion
4. **Analytics Integration:** Connect decisions to metric changes
5. **Team Memory:** Multi-PM collaboration on shared product memory
6. **AI Recommendations:** "Based on past decisions, you should consider..."

### Integration Ideas:
- Linear: Tag issues with decision IDs
- Analytics: Link metric changes to decisions
- Slack: Capture decisions from #product channel
- Calendar: Automatic follow-ups on schedule

---

## Risks & Mitigations

### Risk 1: PMs Won't Use It (Too Much Friction)
**Mitigation:**
- Make capture automatic in existing workflow (strategy sessions)
- Keep questions minimal (4 questions max)
- Show immediate value (surface history in next session)

### Risk 2: Data Quality (Garbage In, Garbage Out)
**Mitigation:**
- Guided questions ensure structure
- Examples shown during capture
- Optional: Auto-extract from conversation if PM doesn't want to answer

### Risk 3: Outcome Tracking Falls Off
**Mitigation:**
- Automatic prompts (not relying on PM to remember)
- Make it easy (conversational, not form-filling)
- Show value: "You've learned X from Y outcomes tracked"

### Risk 4: Search Doesn't Find Relevant Decisions
**Mitigation:**
- Start simple (tag matching works for MVP)
- Iterate based on feedback
- Post-MVP: Add semantic search

---

## Getting Started

### For Contributors:

**Week 1:**
```bash
# Create decision infrastructure
mkdir decisions
cp templates/decision-template.md decisions/README.md
# Edit README to explain schema

# Create example decisions
# Test manually creating a decision file
```

**Week 2:**
```bash
# Enhance /strategy-session
# Add decision capture block at end
# Test with real strategy session
```

### For Users (After MVP Ships):

**Setup:**
```bash
# No setup needed - just start using /strategy-session
/strategy-session "Your product question"
# At the end, Claude will offer to capture decisions
```

**Weekly Ritual:**
```bash
# Every Friday
/weekly-reflection
# Answer: What did you decide this week?
```

**Searching Memory:**
```bash
# Happens automatically in new strategy sessions
# Or manually:
/decision-search "real-time collaboration"
```

---

## Timeline Summary

**6-Week MVP Plan:**
- Week 1: ✅ Decision storage infrastructure (Multi-tenant foundation)
- Week 2: ✅ Decision capture in strategy sessions (Team decision capture)
- Week 3: 🚧 Memory surfacing (show history) - **NEXT TO DEVELOP**
- Week 4: ⏸️ Outcome tracking follow-ups
- Week 5: ⏸️ Weekly decision journal
- Week 6: ⏸️ Polish + documentation

**Progress:** 2 of 6 phases complete (33%)
**First User Value:** End of Week 3 (decisions captured + history surfaced)
**Full MVP:** End of Week 6

---

## Questions for Review

Before starting implementation:

1. **Scope:** Is MVP scope right-sized? Too ambitious or too minimal?
2. **Structure:** Does decision file schema make sense?
3. **UX:** Is capture flow low-friction enough?
4. **Timing:** Is 6 weeks realistic?
5. **Success:** Are success criteria measurable?

---

*This plan is a living document. Update as we learn from building and using the MVP.*
