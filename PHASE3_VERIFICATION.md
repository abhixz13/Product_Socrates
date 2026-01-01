# Phase 3 - Verification Checklist

Run this checklist to verify Phase 3 is working correctly.

## ✅ Pre-flight Checks

### 1. Phase 1 Complete
- [ ] `/memory-init` command exists at `.claude/commands/memory-init.md`
- [ ] Can initialize a product memory repository

### 2. Phase 2 Complete  
- [ ] `/strategy-session` has decision capture (section 3.5)
- [ ] Decision files are created with YAML frontmatter
- [ ] Git commits work for decisions

### 3. Test Data Ready
- [ ] `../team-product-memory/` directory exists
- [ ] Sample decisions exist in `products/test-product/areas/test-area/decisions/`
- [ ] Git repo is initialized

## ✅ Phase 3 Implementation Checks

### Code Changes

**File: `.claude/commands/strategy-session.md`**

Check these sections exist:

- [ ] Line 119-187: Section 0.5.4 - Search team decision history
  - Keyword extraction logic
  - Search strategy (expanding scope)
  - Relevance ranking algorithm
  
- [ ] Line 189-283: Section 0.5.5 - Memory surfacing
  - Decision display format
  - YAML extraction
  - Cross-area highlighting
  - PM selection handling

- [ ] Line 287-331: Section 1 - Updated Opening
  - Two variants (with/without context)
  - Pattern acknowledgment

**File: `README.md`**

- [ ] Lines 56-121: Product Memory section added
- [ ] Describes `/memory-init` command
- [ ] Describes memory surfacing feature
- [ ] Shows example output

### Feature Validation

Run these manual tests:

**Test 1: Search works**
```bash
cd ../team-product-memory
grep -rl "AI\|ai" products/test-product/areas/test-area/decisions/*.md
# Should return: 2024-12-01-build-ai-email-assistant.md
```

**Test 2: YAML extraction works**
```bash
head -15 products/test-product/areas/test-area/decisions/2024-12-01-build-ai-email-assistant.md
# Should show YAML frontmatter with:
# - decision_id
# - pm_name, pm_email
# - date, status
# - decision summary
```

**Test 3: All test scenarios pass**
```bash
cd ../pm-thought-partner
./test-phase3-search.sh
# All 9 tests should pass
```

**Test 4: Config files valid**
```bash
cat ../team-product-memory/products/test-product/config.yml
cat ../team-product-memory/products/test-product/areas/test-area/config.yml
# Should show valid YAML structure
```

## ✅ Functional Tests

### Test Scenario 1: Happy Path

1. **Setup:** Team memory initialized, 3 decisions exist
2. **Action:** Start `/strategy-session` with AI-related topic
3. **Expected:**
   - Claude syncs with team repo (git pull)
   - Searches for "AI" keyword
   - Finds AI email decision
   - Displays with attribution (Sara Chen)
   - Shows outcome (Success, 40% adoption)
   - Offers 3 options (review/start/ignore)
4. **Verify:** Decision surfacing block appears before Opening

### Test Scenario 2: Cross-Area Learning

1. **Setup:** Multiple areas exist with decisions
2. **Action:** Start session from different area
3. **Expected:**
   - Search finds decisions from other areas
   - Highlights "Decision from different team"
   - Notes area difference
   - Still surfaces relevant learnings
4. **Verify:** Cross-area bonus scoring works

### Test Scenario 3: Empty State

1. **Setup:** No relevant decisions for topic
2. **Action:** Start session with unrelated topic
3. **Expected:**
   - Search runs but finds nothing
   - Message: "No past decisions found related to [topic]"
   - Session continues normally
   - No surfacing block
4. **Verify:** Graceful empty state handling

### Test Scenario 4: Performance

1. **Setup:** Time the search operation
2. **Action:** Run search with keywords
3. **Expected:**
   - Total time < 10 seconds
   - With test data: < 3 seconds
4. **Verify:** `time` command shows acceptable performance

## ✅ Documentation

- [ ] `PHASE3_IMPLEMENTATION.md` created with full details
- [ ] `PHASE3_SUMMARY.md` created with overview
- [ ] `test-phase3-search.sh` created and working
- [ ] `README.md` updated with Product Memory section
- [ ] `coding-prompt.md` has Phase 3 plan (lines 1713-2865)

## ✅ Edge Cases

Test these edge cases are handled:

- [ ] No decisions exist yet (new team)
- [ ] Topic is too vague (< 2 keywords)
- [ ] Git pull fails (offline mode)
- [ ] Decision file missing fields (graceful degradation)
- [ ] Search timeout (> 10 seconds)
- [ ] Old decisions (> 6 months) get warning

## ✅ Integration

- [ ] Phase 1 (`/memory-init`) still works
- [ ] Phase 2 (decision capture) still works
- [ ] Phase 3 doesn't break existing session flow
- [ ] All phases work together end-to-end

## Final Verification

**Run full end-to-end test:**

1. `cd ../pm-thought-partner`
2. Initialize product memory: `/memory-init`
3. Create a decision (manually or via Phase 2)
4. Run strategy session: `/strategy-session "AI feature planning"`
5. Verify decision surfacing works
6. Complete session and capture new decision
7. Run another session with different topic
8. Verify cross-decision learning

**If all checks pass: Phase 3 is verified ✅**

---

*Last verified: December 31, 2024*
