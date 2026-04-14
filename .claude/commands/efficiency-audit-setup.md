---
name: efficiency-audit-setup
description: 프로젝트 기본 설정 검사 (CLAUDE.md, .claudeignore, hooks) - 10개 항목
---

# Project Setup Audit

프로젝트의 Claude 사용을 위한 기본 설정 상태를 검사합니다.

## 검사 항목 (10개)

- **CLAUDE.md** (4개): 존재, 크기, 내용 품질, 프로젝트 특화
- **.claudeignore** (4개): 존재, 기본 패턴, 프로젝트 패턴, 커버리지
- **Hooks** (2개): 설정 파일, 유용한 hooks

## 사용법

```
/efficiency-audit-setup
```

<PROCEDURE>

### Step 1: 검사 시작

```bash
echo "=== Project Setup Audit ==="
echo "Checking 10 configuration items..."
echo ""

score=0
max_score=10
issues=()
```

### Step 2: CLAUDE.md 검사 (4개 항목)

```bash
echo "━━━ 1. CLAUDE.md Configuration ━━━"
echo ""
```

#### 2.1 CLAUDE.md 존재 및 위치

```bash
claude_file=""
if [ -f .claude/CLAUDE.md ]; then
  claude_file=".claude/CLAUDE.md"
  echo "✓ CLAUDE.md found at .claude/CLAUDE.md (recommended location)"
  score=$((score + 1))
elif [ -f CLAUDE.md ]; then
  claude_file="CLAUDE.md"
  echo "✓ CLAUDE.md found at project root"
  echo "  ℹ️ Consider moving to .claude/CLAUDE.md"
  score=$((score + 1))
else
  echo "✗ CLAUDE.md NOT FOUND"
  echo "  Impact: No project-specific guidance for Claude"
  echo "  Benefit: +20-30% efficiency with proper rules"
  issues+=("Create CLAUDE.md with project rules")
fi

echo ""
```

#### 2.2 CLAUDE.md 크기 적정성

```bash
if [ -n "$claude_file" ]; then
  lines=$(wc -l < "$claude_file")
  chars=$(wc -c < "$claude_file")
  
  echo "CLAUDE.md size: $lines lines, $chars bytes"
  
  if [ "$lines" -lt 10 ]; then
    echo "  ⚠️ Too small (< 10 lines)"
    echo "  Suggestion: Add token optimization rules, coding standards"
    issues+=("Expand CLAUDE.md with optimization rules")
  elif [ "$lines" -gt 500 ]; then
    echo "  ⚠️ Too large (> 500 lines)"
    echo "  Impact: Cache misses on every edit"
    echo "  Fix: Move detailed docs to separate files, keep core rules"
    issues+=("Reduce CLAUDE.md size to < 500 lines")
  elif [ "$lines" -gt 300 ]; then
    echo "  ⚠️ Large (300-500 lines) - monitor cache hit rate"
    score=$((score + 1))
  else
    echo "  ✓ Good size (10-300 lines)"
    score=$((score + 1))
  fi
else
  echo "⊘ Skipping size check (no CLAUDE.md)"
fi

echo ""
```

#### 2.3 CLAUDE.md 내용 품질

```bash
if [ -n "$claude_file" ]; then
  echo "Content quality check:"
  
  quality_score=0
  
  # 토큰 최적화 규칙 포함
  if grep -qi "token\|토큰\|optimization\|최적화" "$claude_file"; then
    echo "  ✓ Contains token optimization guidance"
    quality_score=$((quality_score + 1))
  else
    echo "  ✗ Missing token optimization rules"
    issues+=("Add token optimization rules to CLAUDE.md")
  fi
  
  # 코딩 스탠다드/규칙
  if grep -qi "rule\|규칙\|standard\|표준\|convention" "$claude_file"; then
    echo "  ✓ Contains coding standards/rules"
    quality_score=$((quality_score + 1))
  else
    echo "  ℹ️ No explicit coding standards (optional)"
  fi
  
  # Git 관련 규칙
  if grep -qi "git\|commit\|커밋" "$claude_file"; then
    echo "  ✓ Contains git/commit guidelines"
    quality_score=$((quality_score + 1))
  else
    echo "  ℹ️ No git guidelines (optional)"
  fi
  
  # 점수 반영
  if [ $quality_score -ge 2 ]; then
    score=$((score + 1))
    echo "  ✓ Content quality: Good"
  else
    echo "  ⚠️ Content quality: Could be improved"
    issues+=("Improve CLAUDE.md content quality")
  fi
else
  echo "⊘ Skipping content check (no CLAUDE.md)"
fi

echo ""
```

#### 2.4 프로젝트 특화 내용

```bash
if [ -n "$claude_file" ]; then
  echo "Project-specific rules:"
  
  # 프로젝트 이름/설명 포함
  if grep -qi "project\|프로젝트\|about\|설명" "$claude_file" | head -20; then
    echo "  ✓ Contains project description"
    score=$((score + 1))
  else
    echo "  ℹ️ No project description (recommended)"
    echo "  Benefit: Better context for Claude"
    issues+=("Add project description to CLAUDE.md")
  fi
else
  echo "⊘ Skipping project-specific check (no CLAUDE.md)"
fi

echo ""
```

### Step 3: .claudeignore 검사 (4개 항목)

```bash
echo "━━━ 2. .claudeignore Configuration ━━━"
echo ""
```

#### 3.1 .claudeignore 존재

```bash
if [ -f .claudeignore ]; then
  echo "✓ .claudeignore exists"
  score=$((score + 1))
  
  lines=$(wc -l < .claudeignore)
  echo "  $lines patterns defined"
else
  echo "✗ .claudeignore NOT FOUND - CRITICAL"
  echo "  Impact: Huge token waste (node_modules, build files loaded)"
  echo "  Estimated waste: 20,000-50,000 tokens per session"
  issues+=("CREATE .claudeignore immediately")
fi

echo ""
```

#### 3.2 필수 패턴 포함

```bash
if [ -f .claudeignore ]; then
  echo "Essential patterns check:"
  
  essential=("node_modules" "dist" "build" ".env")
  missing=()
  
  for pattern in "${essential[@]}"; do
    if grep -q "^$pattern\|/$pattern" .claudeignore 2>/dev/null; then
      echo "  ✓ $pattern"
    else
      echo "  ✗ Missing: $pattern"
      missing+=("$pattern")
    fi
  done
  
  if [ ${#missing[@]} -eq 0 ]; then
    echo "  ✓ All essential patterns present"
    score=$((score + 1))
  else
    echo "  ✗ Missing ${#missing[@]} essential patterns"
    issues+=("Add to .claudeignore: ${missing[*]}")
  fi
else
  echo "⊘ Skipping pattern check (no .claudeignore)"
fi

echo ""
```

#### 3.3 프로젝트별 패턴

```bash
if [ -f .claudeignore ]; then
  echo "Project-specific patterns:"
  
  # 빌드 디렉토리 존재 체크
  build_dirs=("dist" "build" "out" ".next" "target" "pkg")
  found_builds=()
  
  for dir in "${build_dirs[@]}"; do
    if [ -d "$dir" ]; then
      found_builds+=("$dir")
      if grep -q "^$dir" .claudeignore 2>/dev/null; then
        echo "  ✓ $dir/ (exists and excluded)"
      else
        echo "  ✗ $dir/ exists but NOT excluded"
        issues+=("Add $dir/ to .claudeignore")
      fi
    fi
  done
  
  if [ ${#found_builds[@]} -eq 0 ]; then
    echo "  ℹ️ No build directories detected"
    score=$((score + 1))
  else
    # 모든 빌드 디렉토리가 제외되어 있으면 점수 부여
    all_excluded=true
    for dir in "${found_builds[@]}"; do
      if ! grep -q "^$dir" .claudeignore 2>/dev/null; then
        all_excluded=false
      fi
    done
    
    if $all_excluded; then
      echo "  ✓ All build directories excluded"
      score=$((score + 1))
    fi
  fi
else
  echo "⊘ Skipping project patterns (no .claudeignore)"
fi

echo ""
```

#### 3.4 커버리지 평가 (얼마나 잘 걸러지는지)

```bash
if [ -f .claudeignore ]; then
  echo "Coverage evaluation:"
  
  # 전체 파일 수
  total_files=$(find . -type f 2>/dev/null | wc -l)
  
  # Claude가 읽을 파일 수 (소스 코드, 문서)
  readable=$(find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.tsx" -o -name "*.jsx" -o -name "*.py" -o -name "*.go" -o -name "*.md" -o -name "*.json" \) 2>/dev/null | wc -l)
  
  # 제외된 파일 수 추정 (node_modules 등)
  if [ -d node_modules ]; then
    excluded_estimate=$(find node_modules -type f 2>/dev/null | wc -l)
  else
    excluded_estimate=0
  fi
  
  echo "  Total files: $total_files"
  echo "  Readable files: $readable"
  
  if [ $excluded_estimate -gt 0 ]; then
    echo "  Excluded: ~$excluded_estimate (estimated)"
    coverage=$((excluded_estimate * 100 / total_files))
    echo "  Coverage: ~$coverage%"
    
    if [ $coverage -gt 80 ]; then
      echo "  ✓ Excellent coverage"
      score=$((score + 1))
    elif [ $coverage -gt 50 ]; then
      echo "  ✓ Good coverage"
      score=$((score + 1))
    else
      echo "  ⚠️ Low coverage - many files not excluded"
    fi
  else
    echo "  ℹ️ Unable to estimate coverage"
  fi
else
  echo "⊘ Skipping coverage check (no .claudeignore)"
fi

echo ""
```

### Step 4: Hooks 검사 (2개 항목)

```bash
echo "━━━ 3. Hooks Configuration ━━━"
echo ""
```

#### 4.1 Settings 파일 존재

```bash
if [ -f .claude/settings.local.json ]; then
  echo "✓ .claude/settings.local.json found"
  
  # JSON 유효성 간단 체크
  if python3 -m json.tool .claude/settings.local.json >/dev/null 2>&1 || \
     node -e "JSON.parse(require('fs').readFileSync('.claude/settings.local.json'))" >/dev/null 2>&1; then
    echo "  ✓ Valid JSON format"
    score=$((score + 1))
  else
    echo "  ✗ Invalid JSON format"
    issues+=("Fix .claude/settings.local.json JSON syntax")
  fi
else
  echo "ℹ️ .claude/settings.local.json not found (optional)"
  echo "  Benefit: Automation with hooks (pre-commit, session-start, etc.)"
  score=$((score + 1))  # Not penalized as it's optional
fi

echo ""
```

#### 4.2 유용한 Hooks 설정

```bash
if [ -f .claude/settings.local.json ]; then
  echo "Configured hooks:"
  
  hooks_count=0
  
  # hooks 섹션 존재
  if grep -q '"hooks"' .claude/settings.local.json 2>/dev/null; then
    echo "  ✓ Hooks section configured"
    
    # 유용한 hooks 체크
    useful_hooks=("PreToolUse" "PostToolUse" "SessionStart")
    
    for hook in "${useful_hooks[@]}"; do
      if grep -q "\"$hook\"" .claude/settings.local.json 2>/dev/null; then
        echo "    - $hook configured"
        hooks_count=$((hooks_count + 1))
      fi
    done
    
    if [ $hooks_count -ge 1 ]; then
      echo "  ✓ At least one useful hook configured"
      score=$((score + 1))
    else
      echo "  ℹ️ No common hooks configured yet"
    fi
  else
    echo "  ℹ️ No hooks configured (optional)"
    echo "  Suggestion: Add SessionStart hook for optimization status"
  fi
else
  echo "⊘ Skipping hooks check (no settings file)"
  score=$((score + 1))  # Not penalized
fi

echo ""
```

### Step 5: 보너스 검사 (추가 권장사항)

```bash
echo "━━━ 4. Bonus: Additional Recommendations ━━━"
echo ""
```

#### 5.1 문서 구조

```bash
# docs/ 디렉토리 존재
if [ -d docs ]; then
  doc_files=$(find docs -name "*.md" 2>/dev/null | wc -l)
  echo "✓ docs/ directory exists ($doc_files files)"
  
  if [ $doc_files -ge 3 ]; then
    echo "  ✓ Well-documented project"
  else
    echo "  ℹ️ Could add more documentation"
  fi
else
  echo "ℹ️ No docs/ directory"
  echo "  Suggestion: Create docs/ for better organization"
fi

echo ""
```

#### 5.2 README 품질

```bash
if [ -f README.md ]; then
  readme_lines=$(wc -l < README.md)
  echo "✓ README.md exists ($readme_lines lines)"
  
  # README 필수 섹션 체크
  sections=("installation\|설치" "usage\|사용법" "example\|예시")
  found_sections=0
  
  for section in "${sections[@]}"; do
    if grep -qi "$section" README.md 2>/dev/null; then
      found_sections=$((found_sections + 1))
    fi
  done
  
  if [ $found_sections -ge 2 ]; then
    echo "  ✓ Contains essential sections"
  else
    echo "  ℹ️ Could add more sections (installation, usage, examples)"
  fi
else
  echo "⚠️ No README.md - highly recommended"
  issues+=("Create README.md")
fi

echo ""
```

### Step 6: 결과 요약

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Project Setup Score: $score/$max_score"
echo ""

# 등급
if [ $score -ge 9 ]; then
  grade="A (Excellent)"
  emoji="⭐"
elif [ $score -ge 7 ]; then
  grade="B (Good)"
  emoji="✓"
elif [ $score -ge 5 ]; then
  grade="C (Fair)"
  emoji="⚠️"
else
  grade="D (Needs Work)"
  emoji="⚠️"
fi

echo "$emoji Grade: $grade"
echo ""

# 이슈 요약
if [ ${#issues[@]} -gt 0 ]; then
  echo "🔧 Issues to Fix (${#issues[@]}):"
  echo ""
  
  for i in "${!issues[@]}"; do
    echo "$((i + 1)). ${issues[$i]}"
  done
  echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

### Step 7: Quick Fix 제안

```bash
if [ $score -lt 7 ]; then
  echo ""
  echo "🚀 Quick Setup Guide:"
  echo ""
  
  if [ ! -f .claudeignore ]; then
    echo "1. Create .claudeignore:"
    echo ""
    echo "cat > .claudeignore << 'EOF'"
    echo "# Dependencies"
    echo "node_modules/"
    echo "vendor/"
    echo ""
    echo "# Build outputs"
    echo "dist/"
    echo "build/"
    echo "*.min.js"
    echo ""
    echo "# Environment"
    echo ".env*"
    echo ""
    echo "# IDE"
    echo ".idea/"
    echo ".vscode/"
    echo "EOF"
    echo ""
    echo "   Impact: -20,000+ tokens per session"
    echo ""
  fi
  
  if [ ! -f .claude/CLAUDE.md ] && [ ! -f CLAUDE.md ]; then
    echo "2. Create CLAUDE.md:"
    echo ""
    echo "mkdir -p .claude"
    echo "cat > .claude/CLAUDE.md << 'EOF'"
    echo "# Project Guidelines"
    echo ""
    echo "## Token Optimization"
    echo "- Don't re-read files in same session"
    echo "- Use parallel tool calls when possible"
    echo "- Keep file sizes under 500 lines"
    echo ""
    echo "## Project Info"
    echo "[Add your project description]"
    echo "EOF"
    echo ""
    echo "   Impact: +20% efficiency"
    echo ""
  fi
  
  if [ ! -f .claude/settings.local.json ]; then
    echo "3. (Optional) Add hooks for automation:"
    echo ""
    echo "cat > .claude/settings.local.json << 'EOF'"
    echo "{"
    echo "  \"hooks\": {"
    echo "    \"SessionStart\": ["
    echo "      {"
    echo "        \"matcher\": \"\","
    echo "        \"hooks\": ["
    echo "          {"
    echo "            \"type\": \"command\","
    echo "            \"command\": \"echo 'Session started. Remember: check .claudeignore before large operations.'\""
    echo "          }"
    echo "        ]"
    echo "      }"
    echo "    ]"
    echo "  }"
    echo "}"
    echo "EOF"
    echo ""
  fi
fi
```

</PROCEDURE>

## 예상 출력

```
=== Project Setup Audit ===
Checking 10 configuration items...

━━━ 1. CLAUDE.md Configuration ━━━

✓ CLAUDE.md found at .claude/CLAUDE.md (recommended location)

CLAUDE.md size: 127 lines, 3456 bytes
  ✓ Good size (10-300 lines)

Content quality check:
  ✓ Contains token optimization guidance
  ✓ Contains coding standards/rules
  ✓ Contains git/commit guidelines
  ✓ Content quality: Good

Project-specific rules:
  ✓ Contains project description

━━━ 2. .claudeignore Configuration ━━━

✓ .claudeignore exists
  15 patterns defined

Essential patterns check:
  ✓ node_modules
  ✓ dist
  ✓ build
  ✓ .env
  ✓ All essential patterns present

Project-specific patterns:
  ✓ dist/ (exists and excluded)
  ✓ .next/ (exists and excluded)
  ✓ All build directories excluded

Coverage evaluation:
  Total files: 1,234
  Readable files: 89
  Excluded: ~1,100 (estimated)
  Coverage: ~89%
  ✓ Excellent coverage

━━━ 3. Hooks Configuration ━━━

✓ .claude/settings.local.json found
  ✓ Valid JSON format

Configured hooks:
  ✓ Hooks section configured
    - SessionStart configured
    - PreToolUse configured
  ✓ At least one useful hook configured

━━━ 4. Bonus: Additional Recommendations ━━━

✓ docs/ directory exists (12 files)
  ✓ Well-documented project

✓ README.md exists (145 lines)
  ✓ Contains essential sections

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Project Setup Score: 10/10

⭐ Grade: A (Excellent)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

All setup requirements met! Your project is optimally configured.
```

## 실패 예시 (낮은 점수)

```
=== Project Setup Audit ===
Checking 10 configuration items...

━━━ 1. CLAUDE.md Configuration ━━━

✗ CLAUDE.md NOT FOUND
  Impact: No project-specific guidance for Claude
  Benefit: +20-30% efficiency with proper rules

━━━ 2. .claudeignore Configuration ━━━

✗ .claudeignore NOT FOUND - CRITICAL
  Impact: Huge token waste (node_modules, build files loaded)
  Estimated waste: 20,000-50,000 tokens per session

━━━ 3. Hooks Configuration ━━━

ℹ️ .claude/settings.local.json not found (optional)
  Benefit: Automation with hooks (pre-commit, session-start, etc.)

⊘ Skipping hooks check (no settings file)

━━━ 4. Bonus: Additional Recommendations ━━━

ℹ️ No docs/ directory
  Suggestion: Create docs/ for better organization

✓ README.md exists (23 lines)
  ℹ️ Could add more sections (installation, usage, examples)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Project Setup Score: 2/10

⚠️ Grade: D (Needs Work)

🔧 Issues to Fix (4):

1. Create CLAUDE.md with project rules
2. CREATE .claudeignore immediately
3. Add project description to CLAUDE.md
4. Create README.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 Quick Setup Guide:

1. Create .claudeignore:

cat > .claudeignore << 'EOF'
# Dependencies
node_modules/
vendor/

# Build outputs
dist/
build/
*.min.js

# Environment
.env*

# IDE
.idea/
.vscode/
EOF

   Impact: -20,000+ tokens per session

2. Create CLAUDE.md:

mkdir -p .claude
cat > .claude/CLAUDE.md << 'EOF'
# Project Guidelines

## Token Optimization
- Don't re-read files in same session
- Use parallel tool calls when possible
- Keep file sizes under 500 lines

## Project Info
[Add your project description]
EOF

   Impact: +20% efficiency
```

## 참고

- docs/sections/03-project-setup/ - 프로젝트 설정 가이드 (섹션 3.1-3.3)
- docs/examples/hooks-examples.md - Hook 설정 예시
