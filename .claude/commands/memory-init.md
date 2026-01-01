---
description: /memory-init - Initialize team product memory
---

# /memory-init - Setup Team Decision Memory

You are helping a PM initialize a shared decision memory repository for their product and product area.

## Your Role

Set up a git-based product memory system that allows PM teams to:
- Track decisions by product area
- Share context across team members
- Build institutional knowledge over time

## Process

### 1. Gather Product Information

Start by asking the PM for the basic information you need:

```
Let me set up product memory for your team.

I need a few pieces of information:

1. Product name (e.g., "Intersight", "CustomerOS")
2. Product area (e.g., "Monitoring", "Foundation", "Automation", "IMM")
3. Git repository URL (optional - I can create a local repo if you don't have one yet)

What's your product name?
```

After they provide the product name:
- Convert it to lowercase with hyphens (e.g., "Intersight Platform" → "intersight-platform")
- Remove any special characters except hyphens
- If you made changes, tell them: "Converting to: [converted-name]"

Then ask:
```
What product area are you working on?
(Examples: Monitoring, Foundation, Automation, IMM)
```

Apply the same conversion rules to the area name.

Finally ask:
```
Do you have a git repository URL for team-product-memory?
(Leave blank to create a new local repository)
```

### 2. Get PM Information from Git

Use the Bash tool to get their git config:

```bash
git config user.email && git config user.name
```

If either is missing, tell them:

```
I need your git user info to attribute decisions.

Run these commands first:
git config --global user.email "you@company.com"
git config --global user.name "Your Name"

Then run /memory-init again.
```

Stop here if git is not configured.

### 3. Create Repository Structure

Use the Bash tool to set up the repository:

**If team-product-memory directory exists:**
- Change into it
- Try `git pull origin main` (ignore errors if no remote)

**If team-product-memory doesn't exist:**
- If they provided a repo URL: clone it
- If no repo URL: create new directory and `git init`

Then create the directory structure:
```bash
mkdir -p team-product-memory/products/[product]/areas/[area]/decisions
mkdir -p team-product-memory/products/[product]/areas/[area]/sessions
```

### 4. Generate Config Files

**Product config** at `team-product-memory/products/[product]/config.yml`:

Check if it exists:
- **If yes:** Read it, add the new area to `product_areas` list if not present
- **If no:** Create it with this structure:

```yaml
product_id: "[product-slug]"
product_name: "[Product Name]"
created_at: "[YYYY-MM-DD]"
product_areas:
  - "[area-slug]"
description: "Platform product with multiple product areas"
```

**Area config** at `team-product-memory/products/[product]/areas/[area]/config.yml`:

Check if it exists:
- **If yes:** Read it, add PM to `team_members` if not already there
- **If no:** Create it with this structure:

```yaml
product_id: "[product-slug]"
product_area: "[area-slug]"
area_name: "[Area Name]"
created_at: "[YYYY-MM-DD]"
team_members:
  - email: "[pm_email]"
    name: "[pm_name]"
    role: "Product Manager"
    active: true
```

Use the Write tool to create these files.

### 5. Git Commit

Use the Bash tool to commit:

```bash
cd team-product-memory
git add .
git commit -m "Initialize [product]/[area] product memory

Added by: [pm_name]
Product: [product]
Area: [area]"
```

Try to push (ignore errors if no remote):
```bash
git push origin main 2>/dev/null || echo "Note: Push to remote manually if needed"
```

### 6. Validate and Confirm

Use the Bash tool to validate:

```bash
test -d team-product-memory/products/[product]/areas/[area] && echo "✓ Directories created"
test -f team-product-memory/products/[product]/config.yml && echo "✓ Product config exists"
test -f team-product-memory/products/[product]/areas/[area]/config.yml && echo "✓ Area config exists"
```

If all validations pass, show this success message:

```
✅ Product memory initialized for [Product Name] - [Area Name]

Repository: team-product-memory/
Product: [Product Name] (products/[product]/)
Area: [Area Name] (areas/[area]/)
Team members: 1 ([pm_name])

Next steps:
1. Run /strategy-session to start capturing decisions for [Area]
2. Add another area: run /memory-init again with different area name
3. Invite team: share repo URL with other PMs in this area
   git remote add origin <your-repo-url>
   git push -u origin main

📝 Configs saved:
   - Product: products/[product]/config.yml
   - Area: products/[product]/areas/[area]/config.yml
```

## Edge Cases to Handle

### Area Already Exists

If `products/[product]/areas/[area]/config.yml` already exists:

```
✅ Product area already exists for [product]/[area].

Checking if you're already on the team...
```

Read the config:
- If PM's email is in `team_members`: "You're already on the team!"
- If not: Add them to the `team_members` list and show "Added you to the team."

### Product Exists, New Area

If the product config exists but this is a new area:

```
✅ Product [product] exists. Creating new area: [area]

Created: products/[product]/areas/[area]/
Updated product config with new area.
```

### Invalid Names

If product or area contains spaces or special characters, normalize them and tell the PM:

```
Converting names to valid format:
  Product: "Intersight Platform" → "intersight-platform"
  Area: "IMM Manager" → "imm-manager"

Proceeding with converted names.
```

## Notes

- Keep this simple - focus on getting the structure set up correctly
- Use Write tool for config files (not bash heredocs)
- Use Bash tool for git operations and directory creation
- Product memory is team-wide and shared via git
- Decisions are scoped to product areas (team-specific)
- Multiple areas can exist under one product
