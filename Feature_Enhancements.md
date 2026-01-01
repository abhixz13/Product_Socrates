# Feature Enhancements - Product Memory MVP

**Last Updated:** December 31, 2025

This document tracks all feature enhancements for the Product Memory MVP implementation.

---

## Phase 1: Multi-Tenant Foundation

### Feature Name: `/memory-init` - Team Product Memory Setup

**Objective:**
Initialize a shared, team-wide decision memory repository with hierarchical product/area structure. Enables multiple PM teams working on different areas of the same product to share institutional knowledge while keeping decisions scoped to their area.

**Files Added:**
- `.claude/commands/memory-init.md` - New command for initializing product memory

**Files Modified:**
- `.claude-plugin/plugin.json` - Added `/memory-init` to commands array

**Key Capabilities:**
- Prompts PM for product name, product area, and team member emails
- Creates or clones shared git repository (`team-product-memory/`)
- Generates hierarchical directory structure: `products/[product]/areas/[area]/`
- Creates product-level config: `products/[product]/config.yml`
- Creates area-level config: `products/[product]/areas/[area]/config.yml`
- Supports multiple areas under same product (e.g., Intersight → Monitoring, Foundation, Automation, IMM)
- Auto-detects git user info for team member attribution

**Architecture:**
```
team-product-memory/
├── products/
│   └── [product]/              # e.g., "intersight"
│       ├── config.yml          # Product-level config (lists all areas)
│       └── areas/              # Product areas
│           └── [area]/         # e.g., "monitoring"
│               ├── config.yml  # Area-level config (team members)
│               ├── decisions/  # Area-specific decisions
│               └── sessions/   # Area-specific sessions
└── README.md
```

**Edge Cases Handled:**
- Area already initialized (adds PM to team instead of recreating)
- Product exists, new area (updates product config with new area)
- No git installed (clear error message with install instructions)
- No git user config (prompts to configure before proceeding)
- Invalid product/area names (auto-converts to lowercase with hyphens)

---

## Phase 2: Team Decision Capture

### Feature Name: Enhanced `/strategy-session` with Decision Capture

**Objective:**
Automatically capture decisions made during strategy sessions to team-wide product memory repository. Enables team-wide visibility, attribution preservation, and institutional knowledge building through conversational decision documentation.

**Files Modified:**
- `.claude/commands/strategy-session.md` - Enhanced with product memory integration

**Key Modifications:**

#### 1. Product Memory Setup (Section 0.5)
**Added:** Pre-session product/area detection
- Checks for `team-product-memory` repository existence
- Auto-detects current product and area from config files
- Pulls latest team decisions before session starts
- Handles multiple product areas with PM selection
- Gracefully degrades if product memory not initialized

#### 2. Decision Detection (Section 3.5.1)
**Added:** AI-powered decision identification
- Analyzes conversation for commitments, trade-offs, and approach selections
- Detects 1-5 decisions per session (prevents overwhelming)
- Presents decisions to PM for confirmation
- Allows PM to decline capture without breaking flow

**Detection Patterns:**
- Commitments to action ("I'm going to...", "We will...")
- Trade-off resolutions ("We chose X over Y because...")
- Feature prioritization ("We're doing X first, Y later")
- Go/No-Go decisions ("We're not building X")
- Approach selections ("We'll use approach A instead of B")

#### 3. Decision Context Q&A (Section 3.5.2)
**Added:** Conversational 4-question capture flow
- Q1: What assumptions are you making?
- Q2: What's the main trade-off here?
- Q3: When will we know if this worked?
- Q4: What would success look like?

**Design Principles:**
- Natural conversation (not "Question 1 of 4")
- Brief answers accepted (2-3 sentences)
- "Skip" or "I don't know" allowed (noted as "TBD")
- Total time: ~2-3 minutes per decision

#### 4. Decision File Generation (Section 3.5.3)
**Added:** Structured markdown with YAML frontmatter

**Filename Format:** `{YYYY-MM-DD}-{slug}.md`
- Slug: First 5 words, lowercase, hyphens, max 50 chars
- Auto-increments on collision (e.g., `-2`, `-3`)

**YAML Frontmatter Schema:**
```yaml
decision_id: "{YYYY-MM-DD}-{slug}"
product_id: "{product}"
product_area: "{area}"
date: {YYYY-MM-DD}
pm_email: "{pm_email}"
pm_name: "{pm_name}"
decision: "{decision_summary}"
status: "pending"
timeline: "{timeline_from_q3}"
follow_up_date: {YYYY-MM-DD_calculated}
tags: []
```

**Markdown Body Sections:**
- Rationale (why this decision was made)
- Assumptions (from Q1, bulleted)
- Trade-offs (from Q2)
- Context (session context, product state)
- Success Criteria (from Q4)
- Timeline (from Q3, with expected completion date)
- Related Decisions (placeholder)
- Attribution footer

**Follow-up Date Calculation:**
- "2 weeks" → +14 days
- "1 month" → +30 days
- "3 months" → +90 days
- "Q2" → calculate Q2 end date
- "TBD" → +30 days (default)
- Handles both macOS and Linux date commands

#### 5. Git Auto-Commit and Push (Section 3.5.4)
**Added:** Seamless team synchronization
- Auto-adds decision files to git staging
- Creates descriptive commit message with attribution
- Auto-pushes to remote (origin main)
- Handles merge conflicts with rebase strategy
- Clear error messages for remote/conflict scenarios

**Error Handling:**
- No remote configured → Instructions for setup
- Merge conflict → Auto-retry with `pull --rebase`
- Rebase fails → Manual resolution steps with file location
- Push succeeds → Confirmation with team visibility note

**Commit Message Format:**
```
Decision: {first_decision_summary}

Added by: {pm_name} ({pm_email})
Product: {product}
Area: {area}
Decisions: {number_of_decisions}

Session date: {YYYY-MM-DD}
```

#### 6. Updated Session Summary (Section 3.5.5)
**Added:** Decision capture status in output

**With Decisions Captured:**
```
📝 TEAM DECISION MEMORY
✅ Saved {number} decision(s) to team repo
   Product: {product} / Area: {area}
   Files: products/{product}/areas/{area}/decisions/
   Team members: {count} active PMs can see these
```

**Edge Cases Handled:**
- No concrete decisions detected (graceful skip with option to create session record)
- PM declines to capture (skips without breaking flow)
- Multiple decisions in one session (processes each separately)
- No product memory initialized (backward compatible - skips all memory features)
- PM email not in area team (offers to add PM to team)
- Timeline parsing failures (default to 30 days with note)
- Long decision summaries (truncates filename, keeps full in frontmatter)
- Session without product memory context (runs normal strategy session)

**Backward Compatibility:**
- All product memory features are optional
- Sessions work perfectly without `/memory-init`
- No breaking changes to existing workflow

---

## Implementation Notes

### MVP Philosophy Maintained:
- ✅ **Simple:** Uses existing git infrastructure, no new dependencies
- ✅ **Conversational:** Natural Q&A flow, not form-filling
- ✅ **Team-first:** Multi-tenant architecture with attribution
- ✅ **Graceful:** Degrades cleanly when product memory not available
- ✅ **Git-based:** Familiar workflow, version control built-in

### Technology Stack:
- Pure markdown + YAML frontmatter (no database)
- Git for storage and team synchronization
- Bash tool for git operations
- Write/Read/Edit tools for file operations
- No external dependencies required

### Testing Approach:
- Manual testing scenarios documented in `coding-prompt.md`
- Edge case validation built into command logic
- Real-world workflow testing recommended before Phase 3

---

## Next Phase: Team-Wide Memory Surfacing

### Feature Name: Automatic History Surfacing (Phase 3)

**Objective:**
Surface relevant past decisions from entire team history at the start of new strategy sessions, enabling cross-PM learning and preventing repeated mistakes.

**Status:** 🚧 To Be Developed

**Planned Capabilities:**
- Pre-session search of team decision history
- Keyword extraction and tag matching
- Display top 3 relevant decisions with PM attribution
- Format: "Sara decided X on Jan 6, outcome was Y"
- Cross-PM visibility and learning

**Files to Modify:**
- `.claude/commands/strategy-session.md` (add pre-session search step)

---

*This document will be updated as new features are developed and enhanced.*
