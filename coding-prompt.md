# Product Memory MVP - Implementation Guide

**Feature:** Phase 1 - Multi-Tenant Foundation
**Command:** `/memory-init`
**Estimated Time:** 1 week

---

## Architecture Update

**Key Change:** Added **Product Area** hierarchy to support platform products with multiple teams.

**Industry terminology:** Product Area (standard PM usage - Teresa Torres, Marty Cagan)

**Use case:** Large platform products (e.g., Intersight) with multiple teams working on different aspects:
- **Product:** Intersight (the platform)
- **Product Areas:** Monitoring, Foundation, Automation, IMM (different teams)

**Data model:**
```
Product → Product Areas → Decisions
  ↓           ↓              ↓
Intersight  Monitoring   Team-specific decisions
```

**Why:** Enables multiple PM teams working on different areas of same product to share institutional knowledge while keeping decisions scoped to their area.

---

## Goal

Create a setup command that initializes a shared, team-wide decision memory repository for a product and product area.

**What it does:**
- Prompts PM for product name (e.g., "Intersight")
- Prompts for product area (e.g., "Monitoring", "Foundation", "Automation", "IMM")
- Prompts for team member emails
- Creates or clones shared git repository structure
- Generates product + area configuration files
- Sets up directory structure for area-specific decisions

**Why it matters:**
- Foundation for all other Product Memory features
- Establishes multi-tenant, hierarchical data model (Product → Areas → Decisions)
- Enables multiple teams working on different areas of same product
- Enables team-wide collaboration from Day 1

---

## Success Criteria

✅ **Functional:**
1. PM runs `/memory-init` and provides product name + product area + team emails
2. Git repository `team-product-memory` is created (or cloned if exists)
3. Product structure created: `products/[product]/areas/[area]/`
4. Product config generated: `products/[product]/config.yml`
5. Area config generated: `products/[product]/areas/[area]/config.yml`
6. PM is added to area team member list
7. Command outputs: "✅ Product memory initialized for [Product] - [Area]. Ready to capture decisions."

✅ **Validation:**
1. Running `/memory-init` twice on same product area warns "already initialized for this area"
2. Running `/memory-init` with new area creates another area under same product
3. Both config files (product and area) are valid YAML and readable
4. Git repository has correct hierarchical structure

✅ **User Experience:**
- Takes < 2 minutes to complete
- Clear prompts (no technical jargon)
- Helpful error messages if git fails

---

## Documentation References

**Read these first:**
1. `planning.md` - Multi-Tenant Architecture (lines 33-297)
2. `DEPENDENCIES.md` - Phase 1 Prerequisites (lines 881-904)
3. Existing patterns:
   - `commands/reflect.md` - File creation pattern (lines 115-127)
   - `commands/strategy-session.md` - Context gathering (lines 19-50)

**Key decisions from planning:**
- Storage: Git repository (Option 1, simplest MVP)
- Structure: `team-product-memory/products/[product]/`
- Config format: YAML (`config.yml`)
- Attribution: Track PM email/name in config

---

## Integration Points

### 1. New File to Create
**Path:** `commands/memory-init.md`

**Pattern:** Follow existing command structure
- Frontmatter with description
- Clear process steps
- User prompts
- Output format
- Edge cases

**Reference:** `commands/reflect.md` (similar file creation flow)

---

### 2. Update Plugin Manifest
**File:** `.claude-plugin/plugin.json`

**Change:**
```json
"commands": [
  "./commands/strategy-session.md",
  "./commands/reflect.md",
  "./commands/memory-init.md",  // ADD THIS
  // ... rest
]
```

**Why:** Register new command with Claude Code

---

### 3. Git Operations
**Tools used:**
- Bash tool for git commands
- Write tool for creating config.yml
- Read tool for validation

**No new dependencies:** All tools already available

---

## Task List

### Task 1: Create Command File Structure
**File:** `commands/memory-init.md`

**Content:**
```markdown
---
description: /memory-init - Initialize team product memory
---

# /memory-init - Setup Team Decision Memory

[Process steps]
```

**Reference:** Copy structure from `commands/reflect.md`

---

### Task 2: Implement User Prompts
**What to prompt:**
1. Product name (e.g., "Intersight")
2. Product area (e.g., "Monitoring", "Foundation", "Automation", "IMM")
3. Team member emails (comma-separated, optional - use git config if empty)
4. Git repo URL (or create new)

**Validation:**
- Product name: no spaces, lowercase with hyphens
- Product area: no spaces, lowercase with hyphens
- Emails: basic format check (contains @)
- Git URL: optional (can create local first)

**Examples:**
```
Product: Intersight → intersight
Area: Monitoring → monitoring
Area: IMM → imm
```

**Reference:** `commands/strategy-session.md` user input patterns

---

### Task 3: Create Directory Structure
**Bash commands:**
```bash
# Option 1: Create new repo
mkdir -p team-product-memory/products/${product}/areas/${area}
cd team-product-memory
git init
git add .
git commit -m "Initialize ${product}/${area} product memory"

# Option 2: Clone existing
git clone ${repo_url} team-product-memory
cd team-product-memory
mkdir -p products/${product}/areas/${area}
```

**Subdirectories:**
```bash
# Create area-specific directories
mkdir -p products/${product}/areas/${area}/decisions
mkdir -p products/${product}/areas/${area}/sessions
```

**Hierarchy:**
```
team-product-memory/
└── products/
    └── intersight/              # Product
        ├── config.yml           # Product-level config
        └── areas/               # Product areas
            ├── monitoring/      # Area 1
            │   ├── config.yml
            │   ├── decisions/
            │   └── sessions/
            ├── foundation/      # Area 2
            │   ├── config.yml
            │   ├── decisions/
            │   └── sessions/
            └── automation/      # Area 3
                └── ...
```

---

### Task 4: Generate Config Files (Product + Area)

**File 1:** `products/[product]/config.yml` (Product-level)

**Template:**
```yaml
product_id: "${product}"
product_name: "${Product Name}"
created_at: "$(date +%Y-%m-%d)"
product_areas:
  - "${area}"
description: "Platform product with multiple product areas"
```

**Example (Intersight):**
```yaml
product_id: "intersight"
product_name: "Intersight"
created_at: "2025-01-06"
product_areas:
  - "monitoring"
  - "foundation"
  - "automation"
  - "imm"
description: "Platform product with multiple product areas"
```

---

**File 2:** `products/[product]/areas/[area]/config.yml` (Area-level)

**Template:**
```yaml
product_id: "${product}"
product_area: "${area}"
area_name: "${Area Name}"
created_at: "$(date +%Y-%m-%d)"
team_members:
  - email: "${pm_email}"
    name: "${pm_name}"
    role: "Product Manager"
    active: true
```

**Example (Monitoring area):**
```yaml
product_id: "intersight"
product_area: "monitoring"
area_name: "Monitoring"
created_at: "2025-01-06"
team_members:
  - email: "sara@company.com"
    name: "Sara Chen"
    role: "Product Manager"
    active: true
```

---

**Get PM info:**
```bash
pm_email=$(git config user.email)
pm_name=$(git config user.name)
```

**Tool:** Use Write tool to create both files

---

### Task 5: Validate and Confirm
**Checks:**
1. Product config exists: `products/${product}/config.yml`
2. Area config exists: `products/${product}/areas/${area}/config.yml`
3. Directory structure correct (areas/ subdirectory)
4. Git repo initialized

**Output:**
```
✅ Product memory initialized for ${Product Name} - ${Area Name}

Repository: team-product-memory/
Product: ${Product Name} (products/${product}/)
Area: ${Area Name} (areas/${area}/)
Team members: 1 (${pm_name})

Next steps:
1. Run /strategy-session to start capturing decisions for ${Area}
2. Add another area: run /memory-init again with different area name
3. Invite team: share repo URL with other PMs in this area

📝 Configs saved:
   - Product: products/${product}/config.yml
   - Area: products/${product}/areas/${area}/config.yml
```

---

## Validation Strategy

### Manual Testing (During Development)

**Test 1: Happy Path - Single Area**
```bash
# Run command
/memory-init

# Input
Product name: Intersight
Product area: Monitoring
Team member: sara@company.com

# Expected
- Directory created: team-product-memory/products/intersight/areas/monitoring/
- Product config exists: products/intersight/config.yml
- Area config exists: products/intersight/areas/monitoring/config.yml
- Git repo initialized
```

**Validate:**
```bash
cd team-product-memory
ls -la products/intersight/
ls -la products/intersight/areas/monitoring/
cat products/intersight/config.yml
cat products/intersight/areas/monitoring/config.yml
git log
```

---

**Test 2: Multiple Areas Under Same Product**
```bash
# PM 1 initializes Monitoring area
/memory-init
Product: Intersight
Area: Monitoring

# PM 2 initializes Foundation area (same product)
git clone <repo-url>
/memory-init
Product: Intersight
Area: Foundation

# Expected
- Both areas created under same product:
  - products/intersight/areas/monitoring/
  - products/intersight/areas/foundation/
- Product config updated with both areas:
  product_areas:
    - "monitoring"
    - "foundation"
- Each area has own config with own team members
```

**Validate:**
```bash
cat products/intersight/config.yml
# Should show both areas in product_areas list

ls products/intersight/areas/
# Should show: foundation  monitoring
```

---

**Test 3: Invalid Input**
```bash
/memory-init

# Test cases
Product name: "Intersight Platform" (has space) → Convert to intersight-platform
Product area: "IMM Manager" (has space) → Convert to imm-manager
Team email: "invalid-email" → Reject, ask again
Git repo: <invalid-url> → Fallback to local repo

# Expected conversions
"Intersight Platform" → "intersight-platform"
"IMM Manager" → "imm-manager"
"Monitoring & Alerts" → "monitoring-alerts"
```

---

### Automated Validation (Pattern from Existing Code)

**Pattern:** Commands don't have unit tests, they have validation checks

**Add to command:**
```markdown
## Validation Checks (Internal)

After setup, verify:
1. ✅ Product directory exists: `test -d products/${product}`
2. ✅ Area directory exists: `test -d products/${product}/areas/${area}`
3. ✅ Product config valid: `grep -q "product_id" products/${product}/config.yml`
4. ✅ Area config valid: `grep -q "product_area" products/${product}/areas/${area}/config.yml`
5. ✅ Git initialized: `git rev-parse --git-dir` returns `.git`

If any fail, show error and rollback.
```

**Reference:** `commands/reflect.md` lines 129-157 (edge case handling)

---

## Desired Codebase Structure

### After Phase 1 Implementation

```
pm-thought-partner/
├── commands/
│   ├── strategy-session.md
│   ├── reflect.md
│   ├── memory-init.md          ← NEW
│   └── ... (other commands)
├── .claude-plugin/
│   └── plugin.json              ← UPDATED (add memory-init)
├── planning.md                  ← Reference
├── DEPENDENCIES.md              ← Reference
├── coding-prompt.md             ← This file
└── README.md                    ← Update with /memory-init

External (created by /memory-init):
team-product-memory/             ← NEW (user's workspace)
├── products/
│   └── intersight/              ← Product
│       ├── config.yml           ← Product-level config (lists all areas)
│       └── areas/               ← Product areas
│           ├── monitoring/      ← Area 1
│           │   ├── config.yml   ← Area-level config (team members)
│           │   ├── decisions/   ← Area-specific decisions
│           │   └── sessions/    ← Area-specific sessions
│           ├── foundation/      ← Area 2
│           │   ├── config.yml
│           │   ├── decisions/
│           │   └── sessions/
│           ├── automation/      ← Area 3
│           │   └── ...
│           └── imm/             ← Area 4
│               └── ...
└── README.md
```

**Key Hierarchy:**
- **Product:** Intersight (platform)
- **Product Areas:** Monitoring, Foundation, Automation, IMM (teams)
- **Decisions:** Scoped to product area (team-specific)

---

## Implementation Notes

### Keep It Simple (MVP)

**Don't implement yet:**
- [ ] Multiple products (just one for MVP)
- [ ] Remote git hosting setup (manual for MVP)
- [ ] Team member removal/updates (edit config.yml manually)
- [ ] Access control/permissions (trust-based for MVP)

**Do implement:**
- [x] Single product initialization
- [x] Local git repo creation
- [x] Basic config generation
- [x] Team member tracking

---

### Edge Cases to Handle

**1. Area already initialized:**
```
"✅ Product area already exists for ${product}/${area}.

Adding you to the team...
Updated: products/${product}/areas/${area}/config.yml
```

**2. Product exists, new area:**
```
"✅ Product ${product} exists. Creating new area: ${area}

Created: products/${product}/areas/${area}/
Updated product config with new area.
```

**3. No git installed:**
```
"❌ Git not found. Install git first:
brew install git (macOS)
sudo apt install git (Linux)"
```

**4. No git user config:**
```
"⚠️ Git user not configured. Run:
git config --global user.email 'you@company.com'
git config --global user.name 'Your Name'

Then run /memory-init again."
```

**5. Invalid product/area names:**
```
"Product and area names should be lowercase with hyphens.

Converting:
  Product: 'Intersight Platform' → 'intersight-platform'
  Area: 'IMM Manager' → 'imm-manager'

Proceeding with converted names."
```

---

## Success Metrics

After implementation, PM should be able to:

1. ✅ Run `/memory-init` in < 2 minutes
2. ✅ Initialize product with area (e.g., Intersight/Monitoring)
3. ✅ See clear confirmation message
4. ✅ Verify both config files created (product + area)
5. ✅ Add multiple areas to same product
6. ✅ Share repo URL with team
7. ✅ Second PM can run `/memory-init` and join existing area OR create new area

**Definition of Done:**
- [ ] Command file created (`commands/memory-init.md`)
- [ ] Plugin manifest updated
- [ ] Manual tests pass (all 3 scenarios)
- [ ] Product area hierarchy working (Product → Areas → Decisions)
- [ ] Edge cases handled gracefully (5 cases)
- [ ] Documentation updated (README.md)

---

## Next Phase Preview

**After Phase 1 complete, next is Phase 2:**
- Enhance `/strategy-session` with decision capture
- Use `team-product-memory/` repo created in Phase 1
- Write decisions to `products/[product]/areas/[area]/decisions/`
- Decisions scoped to product area (team-specific)

**Dependencies:**
- Phase 2 requires Phase 1 complete (repo + area must exist)
- PM must select which area they're working in for decision capture

---

# Product Memory MVP - Phase 2 Implementation Guide

**Feature:** Phase 2 - Team Decision Capture
**Previous Phase:** Phase 1 (Multi-Tenant Foundation) ✅ **COMPLETED**
**Estimated Time:** 1 week

---

## Phase 1 Status Check

**✅ Phase 1 Prerequisites Met:**
- [x] `/memory-init` command created and working
- [x] Multi-tenant git repository structure (`team-product-memory/`)
- [x] Product + Area configuration files (hierarchical YAML)
- [x] Plugin manifest updated with `/memory-init`
- [x] Git operations tested (clone, pull, push, commit)

**What Phase 1 Delivered:**
```
team-product-memory/
├── products/
│   └── [product]/              # Product (e.g., "intersight")
│       ├── config.yml          # Product-level config (lists all areas)
│       └── areas/              # Product areas
│           └── [area]/         # Area (e.g., "monitoring")
│               ├── config.yml  # Area-level config (team members)
│               ├── decisions/  # ← Phase 2 will write here
│               └── sessions/   # ← Phase 2 will write here
└── README.md
```

---

## Goal

Enhance `/strategy-session` to automatically capture decisions to the team-wide product memory repository.

**What it does:**
- Detects current product/area from initialized repo
- Identifies decisions made during strategy session
- Guides PM through decision context capture (Q&A)
- Generates decision file with multi-tenant YAML frontmatter
- Saves to `products/[product]/areas/[area]/decisions/`
- Auto-commits and pushes to shared git repo
- Handles git conflicts gracefully

**Why it matters:**
- Decisions no longer get lost in chat history
- Team-wide visibility (all PMs see all decisions)
- Attribution preserved (who made what decision)
- Foundation for Phase 3 (memory surfacing)
- Builds institutional knowledge over time

---

## Success Criteria

✅ **Functional:**
1. PM runs `/strategy-session`, has productive conversation
2. At end of session, Claude detects decisions made
3. PM is prompted with 4 context-gathering questions per decision
4. Decision file created in `products/[product]/areas/[area]/decisions/`
5. File has valid YAML frontmatter (pm_email, product_id, product_area, etc.)
6. Git auto-commit + push to team repo succeeds
7. Other team members can `git pull` and see the decision

✅ **Validation:**
1. Running session without decisions doesn't create files (graceful skip)
2. Multiple decisions in one session create multiple files
3. Git conflicts are detected and reported to user
4. Decision files are readable as both YAML and markdown
5. Session files optionally saved to `sessions/` directory

✅ **User Experience:**
- Decision capture takes < 3 minutes total
- Questions are clear and conversational
- PM can decline to capture decisions (not forced)
- Clear confirmation message after capture
- Helpful error messages if git fails

---

## Documentation References

**Read these first:**
1. `planning.md` - Phase 2 Details (lines 911-935)
2. `DEPENDENCIES.md` - Phase 2 Prerequisites (lines 382-404)
3. Existing patterns:
   - `commands/strategy-session.md` - Current session flow (lines 1-470)
   - `commands/memory-init.md` - Git operations pattern
   - `commands/reflect.md` - File writing pattern

**Key decisions from planning:**
- Decision detection: AI-powered (Claude analyzes conversation)
- Capture flow: Conversational Q&A (not a form)
- Storage: Same git repo as Phase 1
- Attribution: Track PM email/name from git config
- Scope: Decisions scoped to product area

---

## Integration Points

### 1. Modify Existing File
**Path:** `commands/strategy-session.md`

**Current flow:**
```
1. Context Gathering (Explore agent)
2. Opening (set expectations)
3. Exploration (conversational Q&A)
4. Capture & Structure (summary)
5. Linear Output (optional)
6. Session Persistence (optional)
```

**New Phase 2 additions:**
```
1. Context Gathering (Explore agent)
   ↓
   + NEW: Check for team-product-memory repo
   + NEW: Detect current product/area
2. Opening (set expectations)
3. Exploration (conversational Q&A)
4. Capture & Structure (summary)
   ↓
   + NEW: Decision Detection
   + NEW: Decision Context Q&A
   + NEW: Generate decision files
   + NEW: Git commit + push
5. Linear Output (optional)
6. Session Persistence (optional)
```

**What to preserve:**
- Existing conversational style
- Explore agent context gathering
- Linear integration
- Session persistence option

**What to add:**
- Decision detection logic (after summary)
- Product/area detection (before session starts)
- Decision Q&A prompts
- YAML frontmatter generation
- Git auto-commit workflow

---

### 2. No New Dependencies Required

**Already available:**
- ✅ Git CLI (version 2.50.1 installed)
- ✅ Git config (user.email and user.name set)
- ✅ Bash tool (for git commands)
- ✅ Write tool (for decision files)
- ✅ Read tool (for config files)
- ✅ Edit tool (for updating configs)
- ✅ Date command (for timestamps)

**No installation needed** - all tools ready to use.

---

## Task List

### Task 1: Add Product/Area Detection (Start of Session)

**Location:** `commands/strategy-session.md` - After frontmatter, before "Your Role"

**Add new section:**

```markdown
## Product Memory Setup (Before Session)

**Before starting the strategy session, check if product memory is initialized.**

### 1. Check for team-product-memory repository

Use Bash tool:
```bash
test -d ../team-product-memory && echo "EXISTS" || echo "NOT_FOUND"
```

**If NOT_FOUND:**
- Skip product memory features for this session
- Proceed with normal strategy session
- At end, optionally suggest: "Run /memory-init to enable team decision memory"

**If EXISTS:**
- Proceed to step 2

### 2. Detect current product and area

Read the config files to find which product/area the PM is working in.

**Strategy:**
- If only one product exists: Use that product
- If only one area exists under that product: Use that area
- If multiple products or areas: Prompt PM to select

**Implementation:**
```bash
cd ../team-product-memory
find products -name "config.yml" -path "*/areas/*/config.yml"
```

Parse the results and extract product/area names.

**If PM's email is in multiple areas:**
```
I found your email in multiple product areas:
1. intersight/monitoring
2. intersight/foundation
3. customer-os/platform

Which area is this session for? (enter number or type product/area)
```

**Store for later use:**
- `current_product`: e.g., "intersight"
- `current_area`: e.g., "monitoring"
- `pm_email`: from git config
- `pm_name`: from git config

### 3. Pull latest team decisions

Before session starts, sync with team repo:
```bash
cd ../team-product-memory
git pull origin main 2>/dev/null || echo "Note: Could not pull from remote"
```

If pull fails (no remote), continue anyway with local repo.

### 4. Continue with normal session flow

After detection complete, proceed with:
- Context Gathering (Explore agent)
- Opening
- Exploration
- etc.
```

---

### Task 2: Add Decision Detection (After Summary)

**Location:** `commands/strategy-session.md` - After "Capture & Structure" section, before "Linear Output"

**Add new section:**

```markdown
### 3.5 Decision Capture (Product Memory)

**Only if product memory is initialized (from step 0).**

After showing the session summary, add this decision capture block:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DECISION CAPTURE

I noticed you made these decisions today:
[Analyze the conversation and list detected decisions]

1. [Decision 1 - one sentence summary]
2. [Decision 2 - one sentence summary]
3. [Decision 3 - one sentence summary]

Should I save these to your product memory for {current_product}/{current_area}? (y/n)

If yes, I'll ask a few quick questions (3 min) to capture context.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Decision Detection Logic:**

Analyze the session conversation for:
- **Commitments to action:** "I'm going to...", "We will...", "Let's..."
- **Trade-off resolutions:** "We chose X over Y because..."
- **Feature prioritization:** "We're doing X first, Y later"
- **Go/No-Go decisions:** "We're not building X", "We're saying no to Y"
- **Approach selections:** "We'll use approach A instead of B"

**Rules:**
- Minimum 1 decision, maximum 5 per session (more = overwhelming)
- Each decision should be actionable (not just insights)
- Ask PM to confirm: "Are these the key decisions? (y/n/add more)"

**If PM says no:**
- Skip decision capture
- Continue to Linear Output or wrap up

**If PM says yes:**
- Proceed to Task 3 (Decision Context Q&A)

**If PM says "add more":**
- Ask: "What other decisions did you make?"
- Add to list and re-confirm
```

---

### Task 3: Implement Decision Context Q&A

**Location:** Same section as Task 2

**For each decision, ask these 4 questions conversationally:**

```markdown
### Decision Context Questions

For each decision, gather context:

```
Let me capture the context for: {decision_summary}

1️⃣ What assumptions are you making?
   (What needs to be true for this to work?)

   PM: [Response]

2️⃣ What's the main trade-off here?
   (What are you giving up or delaying?)

   PM: [Response]

3️⃣ When will we know if this worked?
   (Timeline: 2 weeks, 1 month, 3 months?)

   PM: [Response]

4️⃣ What would success look like?
   (Specific metrics or outcomes)

   PM: [Response]
```

**Keep it conversational:**
- Don't say "Question 1 of 4" - just ask naturally
- Allow brief answers (2-3 sentences each)
- If PM says "skip" or "I don't know", that's okay - note "TBD"
- Total time: ~2-3 minutes for all questions

**After all questions answered:**
```
Got it. Saving {number} decision(s) to team memory...
```

Proceed to Task 4 (Generate decision files).
```

---

### Task 4: Generate Decision Files with YAML Frontmatter

**Implementation: Write tool + String templates**

**For each decision, create a file:**

**Filename format:**
```
../team-product-memory/products/{product}/areas/{area}/decisions/{YYYY-MM-DD}-{slug}.md
```

**Slug generation:**
- Take first 5 words of decision summary
- Convert to lowercase
- Replace spaces with hyphens
- Remove special characters
- Max 50 characters

**Example:** "Build real-time collaboration for Q2" → "build-real-time-collaboration-for"

**File template:**

```yaml
---
decision_id: "{YYYY-MM-DD}-{slug}"
product_id: "{product}"
product_area: "{area}"
date: {YYYY-MM-DD}
pm_email: "{pm_email}"
pm_name: "{pm_name}"
decision: "{decision_summary}"
status: "pending"
timeline: "{timeline_from_q3}"
follow_up_date: {YYYY-MM-DD_calculated_from_timeline}
tags: []
session: "sessions/{YYYY-MM-DD}-{session_topic_slug}.md"
---

# Decision: {decision_summary}

**Date:** {Month DD, YYYY}
**Status:** Pending
**Follow-up:** {follow_up_date_formatted}
**PM:** {pm_name} ({pm_email})

## Rationale

{Why this decision was made - from session context}

## Assumptions

{Answer from Q1, formatted as bullet list}

## Trade-offs

{Answer from Q2}

## Context

{Relevant context from session - product state, customer feedback, competitive pressure, etc.}

## Success Criteria

{Answer from Q4}

## Timeline

{Answer from Q3}

**Expected completion:** {follow_up_date}

## Related Decisions

None yet (first decision in this area!)

---

*Decision captured from strategy session: [Link to session file if saved]*
*Product Memory - Team: {product}/{area}*
```

**Follow-up date calculation:**

```bash
# Based on timeline from Q3:
# "2 weeks" → add 14 days
# "1 month" → add 30 days
# "3 months" → add 90 days
# "Q2" → calculate end of Q2

# Use date command:
date -v+14d +%Y-%m-%d  # macOS
date -d "+14 days" +%Y-%m-%d  # Linux
```

**Edge cases:**
- If timeline is "TBD" → follow_up_date = 30 days from now (default)
- If slug collision exists → append `-2`, `-3`, etc.
- If tags are mentioned in session → extract and add to tags array

**Use Write tool to create file** - one file per decision.

---

### Task 5: Git Auto-Commit and Push

**After all decision files created, commit to git:**

**Implementation:**

```bash
cd ../team-product-memory

# Add all new decision files
git add products/{product}/areas/{area}/decisions/*.md

# Also add session file if saved
git add products/{product}/areas/{area}/sessions/*.md 2>/dev/null || true

# Commit with descriptive message
git commit -m "Decision: {first_decision_summary}

Added by: {pm_name} ({pm_email})
Product: {product}
Area: {area}
Decisions: {number_of_decisions}

Session date: {YYYY-MM-DD}"

# Try to push (handle errors gracefully)
git push origin main 2>&1
```

**Error handling:**

**If push fails (no remote):**
```
✅ Decisions saved locally to team-product-memory/

⚠️ No remote repository configured.

To share with your team:
1. Set up a remote: git remote add origin <repo-url>
2. Push: git push -u origin main
3. Team members can then: git clone <repo-url>
```

**If push fails (merge conflict):**
```
⚠️ Could not push - someone else made changes.

Attempting to resolve...
```

Try to resolve:
```bash
git pull --rebase origin main
git push origin main
```

**If rebase fails:**
```
❌ Merge conflict detected.

Your decisions are saved locally. To sync with team:
1. cd ../team-product-memory
2. git pull origin main
3. Resolve conflicts manually
4. git push origin main

Your local files are safe at:
  products/{product}/areas/{area}/decisions/
```

**If push succeeds:**
```
✅ {number} decision(s) pushed to team memory

Saved to: products/{product}/areas/{area}/decisions/
Team members will see these after: git pull
```

---

### Task 6: Session Persistence (Optional Enhancement)

**Also save session file to team repo (optional):**

If PM chooses "Save this session for future reflection":

**Create session file at:**
```
../team-product-memory/products/{product}/areas/{area}/sessions/{YYYY-MM-DD}-{topic-slug}.md
```

**Use same template as current `/strategy-session`** (lines 421-453), but add frontmatter:

```yaml
---
session_id: "{YYYY-MM-DD}-{topic-slug}"
product_id: "{product}"
product_area: "{area}"
date: {YYYY-MM-DD}
pm_email: "{pm_email}"
pm_name: "{pm_name}"
topic: "{session_topic}"
frameworks_applied: ["Four Risks", "Continuous Discovery", etc.]
decisions_created: ["{decision_id_1}", "{decision_id_2}"]
---

# Strategy Session: {topic}
...
(rest of session content)
```

This creates linkage between sessions and decisions.

---

### Task 7: Update Session Summary Output

**Location:** `commands/strategy-session.md` - "Capture & Structure" section

**After decision capture complete, update summary to include:**

```markdown
Great session. Here's what I captured:

🎯 CORE DECISIONS
• [Decision 1: what was decided]
• [Decision 2: key tradeoff chosen]

⚠️ KEY RISKS IDENTIFIED
• [Risk 1...]
• [Risk 2...]

🔬 PROTOTYPES TO BUILD THIS WEEK
• [Prototype 1...]

❓ OPEN QUESTIONS TO INVESTIGATE
• [Question 1...]

📊 NEXT ACTIONS
• [Action 1...]

📝 TEAM DECISION MEMORY                           ← NEW
✅ Saved {number} decision(s) to team repo
   Product: {product} / Area: {area}
   Files: products/{product}/areas/{area}/decisions/
   Team members: {count} active PMs can see these
   [View decisions: ls ../team-product-memory/products/{product}/areas/{area}/decisions/]

Want me to:
1. Create Linear issues for prototypes + investigations
2. Save this session summary
3. Continue exploring
4. Wrap up
```

This makes it clear decisions were captured and are now team-visible.

---

## Validation Strategy

### Manual Testing (During Development)

**Test 1: Happy Path - Single Decision**

```bash
# Setup
cd pm-thought-partner
/memory-init
  Product: test-product
  Area: test-area

# Run strategy session
/strategy-session "Should we build AI feature?"

[Have conversation with 1 clear decision]

# Expected at end:
- Claude detects 1 decision
- Asks 4 context questions
- Creates decision file
- Git commit succeeds
- Confirmation message shown

# Validate
cd ../team-product-memory
ls products/test-product/areas/test-area/decisions/
# Should show: 2025-01-06-should-we-build-ai.md

cat products/test-product/areas/test-area/decisions/2025-01-06-*.md
# Should have valid YAML frontmatter + markdown body

git log -1
# Should show commit with decision
```

---

**Test 2: Multiple Decisions in One Session**

```bash
/strategy-session "Q1 planning"

[Conversation with 3 decisions:
 1. Prioritize feature A over B
 2. Delay mobile app
 3. Hire 2 engineers]

# Expected:
- Claude detects all 3 decisions
- Asks 4 questions for EACH (12 questions total)
- Creates 3 separate decision files
- All committed in one git commit

# Validate
ls ../team-product-memory/products/test-product/areas/test-area/decisions/
# Should show 3 new files with today's date
```

---

**Test 3: No Decisions Made**

```bash
/strategy-session "Brainstorming session"

[Exploratory conversation, no concrete decisions]

# Expected:
- Claude says "I didn't detect any concrete decisions"
- Skips decision capture
- Continues to Linear/wrap up
- No decision files created
```

---

**Test 4: PM Declines to Capture**

```bash
/strategy-session "Sensitive topic"

[Makes 2 decisions but wants to keep private]

Claude: "Should I save these decisions? (y/n)"
PM: "n"

# Expected:
- Claude respects choice
- No files created
- Continues to Linear/wrap up
- No git commit for decisions
```

---

**Test 5: Git Conflict Handling**

```bash
# Setup: Two PMs working simultaneously

# PM 1
/strategy-session "Feature A planning"
[Makes decision, pushes to remote]

# PM 2 (before pulling PM 1's changes)
/strategy-session "Feature B planning"
[Makes decision, tries to push]

# Expected for PM 2:
- Push fails (remote has new commits)
- Claude attempts git pull --rebase
- If successful: Push succeeds
- If conflict: Clear error message with manual steps
- PM 2's decision file is safe locally
```

---

**Test 6: No Product Memory Initialized**

```bash
# Don't run /memory-init

/strategy-session "Planning session"

[Normal session conversation]

# Expected:
- Decision detection skipped
- No product memory features
- Normal strategy session works as before
- Optionally: "Run /memory-init to enable decision memory"
```

---

**Test 7: Multiple Product Areas**

```bash
# Setup: PM is in 2 areas
/memory-init
  Product: intersight
  Area: monitoring

/memory-init
  Product: intersight
  Area: foundation

# Run session
/strategy-session "Cross-team planning"

# Expected:
- Claude prompts: "Which area is this session for?"
- Shows: 1. intersight/monitoring  2. intersight/foundation
- PM selects area
- Decision saved to correct area
```

---

### Automated Validation (Built into Command)

**Add validation checks after decision files created:**

```markdown
## Internal Validation (after file creation)

Run these checks before git commit:

```bash
# 1. Files exist
for decision_file in {list_of_created_files}; do
  test -f "$decision_file" || echo "ERROR: File not created: $decision_file"
done

# 2. Valid YAML frontmatter
for decision_file in {list_of_created_files}; do
  head -20 "$decision_file" | grep -q "^decision_id:" || echo "ERROR: Invalid YAML in $decision_file"
done

# 3. Required fields present
for decision_file in {list_of_created_files}; do
  grep -q "^pm_email:" "$decision_file" || echo "ERROR: Missing pm_email in $decision_file"
  grep -q "^product_id:" "$decision_file" || echo "ERROR: Missing product_id in $decision_file"
  grep -q "^product_area:" "$decision_file" || echo "ERROR: Missing product_area in $decision_file"
done
```

If any validation fails:
- Don't commit to git
- Show error to user
- Keep local files for inspection
```

---

## Edge Cases to Handle

### 1. PM Email Not in Area Team Members

**Scenario:** PM runs session for an area they're not officially part of

**Detection:**
```bash
grep -q "{pm_email}" products/{product}/areas/{area}/config.yml
```

**If not found:**
```
⚠️ Your email ({pm_email}) is not in the {area} team.

Would you like me to add you? (y/n)
```

**If yes:**
- Edit `config.yml` to add PM to `team_members`
- Commit: "Added {pm_name} to {area} team"
- Continue with session

**If no:**
- Continue with session
- Save decisions with warning comment:
  "Note: Decision made by {pm_name} who is not officially on {area} team"

---

### 2. Timeline Parsing Failures

**PM says:** "We'll know in a few weeks"

**Parse strategies:**
```
"few weeks" → 21 days (3 weeks)
"couple months" → 60 days (2 months)
"end of Q2" → calculate Q2 end date
"next sprint" → 14 days (assume 2-week sprints)
"soon" → 7 days
```

**If unparseable:**
- Default: 30 days from today
- Note in decision: "Timeline: {original_answer} (estimated ~30 days)"

---

### 3. Decision Slug Collisions

**If file already exists:**
```
products/{product}/areas/{area}/decisions/2025-01-06-build-ai-feature.md
```

**Append counter:**
```
2025-01-06-build-ai-feature-2.md
2025-01-06-build-ai-feature-3.md
```

**Check with:**
```bash
base_file="2025-01-06-build-ai-feature.md"
counter=2
while [[ -f "$base_file" ]]; do
  base_file="${base_file%.md}-${counter}.md"
  ((counter++))
done
```

---

### 4. Session Without Product Memory Context

**PM starts session from different directory:**

```bash
pwd
# /Users/pm/some-random-dir

/strategy-session "Planning"
```

**Claude checks:**
```bash
test -d ./team-product-memory || test -d ../team-product-memory
```

**If neither exists:**
- Skip product memory
- Run normal strategy session
- At end: "Want to enable decision memory? Run /memory-init"

---

### 5. Long Decision Summaries

**PM's decision is verbose:**
```
"We're going to build a comprehensive AI-powered recommendation engine that analyzes user behavior across multiple dimensions including time on page, scroll depth, click patterns, and purchase history to surface personalized product recommendations in real-time..."
```

**Truncate for file naming:**
- Take first 50 characters
- Ensure complete words (don't cut mid-word)
- Example: "build-comprehensive-ai-powered-recommendation-engine"

**Keep full summary in YAML frontmatter** and markdown heading.

---

## Implementation Notes

### Keep It Simple (MVP)

**Don't implement yet:**
- [ ] Semantic search for decision relevance (Phase 3)
- [ ] Outcome tracking prompts (Phase 4)
- [ ] Pattern recognition across decisions (Phase 6)
- [ ] Analytics dashboard (Post-MVP)
- [ ] Web interface for decision CRUD (Week 7+)
- [ ] Slack/email integration (Post-MVP)

**Do implement:**
- [x] Decision detection (AI-based)
- [x] Decision context capture (4 questions)
- [x] YAML frontmatter generation
- [x] Git auto-commit + push
- [x] Product/area detection
- [x] Team-wide storage

---

### Conversation Flow Example

**End of strategy session:**

```
You: "Great session. Here's what I captured:

🎯 CORE DECISIONS
• Build AI email assistant with industry templates
• Delay mobile app improvements for 2 months
• Hire ML engineer by end of Q1

[rest of summary...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DECISION CAPTURE

I noticed you made these decisions today:
1. Build AI email assistant with industry templates
2. Delay mobile app improvements for 2 months
3. Hire ML engineer by end of Q1

Should I save these to your product memory for customer-os/platform? (y/n)"

PM: "y"

You: "Great! Let me capture the context. This will take about 3 minutes.

Decision 1: Build AI email assistant with industry templates

What assumptions are you making?"

PM: "That domain-specific AI will perform better than generic AI"

You: "What's the main trade-off?"

PM: "Delaying the mobile app work that sales has been asking for"

You: "When will we know if this worked?"

PM: "4 weeks - we'll measure adoption rate"

You: "What would success look like?"

PM: "Adoption goes from 15% to 30%"

You: "Got it.

[Repeats for decisions 2 and 3...]

Saving 3 decisions to team memory...

✅ 3 decisions pushed to team memory

Saved to: products/customer-os/areas/platform/decisions/
  - 2025-01-06-build-ai-email-assistant.md
  - 2025-01-06-delay-mobile-app-improvements.md
  - 2025-01-06-hire-ml-engineer.md

Team members (Sara, Alex, Jordan) will see these after: git pull

Want me to:
1. Create Linear issues for these decisions
2. Save this session summary
3. Wrap up"
```

---

## Success Metrics

After implementation, PM should be able to:

1. ✅ Run `/strategy-session` and have decisions automatically detected
2. ✅ Answer 4 quick context questions per decision (< 3 min total)
3. ✅ See decisions saved to team repo with confirmation
4. ✅ Have other team members pull and see the decisions
5. ✅ See clear git commit messages with attribution
6. ✅ Decline to capture decisions without breaking session flow
7. ✅ Handle multiple decisions in one session smoothly
8. ✅ Get helpful errors if git operations fail

**Definition of Done:**
- [ ] `/strategy-session` modified with decision capture flow
- [ ] Product/area detection working (uses /memory-init data)
- [ ] Decision detection logic implemented (AI-based)
- [ ] Decision Q&A prompts working (4 questions)
- [ ] YAML frontmatter generation correct (all required fields)
- [ ] Decision files created in correct directory
- [ ] Git auto-commit + push working
- [ ] Conflict handling graceful (retry with rebase)
- [ ] Manual tests pass (all 7 scenarios)
- [ ] Edge cases handled (5 cases documented)
- [ ] Session summary updated to show decision capture status

---

## Next Phase Preview

**After Phase 2 complete, next is Phase 3: Team-Wide Memory Surfacing**

**What Phase 3 will do:**
- Enhance `/strategy-session` to search team decision history
- Before session starts: `git pull` + search relevant decisions
- Surface top 3 relevant past decisions from team
- Show attribution: "Sara decided X on Jan 6, outcome was Y"
- Enable cross-PM learning

**Dependencies:**
- Phase 2 must be complete (decisions must exist in repo)
- Need search algorithm (keyword matching for MVP)
- Need relevance ranking (date + keyword overlap)

**New capabilities unlocked:**
- "We tried this before" intelligence
- Prevent repeating past mistakes
- Learn from other PMs' decisions
- Inherit institutional knowledge on Day 1

---

## Git-Related Dependencies Analysis

### ✅ Already Available (No Action Needed)

1. **Git Installation**
   - Version: 2.50.1 (Apple Git-155)
   - Location: `/usr/bin/git`
   - Status: ✅ Installed and working

2. **Git Configuration**
   - User email: `urabhijeet.singh@gmail.com`
   - User name: `abhixz13`
   - Status: ✅ Configured correctly

3. **Bash Tool**
   - Available via Claude Code
   - Can run all git commands
   - Status: ✅ Ready to use

4. **File Tools**
   - Write: ✅ Available
   - Read: ✅ Available
   - Edit: ✅ Available
   - Glob: ✅ Available
   - Grep: ✅ Available

5. **Date/Time**
   - `date` command available
   - Can format: `date +%Y-%m-%d`
   - Status: ✅ Ready to use

### ❌ NOT Required (Explicitly Avoiding)

1. **YAML Libraries** - Manual string generation instead
2. **Databases** - Using git + markdown files
3. **Web Frameworks** - CLI-first for MVP
4. **External APIs** - Self-contained system

### 📋 Implementation Checklist for Phase 2

**Before starting:**
- [x] Phase 1 complete (`/memory-init` working)
- [x] Git installed and configured
- [x] Test repo exists (`team-product-memory/`)
- [ ] Read Phase 2 plan thoroughly

**During implementation:**
- [ ] Add product/area detection logic
- [ ] Implement decision detection (AI analysis)
- [ ] Create decision Q&A flow
- [ ] Generate YAML frontmatter templates
- [ ] Implement git auto-commit
- [ ] Add conflict handling
- [ ] Update session summary output
- [ ] Test all 7 manual test scenarios
- [ ] Handle all 5 edge cases

**After implementation:**
- [ ] Manual testing complete (all pass)
- [ ] Edge cases verified (all handled)
- [ ] Git operations tested (commit, push, conflict)
- [ ] Multi-tenant attribution verified
- [ ] Documentation updated (README.md)
- [ ] Ready for Phase 3

---

# Product Memory MVP - Phase 3 Implementation Guide

**Feature:** Phase 3 - Team-Wide Memory Surfacing
**Previous Phase:** Phase 2 (Team Decision Capture) ✅ **COMPLETED**
**Estimated Time:** 1 week

---

## Phase 2 Status Check

**✅ Phase 2 Prerequisites Met:**
- [x] `/strategy-session` enhanced with decision capture
- [x] Decision detection logic (AI-powered)
- [x] Decision context Q&A (4 questions)
- [x] YAML frontmatter generation
- [x] Decision files saved to `products/[product]/areas/[area]/decisions/`
- [x] Git auto-commit and push working
- [x] Product/area detection working

**What Phase 2 Delivered:**
```
team-product-memory/
└── products/
    └── [product]/
        └── areas/
            └── [area]/
                ├── decisions/
                │   ├── 2025-01-06-build-ai-feature.md
                │   ├── 2025-01-07-delay-mobile-app.md
                │   └── 2025-01-10-hire-ml-engineer.md  ← Phase 3 will search these
                └── sessions/
                    └── 2025-01-06-planning.md
```

---

## Goal

Enhance `/strategy-session` to automatically surface relevant past decisions from team memory before starting new sessions.

**What it does:**
- Before session starts: `git pull` to sync team decisions
- Analyzes session topic/context from user's opening question
- Searches team decision history for relevant past decisions
- Surfaces top 3 most relevant decisions with attribution
- Shows outcomes if tracked (Phase 4 will add outcome tracking)
- Enables cross-PM learning and pattern recognition
- Prevents "we tried this before" mistakes

**Why it matters:**
- New PMs inherit institutional knowledge on Day 1
- Teams don't repeat past mistakes
- Cross-PM learning (Platform learns from Product, etc.)
- Decisions compound over time
- Pattern recognition ("prototypes work better than interviews for us")
- Faster onboarding

---

## Success Criteria

✅ **Functional:**
1. PM starts `/strategy-session` with a topic
2. Claude syncs with team repo (`git pull`)
3. Searches decision history for relevant past decisions
4. Surfaces top 3 most relevant with attribution (PM name, date, outcome)
5. PM sees context before making new decisions
6. If no relevant decisions found, session continues normally
7. Memory surfacing happens within 10 seconds (fast search)

✅ **Validation:**
1. Search finds decisions with keyword overlap (MVP algorithm)
2. Ranking prioritizes recent + high keyword overlap
3. Attribution shows correct PM name and date
4. Cross-area surfacing works (Platform sees Product decisions)
5. Empty state handled gracefully (no decisions yet)
6. Search doesn't block if git pull fails

✅ **User Experience:**
- Memory surfacing takes < 10 seconds
- Relevant decisions shown in readable format
- PM can skip if not interested ("Start session anyway")
- Clear attribution (who, when, what outcome)
- Doesn't overwhelm (max 3 decisions shown)

---

## Documentation References

**Read these first:**
1. `planning.md` - Phase 3 Vision (lines 1206-1263)
2. `coding-prompt.md` - Phase 2 Implementation (lines 574-1713)
3. Existing patterns:
   - `commands/strategy-session.md` - Session flow
   - `commands/memory-init.md` - Git operations
   - Phase 2 decision detection logic

**Key decisions from planning:**
- Search algorithm: Keyword matching (MVP - no semantic search yet)
- Ranking: Recent decisions + keyword overlap score
- Scope: Cross-area search (all areas in product, or all products)
- Display: Top 3 decisions with attribution
- Timing: Before session starts (not during)

---

## Integration Points

### 1. Modify Existing File
**Path:** `commands/strategy-session.md`

**Current Phase 2 flow:**
```
0. Product Memory Setup (detect product/area, git pull)
1. Context Gathering (Explore agent)
2. Opening (set expectations)
3. Exploration (conversational Q&A)
4. Capture & Structure (summary)
5. Decision Capture (4 questions per decision)
6. Linear Output (optional)
7. Session Persistence (optional)
```

**New Phase 3 additions:**
```
0. Product Memory Setup (detect product/area, git pull)
   ↓
   + NEW: Search team decision history
   + NEW: Surface top 3 relevant decisions
   + NEW: Show attribution and outcomes
1. Context Gathering (Explore agent)
2. Opening (set expectations)
   ↓
   + UPDATED: Reference surfaced decisions in opening
3. Exploration (conversational Q&A)
4. Capture & Structure (summary)
5. Decision Capture (4 questions per decision)
6. Linear Output (optional)
7. Session Persistence (optional)
```

**What to preserve:**
- All Phase 2 functionality (decision capture)
- Conversational style
- Product/area detection
- Git sync workflow

**What to add:**
- Decision search algorithm (keyword-based)
- Relevance ranking logic
- Decision surfacing display
- Cross-area search capability

---

### 2. No New Dependencies Required

**Already available:**
- ✅ Git CLI (for `git pull` sync)
- ✅ Bash tool (for search commands)
- ✅ Read tool (for reading decision files)
- ✅ Grep tool (for keyword search)
- ✅ Date parsing (for recency scoring)

**No installation needed** - all tools ready to use.

---

## Task List

### Task 1: Enhance Product Memory Setup (Before Session)

**Location:** `commands/strategy-session.md` - "Product Memory Setup" section

**Update existing section from Phase 2:**

```markdown
## Product Memory Setup (Before Session)

### 1. Check for team-product-memory repository
[Existing Phase 2 logic - keep as-is]

### 2. Detect current product and area
[Existing Phase 2 logic - keep as-is]

### 3. Pull latest team decisions
[Existing Phase 2 logic - keep as-is]

### 4. NEW: Search team decision history for relevant past decisions

**Extract topic/context from user's opening question:**

User question: "/strategy-session Should we build AI feature for email?"

Extract keywords:
- "AI feature"
- "email"
- Core concepts: ["AI", "feature", "email", "build"]

**Search strategy (MVP - keyword matching):**

```bash
cd ../team-product-memory

# Search all decision files for keyword matches
# Start with current area, then expand to other areas in product
grep -rl "AI\|feature\|email" products/{product}/areas/{area}/decisions/*.md

# If less than 3 results, expand to all areas in product
grep -rl "AI\|feature\|email" products/{product}/areas/*/decisions/*.md

# If still less than 3, expand to all products (cross-product learning)
grep -rl "AI\|feature\|email" products/*/areas/*/decisions/*.md
```

**Keyword extraction logic:**

From user's question:
1. Remove stop words (the, is, we, should, for, etc.)
2. Extract nouns and verbs
3. Include domain terms (AI, email, mobile, API, etc.)
4. Max 10 keywords

Examples:
- "Should we build real-time collaboration?" → ["build", "real-time", "collaboration"]
- "AI adoption is low" → ["AI", "adoption", "low"]
- "Delay mobile app?" → ["delay", "mobile", "app"]

**Rank by relevance:**

For each decision file found:
1. Count keyword matches (more = higher score)
2. Check recency (more recent = higher score)
3. Check same area (same area = bonus points)
4. Combine scores: `(keyword_matches * 10) + (recency_days_ago * -0.1) + (same_area_bonus * 5)`

**Select top 3 decisions:**

Sort by score (highest first), take top 3.

**If no decisions found:**
- Skip surfacing
- Continue to normal session flow
- Note: "No relevant past decisions found (this might be a new area for your team)"

**If decisions found:**
- Proceed to Task 2 (Surface decisions)

### 5. Continue with normal session flow
[Existing Phase 2 logic - continue to Context Gathering]
```

---

### Task 2: Surface Relevant Decisions (Before Opening)

**Location:** `commands/strategy-session.md` - New section after "Product Memory Setup", before "Opening"

**Add new section:**

```markdown
### 0.5 Memory Surfacing (If Relevant Decisions Found)

**Display top 3 relevant decisions:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RELEVANT HISTORY (from team memory)

I found {number} past decision(s) that might inform this session:

📌 1. {Decision Summary}
   Who: {PM Name} ({PM Email})
   When: {Date} ({X days/weeks/months ago})
   Product Area: {product}/{area}
   Outcome: {Pending / Success / Failed / TBD}

   Key context:
   • Assumptions: {First assumption from decision file}
   • Trade-off: {Trade-off from decision file}
   • Result: {Success criteria met? or still pending}

   [View full decision: products/{product}/areas/{area}/decisions/{filename}]

📌 2. {Decision Summary}
   ...

📌 3. {Decision Summary}
   ...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Would you like to:
1. Review these decisions in detail (I'll summarize key learnings)
2. Start the session (I'll keep these in mind as context)
3. Ignore and start fresh

```

**Extract decision details from YAML frontmatter:**

```bash
# For each decision file in top 3:
# Read YAML frontmatter
head -20 products/{product}/areas/{area}/decisions/{file}.md

# Extract fields:
decision_id: ...
pm_name: ...
pm_email: ...
date: ...
decision: ...
status: pending / success / failed
timeline: ...
follow_up_date: ...

# Extract from markdown body:
## Assumptions
{first bullet point}

## Trade-offs
{summary}

## Success Criteria
{what success looks like}
```

**Handle PM selection:**

**If PM chooses 1 (Review details):**
- For each decision, show full markdown content
- Highlight: What was decided, why, what happened
- Then ask: "Ready to start the session with this context?"

**If PM chooses 2 (Start session):**
- Store decisions as session context
- Reference them during exploration if relevant
- Continue to normal session flow

**If PM chooses 3 (Ignore):**
- Skip surfacing
- Continue to normal session flow
- Don't reference in exploration

### 6. Continue to Opening and Exploration

After memory surfacing, continue with existing session flow:
- Context Gathering (Explore agent)
- Opening (set expectations)
- Exploration (conversational Q&A)
- etc.
```

---

### Task 3: Update Session Opening to Reference Surfaced Decisions

**Location:** `commands/strategy-session.md` - "Opening" section

**Enhance opening to acknowledge surfaced decisions:**

```markdown
## Opening

**If decisions were surfaced:**

```
I see you're exploring: {topic}

Based on your team's past decisions, I noticed:
• {Pattern from surfaced decisions - e.g., "Your team has tried AI features before"}
• {Key learning - e.g., "Domain-specific AI performed better than generic"}

I'll keep these in mind as we explore today.

{Rest of normal opening...}
```

**If no decisions surfaced:**

{Use normal Phase 2 opening - no changes}
```

---

### Task 4: Implement Cross-Area Learning Logic

**Feature: Surface decisions from other product areas**

**Use case:**
- Platform PM (Jordan) benefits from Product PM (Sara) decisions
- Same product, different area
- Cross-pollination of learnings

**Implementation:**

```markdown
## Cross-Area Search (Expansion Logic)

**Search priority:**
1. Same area (e.g., `products/intersight/areas/monitoring/`)
2. Other areas in same product (e.g., `products/intersight/areas/foundation/`)
3. All products (e.g., `products/customer-os/areas/platform/`)

**Scoring adjustments:**
- Same area: +5 bonus points
- Same product, different area: +2 bonus points
- Different product: +0 bonus points

**Display cross-area decisions differently:**

```
📌 Decision from different team (but related):
   Who: Sara Chen (Product PM)
   Product Area: intersight/foundation  ← Note: Different area
   Pattern: Domain-specific AI > Generic AI

   This was a different team, but the learning might apply to your decision.
```

**Benefits:**
- New PMs see decisions from across the organization
- Teams don't repeat mistakes in silos
- Pattern recognition across product areas
```

---

### Task 5: Add Decision Outcome Display (Phase 4 Preview)

**Phase 4 will add outcome tracking, but Phase 3 can show status:**

```markdown
## Outcome Status Display

**Read from decision YAML:**

```yaml
status: "pending" | "success" | "failed" | "cancelled"
```

**Display logic:**

**If status = "pending":**
```
Outcome: Still pending (follow-up: {follow_up_date})
```

**If status = "success":**
```
✅ Outcome: Success
   {Success criteria from decision file}
```

**If status = "failed":**
```
❌ Outcome: Did not work
   {What went wrong - from outcome notes}
```

**If status = "cancelled":**
```
⏸️ Outcome: Decision was reversed/cancelled
   {Why - from notes}
```

**For MVP (Phase 3):**
- All decisions will have status = "pending"
- Phase 4 will add follow-up prompts to track outcomes
- But structure is ready
```

---

### Task 6: Implement Search Performance Optimization

**Goal: Search completes in < 10 seconds**

**Optimization strategies:**

```bash
# 1. Limit search scope
# Don't search all files - use grep efficiently
cd ../team-product-memory

# Search only decision files (not sessions, not configs)
find products -name "*.md" -path "*/decisions/*" | xargs grep -l "keyword1\|keyword2"

# 2. Limit results
# Only read top 10 files (we'll rank and pick top 3)
find products -name "*.md" -path "*/decisions/*" | xargs grep -l "keyword1\|keyword2" | head -10

# 3. Cache git pull
# Only pull if last pull was > 5 minutes ago
LAST_PULL=$(stat -f %m .git/FETCH_HEAD 2>/dev/null || echo 0)
NOW=$(date +%s)
if (( NOW - LAST_PULL > 300 )); then
  git pull origin main 2>/dev/null || true
fi

# 4. Parallel processing
# Search multiple areas in parallel (if needed)
# For MVP: Sequential is fine (<100 decision files expected)
```

**Performance targets:**
- Git pull: < 2 seconds
- Search: < 3 seconds
- Ranking: < 1 second
- Display: < 1 second
- **Total: < 7 seconds** (within 10 second goal)

---

### Task 7: Add Empty State Handling

**Scenarios:**

**1. No decisions exist yet (new team):**
```
No team decisions found yet.

This is your first strategy session - I'll help you capture your first decision!

{Continue to normal session}
```

**2. No relevant decisions found (topic is new):**
```
No past decisions found related to "{topic}".

This might be a new area for your team. I'll help you explore it fresh.

{Continue to normal session}
```

**3. Git pull fails (offline/no remote):**
```
⚠️ Could not sync with team repo (working offline).

I'll search your local decision history.

{Continue with local search}
```

**4. Search takes too long (>10 seconds):**
```
⏳ Search is taking longer than expected...

Starting the session now. I'll reference past decisions if they become relevant.

{Skip surfacing, continue to session}
```

---

## Validation Strategy

### Manual Testing (During Development)

**Test 1: Happy Path - Relevant Decisions Found**

```bash
# Setup: Create 3 past decisions
cd team-product-memory/products/test-product/areas/test-area/decisions/

# Decision 1: AI feature
cat > 2025-01-01-build-ai-email.md <<EOF
---
decision_id: "2025-01-01-build-ai-email"
product_id: "test-product"
product_area: "test-area"
date: 2025-01-01
pm_email: "sara@company.com"
pm_name: "Sara Chen"
decision: "Build AI email assistant with domain templates"
status: "success"
---
# Decision: Build AI email assistant
[content...]
EOF

# Decision 2: Mobile app
cat > 2025-01-05-delay-mobile.md <<EOF
---
decision_id: "2025-01-05-delay-mobile"
product_id: "test-product"
product_area: "test-area"
date: 2025-01-05
pm_email: "alex@company.com"
pm_name: "Alex Kim"
decision: "Delay mobile app for 2 months"
status: "pending"
---
# Decision: Delay mobile app
[content...]
EOF

# Decision 3: Unrelated
cat > 2025-01-03-hire-engineer.md <<EOF
---
decision_id: "2025-01-03-hire-engineer"
product_id: "test-product"
product_area: "test-area"
date: 2025-01-03
pm_name: "Jordan Lee"
decision: "Hire ML engineer"
status: "pending"
---
# Decision: Hire ML engineer
[content...]
EOF

# Run strategy session
/strategy-session "Should we add AI features to mobile app?"

# Expected:
- Git pull succeeds
- Search finds 2 relevant decisions (AI email, mobile app)
- Surfaces top 2 with attribution
- Shows Sara (AI) and Alex (mobile)
- PM can review or start session
- Opening references past decisions
```

**Validate:**
```bash
# Check that search found correct decisions
# Verify ranking (AI email should rank higher - 2 keyword matches)
# Verify attribution (Sara, Alex names shown)
# Verify dates shown correctly
```

---

**Test 2: Cross-Area Learning**

```bash
# Setup: PM from different area searching
cd team-product-memory

# Create decision in area A
mkdir -p products/intersight/areas/monitoring/decisions
cat > products/intersight/areas/monitoring/decisions/2025-01-01-ai-adoption.md <<EOF
---
product_id: "intersight"
product_area: "monitoring"
pm_name: "Sara Chen"
decision: "Domain-specific AI increased adoption by 73%"
status: "success"
---
EOF

# PM from area B starts session
/memory-init
  Product: intersight
  Area: foundation

/strategy-session "Should we add AI to our API docs?"

# Expected:
- Search finds Sara's decision from monitoring area
- Surfacing shows: "Decision from different team (but related)"
- Notes: "intersight/monitoring (different area)"
- PM sees cross-team learning
```

---

**Test 3: No Relevant Decisions**

```bash
# Setup: Decisions exist, but unrelated
# Existing decisions about "mobile app"

/strategy-session "Should we support GraphQL?"

# Expected:
- Search runs
- No relevant decisions found (GraphQL != mobile)
- Message: "No past decisions found related to GraphQL"
- Continue to normal session
- No surfacing block shown
```

---

**Test 4: Empty State (No Decisions Yet)**

```bash
# Setup: Fresh repo, no decision files
rm -rf team-product-memory/products/*/areas/*/decisions/*.md

/strategy-session "First planning session"

# Expected:
- Search runs
- No decisions exist yet
- Message: "No team decisions found yet. This is your first session!"
- Continue to normal session
- Decision capture works at end (Phase 2)
```

---

**Test 5: Git Pull Fails (Offline)**

```bash
# Setup: No remote configured
cd team-product-memory
git remote remove origin

/strategy-session "Planning session"

# Expected:
- Git pull fails gracefully
- Warning: "Could not sync (working offline)"
- Search continues with local decisions
- Surfacing works with local data
```

---

**Test 6: Search Performance**

```bash
# Setup: Create 50 decision files
for i in {1..50}; do
  cat > products/test/areas/test/decisions/2025-01-$i-decision.md <<EOF
---
decision: "Test decision $i with AI feature keyword"
---
EOF
done

# Run session with timer
time /strategy-session "AI feature planning"

# Expected:
- Search completes in < 10 seconds
- Top 3 decisions surfaced
- Performance acceptable
```

---

**Test 7: Relevance Ranking Accuracy**

```bash
# Setup: Create decisions with varying relevance
# Decision A: 5 keyword matches
# Decision B: 2 keyword matches
# Decision C: 1 keyword match

/strategy-session "Build AI email feature with mobile support"

# Expected:
- Decision A ranks first (most keyword overlap)
- Decision B ranks second
- Decision C ranks third (or not shown if <3 total)
- Ranking order makes sense
```

---

### Automated Validation (Built into Command)

```markdown
## Internal Validation (after search)

Run these checks after decision search:

```bash
# 1. Search completed within time limit
search_start=$(date +%s)
{run search}
search_end=$(date +%s)
search_duration=$((search_end - search_start))

if (( search_duration > 10 )); then
  echo "⚠️ Search took ${search_duration}s (expected <10s)"
fi

# 2. Decision files are valid YAML
for decision_file in {top_3_results}; do
  head -20 "$decision_file" | grep -q "^decision:" || echo "ERROR: Invalid YAML in $decision_file"
done

# 3. Required fields present
for decision_file in {top_3_results}; do
  grep -q "^pm_name:" "$decision_file" || echo "WARN: Missing pm_name in $decision_file"
  grep -q "^date:" "$decision_file" || echo "WARN: Missing date in $decision_file"
done

# 4. Ranking scores are sensible
# Top result should have higher score than 2nd, etc.
# Log scores for debugging if needed
```

If any validation fails:
- Log warning (don't block session)
- Skip problematic decisions
- Continue with valid ones
```

---

## Edge Cases to Handle

### 1. Decision Files with Missing Fields

**Scenario:** Old decision file missing `pm_name` or `status`

**Detection:**
```bash
grep -q "^pm_name:" decision_file.md
```

**If missing:**
```
Display as:
Who: Unknown PM (file: {decision_id})
```

**Or extract from filename/git:**
```bash
# Try to get PM from git blame
git log -1 --format="%an (%ae)" decision_file.md
```

---

### 2. Decisions from Deactivated Team Members

**Scenario:** PM left the company, but decisions remain

**Handling:**
```
Display as:
Who: Sara Chen (former PM, left Jan 2025)
Note: This decision is still relevant even though Sara is no longer on the team.
```

**Detection:**
```yaml
# In area config.yml
team_members:
  - email: "sara@company.com"
    name: "Sara Chen"
    active: false  ← Deactivated
```

---

### 3. Duplicate Decisions (Same Topic, Different PMs)

**Scenario:** Two PMs made similar decisions independently

**Handling:**
```
📌 1. Build AI feature (Sara, Jan 1)
📌 2. Build AI assistant (Alex, Jan 5)  ← Similar

Note: Your team has explored this topic multiple times. Consider why.
```

**Detection:**
- Similar decision summaries (keyword overlap > 80%)
- Flag as potential duplicate
- Show both, but note similarity

---

### 4. Very Old Decisions (>6 months)

**Scenario:** Decision is old, might be outdated

**Handling:**
```
📌 Decision from 8 months ago
   {decision summary}

   ⚠️ This decision is quite old - context may have changed.
   Use as reference, not gospel.
```

**Detection:**
```bash
decision_date="2024-05-01"
today=$(date +%Y-%m-%d)
age_days=$(( ($(date -d "$today" +%s) - $(date -d "$decision_date" +%s)) / 86400 ))

if (( age_days > 180 )); then
  echo "OLD_DECISION"
fi
```

---

### 5. Search Returns Too Many Results (>10)

**Scenario:** Broad topic, 50+ matching decisions

**Handling:**
```
I found 50+ past decisions related to "{topic}".

Showing top 3 most relevant:
{top 3}

Want to see more? Run: /decision-search "{topic}" --limit 10
```

**Implementation:**
- Limit surfacing to top 3 (always)
- Optionally suggest manual search for more

---

### 6. Session Topic is Too Vague

**Scenario:** PM says "/strategy-session planning"

**Handling:**
```
I couldn't extract specific keywords from "planning".

Starting the session fresh. As we explore, I'll reference relevant past decisions if they come up.

{Continue to normal session}
```

**Detection:**
- After removing stop words, < 2 keywords remain
- Keywords are too generic ("planning", "session", "meeting")
- Skip search, continue to session

---

## Implementation Notes

### Keep It Simple (MVP)

**Don't implement yet:**
- [ ] Semantic search (vector embeddings - Post-MVP)
- [ ] Decision graph visualization (Phase 6)
- [ ] Pattern recognition ("you always delay mobile") (Phase 6)
- [ ] Auto-tagging decisions (Post-MVP)
- [ ] Outcome prediction (Post-MVP)

**Do implement:**
- [x] Keyword-based search (grep)
- [x] Simple relevance ranking (keyword count + recency)
- [x] Top 3 decision surfacing
- [x] Cross-area learning
- [x] Attribution display
- [x] Empty state handling

---

### Search Algorithm Details

**Keyword extraction:**
```python
# Pseudocode for keyword extraction
def extract_keywords(question):
    stop_words = ["the", "is", "we", "should", "for", "a", "an", "to", "in", "on", "at"]
    words = question.lower().split()
    keywords = [w for w in words if w not in stop_words and len(w) > 2]
    return keywords[:10]  # Max 10 keywords

# Example:
# "Should we build AI feature for email?"
# → ["build", "ai", "feature", "email"]
```

**Relevance scoring:**
```python
# Pseudocode for ranking
def calculate_relevance_score(decision, keywords, current_area):
    score = 0

    # Keyword matches (10 points each)
    for keyword in keywords:
        if keyword in decision.content.lower():
            score += 10

    # Recency bonus (newer = higher)
    days_ago = (today - decision.date).days
    recency_score = max(0, 100 - days_ago)  # 100 for today, 0 for 100+ days ago
    score += recency_score * 0.1

    # Same area bonus
    if decision.product_area == current_area:
        score += 5

    return score
```

**Example ranking:**

Decision A: "Build AI email assistant" (10 days ago, same area)
- Keywords: ["AI", "email", "build"] → 3 matches × 10 = 30
- Recency: (100 - 10) × 0.1 = 9
- Same area: 5
- **Total: 44**

Decision B: "Delay mobile app" (5 days ago, different area)
- Keywords: ["mobile"] → 1 match × 10 = 10
- Recency: (100 - 5) × 0.1 = 9.5
- Same area: 0
- **Total: 19.5**

Decision A ranks higher → shown first.

---

### Performance Considerations

**For MVP (< 100 decision files):**
- Simple grep search is sufficient
- No indexing needed
- Sequential search acceptable
- Performance target: < 10 seconds

**Post-MVP (> 1000 decision files):**
- Consider adding search index
- Use ripgrep (rg) instead of grep
- Cache search results
- Parallel processing

**For now: Keep it simple.**

---

## Success Metrics

After implementation, PM should be able to:

1. ✅ Start `/strategy-session` and see relevant past decisions automatically
2. ✅ See top 3 decisions with attribution (who, when, outcome)
3. ✅ Learn from other PMs' decisions (cross-area learning)
4. ✅ See "we tried this before" intelligence
5. ✅ Handle empty state gracefully (no decisions yet)
6. ✅ Get search results in < 10 seconds
7. ✅ Review full decision details if interested
8. ✅ Continue to session with context in mind

**Definition of Done:**
- [ ] Memory surfacing logic added to `/strategy-session`
- [ ] Keyword extraction working (removes stop words, max 10 keywords)
- [ ] Search algorithm implemented (grep-based)
- [ ] Relevance ranking working (keyword + recency + area)
- [ ] Top 3 decision display with attribution
- [ ] Cross-area learning functional (different areas shown)
- [ ] Outcome status displayed (pending/success/failed)
- [ ] Empty states handled (no decisions, no relevant, git fail)
- [ ] Search performance < 10 seconds
- [ ] Manual tests pass (all 7 scenarios)
- [ ] Edge cases handled (6 cases documented)
- [ ] Session opening references surfaced decisions

---

## Next Phase Preview

**After Phase 3 complete, next is Phase 4: Outcome Tracking**

**What Phase 4 will do:**
- Add follow-up prompts for decision outcomes
- When `follow_up_date` arrives, prompt PM: "How did X decision work out?"
- Update decision status: `pending` → `success` / `failed`
- Capture outcome learnings
- Enable pattern recognition ("features with prototypes succeed 85% of the time")

**Dependencies:**
- Phase 3 must be complete (surfacing must work)
- Need date-based trigger system
- Need outcome update workflow

**New capabilities unlocked:**
- "What works for YOUR team" intelligence
- Learn from outcomes, not just decisions
- Pattern recognition across decisions
- Compound learning over time

---

## Example User Flow

**PM starts new session:**

```
PM: /strategy-session "Should we add real-time collaboration?"

Claude: {Syncing with team memory...}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RELEVANT HISTORY (from team memory)

I found 2 past decision(s) that might inform this session:

📌 1. Real-time features require WebSocket infrastructure
   Who: Sara Chen (Product PM)
   When: Dec 15, 2024 (6 weeks ago)
   Product Area: customer-os/platform
   Outcome: ✅ Success - 40% adoption in 2 weeks

   Key context:
   • Assumption: Users want live updates
   • Trade-off: Delayed mobile app work for 1 month
   • Result: Adoption exceeded 30% goal

   [View full decision: products/customer-os/areas/platform/decisions/2024-12-15-real-time-websocket.md]

📌 2. Collaboration features have low adoption without onboarding
   Who: Alex Kim (Foundation PM)
   When: Nov 20, 2024 (10 weeks ago)
   Product Area: intersight/foundation  ← Different area
   Outcome: ❌ Failed - only 12% adoption

   Key context:
   • Assumption: Feature discoverability would be enough
   • Trade-off: Shipped without in-app tutorial
   • Result: Users didn't find the feature

   Note: This was a different team, but the learning might apply.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Would you like to:
1. Review these decisions in detail (I'll summarize key learnings)
2. Start the session (I'll keep these in mind as context)
3. Ignore and start fresh

PM: 2

Claude: Got it. I see you're exploring real-time collaboration.

Based on your team's past decisions, I noticed:
• Real-time features can achieve high adoption (Sara's 40%)
• But require good onboarding (Alex's warning about 12% without it)

I'll keep these patterns in mind as we explore today.

Let's start by understanding the current state...

{Normal strategy session continues}
```

---

*Phase 3 implementation guide complete. When Phase 3 is validated, update this file with Phase 4 implementation guide.*
