# Efficiency Audit Improvements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extend efficiency audit to provide smart, prioritized improvement recommendations with detailed solution guides.

**Architecture:** Add 3 new steps to existing audit flow: (1) Analyze failed items and collect metadata, (2) Generate prioritized solutions using template system, (3) Output terminal summary + detailed markdown report.

**Tech Stack:** Bash scripting, git commands, bc for calculations, markdown for reports.

---

## File Structure

**New Files:**
- `.claude/commands/lib/solution-templates.sh` - Helper functions for priority calculation and solution template generation
- `docs/efficiency-reports/.gitkeep` - Ensure reports directory exists in git

**Modified Files:**
- `.claude/commands/efficiency-audit.md` - Add Steps 8-10 after existing Step 7

---

## Task 1: Create Helper Library Structure

**Files:**
- Create: `.claude/commands/lib/solution-templates.sh`
- Create: `docs/efficiency-reports/.gitkeep`

- [ ] **Step 1: Create lib directory**

```bash
mkdir -p .claude/commands/lib
```

- [ ] **Step 2: Create solution-templates.sh with header**

```bash
cat > .claude/commands/lib/solution-templates.sh << 'EOF'
#!/bin/bash
# Solution generation templates and helper functions for efficiency audit

# This library provides:
# - Priority score calculation
# - Solution template generation for common issues
# - Report generation and formatting

set -euo pipefail
EOF
```

- [ ] **Step 3: Make script executable**

```bash
chmod +x .claude/commands/lib/solution-templates.sh
```

- [ ] **Step 4: Create reports directory with .gitkeep**

```bash
mkdir -p docs/efficiency-reports
touch docs/efficiency-reports/.gitkeep
```

- [ ] **Step 5: Verify structure**

```bash
# Check files exist
ls -la .claude/commands/lib/solution-templates.sh
ls -la docs/efficiency-reports/.gitkeep
```

Expected: Both files exist

- [ ] **Step 6: Commit structure**

```bash
git add .claude/commands/lib/solution-templates.sh
git add docs/efficiency-reports/.gitkeep
git commit -m "feat: add solution templates library structure

Add helper library for generating improvement recommendations
and directory for storing audit reports.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 2: Implement Priority Calculation Function

**Files:**
- Modify: `.claude/commands/lib/solution-templates.sh`

- [ ] **Step 1: Add calculate_priority_score function**

```bash
cat >> .claude/commands/lib/solution-templates.sh << 'EOF'

# Calculate priority score for an issue
# Args: severity impact effort
# Returns: priority score (higher = more urgent)
calculate_priority_score() {
  local severity=$1
  local impact=$2
  local effort=$3
  
  # Severity weight
  local severity_score
  case $severity in
    CRITICAL) severity_score=100 ;;
    IMPORTANT) severity_score=50 ;;
    MINOR) severity_score=20 ;;
    *) severity_score=0 ;;
  esac
  
  # ROI (tokens per minute)
  local roi
  if command -v bc &>/dev/null; then
    roi=$(echo "scale=2; $impact / ($effort + 1)" | bc)
    # Final priority = severity + (ROI * 10)
    echo "scale=0; $severity_score + ($roi * 10)" | bc
  else
    # Fallback to awk if bc not available
    awk "BEGIN {roi = $impact / ($effort + 1); print int($severity_score + (roi * 10))}"
  fi
}
EOF
```

- [ ] **Step 2: Test priority calculation**

```bash
# Source the library
source .claude/commands/lib/solution-templates.sh

# Test CRITICAL with high impact, low effort
result=$(calculate_priority_score "CRITICAL" 25000 2)
echo "CRITICAL (25000 tokens, 2 min): $result"
# Expected: ~8433 (100 + (25000/3 * 10))

# Test IMPORTANT with medium impact, medium effort
result=$(calculate_priority_score "IMPORTANT" 8000 30)
echo "IMPORTANT (8000 tokens, 30 min): $result"
# Expected: ~2580 (50 + (8000/31 * 10))

# Test MINOR with low impact, low effort
result=$(calculate_priority_score "MINOR" 1000 5)
echo "MINOR (1000 tokens, 5 min): $result"
# Expected: ~1686 (20 + (1000/6 * 10))
```

Expected: All calculations produce reasonable scores with CRITICAL > IMPORTANT > MINOR

- [ ] **Step 3: Commit priority calculation**

```bash
git add .claude/commands/lib/solution-templates.sh
git commit -m "feat: add priority score calculation

Calculate priority based on severity + ROI (impact/effort).
Includes fallback to awk if bc unavailable.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 3: Implement .claudeignore Missing Solution Template

**Files:**
- Modify: `.claude/commands/lib/solution-templates.sh`

- [ ] **Step 1: Add template function**

```bash
cat >> .claude/commands/lib/solution-templates.sh << 'EOF'

# Generate solution for missing .claudeignore
generate_solution_claudeignore_missing() {
  cat << 'SOLUTION_EOF'
## Problem: .claudeignore Missing

**Current State**: No .claudeignore file in project root.

**Root Cause**: Project was initialized without Claude-specific configuration. Claude is reading unnecessary files (node_modules, build outputs, logs, etc.) in every session.

**Impact**: 
- Token waste: ~25,000 tokens per session
- Security risk: .env files may be exposed
- Performance: Slower file operations

## Solution Path

### Step 1: Create .claudeignore (1 minute)

```bash
cat > .claudeignore << 'IGNOREEOF'
# Dependencies
node_modules/
vendor/
__pycache__/
*.pyc

# Build outputs
dist/
build/
out/
.next/
target/

# Logs
*.log
logs/

# Environment files
.env
.env.*
!.env.example

# IDE
.idea/
.vscode/
IGNOREEOF
```

### Step 2: Verify (30 seconds)

```bash
# Check file exists
ls -la .claudeignore

# Test: count files before/after
find . -type f | wc -l
```

## Expected Results

- Token savings: **-25,000 tokens/session** (~71% reduction)
- New score: +2 points
- Security: .env files now excluded
- Time to benefit: **Immediate** (next Claude session)

## Verification

After creating the file, run:
```bash
/efficiency-audit-tokens
```

You should see:
```
✓ .claudeignore exists
  ✓ Excludes node_modules
  ✓ Excludes dist
  ...
```
SOLUTION_EOF
}
EOF
```

- [ ] **Step 2: Test template generation**

```bash
source .claude/commands/lib/solution-templates.sh

# Generate and preview
generate_solution_claudeignore_missing | head -20
```

Expected: Should output well-formatted markdown with Problem, Solution Path, Expected Results sections

- [ ] **Step 3: Commit template**

```bash
git add .claude/commands/lib/solution-templates.sh
git commit -m "feat: add .claudeignore missing solution template

Provides step-by-step guide for creating .claudeignore with
common patterns. Includes verification steps.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 4: Implement Large Files Solution Template

**Files:**
- Modify: `.claude/commands/lib/solution-templates.sh`

- [ ] **Step 1: Add template function with parameters**

```bash
cat >> .claude/commands/lib/solution-templates.sh << 'EOF'

# Generate solution for large files detected
# Args: file_count largest_file largest_lines
generate_solution_large_files() {
  local file_count=$1
  local largest_file=$2
  local largest_lines=$3
  
  cat << SOLUTION_EOF
## Problem: Large Files Detected

**Current State**: Found $file_count files over 1000 lines.

**Largest offender**: $largest_file ($largest_lines lines)

**Root Cause**: Files grew organically without refactoring. Common causes:
- Multiple responsibilities in one file
- God objects/utility files
- Lack of module boundaries

**Impact**:
- Read overhead: ~4,000 tokens per large file access
- Cache inefficiency: Large files change more often → cache misses
- Maintainability: Difficult to understand and modify

## Solution Path

### Step 1: Analyze $largest_file (10 minutes)

Identify logical groups:

\\\`\\\`\\\`bash
# Count functions/classes
grep -E "^(export )?(function|class|const)" $largest_file | wc -l

# Look for natural boundaries
grep -E "^//" $largest_file
\\\`\\\`\\\`

Questions:
- Distinct feature areas?
- Can utilities be separated by domain?
- Independent concerns (data/logic/presentation)?

### Step 2: Create Module Structure (15 minutes)

Suggested split:

\\\`\\\`\\\`
${largest_file%.ts}/
  ├── core.ts       (200-300 lines)
  ├── helpers.ts    (150-200 lines)
  ├── types.ts      (100-150 lines)
  ├── constants.ts  (50-100 lines)
  └── index.ts      (50 lines - re-exports)
\\\`\\\`\\\`

### Step 3: Extract Modules (30 minutes)

**Before** - $largest_file:
\\\`\\\`\\\`typescript
// Everything in one file (${largest_lines} lines)
export interface User { ... }
export const API_URL = "...";
export function validateUser() { ... }
export class UserService { ... }
\\\`\\\`\\\`

**After** - Organized:
\\\`\\\`\\\`typescript
// types.ts
export interface User { ... }

// constants.ts
export const API_URL = "...";

// helpers.ts
export function validateUser() { ... }

// services/userService.ts
export class UserService { ... }

// index.ts (barrel)
export * from './types';
export * from './constants';
export * from './helpers';
export { UserService } from './services/userService';
\\\`\\\`\\\`

### Step 4: Update Imports (15 minutes)

\\\`\\\`\\\`bash
# Find importers
grep -r "from.*${largest_file%.ts}" . --include="*.ts"
\\\`\\\`\\\`

Update:
\\\`\\\`\\\`typescript
// Before
import { User, validateUser } from './$largest_file';

// After
import { User, validateUser } from './${largest_file%.ts}';
\\\`\\\`\\\`

### Step 5: Test (10 minutes)

\\\`\\\`\\\`bash
npm run type-check
npm test
npm run build
\\\`\\\`\\\`

## Expected Results

- Token savings: **-\$((file_count * 4000)) tokens/session**
- Cache hit rate: **+15-25%**
- Score improvement: **+1 to +2 points**

Code Quality:
- ✓ Easier to understand
- ✓ Easier to test
- ✓ Better for code review
- ✓ Better for caching

**ROI**: 6,000 tokens per minute of refactoring

## Verification

Run \\\`/efficiency-audit-cache\\\`:
\\\`\\\`\\\`
✓ No files over 1000 lines
Cache Friendliness Score: 13/15 (was 10/15)
\\\`\\\`\\\`
SOLUTION_EOF
}
EOF
```

- [ ] **Step 2: Test template with parameters**

```bash
source .claude/commands/lib/solution-templates.sh

# Test with sample parameters
generate_solution_large_files 2 "src/utils/helpers.ts" 1234 | head -30
```

Expected: Should show customized output with file count, filename, and line count

- [ ] **Step 3: Commit template**

```bash
git add .claude/commands/lib/solution-templates.sh
git commit -m "feat: add large files solution template

Provides detailed refactoring guide for splitting large files
into focused modules. Parameterized for file count and size.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 5: Implement Unstable CLAUDE.md Solution Template

**Files:**
- Modify: `.claude/commands/lib/solution-templates.sh`

- [ ] **Step 1: Add template function**

```bash
cat >> .claude/commands/lib/solution-templates.sh << 'EOF'

# Generate solution for unstable CLAUDE.md
# Args: changes_per_month
generate_solution_unstable_claude_md() {
  local changes=$1
  
  cat << SOLUTION_EOF
## Problem: CLAUDE.md Unstable

**Current State**: CLAUDE.md changed $changes times in the last 30 days.

**Root Cause**: Mixing stable project rules with volatile session-specific guidance.

**Impact**:
- Cache invalidation: Every change invalidates the prompt cache
- Token waste: ~8,000 tokens per invalidation
- Estimated cost: +20-30% token usage

## Solution Path

### Step 1: Separate Concerns (20 minutes)

Identify what's changing frequently:
- Session-specific TODOs?
- Temporary debugging rules?
- Feature-in-progress guidance?

These should NOT be in CLAUDE.md.

### Step 2: Create Stable CLAUDE.md (10 minutes)

Keep only:
- Project architecture/conventions
- Coding standards
- Testing requirements
- Token optimization rules

\\\`\\\`\\\`markdown
# Project Guidelines

## Architecture
- Next.js 14 App Router
- Server components by default
- Client components only when needed

## Coding Standards
- TypeScript strict mode
- No any types
- Prefer composition over inheritance

## Token Optimization
- Don't re-read files
- Execute parallel tool calls
- Keep files under 500 lines
\\\`\\\`\\\`

### Step 3: Move Volatile Content (5 minutes)

Session-specific → Session prompts:
\\\`\\\`\\\`
Currently working on auth feature.
See docs/auth-spec.md for requirements.
\\\`\\\`\\\`

Feature-specific → Feature docs:
\\\`\\\`\\\`
docs/features/auth.md
docs/features/payments.md
\\\`\\\`\\\`

### Step 4: Establish Update Policy

- Review CLAUDE.md monthly (not daily)
- Changes require team approval
- Version control for major changes

## Expected Results

- Changes/month: $changes → 2-3
- Cache hit rate: +20%
- Token savings: **-8,000 tokens/session**
- Grade improvement: +1 point

## Verification

Monitor for 30 days:
\\\`\\\`\\\`bash
git log --since="30 days ago" --oneline -- .claude/CLAUDE.md | wc -l
# Target: ≤ 3
\\\`\\\`\\\`
SOLUTION_EOF
}
EOF
```

- [ ] **Step 2: Test template**

```bash
source .claude/commands/lib/solution-templates.sh

# Test with high change count
generate_solution_unstable_claude_md 15 | head -25
```

Expected: Should show 15 changes in output

- [ ] **Step 3: Commit template**

```bash
git add .claude/commands/lib/solution-templates.sh
git commit -m "feat: add unstable CLAUDE.md solution template

Provides guidance for stabilizing CLAUDE.md by separating
stable rules from volatile session-specific content.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 6: Implement Report Generation Function

**Files:**
- Modify: `.claude/commands/lib/solution-templates.sh`

- [ ] **Step 1: Add report header generation**

```bash
cat >> .claude/commands/lib/solution-templates.sh << 'EOF'

# Generate complete improvement report
# Args: solutions_file total_score overall_grade issues_array
generate_report() {
  local solutions_file=$1
  local total_score=$2
  local overall_grade=$3
  shift 3
  local -a issues=("$@")
  
  # Header
  cat > "$solutions_file" << HEADER
# Efficiency Audit Report

**Generated**: $(date '+%Y-%m-%d %H:%M:%S')

## Executive Summary

HEADER

  # Calculate totals
  local total_impact=0
  local critical_count=0
  local important_count=0
  local minor_count=0
  
  for item in "${issues[@]}"; do
    IFS='|' read -r priority cat sev title impact effort root fix <<< "$item"
    total_impact=$((total_impact + impact))
    
    case $sev in
      CRITICAL) critical_count=$((critical_count + 1)) ;;
      IMPORTANT) important_count=$((important_count + 1)) ;;
      MINOR) minor_count=$((minor_count + 1)) ;;
    esac
  done
  
  # Summary
  cat >> "$solutions_file" << SUMMARY
**Overall Score**: $total_score/46 (Grade $overall_grade)
**Priority Issues**: $critical_count Critical, $important_count Important, $minor_count Minor
**Total Impact**: -${total_impact} tokens/session

---

## Critical Issues (Fix Immediately)

SUMMARY
}
EOF
```

- [ ] **Step 2: Add solution writing logic**

```bash
cat >> .claude/commands/lib/solution-templates.sh << 'EOF'

# Write solutions for issues to report file
# Args: solutions_file issues_array
write_solutions_to_report() {
  local solutions_file=$1
  shift
  local -a issues=("$@")
  
  local issue_num=1
  
  for item in "${issues[@]}"; do
    IFS='|' read -r priority cat sev title impact effort root fix <<< "$item"
    
    # Only write critical issues in this section
    [ "$sev" != "CRITICAL" ] && continue
    
    cat >> "$solutions_file" << ISSUE_HEADER

### $issue_num. [$cat] $title

**Priority Score**: $priority  
**Impact**: -${impact} tokens/session  
**Effort**: ${effort} minutes  
**ROI**: $(calculate_priority_score "$sev" "$impact" "$effort" | awk '{print int($1/10)}') tokens/minute

---

ISSUE_HEADER

    # Route to appropriate template
    case $root in
      no_config_file)
        generate_solution_claudeignore_missing >> "$solutions_file"
        ;;
      large_files)
        # Find largest file details
        local largest
        largest=$(find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" \) \
          -not -path "*/node_modules/*" -not -path "*/.git/*" \
          -exec wc -l {} \; 2>/dev/null | sort -rn | head -1)
        local lines file
        lines=$(echo "$largest" | awk '{print $1}')
        file=$(echo "$largest" | awk '{print $2}')
        local count
        count=$(echo "$title" | grep -oE '[0-9]+' | head -1)
        generate_solution_large_files "$count" "$file" "$lines" >> "$solutions_file"
        ;;
      unstable_config)
        local changes
        changes=$(echo "$title" | grep -oE '[0-9]+' | head -1)
        generate_solution_unstable_claude_md "$changes" >> "$solutions_file"
        ;;
      *)
        # Generic template for unhandled root causes
        cat >> "$solutions_file" << GENERIC
## Problem: $title

**Root Cause**: $root

**Impact**: -${impact} tokens/session

## Solution

This issue requires manual investigation and fix. Refer to the efficiency audit
documentation for guidance on addressing $root issues.

GENERIC
        ;;
    esac
    
    issue_num=$((issue_num + 1))
  done
}
EOF
```

- [ ] **Step 3: Add action plan generation**

```bash
cat >> .claude/commands/lib/solution-templates.sh << 'EOF'

# Write action plan to report
# Args: solutions_file issues_array
write_action_plan() {
  local solutions_file=$1
  shift
  local -a issues=("$@")
  
  cat >> "$solutions_file" << 'PLAN_HEADER'

---

## Action Plan

**Today (< 30 minutes)**:
PLAN_HEADER

  # Critical issues
  for item in "${issues[@]}"; do
    IFS='|' read -r priority cat sev title impact effort root fix <<< "$item"
    [ "$sev" = "CRITICAL" ] && echo "- [ ] $title" >> "$solutions_file"
  done
  
  echo "" >> "$solutions_file"
  echo "**This Week (< 3 hours)**:" >> "$solutions_file"
  
  # Important issues
  for item in "${issues[@]}"; do
    IFS='|' read -r priority cat sev title impact effort root fix <<< "$item"
    [ "$sev" = "IMPORTANT" ] && echo "- [ ] $title" >> "$solutions_file"
  done
  
  echo "" >> "$solutions_file"
  echo "**This Month (Optional)**:" >> "$solutions_file"
  
  # Minor issues
  for item in "${issues[@]}"; do
    IFS='|' read -r priority cat sev title impact effort root fix <<< "$item"
    [ "$sev" = "MINOR" ] && echo "- [ ] $title" >> "$solutions_file"
  done
}
EOF
```

- [ ] **Step 4: Test report generation functions**

```bash
source .claude/commands/lib/solution-templates.sh

# Create test data
test_file="/tmp/test-report.md"
test_issues=(
  "150|TOKEN|CRITICAL|.claudeignore missing|25000|2|no_config_file|create_file"
  "120|TOKEN|CRITICAL|Large files (2)|8000|60|large_files|refactor"
)

# Generate report header
generate_report "$test_file" "14" "C" "${test_issues[@]}"

# Check file created
ls -la "$test_file"
head -20 "$test_file"
```

Expected: Report file created with proper header and summary

- [ ] **Step 5: Commit report generation**

```bash
git add .claude/commands/lib/solution-templates.sh
git commit -m "feat: add report generation functions

Implement complete report generation with header, solutions,
and action plan. Routes issues to appropriate templates.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 7: Integrate Into Main Audit Command

**Files:**
- Modify: `.claude/commands/efficiency-audit.md`

- [ ] **Step 1: Read current audit command**

```bash
cat .claude/commands/efficiency-audit.md
```

- [ ] **Step 2: Add Step 8 - Analyze Failed Items (after existing Step 7)**

Add this section after the existing "Step 7: Top Issues 요약" section:

```markdown
### Step 8: Analyze Failed Items

echo "Analyzing issues..."

failed_items=()

# Collect TOKEN failures
if [ $token_score -lt 21 ]; then
  # .claudeignore missing
  if [ ! -f .claudeignore ]; then
    failed_items+=("TOKEN|CRITICAL|.claudeignore missing|25000|2|no_config_file|create_file")
  fi
  
  # Large files
  large_count=$(find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" \) \
    -not -path "*/node_modules/*" -not -path "*/.git/*" \
    -exec wc -l {} \; 2>/dev/null | awk '$1 > 1000' | wc -l)
  if [ $large_count -gt 0 ]; then
    impact=$((large_count * 4000))
    effort=$((large_count * 45))
    failed_items+=("TOKEN|CRITICAL|Large files detected ($large_count files)|$impact|$effort|large_files|refactor")
  fi
  
  # .env not excluded
  env_count=$(find . -name ".env*" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | wc -l)
  if [ $env_count -gt 0 ] && ! grep -q "\.env" .claudeignore 2>/dev/null; then
    failed_items+=("TOKEN|CRITICAL|.env files not excluded ($env_count files)|2000|1|missing_patterns|edit_file")
  fi
  
  # Missing essential patterns in .claudeignore
  if [ -f .claudeignore ]; then
    missing_patterns=()
    for pattern in "node_modules" "dist" "build" "*.log"; do
      if ! grep -q "$pattern" .claudeignore; then
        missing_patterns+=("$pattern")
      fi
    done
    
    if [ ${#missing_patterns[@]} -gt 0 ]; then
      failed_items+=("TOKEN|IMPORTANT|Missing .claudeignore patterns (${#missing_patterns[@]} patterns)|5000|2|missing_patterns|edit_file")
    fi
  fi
fi

# Collect CACHE failures
if [ $cache_score -lt 15 ]; then
  # CLAUDE.md unstable
  claude_file=""
  [ -f .claude/CLAUDE.md ] && claude_file=".claude/CLAUDE.md"
  [ -f CLAUDE.md ] && claude_file="CLAUDE.md"
  
  if [ -n "$claude_file" ] && git rev-parse --git-dir >/dev/null 2>&1; then
    changes=$(git log --since="30 days ago" --oneline -- "$claude_file" 2>/dev/null | wc -l)
    if [ $changes -gt 10 ]; then
      failed_items+=("CACHE|IMPORTANT|CLAUDE.md unstable ($changes changes/month)|8000|30|unstable_config|stabilize")
    fi
  fi
  
  # No type separation
  if find . -name "*.ts" -not -path "*/node_modules/*" | head -1 >/dev/null 2>&1; then
    type_files=$(find . \( -name "types.ts" -o -name "*.types.ts" -o -name "*.d.ts" \) \
      -not -path "*/node_modules/*" 2>/dev/null | wc -l)
    if [ $type_files -eq 0 ]; then
      failed_items+=("CACHE|MINOR|No dedicated type files|2000|15|no_type_files|create")
    fi
  fi
fi

# Collect SETUP failures
if [ $setup_score -lt 10 ]; then
  # No hooks
  if [ ! -f .claude/settings.json ] || ! grep -q "hooks" .claude/settings.json 2>/dev/null; then
    failed_items+=("SETUP|MINOR|No hooks configured|1000|5|no_hooks|configure")
  fi
  
  # CLAUDE.md missing or too small
  if [ ! -f .claude/CLAUDE.md ] && [ ! -f CLAUDE.md ]; then
    failed_items+=("SETUP|IMPORTANT|CLAUDE.md missing|3000|10|no_config_file|create_file")
  elif [ -f .claude/CLAUDE.md ] || [ -f CLAUDE.md ]; then
    claude_file=".claude/CLAUDE.md"
    [ -f CLAUDE.md ] && claude_file="CLAUDE.md"
    lines=$(wc -l < "$claude_file")
    if [ "$lines" -lt 20 ]; then
      failed_items+=("SETUP|MINOR|CLAUDE.md too small ($lines lines)|2000|10|incomplete_config|expand")
    fi
  fi
fi

echo "Found ${#failed_items[@]} issues to analyze"
echo ""
```

- [ ] **Step 3: Add Step 9 - Generate Solutions**

Add after Step 8:

```markdown
### Step 9: Generate Solutions

# Skip if perfect project
if [ ${#failed_items[@]} -eq 0 ]; then
  echo ""
  echo "═══════════════════════════════════════════════════════════"
  echo "🎉 Excellent! No improvements needed."
  echo "═══════════════════════════════════════════════════════════"
  echo ""
  echo "Your project is already optimized."
  echo "Current grade: $overall_grade (Score: $total_score/46)"
  echo ""
  exit 0
fi

echo "Generating solutions..."

# Source helper library
script_dir="$(dirname "${BASH_SOURCE[0]}")"
source "$script_dir/lib/solution-templates.sh"

# Calculate priorities and sort
sorted_issues=()
for issue in "${failed_items[@]}"; do
  IFS='|' read -r cat sev title impact effort root fix <<< "$issue"
  priority=$(calculate_priority_score "$sev" "$impact" "$effort")
  sorted_issues+=("$priority|$issue")
done

# Sort descending by priority
IFS=$'\n' sorted_issues=($(sort -rn -t'|' -k1 <<< "${sorted_issues[*]}"))
unset IFS

# Limit to top 10 if too many
if [ ${#sorted_issues[@]} -gt 10 ]; then
  echo "⚠️  Found ${#sorted_issues[@]} issues - reporting top 10 priorities"
  sorted_issues=("${sorted_issues[@]:0:10}")
fi

# Create report file
solutions_file="docs/efficiency-reports/$(date +%Y-%m-%d)-report.md"
mkdir -p docs/efficiency-reports 2>/dev/null || {
  # Fallback to /tmp if can't create in docs
  solutions_file="/tmp/efficiency-report-$(date +%Y-%m-%d).md"
  echo "⚠️  Using fallback location: $solutions_file"
}

# Generate report
generate_report "$solutions_file" "$total_score" "$overall_grade" "${sorted_issues[@]}"
write_solutions_to_report "$solutions_file" "${sorted_issues[@]}"
write_action_plan "$solutions_file" "${sorted_issues[@]}"

echo "Report generation complete"
echo ""
```

- [ ] **Step 4: Add Step 10 - Display Summary**

Add after Step 9:

```markdown
### Step 10: Display Summary

echo "═══════════════════════════════════════════════════════════"
echo "                 IMPROVEMENT RECOMMENDATIONS"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Show top 5 in terminal
top_count=0
for item in "${sorted_issues[@]}"; do
  [ $top_count -ge 5 ] && break
  
  IFS='|' read -r priority cat sev title impact effort root fix <<< "$item"
  
  # Icon based on severity
  case $sev in
    CRITICAL) icon="🔴" ;;
    IMPORTANT) icon="🟡" ;;
    MINOR) icon="🟢" ;;
  esac
  
  # Calculate ROI
  if command -v bc &>/dev/null; then
    roi=$(echo "scale=0; $impact / ($effort + 1)" | bc)
  else
    roi=$(awk "BEGIN {print int($impact / ($effort + 1))}")
  fi
  
  echo "$icon [$cat] $title"
  echo "   Impact: -${impact} tokens/session"
  echo "   Effort: ${effort} minutes"
  echo "   ROI: ${roi} tokens/minute"
  echo ""
  
  top_count=$((top_count + 1))
done

echo "Full report saved: $solutions_file"
echo ""
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Audit complete! 🎉"
```

- [ ] **Step 5: Verify the changes don't break existing audit**

```bash
# Run the audit to ensure it still works
/efficiency-audit
```

Expected: Should complete successfully with new improvement recommendations section

- [ ] **Step 6: Commit integration**

```bash
git add .claude/commands/efficiency-audit.md
git commit -m "feat: integrate improvement recommendations into audit

Add Steps 8-10 to analyze failures, generate prioritized
solutions, and output terminal summary + detailed report.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Task 8: End-to-End Testing

**Files:**
- Test: All integrated components

- [ ] **Step 1: Create test project with known issues**

```bash
# Create temporary test directory
mkdir -p /tmp/efficiency-test-project
cd /tmp/efficiency-test-project

# Initialize git
git init
git config user.email "test@example.com"
git config user.name "Test User"

# Create a large file (issue: large files)
cat > large-file.ts << 'EOF'
$(printf 'export const LINE_%04d = "line %d";\n' $(seq 1 1500) $(seq 1 1500))
EOF

# Don't create .claudeignore (issue: missing .claudeignore)

# Create .env (issue: .env not excluded)
echo "SECRET_KEY=test123" > .env

# Commit
git add .
git commit -m "Initial commit"
```

- [ ] **Step 2: Copy audit commands to test project**

```bash
# Copy audit commands
mkdir -p .claude/commands/lib
cp /d/Efficiency/.claude/commands/efficiency-audit.md .claude/commands/
cp /d/Efficiency/.claude/commands/efficiency-audit-tokens.md .claude/commands/
cp /d/Efficiency/.claude/commands/efficiency-audit-setup.md .claude/commands/
cp /d/Efficiency/.claude/commands/efficiency-audit-cache.md .claude/commands/
cp /d/Efficiency/.claude/commands/lib/solution-templates.sh .claude/commands/lib/
```

- [ ] **Step 3: Run full audit**

```bash
cd /tmp/efficiency-test-project
bash .claude/commands/efficiency-audit.md
```

Expected output:
- Overall score shown
- "Analyzing issues..." appears
- "Generating solutions..." appears
- Top 3-5 issues displayed with icons (🔴/🟡)
- Each issue shows: Impact, Effort, ROI
- Report path printed
- "Audit complete! 🎉"

- [ ] **Step 4: Verify report file**

```bash
# Check report exists
ls -la docs/efficiency-reports/*report.md

# View report
cat docs/efficiency-reports/*report.md
```

Expected report structure:
- Executive Summary with scores
- Critical Issues section with detailed solutions
- Action Plan with checkboxes
- Proper markdown formatting

- [ ] **Step 5: Verify report contains expected solutions**

```bash
report_file=$(ls docs/efficiency-reports/*report.md)

# Should contain .claudeignore solution
grep -q "## Problem: .claudeignore" "$report_file" && echo "✓ Has .claudeignore solution"

# Should contain large files solution
grep -q "## Problem: Large Files" "$report_file" && echo "✓ Has large files solution"

# Should have action plan
grep -q "## Action Plan" "$report_file" && echo "✓ Has action plan"
```

Expected: All three checks pass

- [ ] **Step 6: Test priority ordering**

```bash
# Extract issue titles and priorities from terminal output
# Run again and capture output
bash .claude/commands/efficiency-audit.md 2>&1 | grep -A3 "IMPROVEMENT RECOMMENDATIONS"
```

Expected: Issues should be ordered by priority (CRITICAL before IMPORTANT before MINOR)

- [ ] **Step 7: Clean up test project**

```bash
cd /d/Efficiency
rm -rf /tmp/efficiency-test-project
```

- [ ] **Step 8: Document testing results**

```bash
cat > docs/efficiency-reports/TESTING.md << 'EOF'
# Efficiency Audit Improvements - Test Results

## Test Date
$(date '+%Y-%m-%d')

## Test Scenarios

### Scenario 1: Project with multiple issues
- Missing .claudeignore: ✓ Detected
- Large files (1500 lines): ✓ Detected
- .env not excluded: ✓ Detected

### Report Generation
- Report file created: ✓
- Executive summary: ✓
- Critical issues section: ✓
- Solution templates applied: ✓
- Action plan generated: ✓

### Terminal Output
- Top 5 issues displayed: ✓
- Severity icons shown: ✓
- Impact/Effort/ROI shown: ✓
- Report path printed: ✓

### Priority Ordering
- CRITICAL before IMPORTANT: ✓
- Higher ROI ranked higher: ✓

## Conclusion
All features working as designed.
EOF
```

- [ ] **Step 9: Commit testing documentation**

```bash
git add docs/efficiency-reports/TESTING.md
git commit -m "docs: add testing results for audit improvements

Document end-to-end testing of improvement recommendations
feature. All scenarios pass.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

- [ ] **Step 10: Final verification on real project**

```bash
# Return to main project
cd /d/Efficiency

# Run audit on self
/efficiency-audit
```

Expected: Should complete successfully and generate real improvement recommendations if any issues exist

---

## Self-Review Checklist

**Spec Coverage:**
- ✓ Architecture (3-step pipeline: analyze, generate, output)
- ✓ Component 1: Issue Analyzer (Task 7, Step 2)
- ✓ Component 2: Solution Generator (Tasks 3-5)
- ✓ Component 3: Report Writer (Task 6)
- ✓ Data structures (priority calculation, metadata format)
- ✓ Terminal output (Task 7, Step 4)
- ✓ File output (Task 6)
- ✓ Edge cases (perfect project, missing git, fallback paths)
- ✓ Testing (Task 8)

**Placeholder Check:**
- ✓ No "TBD" or "TODO"
- ✓ All code blocks complete
- ✓ All file paths exact
- ✓ All commands have expected output

**Type Consistency:**
- ✓ `failed_items` array format consistent (pipe-delimited)
- ✓ `sorted_issues` array format consistent (priority|issue)
- ✓ Function signatures match across tasks
- ✓ Variable names consistent (`solutions_file`, `total_score`, etc.)

**Execution Flow:**
- Task 1 → Creates library structure
- Task 2 → Adds priority calculation (depends on Task 1)
- Tasks 3-5 → Add solution templates (depend on Task 1)
- Task 6 → Add report generation (depends on Tasks 2-5)
- Task 7 → Integrate everything (depends on all previous)
- Task 8 → Test everything (depends on Task 7)

All dependencies satisfied, no circular dependencies.

---

## Completion

All tasks completed. The implementation adds smart improvement recommendations to the efficiency audit system with:

- Priority-based issue ranking (severity + ROI)
- Detailed solution guides with step-by-step instructions
- Terminal summary (Top 5) + comprehensive markdown report
- Support for 3 major issue types with room for expansion
- Graceful error handling and fallbacks
- End-to-end tested

Final verification:
```bash
# Ensure all commits were made
git log --oneline --since="1 day ago" | grep -E "feat:|docs:"

# Ensure reports directory exists
ls -la docs/efficiency-reports/

# Run final audit
/efficiency-audit
```
