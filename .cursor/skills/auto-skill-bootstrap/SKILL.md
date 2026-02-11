---
name: auto-skill-bootstrap
description: Automatic skill discovery and installation based on project capabilities
capabilities: [skill-management, capability-mapping, trust-policy]
version: 1.0.0
author: SteelMorgan (adapted for 1C development)
---

# Auto Skill Bootstrap

## PURPOSE

Deterministic "pre-flight" mechanism that:
1. **Inventories** existing skills in project
2. **Maps** task to required capabilities
3. **Identifies gaps** (missing capabilities)
4. **Finds candidates** on skills.sh via Skills CLI
5. **Filters** by trust policy (allowlist)
6. **Proposes** installation (user approval required)

## DESIGN PHILOSOPHY

**Fail-closed by default**: If capability has only non-allowlisted candidates, block and require explicit user decision.

Never guess. Never auto-install untrusted. Always ask.

## FILE STRUCTURE

```
.cursor/skills/
├── skills-manifest.json          # Generated inventory
└── auto-skill-bootstrap/
    ├── SKILL.md                   # This file
    ├── capabilities-1c.json       # 1C-specific capabilities
    ├── trust-policy.json          # Allowlist/denylist
    ├── state.json                 # Last run state
    ├── candidates.json            # Found candidates
    └── bin/
        ├── update-manifest.py     # Generate inventory
        └── auto-skill-bootstrap.py # Main orchestrator
```

## PREREQUISITES

### Required
- **Node.js + npm**: For `npx skills` CLI
- **Python 3.8+**: For orchestrator scripts

### Skills CLI
```bash
# Test availability
npx --yes skills --version

# Should output: skills@x.x.x
```

## WORKFLOW

### Step 1: Update Manifest
```bash
# Generate inventory of current skills
python .cursor/skills/auto-skill-bootstrap/bin/update-manifest.py

# Output: .cursor/skills/skills-manifest.json
```

### Step 2: Identify Capabilities
```yaml
For current task, determine required capabilities:
  - 1c-query-optimization: If working with queries
  - 1c-forms: If generating forms
  - 1c-testing: If writing tests
  - docker: If working with containers
  - etc.

Typical task needs 3-8 capabilities.
```

### Step 3: Find Candidates
```bash
# Search for skills (no installation)
python .cursor/skills/auto-skill-bootstrap/bin/auto-skill-bootstrap.py \
  --no-install \
  --cap 1c-query-optimization \
  --cap 1c-forms \
  --cap 1c-testing

# Output:
# - .cursor/skills/auto-skill-bootstrap/candidates.json
# - .cursor/skills/auto-skill-bootstrap/state.json
```

### Step 4: Review Candidates
```yaml
Check candidates.json:
  - allowlisted: Can auto-install (if enabled)
  - non_allowlisted: Require manual review

Check state.json:
  - missing_caps: Capabilities without coverage
  - no_candidates_caps: No skills found
  - non_allowlisted_only_caps: Only untrusted skills found
```

### Step 5: Install Skills
```bash
# Option A: Auto-install allowlisted only
python .cursor/skills/auto-skill-bootstrap/bin/auto-skill-bootstrap.py \
  --install-allowlisted \
  --max-per-cap 1 \
  --cap 1c-query-optimization \
  --cap 1c-forms

# Option B: Manual installation
npx skills add alkoleft/mcp-onec-test-runner -y
npx skills add vercel/some-skill -y

# Option C: Ignore capability (won't ask again)
python .cursor/skills/auto-skill-bootstrap/bin/auto-skill-bootstrap.py \
  --no-install \
  --cap 1c-query-optimization \
  --ignore-cap 1c-query-optimization
```

### Step 6: Update Manifest
```bash
# After any installation, regenerate manifest
python .cursor/skills/auto-skill-bootstrap/bin/update-manifest.py
```

## CAPABILITY MAPPING

### 1C Development
```yaml
1c-query-optimization:
  - Queries: ["1c query optimization", "bsl query performance"]
  - Keywords: ["запросы", "индексы", "query", "optimization"]

1c-forms:
  - Queries: ["1c managed forms", "bsl forms generation"]
  - Keywords: ["управляемые формы", "forms"]

1c-testing:
  - Queries: ["vanessa automation", "yaxunit", "1c bdd"]
  - Keywords: ["тесты", "vanessa", "testing"]

1c-code-quality:
  - Queries: ["bsl linter", "1c coding standards"]
  - Keywords: ["качество", "стандарты", "linter"]

1c-bsp:
  - Queries: ["1c ssl", "standard subsystems library"]
  - Keywords: ["бсп", "ssl", "стандартные подсистемы"]
```

### Infrastructure
```yaml
docker:
  - Queries: ["docker best practices", "dockerfile optimization"]
  - Keywords: ["docker", "container"]

proxmox:
  - Queries: ["proxmox automation", "proxmox lxc"]
  - Keywords: ["proxmox", "lxc", "virtualization"]

postgresql:
  - Queries: ["postgresql for 1c", "postgresql optimization"]
  - Keywords: ["postgresql", "postgres"]
```

### AI/Development
```yaml
mcp-development:
  - Queries: ["mcp server development", "model context protocol"]
  - Keywords: ["mcp", "model context protocol"]

cursor-skills:
  - Queries: ["cursor skills development", "cursor agent creation"]
  - Keywords: ["cursor", "skills", "agents"]

ai-prompting:
  - Queries: ["prompt engineering", "ai prompting best practices"]
  - Keywords: ["prompting", "ai", "llm"]
```

## TRUST POLICY

### Allowlist
```yaml
Automatically trusted:
  - anthropic/*: Official Anthropic skills
  - vercel/*: Skills.sh maintainer
  - alkoleft/*: 1C testing tools
  - SteelMorgan/*: Auto-skill-bootstrap author
  - microsoft/*: Official Microsoft
  - 1c-syntax/*: 1C syntax tools
  - silverbulleters/*: 1C community
  - vanessa-opensource/*: Vanessa BDD
```

### Review Required
```yaml
All other sources require:
  1. Manual review: Check source code
  2. Explicit approval: User decision
  3. One-time install: npx skills add <package>
  4. Update manifest: After installation
```

### Denylist
```yaml
Never install:
  - */malicious-*
  - */test-*
  - */experimental-*
```

## STATE MANAGEMENT

### state.json Structure
```json
{
  "version": "1.0",
  "last_run": "2026-02-08T12:00:00Z",
  "caps": ["1c-query-optimization", "1c-forms"],
  "missing_caps": ["1c-forms"],
  "no_candidates_caps": [],
  "non_allowlisted_only_caps": ["1c-forms"],
  "ignored_caps": [],
  "installed": [],
  "adhoc_queries": []
}
```

### Idempotency
```yaml
Same capabilities + same state = same result

State tracks:
  - What was requested: caps
  - What was missing: missing_caps
  - What was ignored: ignored_caps
  - What was installed: installed

Prevents:
  - Duplicate installations
  - Repeated prompts for ignored capabilities
  - Unnecessary searches
```

## INTEGRATION WITH AGENTS

### dev-optimizer Integration
```yaml
When dev-optimizer detects pattern:
  1. Identify capability: Map pattern to capability
  2. Check coverage: Is capability covered?
  3. If not covered:
     - Run auto-skill-bootstrap
     - Propose installation
     - Record decision in RLM

Example:
  Pattern: "User searched for function 5 times"
  Capability: "1c-code-quality" (code search)
  Action: Find and install code search skill
```

### Agent Coordination
```yaml
Before agent starts work:
  1. Identify required capabilities
  2. Check manifest: Are capabilities covered?
  3. If gaps:
     - Run auto-skill-bootstrap
     - Wait for user decision
     - Proceed only when covered

This ensures agents have necessary tools.
```

## COMMANDS REFERENCE

### Update Manifest
```bash
python .cursor/skills/auto-skill-bootstrap/bin/update-manifest.py

# Scans: .cursor/skills/**/SKILL.md
# Generates: .cursor/skills/skills-manifest.json
# Output: List of skills with capabilities
```

### Search Candidates (No Install)
```bash
python .cursor/skills/auto-skill-bootstrap/bin/auto-skill-bootstrap.py \
  --no-install \
  --cap <capability1> \
  --cap <capability2>

# Searches: skills.sh via npx skills find
# Generates: candidates.json, state.json
# Exit code: 0 (success), 2 (user action required)
```

### Auto-Install Allowlisted
```bash
python .cursor/skills/auto-skill-bootstrap/bin/auto-skill-bootstrap.py \
  --install-allowlisted \
  --max-per-cap 1 \
  --cap <capability>

# Installs: Only allowlisted candidates
# Limit: max-per-cap per capability
# Updates: state.json with installed
```

### Ignore Capability
```bash
python .cursor/skills/auto-skill-bootstrap/bin/auto-skill-bootstrap.py \
  --no-install \
  --cap <capability> \
  --ignore-cap <capability>

# Records: In state.json ignored_caps
# Effect: Won't prompt for this capability again
# Scope: Only for current run's capabilities
```

### Ad-hoc Search
```bash
python .cursor/skills/auto-skill-bootstrap/bin/auto-skill-bootstrap.py \
  --no-install \
  --cap other \
  --query "react best practices" \
  --query "testing patterns"

# Searches: Custom queries
# Records: In state.json adhoc_queries
# Use: When capability not in mapping
```

### Manual Installation
```bash
# Install specific skill
npx skills add <owner>/<repo>@<skill> -y

# Example
npx skills add alkoleft/mcp-onec-test-runner -y

# After installation
python .cursor/skills/auto-skill-bootstrap/bin/update-manifest.py
```

## ERROR HANDLING

### Exit Codes
```yaml
0: Success, all capabilities covered or allowlisted
1: Error (script failure, missing dependencies)
2: User action required (non-allowlisted candidates)
```

### User Action Required (Exit 2)
```yaml
Trigger: non_allowlisted_only_caps not empty

Message:
  "USER ACTION REQUIRED
   
   Capabilities with only non-allowlisted candidates:
   - 1c-forms
   
   Options:
   1. Review candidates.json
   2. Install manually: npx skills add <package>
   3. Ignore capability: --ignore-cap 1c-forms
   4. Add to allowlist: Edit trust-policy.json"

Action: User must decide
```

### Missing Dependencies
```yaml
If npx not found:
  Error: "Node.js/npm required. Install: https://nodejs.org/"
  Exit: 1

If Python < 3.8:
  Error: "Python 3.8+ required"
  Exit: 1

If Skills CLI fails:
  Error: "Skills CLI unavailable. Check: npx skills --version"
  Exit: 1
```

## BEST PRACTICES

### Capability Selection
```yaml
Choose 3-8 capabilities per task:
  - Too few: Miss important tools
  - Too many: Overwhelming choices

Example task: "Optimize 1C query"
  Capabilities:
    - 1c-query-optimization (primary)
    - 1c-code-quality (review)
    - postgresql (database)
    - 1c-debugging (diagnostics)
```

### Trust Policy Updates
```yaml
Add to allowlist:
  1. Verify source: Check GitHub repo
  2. Review code: Ensure no malicious code
  3. Test locally: Install and test
  4. Update policy: Add to trust-policy.json
  5. Commit: Version control

Never blindly trust. Always verify.
```

### State Management
```yaml
Commit state.json:
  - Yes: Track decisions across team
  - No: If personal preferences

Commit candidates.json:
  - No: Temporary, regenerate each run

Commit skills-manifest.json:
  - Yes: Track installed skills
```

## EXAMPLES

### Example 1: New 1C Project
```yaml
Task: Start 1C development

Capabilities needed:
  - 1c-code-quality
  - 1c-testing
  - 1c-bsp
  - 1c-git
  - cursor-skills

Commands:
  1. Update manifest:
     python .cursor/skills/auto-skill-bootstrap/bin/update-manifest.py
  
  2. Find skills:
     python .cursor/skills/auto-skill-bootstrap/bin/auto-skill-bootstrap.py \
       --no-install \
       --cap 1c-code-quality \
       --cap 1c-testing \
       --cap 1c-bsp \
       --cap 1c-git \
       --cap cursor-skills
  
  3. Review candidates.json
  
  4. Install allowlisted:
     python .cursor/skills/auto-skill-bootstrap/bin/auto-skill-bootstrap.py \
       --install-allowlisted \
       --max-per-cap 1 \
       --cap 1c-code-quality \
       --cap 1c-testing
  
  5. Manual install others:
     npx skills add <package> -y
  
  6. Update manifest:
     python .cursor/skills/auto-skill-bootstrap/bin/update-manifest.py

Result: Project ready with necessary skills
```

### Example 2: Query Optimization Task
```yaml
Task: Optimize slow 1C query

Capabilities needed:
  - 1c-query-optimization
  - postgresql
  - 1c-debugging

Commands:
  1. Check coverage:
     python .cursor/skills/auto-skill-bootstrap/bin/update-manifest.py
  
  2. Find gaps:
     python .cursor/skills/auto-skill-bootstrap/bin/auto-skill-bootstrap.py \
       --no-install \
       --cap 1c-query-optimization \
       --cap postgresql \
       --cap 1c-debugging
  
  3. If gaps found:
     - Review candidates
     - Install needed skills
     - Update manifest

Result: Tools available for optimization
```

### Example 3: Ignore Capability
```yaml
Task: Work without specific capability

Scenario: No good skills for "1c-deployment"

Command:
  python .cursor/skills/auto-skill-bootstrap/bin/auto-skill-bootstrap.py \
    --no-install \
    --cap 1c-deployment \
    --ignore-cap 1c-deployment

Effect:
  - Recorded in state.json
  - Won't prompt again
  - Can proceed without this capability

Use: When capability optional or handled manually
```

## TROUBLESHOOTING

### Skills CLI Not Found
```bash
# Test
npx --yes skills --version

# If fails
npm install -g skills

# Or use npx (downloads on-demand)
npx --yes skills find "test"
```

### No Candidates Found
```yaml
Possible causes:
  - Capability too specific: Broaden queries
  - Skills.sh down: Check https://skills.sh
  - Network issues: Check connectivity

Solutions:
  - Use ad-hoc search: --cap other --query "..."
  - Manual search: Browse skills.sh
  - Ignore capability: --ignore-cap <cap>
```

### Non-Allowlisted Only
```yaml
Situation: All candidates non-allowlisted

Options:
  1. Review manually: Check source code
  2. Add to allowlist: If trusted
  3. Install manually: npx skills add
  4. Ignore: --ignore-cap
  5. Work without: Proceed without skill

Never auto-install untrusted.
```

## METRICS

### Track in RLM
```yaml
After each run:
  rlm_add_hierarchical_fact(
    content="Auto-skill-bootstrap: Found X candidates for Y capabilities",
    level=0,
    domain="skill-management",
    ttl_days=30
  )

Metrics:
  - capabilities_requested: Count
  - candidates_found: Count
  - skills_installed: Count
  - user_decisions: List
```

---

## CRITICAL RULES

1. **Never auto-install untrusted** - Allowlist only
2. **Always update manifest** - After installations
3. **User approval required** - For non-allowlisted
4. **Fail-closed by default** - Block on gaps
5. **Track decisions** - In state.json and RLM
6. **Idempotent operations** - Same input = same output
7. **Verify sources** - Before adding to allowlist
8. **Document choices** - Why skill chosen

---

## INTEGRATION CHECKLIST

- [ ] Node.js/npm installed
- [ ] Python 3.8+ installed
- [ ] Skills CLI tested: `npx skills --version`
- [ ] Manifest generated: `update-manifest.py`
- [ ] Capabilities defined: `capabilities-1c.json`
- [ ] Trust policy configured: `trust-policy.json`
- [ ] Test run: `--no-install --cap docker`
- [ ] RLM integration: Record facts
- [ ] Agent integration: dev-optimizer uses this
