---
name: efficiency-audit-tokens
description: 토큰 최적화 21개 체크리스트 기반 자동 검사 (파일 크기, .claudeignore, 불필요한 파일 등)
---

# Token Optimization Audit

프로젝트의 토큰 최적화 상태를 21개 체크리스트 기준으로 검사합니다.

## 검사 항목 (21개)

- **Project Setup** (6개): .claudeignore, 큰 파일, 빌드 산출물, 의존성, IDE 파일
- **Session Management** (4개): 파일 크기, 중복 가능성, 압축 가이드
- **Caching** (4개): CLAUDE.md 안정성, 공유 타입
- **File Management** (3개): 대용량 파일, 로그 파일
- **Prompting** (4개): 템플릿, 워크플로우 문서

## 사용법

```
/efficiency-audit-tokens
```

<PROCEDURE>

### Step 1: 프로젝트 루트 확인

```bash
git rev-parse --show-toplevel 2>/dev/null || pwd
```

Git 저장소가 아니면 현재 디렉토리 사용.

### Step 2: 검사 시작 메시지

```
=== Token Optimization Audit ===
Checking 21 items...
```

### Step 3: Project Setup 검사 (6개 항목)

#### 3.1 .claudeignore 존재 및 기본 패턴

```bash
echo "━━━ 1. Project Setup (6 items) ━━━"
echo ""

# .claudeignore 존재
if [ -f .claudeignore ]; then
  echo "✓ .claudeignore exists"
  score=$((score + 1))
  
  # 필수 패턴 체크
  patterns=("node_modules" "dist" "build" "*.log" ".env")
  missing=()
  
  for pattern in "${patterns[@]}"; do
    if grep -q "$pattern" .claudeignore 2>/dev/null; then
      echo "  ✓ Excludes $pattern"
    else
      echo "  ✗ Missing pattern: $pattern"
      missing+=("$pattern")
    fi
  done
  
  if [ ${#missing[@]} -eq 0 ]; then
    echo "  ✓ All essential patterns present"
    score=$((score + 1))
  else
    echo "  ⚠️ Missing ${#missing[@]} essential patterns"
  fi
else
  echo "✗ .claudeignore NOT FOUND - CRITICAL"
  echo "  Impact: 20,000+ tokens wasted on node_modules, build files"
  echo "  Fix: Create .claudeignore with basic patterns"
  critical_issues=$((critical_issues + 1))
fi

echo ""
```

#### 3.2 큰 파일 제외 설정

```bash
# node_modules 제외 확인
if [ -d node_modules ] && ! grep -q "node_modules" .claudeignore 2>/dev/null; then
  echo "✗ node_modules/ exists but not excluded"
  echo "  Impact: 50,000+ tokens wasted"
  critical_issues=$((critical_issues + 1))
else
  echo "✓ node_modules properly excluded (or doesn't exist)"
  score=$((score + 1))
fi

echo ""
```

#### 3.3 빌드 산출물 제외

```bash
# 빌드 디렉토리 체크
build_dirs=("dist" "build" "out" ".next" "target")
excluded_count=0
exists_count=0

for dir in "${build_dirs[@]}"; do
  if [ -d "$dir" ]; then
    exists_count=$((exists_count + 1))
    if grep -q "^$dir" .claudeignore 2>/dev/null; then
      echo "✓ $dir/ excluded"
      excluded_count=$((excluded_count + 1))
    else
      echo "✗ $dir/ exists but not excluded"
      echo "  Impact: Medium (5,000-10,000 tokens)"
    fi
  fi
done

if [ $exists_count -eq 0 ]; then
  echo "ℹ️ No build directories found"
  score=$((score + 1))
elif [ $excluded_count -eq $exists_count ]; then
  echo "✓ All build directories excluded"
  score=$((score + 1))
fi

echo ""
```

#### 3.4 로그 파일 제외

```bash
# 로그 파일 존재 확인
log_count=$(find . -name "*.log" -not -path "*/.git/*" -not -path "*/node_modules/*" 2>/dev/null | wc -l)

if [ "$log_count" -gt 0 ]; then
  if grep -q "\.log\|\*\.log\|logs/" .claudeignore 2>/dev/null; then
    echo "✓ Log files excluded ($log_count found)"
    score=$((score + 1))
  else
    echo "✗ Found $log_count log files not excluded"
    echo "  Impact: Low-Medium (100-1,000 tokens per file)"
  fi
else
  echo "✓ No log files found"
  score=$((score + 1))
fi

echo ""
```

#### 3.5 IDE 설정 파일 제외

```bash
# IDE 디렉토리 체크
ide_dirs=(".idea" ".vscode" ".vs")
ide_excluded=0
ide_exists=0

for dir in "${ide_dirs[@]}"; do
  if [ -d "$dir" ]; then
    ide_exists=$((ide_exists + 1))
    if grep -q "$dir" .claudeignore 2>/dev/null; then
      ide_excluded=$((ide_excluded + 1))
    fi
  fi
done

if [ $ide_exists -eq 0 ]; then
  echo "ℹ️ No IDE directories found"
  score=$((score + 1))
elif [ $ide_excluded -eq $ide_exists ]; then
  echo "✓ IDE directories excluded"
  score=$((score + 1))
else
  echo "⚠️ IDE directories exist but not all excluded"
  echo "  Impact: Low (500-2,000 tokens)"
fi

echo ""
```

### Step 4: Session Management 검사 (4개 항목)

```bash
echo "━━━ 2. Session Management (4 items) ━━━"
echo ""
```

#### 4.1 평균 파일 크기 적정성

```bash
# 소스 파일 평균 크기 계산
echo "Analyzing file sizes..."

find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.tsx" -o -name "*.jsx" -o -name "*.py" -o -name "*.go" -o -name "*.java" \) \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/dist/*" \
  -not -path "*/build/*" \
  -not -path "*/vendor/*" \
  -exec wc -l {} \; 2>/dev/null | \
  awk '{sum+=$1; count++; if ($1>1000) xlarge++} 
  END {
    if (count > 0) {
      avg = sum/count;
      printf "  Files: %d, Average: %d lines\n", count, int(avg);
      
      if (avg < 200) {
        print "  ✓ Excellent average (< 200 lines)";
        exit 2;
      } else if (avg < 350) {
        print "  ✓ Good average (200-350 lines)";
        exit 1;
      } else if (avg < 500) {
        print "  ⚠️ OK average (350-500 lines)";
        exit 0;
      } else {
        print "  ✗ High average (> 500 lines) - consider splitting";
        exit 0;
      }
    }
  }'

case $? in
  2) score=$((score + 1)) ;;
  1) score=$((score + 1)) ;;
  0) echo "  Impact: Medium (slower read operations)" ;;
esac

echo ""
```

#### 4.2 대용량 파일 검사 (1000+ lines)

```bash
echo "Checking large files (1000+ lines)..."

large_files=$(find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.tsx" -o -name "*.jsx" -o -name "*.py" \) \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/dist/*" \
  -not -path "*/build/*" \
  -exec wc -l {} \; 2>/dev/null | \
  awk '$1 > 1000 {print}')

if [ -z "$large_files" ]; then
  echo "✓ No files over 1000 lines"
  score=$((score + 1))
else
  file_count=$(echo "$large_files" | wc -l)
  echo "✗ Found $file_count files over 1000 lines:"
  echo "$large_files" | awk '{print "  - " $2 " (" $1 " lines)"}' | head -5
  
  if [ $file_count -gt 5 ]; then
    echo "  ... and $((file_count - 5)) more"
  fi
  
  echo "  Impact: High (3,000+ tokens per read)"
  critical_issues=$((critical_issues + 1))
fi

echo ""
```

#### 4.3 중복 읽기 가능성 (같은 이름 파일)

```bash
echo "Checking for duplicate file names..."

duplicates=$(find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" \) \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/dist/*" \
  -not -path "*/build/*" \
  -printf "%f\n" 2>/dev/null | \
  sort | uniq -d)

if [ -z "$duplicates" ]; then
  echo "✓ No duplicate file names"
  score=$((score + 1))
else
  dup_count=$(echo "$duplicates" | wc -l)
  echo "⚠️ Found $dup_count duplicate file names:"
  echo "$duplicates" | head -3 | sed 's/^/  - /'
  echo "  Impact: Medium (may cause re-reading confusion)"
fi

echo ""
```

#### 4.4 압축/저장 가이드 존재

```bash
# progress.md 또는 저장 템플릿 존재 확인
if [ -f .claude/templates/progress.md ] || [ -f docs/templates/progress.md ] || grep -q "progress\.md\|state\.md" .claude/CLAUDE.md 2>/dev/null; then
  echo "✓ Session state template exists"
  score=$((score + 1))
else
  echo "ℹ️ No session state template (optional but recommended)"
fi

echo ""
```

### Step 5: Caching 검사 (4개 항목)

```bash
echo "━━━ 3. Caching Optimization (4 items) ━━━"
echo ""
```

#### 5.1 CLAUDE.md 크기 적정성

```bash
if [ -f .claude/CLAUDE.md ] || [ -f CLAUDE.md ]; then
  claude_file=".claude/CLAUDE.md"
  [ -f CLAUDE.md ] && claude_file="CLAUDE.md"
  
  lines=$(wc -l < "$claude_file")
  echo "CLAUDE.md: $lines lines"
  
  if [ "$lines" -lt 20 ]; then
    echo "  ⚠️ Too small (< 20 lines) - consider adding rules"
  elif [ "$lines" -gt 500 ]; then
    echo "  ✗ Too large (> 500 lines) - causes cache misses"
    echo "  Impact: High (frequent cache invalidation)"
  else
    echo "  ✓ Good size (20-500 lines)"
    score=$((score + 1))
  fi
else
  echo "ℹ️ CLAUDE.md not found (optional)"
fi

echo ""
```

#### 5.2 CLAUDE.md 안정성 (변경 빈도)

```bash
if [ -f .claude/CLAUDE.md ] || [ -f CLAUDE.md ]; then
  claude_file=".claude/CLAUDE.md"
  [ -f CLAUDE.md ] && claude_file="CLAUDE.md"
  
  if git log --since="30 days ago" --oneline -- "$claude_file" &>/dev/null; then
    changes=$(git log --since="30 days ago" --oneline -- "$claude_file" 2>/dev/null | wc -l)
    echo "CLAUDE.md changes (last 30 days): $changes"
    
    if [ "$changes" -le 4 ]; then
      echo "  ✓ Stable (≤ 4 changes/month)"
      score=$((score + 1))
    elif [ "$changes" -le 10 ]; then
      echo "  ⚠️ Moderate (5-10 changes/month)"
      echo "  Impact: Medium (some cache misses)"
    else
      echo "  ✗ Unstable (> 10 changes/month)"
      echo "  Impact: High (frequent cache invalidation)"
      echo "  Fix: Move volatile rules to session prompts"
    fi
  else
    echo "  ℹ️ Not in git or no recent history"
  fi
else
  echo "ℹ️ CLAUDE.md not found"
fi

echo ""
```

#### 5.3 공유 타입 파일 분리

```bash
# TypeScript types
if find . -name "*.ts" -not -path "*/node_modules/*" | head -1 >/dev/null 2>&1; then
  type_files=$(find . -name "types.ts" -o -name "*.types.ts" -o -name "*.d.ts" | \
    grep -v node_modules | wc -l)
  
  if [ "$type_files" -gt 0 ]; then
    echo "✓ Found $type_files TypeScript type files"
    score=$((score + 1))
  else
    echo "ℹ️ No dedicated type files (consider separating)"
  fi
fi

# Python typing
if find . -name "*.py" -not -path "*/node_modules/*" -not -path "*/.git/*" | head -1 >/dev/null 2>&1; then
  if find . -name "*.py" -exec grep -l "from typing import\|import typing" {} \; | head -1 >/dev/null 2>&1; then
    echo "✓ Python type hints in use"
    score=$((score + 1))
  fi
fi

echo ""
```

### Step 6: File Management 검사 (3개 항목)

```bash
echo "━━━ 4. File Management (3 items) ━━━"
echo ""
```

#### 6.1 소스 파일 크기 분포

```bash
echo "File size distribution:"

find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.tsx" -o -name "*.jsx" -o -name "*.py" \) \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/dist/*" \
  -not -path "*/build/*" \
  -exec wc -l {} \; 2>/dev/null | \
  awk '{
    if ($1 < 200) small++;
    else if ($1 < 500) medium++;
    else if ($1 < 1000) large++;
    else xlarge++;
    total++;
  }
  END {
    if (total > 0) {
      printf "  0-200:   %3d files (%2d%%)\n", small, int(small/total*100);
      printf "  200-500: %3d files (%2d%%)\n", medium, int(medium/total*100);
      printf "  500-1000:%3d files (%2d%%)\n", large, int(large/total*100);
      printf "  1000+:   %3d files (%2d%%)\n", xlarge, int(xlarge/total*100);
      
      if (xlarge/total > 0.15) {
        print "  ✗ Too many large files (> 15%)";
        exit 0;
      } else if (xlarge/total > 0.05) {
        print "  ⚠️ Some large files (5-15%)";
        exit 1;
      } else {
        print "  ✓ Good distribution (< 5% large files)";
        exit 2;
      }
    }
  }'

case $? in
  2) score=$((score + 1)) ;;
  1) ;;
  0) echo "  Impact: High (slow reads, high token usage)" ;;
esac

echo ""
```

#### 6.2 환경 파일 제외

```bash
# .env 파일 체크
env_files=$(find . -name ".env*" -not -path "*/.git/*" -not -path "*/node_modules/*" 2>/dev/null | wc -l)

if [ "$env_files" -gt 0 ]; then
  if grep -q "\.env" .claudeignore 2>/dev/null; then
    echo "✓ .env files excluded ($env_files found)"
    score=$((score + 1))
  else
    echo "✗ Found $env_files .env files NOT excluded"
    echo "  Impact: CRITICAL (security risk + token waste)"
    critical_issues=$((critical_issues + 1))
  fi
else
  echo "✓ No .env files found"
  score=$((score + 1))
fi

echo ""
```

### Step 7: Prompting 검사 (4개 항목)

```bash
echo "━━━ 5. Prompting Best Practices (4 items) ━━━"
echo ""
```

#### 7.1 템플릿 파일 존재

```bash
# 프롬프트 템플릿 존재 확인
template_locations=(
  ".claude/templates"
  "docs/templates"
  "docs/prompts"
  ".github/templates"
)

found_templates=false
for loc in "${template_locations[@]}"; do
  if [ -d "$loc" ] && [ "$(find "$loc" -type f | wc -l)" -gt 0 ]; then
    template_count=$(find "$loc" -type f | wc -l)
    echo "✓ Found $template_count templates in $loc/"
    score=$((score + 1))
    found_templates=true
    break
  fi
done

if ! $found_templates; then
  echo "ℹ️ No template directory (consider creating for reusable prompts)"
fi

echo ""
```

#### 7.2 워크플로우 문서화

```bash
# 워크플로우 문서 존재
workflow_docs=$(find . -maxdepth 3 -name "*workflow*.md" -o -name "CONTRIBUTING.md" -o -name "*process*.md" 2>/dev/null | wc -l)

if [ "$workflow_docs" -gt 0 ]; then
  echo "✓ Found $workflow_docs workflow/process documents"
  score=$((score + 1))
else
  echo "ℹ️ No workflow documentation (recommended for teams)"
fi

echo ""
```

#### 7.3 README 품질

```bash
if [ -f README.md ]; then
  readme_lines=$(wc -l < README.md)
  
  if [ "$readme_lines" -lt 20 ]; then
    echo "⚠️ README.md too brief (< 20 lines)"
  else
    echo "✓ README.md exists ($readme_lines lines)"
    score=$((score + 1))
  fi
else
  echo "⚠️ No README.md found"
fi

echo ""
```

#### 7.4 문서화 수준

```bash
doc_count=$(find . -name "*.md" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | wc -l)

if [ "$doc_count" -ge 5 ]; then
  echo "✓ Good documentation ($doc_count markdown files)"
  score=$((score + 1))
elif [ "$doc_count" -ge 2 ]; then
  echo "⚠️ Minimal documentation ($doc_count markdown files)"
else
  echo "✗ Poor documentation ($doc_count markdown files)"
fi

echo ""
```

### Step 8: 결과 요약

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Token Optimization Score: $score/21"
echo ""

# 등급 계산
if [ $score -ge 19 ]; then
  grade="A+ (Excellent)"
  emoji="🏆"
elif [ $score -ge 17 ]; then
  grade="A (Very Good)"
  emoji="⭐"
elif [ $score -ge 14 ]; then
  grade="B (Good)"
  emoji="✓"
elif [ $score -ge 10 ]; then
  grade="C (Fair)"
  emoji="⚠️"
elif [ $score -ge 7 ]; then
  grade="D (Needs Work)"
  emoji="⚠️"
else
  grade="F (Critical)"
  emoji="🔴"
fi

echo "$emoji Grade: $grade"
echo ""

if [ $critical_issues -gt 0 ]; then
  echo "🔴 Critical Issues: $critical_issues"
  echo "   → Fix immediately (high token waste or security risk)"
  echo ""
fi

# 개선 잠재력 계산
missing=$((21 - score))
if [ $missing -gt 0 ]; then
  # 간단한 추정: 각 항목당 평균 2,000 토큰 절감 가능
  potential=$((missing * 2000))
  echo "📈 Improvement Potential:"
  echo "   $missing items to fix → ~$potential tokens saved per session"
  echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

### Step 9: 상세 제안 (점수가 낮을 경우)

점수가 15 미만인 경우 구체적인 개선 제안 출력:

```bash
if [ $score -lt 15 ]; then
  echo ""
  echo "🔧 Quick Fixes (High Impact):"
  echo ""
  
  if [ ! -f .claudeignore ]; then
    echo "1. Create .claudeignore:"
    echo "   echo 'node_modules/' > .claudeignore"
    echo "   echo 'dist/' >> .claudeignore"
    echo "   Impact: -20,000 tokens per session"
    echo ""
  fi
  
  # 대용량 파일이 많으면
  large_count=$(find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" \) \
    -not -path "*/node_modules/*" -not -path "*/.git/*" \
    -exec wc -l {} \; 2>/dev/null | awk '$1 > 1000' | wc -l)
  
  if [ "$large_count" -gt 3 ]; then
    echo "2. Split large files ($large_count files > 1000 lines)"
    echo "   Target: < 500 lines per file"
    echo "   Impact: -5,000 tokens per session"
    echo ""
  fi
  
  if [ ! -f .claude/CLAUDE.md ] && [ ! -f CLAUDE.md ]; then
    echo "3. Create CLAUDE.md with token optimization rules"
    echo "   See: docs/claude-efficiency-guide.md"
    echo "   Impact: Better cache hit rate"
    echo ""
  fi
fi
```

</PROCEDURE>

## 예상 출력

```
=== Token Optimization Audit ===
Checking 21 items...

━━━ 1. Project Setup (6 items) ━━━

✓ .claudeignore exists
  ✓ Excludes node_modules
  ✓ Excludes dist
  ✓ Excludes build
  ✗ Missing pattern: *.log
  ✗ Missing pattern: .env
  ⚠️ Missing 2 essential patterns

✓ node_modules properly excluded (or doesn't exist)

✓ dist/ excluded

✗ Found 5 log files not excluded
  Impact: Low-Medium (100-1,000 tokens per file)

⚠️ IDE directories exist but not all excluded
  Impact: Low (500-2,000 tokens)

━━━ 2. Session Management (4 items) ━━━

Analyzing file sizes...
  Files: 45, Average: 287 lines
  ✓ Good average (200-350 lines)

Checking large files (1000+ lines)...
✗ Found 2 files over 1000 lines:
  - src/utils/helpers.ts (1,234 lines)
  - src/services/api.ts (1,089 lines)
  Impact: High (3,000+ tokens per read)

✓ No duplicate file names

ℹ️ No session state template (optional but recommended)

━━━ 3. Caching Optimization (4 items) ━━━

CLAUDE.md: 156 lines
  ✓ Good size (20-500 lines)

CLAUDE.md changes (last 30 days): 3
  ✓ Stable (≤ 4 changes/month)

✓ Found 4 TypeScript type files

━━━ 4. File Management (3 items) ━━━

File size distribution:
  0-200:    28 files (62%)
  200-500:  13 files (29%)
  500-1000:  2 files ( 4%)
  1000+:     2 files ( 4%)
  ✓ Good distribution (< 5% large files)

✗ Found 2 .env files NOT excluded
  Impact: CRITICAL (security risk + token waste)

━━━ 5. Prompting Best Practices (4 items) ━━━

ℹ️ No template directory (consider creating for reusable prompts)

✓ Found 2 workflow/process documents

✓ README.md exists (89 lines)

⚠️ Minimal documentation (3 markdown files)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Token Optimization Score: 14/21

✓ Grade: B (Good)

🔴 Critical Issues: 2
   → Fix immediately (high token waste or security risk)

📈 Improvement Potential:
   7 items to fix → ~14,000 tokens saved per session

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔧 Quick Fixes (High Impact):

1. Add missing patterns to .claudeignore:
   echo '*.log' >> .claudeignore
   echo '.env*' >> .claudeignore
   Impact: -2,000 tokens + security fix

2. Split large files (2 files > 1000 lines)
   Target: < 500 lines per file
   Impact: -5,000 tokens per session
```

## 참고

- docs/checklists/token-optimization.md - 21개 체크리스트 상세
- docs/claude-efficiency-guide.md - 섹션 2: 토큰 최적화 전략
