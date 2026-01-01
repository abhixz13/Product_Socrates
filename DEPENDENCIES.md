# Product Memory MVP - Technical Dependencies

**Last Updated:** January 6, 2025

---

## Overview

This document outlines all technical dependencies and gaps for implementing the Product Memory MVP as defined in `planning.md`.

---

## Current State Analysis

### ✅ What Already Exists

**1. Command Infrastructure**
- ✅ Claude Code plugin system (`plugin.json`)
- ✅ Command pattern (markdown files in `commands/`)
- ✅ 18 existing slash commands
- ✅ Installation script (`install.sh`)

**2. Session Management**
- ✅ `/strategy-session` command exists
- ✅ Sessions saved to `sessions/` (gitignored)
- ✅ Session format: markdown files with date prefix
- ✅ Context gathering via Explore agent (Task tool)

**3. Reflection System**
- ✅ `/reflect` command exists
- ✅ Reads from `sessions/` directory
- ✅ Pattern recognition across sessions
- ✅ Saves to `reflections/` (gitignored)

**4. Skills System**
- ✅ 5 auto-invoked skills
- ✅ PM frameworks knowledge base
- ✅ Workspace calibration patterns

**5. Git Integration**
- ✅ Repository is git-based
- ✅ `.gitignore` configured
- ✅ Sessions/reflections gitignored by default

---

## MVP Requirements (from planning.md)

### Phase 1: Multi-Tenant Foundation
**Needed:**
- [ ] Shared git repository structure (`team-product-memory/`)
- [ ] Product configuration system (`config.yml`)
- [ ] Multi-tenant directory layout
- [ ] `/memory-init` command

**Dependencies:**
- Git operations (clone, pull, push)
- YAML parsing
- User identification (PM email/name)

---

### Phase 2: Team Decision Capture
**Needed:**
- [ ] Enhanced `/strategy-session` with decision detection
- [ ] Decision capture Q&A flow
- [ ] Multi-tenant YAML frontmatter generation
- [ ] Git auto-commit/push workflow
- [ ] Conflict handling

**Dependencies:**
- YAML frontmatter writing
- Git user config detection
- Git push/pull automation
- Merge conflict detection

---

### Phase 3: Team-Wide Memory Surfacing
**Needed:**
- [ ] Pre-session git pull
- [ ] Team-wide decision search
- [ ] Keyword extraction and matching
- [ ] Attribution display ("Sara decided X")

**Dependencies:**
- YAML frontmatter parsing
- Keyword/tag matching algorithm
- Date-based ranking
- Git pull automation

---

### Phase 4: Team Outcome Tracking
**Needed:**
- [ ] Follow-up date tracking
- [ ] Cross-PM outcome reporting
- [ ] Outcome history versioning
- [ ] Amendment tracking

**Dependencies:**
- Date comparison logic
- YAML array handling (outcome_history)
- Git commit for updates

---

### Phase 5: Weekly Decision Journal
**Needed:**
- [ ] `/weekly-reflection` command
- [ ] Same capture flow as strategy session
- [ ] Friday reminder system (optional for MVP)

**Dependencies:**
- Day-of-week detection
- Reusable decision capture module

---

### Phase 6: Web Interface (Post-Week 6)
**Needed:**
- [ ] Web form for decision CRUD
- [ ] Search/browse UI
- [ ] SSO authentication
- [ ] Git repo read/write from web

**Dependencies:**
- Web framework (Flask/FastAPI or Node/Express)
- Git operations from server
- Authentication system
- Database (optional - can read git directly)

---

## Technical Dependencies by Category

### 1. Git Operations

**Required:**
- ✅ Git CLI available (standard on macOS/Linux)
- ✅ Basic git commands (add, commit, push, pull)
- [ ] Automated git workflows (via Bash tool)
- [ ] Conflict detection and resolution

**Implementation:**
```bash
# Already available via Bash tool:
git clone <repo>
git pull origin main
git add decisions/
git commit -m "Decision: [summary]"
git push origin main
```

**Gaps:**
- [ ] Conflict handling strategy
- [ ] Retry logic for failed pushes
- [ ] User attribution (git config user.email)

---

### 2. YAML Processing

**Required:**
- [ ] YAML frontmatter parsing (read)
- [ ] YAML frontmatter generation (write)
- [ ] YAML array handling (outcome_history)

**Current State:**
- ❌ No YAML library in use
- ✅ Can generate YAML manually (string formatting)
- ✅ Can parse YAML with simple regex for MVP

**Implementation Options:**

**Option 1: Manual YAML (Simplest for MVP)**
```markdown
Generate via string templates:
---
decision_id: "${date}-${slug}"
pm_email: "${email}"
tags: [${tags.join(', ')}]
---
```

Parse via regex/grep:
```bash
grep "^pm_email:" decision.md | cut -d: -f2
```

**Option 2: Use Python/Ruby (if needed)**
```python
# Python has PyYAML
import yaml
data = yaml.safe_load(frontmatter)
```

**Recommendation:** Start with Option 1 (manual) for MVP, upgrade later if needed.

**Gaps:**
- [ ] YAML generation templates
- [ ] YAML parsing logic (can use grep/awk for MVP)

---

### 3. File System Operations

**Required:**
- ✅ Read files (Read tool)
- ✅ Write files (Write tool)
- ✅ Edit files (Edit tool)
- ✅ Search files (Glob, Grep tools)
- [ ] Create directories (mkdir via Bash)

**Current State:**
- ✅ All file operations available via tools

**Gaps:**
- [ ] Directory structure creation logic
- [ ] File naming conventions implementation

---

### 4. Date/Time Handling

**Required:**
- [ ] Current date (YYYY-MM-DD)
- [ ] Date comparison (for follow-up tracking)
- [ ] Date parsing from filenames
- [ ] Week number calculation (optional)

**Current State:**
- ✅ Can get date via `date` command (Bash tool)
- ❌ No date library in use

**Implementation:**
```bash
# Get current date
date +%Y-%m-%d  # 2025-01-06

# Get week number
date +%Y-w%V    # 2025-w01

# Date comparison (bash)
if [[ "2025-01-06" < "2025-03-01" ]]; then
  echo "Follow-up needed"
fi
```

**Gaps:**
- [ ] Date comparison logic in commands
- [ ] Follow-up date calculation

---

### 5. Search and Ranking

**Required:**
- [ ] Keyword extraction from text
- [ ] Tag matching
- [ ] Date-based ranking
- [ ] Relevance scoring

**Current State:**
- ✅ Grep tool for text search
- ✅ Glob tool for file matching
- ❌ No ranking algorithm

**Implementation (MVP - Simple):**
```markdown
1. Extract keywords from session topic (split on spaces)
2. Grep for keywords in decision files
3. Count matches per file
4. Sort by: match_count DESC, date DESC
5. Return top 3
```

**Gaps:**
- [ ] Keyword extraction logic
- [ ] Scoring algorithm
- [ ] Top-N selection

---

### 6. User Identification

**Required:**
- [ ] PM email detection
- [ ] PM name detection
- [ ] Product identification

**Current State:**
- ❌ No user config system
- ✅ Can read from git config

**Implementation:**
```bash
# Get from git config
git config user.email  # pm@company.com
git config user.name   # Sara Chen

# Or prompt user
echo "What's your email?"
read pm_email
```

**Gaps:**
- [ ] User config storage
- [ ] Product selection mechanism
- [ ] Team member management

---

### 7. Decision Detection (AI)

**Required:**
- [ ] Analyze strategy session conversation
- [ ] Identify decisions made
- [ ] Extract decision summary

**Current State:**
- ✅ Claude can analyze conversation text
- ✅ Pattern recognition capability

**Implementation:**
- Use Claude's conversation analysis
- Prompt engineering to detect decisions
- Extract key phrases

**Gaps:**
- [ ] Decision detection prompt template
- [ ] Validation (ask user to confirm)

---

## Dependency Matrix

| Feature | Git | YAML | Files | Date | Search | User | AI |
|---------|-----|------|-------|------|--------|------|-----|
| Multi-Tenant Foundation | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ |
| Decision Capture | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| Memory Surfacing | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ |
| Outcome Tracking | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ |
| Weekly Journal | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ |
| Web Interface | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ | ❌ |

**Legend:**
- ✅ Required
- ❌ Not required

---

## Implementation Dependencies (Detailed)

### Phase 1: Multi-Tenant Foundation

**What's needed:**
1. ✅ Git CLI (already available)
2. ✅ Bash tool (already available)
3. ✅ Write tool (already available)
4. [ ] `/memory-init` command file
5. [ ] Product config template (`config.yml`)
6. [ ] Team repo structure template

**Dependencies:**
```
Claude Code Plugin System
  └─ Bash tool
      └─ git clone/init
      └─ mkdir -p
  └─ Write tool
      └─ Create config.yml
  └─ User input
      └─ Product name
      └─ Team members
```

**No external dependencies needed.**

---

### Phase 2: Team Decision Capture

**What's needed:**
1. ✅ Existing `/strategy-session` command
2. [ ] Enhanced decision detection logic
3. [ ] Decision Q&A prompts
4. [ ] YAML frontmatter generation
5. [ ] Git auto-commit workflow

**Dependencies:**
```
Enhanced /strategy-session
  └─ Bash tool
      └─ git config user.email
      └─ git add/commit/push
  └─ Write tool
      └─ Create decision file
  └─ Claude AI
      └─ Detect decisions in conversation
      └─ Extract key points
```

**No external dependencies needed.**

---

### Phase 3: Team-Wide Memory Surfacing

**What's needed:**
1. [ ] Pre-session git pull
2. [ ] Decision file search
3. [ ] Keyword extraction
4. [ ] Ranking algorithm

**Dependencies:**
```
Memory Surfacing
  └─ Bash tool
      └─ git pull
  └─ Grep tool
      └─ Search decision files
  └─ Read tool
      └─ Parse YAML frontmatter
  └─ Sorting logic
      └─ Rank by relevance
```

**No external dependencies needed.**

---

### Phase 4: Team Outcome Tracking

**What's needed:**
1. [ ] Date comparison logic
2. [ ] Follow-up prompts
3. [ ] Outcome history array handling
4. [ ] File editing for updates

**Dependencies:**
```
Outcome Tracking
  └─ Bash tool
      └─ date command
      └─ git commit/push
  └─ Edit tool
      └─ Update decision files
  └─ Read tool
      └─ Find decisions needing follow-up
```

**No external dependencies needed.**

---

### Phase 5: Weekly Decision Journal

**What's needed:**
1. [ ] `/weekly-reflection` command
2. [ ] Reuse decision capture logic
3. [ ] Day-of-week detection (optional)

**Dependencies:**
```
/weekly-reflection
  └─ Same as /strategy-session
  └─ Bash tool
      └─ date +%u (day of week)
```

**No external dependencies needed.**

---

### Phase 6: Web Interface (Week 7+)

**What's needed:**
1. [ ] Web framework (Flask/FastAPI or Node/Express)
2. [ ] Git operations from server
3. [ ] SSO/Authentication
4. [ ] HTML forms + UI

**Dependencies:**
```
Web Interface
  └─ Python Flask/FastAPI OR Node Express
  └─ Git CLI (server-side)
  └─ Authentication library
      └─ OAuth/SAML for SSO
  └─ Static hosting
      └─ Can use GitHub Pages + API
```

**External dependencies:**
- Web framework (TBD)
- Auth provider (TBD)
- Hosting (TBD)

**For MVP Week 7:** Keep it simple - basic HTML forms, no fancy frameworks.

---

## Critical Gaps to Address

### 1. Decision Detection Algorithm (HIGH PRIORITY)

**Problem:** Need to detect decisions in strategy session conversations.

**Solution:**
```markdown
Add to /strategy-session command:

After exploration phase, before summary:

"Let me identify the decisions you made today:

[Analyze conversation for:]
- Statements like "I'm going to...", "We should...", "Let's..."
- Commitments to action
- Trade-off resolutions
- Feature prioritization choices

Present to user:
1. [Decision 1]
2. [Decision 2]
3. [Decision 3]

Are these the key decisions? (y/n/add more)
```

**Implementation:** Prompt engineering in `/strategy-session.md`

---

### 2. YAML Frontmatter Generation (MEDIUM PRIORITY)

**Problem:** Need to generate structured YAML for decision files.

**Solution:**
```markdown
Template:
---
decision_id: "${date}-${slug}"
product_id: "${product}"
pm_email: "${email}"
pm_name: "${name}"
decision: "${summary}"
status: "pending"
timeline: "${timeline}"
follow_up_date: "${follow_up_date}"
tags: [${tags}]
---

Generate using string replacement.
```

**Implementation:** String template in command logic

---

### 3. Git Workflow Automation (HIGH PRIORITY)

**Problem:** Need to automate git operations without user intervention.

**Solution:**
```bash
# After decision captured:
cd team-product-memory
git pull origin main
git add products/${product}/decisions/${decision_file}
git commit -m "Decision: ${decision_summary}

Added by: ${pm_name}
Product: ${product}"
git push origin main

# Handle conflicts:
if git push fails:
  - git pull --rebase
  - retry push
  - if still fails: warn user
```

**Implementation:** Bash commands in `/strategy-session.md`

---

### 4. Search/Ranking Algorithm (MEDIUM PRIORITY)

**Problem:** Need to rank decision relevance for memory surfacing.

**Solution (MVP - Simple):**
```bash
# 1. Extract keywords from session topic
keywords=$(echo "$topic" | tr ' ' '\n')

# 2. Search decision files
for keyword in $keywords; do
  grep -l "$keyword" products/$product/decisions/*.md
done | sort | uniq -c | sort -rn

# 3. Return top 3
head -3
```

**Implementation:** Bash script in command

---

### 5. User Configuration Storage (MEDIUM PRIORITY)

**Problem:** Need to persist user/product config.

**Solution (MVP):**
```yaml
# Store in: team-product-memory/products/${product}/config.yml
product_id: "customer-os"
product_name: "CustomerOS"
team_members:
  - email: "sara@company.com"
    name: "Sara Chen"
    active: true
```

**Implementation:** Write once during `/memory-init`, read thereafter

---

### 6. Date Comparison Logic (LOW PRIORITY)

**Problem:** Need to check if follow-up date has passed.

**Solution:**
```bash
# Get today
today=$(date +%Y-%m-%d)

# Compare dates (bash string comparison works for ISO dates)
if [[ "$today" > "$follow_up_date" ]]; then
  echo "Follow-up needed"
fi
```

**Implementation:** Bash logic in `/strategy-session.md`

---

## External Dependencies Summary

### ✅ Already Available (No Installation Needed)

1. **Claude Code CLI** - Required, already installed
2. **Git** - Standard on macOS/Linux
3. **Bash** - Standard shell
4. **Unix tools** - grep, awk, sed, date, etc.

### ❌ NOT Required for MVP

1. **No databases** - Using git repo + markdown files
2. **No web frameworks** - CLI-first for Weeks 1-6
3. **No YAML libraries** - Manual generation/parsing for MVP
4. **No external APIs** - Self-contained
5. **No cloud services** - Shared git repo is the only "cloud" component

### 🔮 Future (Post-MVP)

1. **Web Framework** - Week 7+ (Flask/FastAPI or Express)
2. **Database** - Optional (SQLite for fast search)
3. **MCP Server** - Long-term (multi-tenant SaaS)

---

## Implementation Checklist

### Before Starting Development

- [ ] Clone/create shared git repo (`team-product-memory`)
- [ ] Test git operations (clone, pull, push)
- [ ] Create example product structure
- [ ] Test YAML generation (manual templates)
- [ ] Test decision file parsing (grep/awk)

### Phase 1 Prerequisites

- [ ] Git repo accessible to all PMs
- [ ] PM emails identified (git config)
- [ ] Product name decided

### Phase 2 Prerequisites

- [ ] Phase 1 complete
- [ ] Decision detection prompt tested
- [ ] Git auto-commit tested

### Phase 3 Prerequisites

- [ ] Phase 2 complete
- [ ] Sample decisions in repo
- [ ] Search algorithm tested

### Phase 4 Prerequisites

- [ ] Phase 3 complete
- [ ] Date comparison logic tested

### Phase 5 Prerequisites

- [ ] Phase 4 complete
- [ ] Decision capture reusable

### Phase 6 Prerequisites

- [ ] Phase 5 complete
- [ ] Web framework chosen
- [ ] Auth strategy decided

---

## Risk Assessment

### LOW RISK (Can implement with existing tools)

✅ Multi-tenant foundation
✅ Decision capture
✅ Git automation
✅ YAML generation (manual)
✅ File operations

### MEDIUM RISK (Needs testing/iteration)

⚠️ Decision detection (AI prompt quality)
⚠️ Search relevance (ranking algorithm)
⚠️ Conflict handling (git merge conflicts)
⚠️ User adoption (team workflow change)

### HIGH RISK (Requires external dependencies)

🔴 Web interface (new stack, hosting)
🔴 SSO/Authentication (security critical)
🔴 Multi-product scaling (data modeling)

---

## Recommendation: Minimal Dependencies Approach

**For MVP (Weeks 1-6):**

✅ **Use only built-in tools:**
- Claude Code CLI
- Git
- Bash
- Grep/Awk
- File operations (Read/Write/Edit tools)

✅ **Avoid external dependencies:**
- No web frameworks
- No databases
- No YAML libraries
- No cloud services (except git hosting)

✅ **Keep it simple:**
- Markdown files
- Manual YAML
- Bash scripts
- String templates

**Result:** Zero external dependencies for MVP. Can ship Week 1 with just Claude Code + Git.

---

## Next Steps

1. **Create `/memory-init` command** (Week 1)
2. **Test git workflows** (Week 1)
3. **Enhance `/strategy-session`** (Week 2)
4. **Build search logic** (Week 3)
5. **Add outcome tracking** (Week 4)
6. **Create `/weekly-reflection`** (Week 5)
7. **Polish** (Week 6)
8. **Add web form** (Week 7+)

---

*Last updated: January 6, 2025*
