#!/bin/bash
# Solution generation templates and helper functions for efficiency audit

# This library provides:
# - Priority score calculation
# - Solution template generation for common issues
# - Report generation and formatting

set -euo pipefail

# Calculate priority score for an issue
# Args: severity impact effort
# Returns: priority score (higher = more urgent)
calculate_priority_score() {
  # Validate arguments
  if [[ $# -ne 3 ]]; then
    echo "Error: calculate_priority_score requires 3 args (severity impact effort)" >&2
    return 1
  fi

  local severity=$1
  local impact=$2
  local effort=$3

  # Validate numeric inputs
  if ! [[ "$impact" =~ ^[0-9]+$ ]] || ! [[ "$effort" =~ ^[0-9]+$ ]]; then
    echo "Error: impact and effort must be numeric" >&2
    return 1
  fi

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
    # Add 0.5 before truncation to achieve round-half-up
    echo "scale=0; ($severity_score + ($roi * 10) + 0.5) / 1" | bc
  else
    # Fallback to awk if bc not available
    awk "BEGIN {roi = $impact / ($effort + 1); print int($severity_score + (roi * 10) + 0.5)}"
  fi
}

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
