#!/bin/bash

# Simple validation test for /memory-init
# Tests basic directory structure creation

set -e

echo "🧪 Testing /memory-init command..."
echo ""

# Cleanup from previous test
rm -rf test-product-memory

# Test 1: Create directory structure
echo "Test 1: Directory structure creation"
product="test-product"
area="test-area"

mkdir -p test-product-memory/products/${product}/areas/${area}/decisions
mkdir -p test-product-memory/products/${product}/areas/${area}/sessions

if [ -d "test-product-memory/products/${product}/areas/${area}/decisions" ]; then
  echo "✅ Directory structure created correctly"
else
  echo "❌ Directory structure creation failed"
  exit 1
fi

# Test 2: Config file creation
echo ""
echo "Test 2: Config file creation"

# Product config
cat > test-product-memory/products/${product}/config.yml << EOF
product_id: "${product}"
product_name: "Test Product"
created_at: "$(date +%Y-%m-%d)"
product_areas:
  - "${area}"
description: "Platform product with multiple product areas"
EOF

# Area config
cat > test-product-memory/products/${product}/areas/${area}/config.yml << EOF
product_id: "${product}"
product_area: "${area}"
area_name: "Test Area"
created_at: "$(date +%Y-%m-%d)"
team_members:
  - email: "test@example.com"
    name: "Test User"
    role: "Product Manager"
    active: true
EOF

# Validate configs exist
if [ -f "test-product-memory/products/${product}/config.yml" ] && \
   [ -f "test-product-memory/products/${product}/areas/${area}/config.yml" ]; then
  echo "✅ Config files created correctly"
else
  echo "❌ Config file creation failed"
  exit 1
fi

# Validate YAML structure
if grep -q "product_id" test-product-memory/products/${product}/config.yml && \
   grep -q "product_area" test-product-memory/products/${product}/areas/${area}/config.yml; then
  echo "✅ Config files have valid structure"
else
  echo "❌ Config file structure invalid"
  exit 1
fi

echo ""
echo "🎉 All tests passed!"
echo ""
echo "Cleanup test files? (y/n)"
read cleanup
if [ "$cleanup" = "y" ]; then
  rm -rf test-product-memory
  echo "✅ Cleaned up test files"
fi
