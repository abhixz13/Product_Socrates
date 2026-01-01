# Product Memory - Interactive Demo Guide

**Purpose:** Walk a PM through the complete Product Memory experience to demonstrate value.

**Time:** 15-20 minutes

**Who runs this:** You (showing to a PM or stakeholder)

---

## Demo Overview

You'll demonstrate 3 scenarios that show the compounding value:

1. **Scenario 1:** Initial setup (cold start - no memory yet)
2. **Scenario 2:** First decision captured (building memory)
3. **Scenario 3:** Memory surfacing in action (compound effect)

Each scenario shows **before/after** so the PM sees the difference.

---

## Prerequisites

Before starting the demo:

```bash
# 1. Ensure you're in the pm-thought-partner directory
cd pm-thought-partner

# 2. Check test data exists (we created this during Phase 3)
ls -la ../team-product-memory/products/test-product/areas/test-area/decisions/

# Should show 3 decision files:
# - 2024-12-01-build-ai-email-assistant.md
# - 2024-12-15-delay-mobile-app.md
# - 2024-12-20-real-time-collaboration.md
```

---

## Scenario 1: The Cold Start Problem

**Tell the PM:** *"This is what it looks like today when you start a new strategy session. No context, no history."*

### Step 1: Show the "Before" State

```bash
# Ask the PM to imagine this scenario:
# "You're a new PM who just joined the team.
#  You want to think through whether to build AI features."
```

**What happens today (without Product Memory):**
- You run `/strategy-session "Should we build AI features?"`
- Claude has NO team context
- No idea if anyone tried this before
- No knowledge of what worked/failed
- You're starting from scratch

**The problem:** You're about to repeat mistakes the team already learned from.

---

### Step 2: Initialize Product Memory

**Tell the PM:** *"Let's set up Product Memory. This is a one-time setup."*

```bash
# Run this command:
/memory-init
```

**Claude will ask:**
1. **Product name:** `test-product`
2. **Product area:** `test-area`
3. **Git repository URL:** [Press Enter - create local]

**What just happened:**
- Created `team-product-memory/` directory
- Multi-tenant structure: Product → Areas → Decisions
- Git repository initialized
- You're added as team member

**Show them the structure:**
```bash
# Let them see what was created:
ls -la ../team-product-memory/
tree ../team-product-memory/products/test-product/

# Expected output:
# test-product/
# ├── config.yml              (product-level config)
# └── areas/
#     └── test-area/
#         ├── config.yml       (area-level config, has your name)
#         ├── decisions/       (empty - no decisions yet)
#         └── sessions/        (empty - no sessions yet)
```

**Tell the PM:** *"That's it. Setup done. Now watch what happens over time..."*

---

## Scenario 2: First Decision Captured

**Tell the PM:** *"Let's have your first strategy session. Notice what Claude does automatically."*

### Step 1: Start a Strategy Session

**You type (in Claude):**
```
/strategy-session "Should we build AI email assistant?"
```

**What Claude does:**
1. Checks for `team-product-memory/` → EXISTS
2. Searches for relevant decisions → NONE (first time)
3. Shows: "No team decisions found yet. This is your first session!"
4. Proceeds to normal strategy session

**Walk through the conversation:**
- Claude asks probing questions
- Applies frameworks (Four Risks, etc.)
- You discuss: build AI assistant with domain templates
- Decision made: "Yes, build it"

### Step 2: Decision Capture Happens Automatically

**At end of session, Claude detects the decision:**

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DECISION CAPTURE

I noticed you made this decision today:
1. Build AI email assistant with domain-specific templates

Should I save this to your product memory for test-product/test-area? (y/n)

If yes, I'll ask a few quick questions (3 min) to capture context.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**You answer:** `y`

**Claude asks 4 questions:**

```
1️⃣ What assumptions are you making?
   → "Users want domain-specific AI, not generic"

2️⃣ What's the main trade-off?
   → "Delaying mobile app work for 1 month"

3️⃣ When will we know if this worked?
   → "4 weeks - we'll measure adoption rate"

4️⃣ What would success look like?
   → "Adoption goes from 15% to 30%"
```

**Claude creates the decision file:**
```
✅ 1 decision saved to team memory

Saved to: products/test-product/areas/test-area/decisions/
  - 2025-01-06-build-ai-email-assistant.md

Team members can see this after: git pull
```

### Step 3: Show What Was Captured

**Let them see the file:**
```bash
cat ../team-product-memory/products/test-product/areas/test-area/decisions/2025-01-06-build-ai-email-assistant.md
```

**Point out:**
- **YAML frontmatter** with structured data (who, when, status)
- **Markdown body** with assumptions, trade-offs, success criteria
- **Attribution** to you (your name, email)
- **Git committed** automatically

**Tell the PM:** *"Now watch what happens when you OR someone else on your team has another session..."*

---

## Scenario 3: Memory Surfacing in Action (The Magic)

**Tell the PM:** *"A week later, you want to think through mobile features. Watch what happens now..."*

### Step 1: Start Another Session

**You type:**
```
/strategy-session "Should we add mobile app improvements?"
```

**What Claude does (automatically):**
1. Syncs with team repo (`git pull`)
2. Extracts keywords: `["add", "mobile", "app", "improvements"]`
3. Searches team decisions
4. Finds 1 relevant decision (AI email assistant mentions mobile delay)
5. Ranks by relevance
6. Surfaces it BEFORE the session starts

### Step 2: See the Memory Surface

**Claude shows:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RELEVANT HISTORY (from team memory)

I found 1 past decision that might inform this session:

📌 1. Build AI email assistant with domain templates
   Who: [Your Name] ([your email])
   When: January 6, 2025 (7 days ago)
   Product Area: test-product/test-area
   Outcome: Pending (follow-up: Feb 3, 2025)

   Key context:
   • Assumptions: Users want domain-specific AI
   • Trade-off: Delayed mobile app work for 1 month  ← RELEVANT!
   • Timeline: 4 weeks to measure adoption

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Would you like to:
1. Review this decision in detail
2. Start the session (I'll keep this in mind)
3. Ignore and start fresh
```

**Pause here. Ask the PM:**
- *"Do you see what just happened?"*
- *"Claude remembered that you delayed mobile for AI"*
- *"It's surfacing that context automatically"*

**You choose:** `2` (Start session with context)

### Step 3: See How Context Shapes the Conversation

**Claude opens with:**
```
I see you're exploring: mobile app improvements

Based on your team's past decisions, I noticed:
• You delayed mobile work 7 days ago to focus on AI assistant
• That decision assumed 4 weeks to validate
• We're only 1 week in - AI results aren't known yet

Should we revisit mobile now, or wait for AI validation first?
Let's think through the timing...
```

**Point out to the PM:**
- Claude didn't just list past decisions
- It **connected** them to the current question
- It **challenged** the timing (only 1 week in, promised 4 weeks)
- The conversation is **informed by team memory**

---

## Scenario 4: Cross-PM Learning (The Compound Effect)

**Tell the PM:** *"Now imagine a new PM joins your team. Watch what they inherit..."*

### Step 1: Simulate New PM

**You type (as the new PM):**
```
/strategy-session "Should we build AI features?"
```

**What Claude does:**
1. Searches team decisions
2. Finds YOUR decision from Scenario 2
3. Surfaces it to the new PM

**Claude shows the new PM:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RELEVANT HISTORY (from team memory)

📌 1. Build AI email assistant with domain templates
   Who: [Your Name] (different PM!)
   When: January 6, 2025
   Outcome: Success - 40% adoption (exceeded 30% goal)

   Key learning:
   • Domain-specific AI > Generic AI (73% lift)
   • Validated with customer interviews first
   • Template approach worked well
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Ask the PM:**
- *"What did the new PM just inherit?"*
- *"Did they have to ask around for this context?"*
- *"Did they have to repeat your mistakes?"*

**The answer:** No. They got 6 months of your learnings in 3 seconds.

---

## Demo Debrief: The Value Proposition

After showing all 3 scenarios, summarize:

### Before Product Memory
- ❌ Decisions made in isolation
- ❌ Context lost when PMs leave
- ❌ Teams repeat mistakes
- ❌ New PMs start from scratch
- ❌ No learning loops

### After Product Memory
- ✅ **Phase 1:** Team repository created (one-time setup)
- ✅ **Phase 2:** Decisions captured automatically (4 quick questions)
- ✅ **Phase 3:** Past decisions surface in new sessions (keyword search)
- ✅ **Cross-PM learning** (Platform sees Product decisions)
- ✅ **Institutional knowledge** compounds over time

### The Compound Effect (6 Months Later)
- 50+ decisions captured
- Every session starts with relevant history
- Patterns emerge: "Prototypes work 85% for us, interviews 40%"
- New PMs inherit months of context on Day 1
- Team stops repeating mistakes

---

## Advanced Demo: Cross-Area Learning (Optional)

**If they want to see more, show cross-area learning:**

### Setup
```bash
# Create a second area for the same product
/memory-init
  Product: test-product
  Area: platform  (different team)
```

### Scenario
**Platform PM asks:**
```
/strategy-session "Should we build AI for API docs?"
```

**Claude surfaces:**
```
📌 Decision from different team (but related):
   Who: [Your Name] (Product PM - test-area)
   Product Area: test-product/test-area  ← Different area!

   Pattern: Domain-specific AI performed 73% better than generic

   This was a different team, but the learning might apply.
```

**The point:** Learning crosses team boundaries automatically.

---

## Questions to Ask the PM During Demo

**After Scenario 1 (Setup):**
- "How long did that take?" (< 2 minutes)
- "Any databases, servers, or complex setup?" (No - just git)

**After Scenario 2 (First capture):**
- "How many questions did you answer?" (4)
- "How long did that take?" (2-3 minutes)
- "Where did this get saved?" (Git repo, sharable)

**After Scenario 3 (Memory surfacing):**
- "Did you have to remember that past decision?" (No - automatic)
- "Did you search for it?" (No - automatic)
- "How long did surfacing take?" (< 3 seconds)

**After Scenario 4 (Cross-PM learning):**
- "What happens when you leave the team?" (Knowledge stays)
- "What does a new PM get on Day 1?" (All past decisions)
- "How does this change onboarding?" (Instant context)

---

## Demo Tips

### Do:
- ✅ Let THEM drive the keyboard (not you)
- ✅ Pause after each scenario for questions
- ✅ Show the actual files (`cat decision.md`)
- ✅ Emphasize automatic behavior (no manual work)
- ✅ Connect to their pain ("Do you repeat mistakes?")

### Don't:
- ❌ Rush through scenarios
- ❌ Show code or implementation details
- ❌ Talk about "phases" or "MVP" (that's internal)
- ❌ Demo without test data loaded first
- ❌ Skip the "before" state (shows contrast)

---

## Expected Questions from PM

**Q: "Is this another tool I have to remember to use?"**
A: No. It's built into `/strategy-session` which you already use. Decision capture happens automatically at the end.

**Q: "What if I don't want to capture a decision?"**
A: Just say "no" when Claude asks. It's optional every time.

**Q: "How do I search old decisions manually?"**
A: Phase 4 (coming soon). For now, they surface automatically in sessions.

**Q: "What about privacy/sensitive decisions?"**
A: Local git repo. You control what gets pushed to remote. Private by default.

**Q: "Can I edit a decision later?"**
A: Yes. They're just markdown files. Edit them directly.

**Q: "What happens when we have 1000 decisions?"**
A: Search performance stays under 10 seconds (tested). Post-MVP: add indexing if needed.

**Q: "How do I share with my team?"**
A: Push to a shared git repo. Team does `git clone` and they're in.

---

## Success Criteria for Demo

**The PM should:**
1. ✅ Understand the "decisions don't compound" problem
2. ✅ See the automatic capture (no manual effort)
3. ✅ Experience the memory surfacing (automatic context)
4. ✅ Recognize the compound effect (new PMs inherit knowledge)
5. ✅ Want to try it with their team

**If they say:** *"I want this for my team"* → Demo succeeded.

**If they say:** *"This is cool but..."* → Find the objection, address it.

**If they say:** *"When can we use this?"* → It's ready now (Phases 1-3 complete).

---

## Next Steps After Demo

**If they want to try it:**
1. Set up on their machine (5 min)
2. Run `/memory-init` with their product
3. Have 1 real strategy session
4. Capture 1 real decision
5. Check back in 2 weeks to see compound effect

**If they want to see more:**
- Show them test data decisions (full examples)
- Walk through a complete decision file
- Show git history (`git log` in team-product-memory)
- Demo cross-area learning with 2 areas

---

## Demo Variations

### For Technical PM:
- Show the git structure (`tree` command)
- Show YAML frontmatter details
- Explain keyword search algorithm
- Show relevance scoring

### For Non-Technical PM:
- Skip technical details
- Focus on "auto-magic" behavior
- Emphasize time savings
- Show tangible examples

### For PM Leader (Managing Multiple PMs):
- Focus on cross-PM learning
- Show how new PMs onboard faster
- Emphasize knowledge retention
- Show pattern recognition (Phase 6 preview)

---

**Demo Guide Complete. Ready to run!**

*Tip: Practice once with the test data before showing to a real PM.*
