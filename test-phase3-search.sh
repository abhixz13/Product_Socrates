#!/bin/bash

# Test Phase 3 - Memory Surfacing Search Algorithm
# This tests the keyword-based search and ranking logic

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 3 Search Algorithm Test"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd ../team-product-memory || exit 1

# Test 1: Search for "AI" keyword
echo "Test 1: Search for 'AI' keyword"
echo "Expected: Should find AI email assistant decision"
echo ""
grep -rl "AI\|ai" products/test-product/areas/test-area/decisions/*.md 2>/dev/null
echo ""

# Test 2: Search for "mobile" keyword
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 2: Search for 'mobile' keyword"
echo "Expected: Should find mobile app delay decision"
echo ""
grep -rl "mobile\|Mobile" products/test-product/areas/test-area/decisions/*.md 2>/dev/null
echo ""

# Test 3: Search for "real-time collaboration" keywords
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 3: Search for 'real-time collaboration' keywords"
echo "Expected: Should find real-time collaboration decision"
echo ""
grep -rl "real-time\|collaboration\|realtime" products/test-product/areas/test-area/decisions/*.md 2>/dev/null
echo ""

# Test 4: Search for "AI mobile" (multiple keywords)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 4: Search for 'AI mobile' (should find 2 files)"
echo "Expected: AI email assistant + mobile app delay"
echo ""
grep -rl "AI\|mobile\|ai" products/test-product/areas/test-area/decisions/*.md 2>/dev/null
echo ""

# Test 5: Count keyword matches in AI email decision
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 5: Count 'AI' keyword matches in AI email decision"
echo "Expected: Multiple matches (high relevance score)"
echo ""
file="products/test-product/areas/test-area/decisions/2024-12-01-build-ai-email-assistant.md"
matches=$(grep -io "ai" "$file" | wc -l | tr -d ' ')
echo "Keyword matches for 'AI': $matches"
echo "Relevance score calculation: $matches * 10 = $(($matches * 10)) points"
echo ""

# Test 6: Extract decision frontmatter
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 6: Extract YAML frontmatter from decision file"
echo ""
head -15 "$file"
echo ""

# Test 7: Test date calculation for recency score
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 7: Calculate recency scores"
echo ""

today=$(date +%s)
decision_date="2024-12-01"
decision_timestamp=$(date -j -f "%Y-%m-%d" "$decision_date" +%s 2>/dev/null || date -d "$decision_date" +%s)
days_ago=$(( ($today - $decision_timestamp) / 86400 ))
recency_score=$(echo "scale=1; (100 - $days_ago) * 0.1" | bc)

echo "Decision date: $decision_date"
echo "Days ago: $days_ago"
echo "Recency score: $recency_score points"
echo ""

# Test 8: List all decisions
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 8: List all available decisions"
echo ""
ls -1 products/test-product/areas/test-area/decisions/
echo ""

# Test 9: Check config files
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 9: Verify config files exist"
echo ""
echo "Product config:"
test -f products/test-product/config.yml && echo "✓ exists" || echo "✗ missing"

echo "Area config:"
test -f products/test-product/areas/test-area/config.yml && echo "✓ exists" || echo "✗ missing"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Phase 3 Search Tests Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
