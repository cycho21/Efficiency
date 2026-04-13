---
name: efficiency-audit-cache
description: 캐시 친화적 구조 검사 (파일 크기, 안정성 분리, 의존성 방향) - 캐시 히트율 개선
---

# Cache Friendliness Audit

프로젝트 구조가 Claude의 프롬프트 캐싱에 얼마나 최적화되어 있는지 평가합니다.

## 검사 영역

- **파일 크기 분포**: 작은 파일이 캐시에 유리
- **안정성/휘발성 분리**: 자주 변경되는 파일과 안정적인 파일 분리
- **CLAUDE.md 안정성**: 변경 빈도 분석
- **타입 분리**: 공유 타입 파일 별도 관리
- **프로젝트 구조**: 모듈화 수준

## 사용법

```
/efficiency-audit-cache
```

<PROCEDURE>

### Step 1: 검사 시작

```bash
echo "=== Cache Friendliness Audit ==="
echo "Analyzing project structure for caching optimization..."
echo ""

score=0
max_score=15
recommendations=()
```

### Step 2: 파일 크기 분포 분석 (5점)

```bash
echo "━━━ 1. File Size Distribution (5 pts) ━━━"
echo ""
```

#### 2.1 크기별 파일 분류

```bash
echo "Analyzing file sizes..."

# 소스 파일 크기 분석
find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.tsx" -o -name "*.jsx" -o -name "*.py" -o -name "*.go" \) \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/dist/*" \
  -not -path "*/build/*" \
  -not -path "*/vendor/*" \
  -exec wc -l {} \; 2>/dev/null | \
  awk '{
    if ($1 < 100) tiny++;
    else if ($1 < 200) small++;
    else if ($1 < 500) medium++;
    else if ($1 < 1000) large++;
    else xlarge++;
    total++;
    sum += $1;
  }
  END {
    if (total > 0) {
      printf "Total files: %d, Average: %d lines\n\n", total, int(sum/total);
      printf "  < 100 lines:   %3d (%2d%%) - Excellent for caching\n", tiny, int(tiny/total*100);
      printf "  100-200:       %3d (%2d%%) - Good for caching\n", small, int(small/total*100);
      printf "  200-500:       %3d (%2d%%) - OK\n", medium, int(medium/total*100);
      printf "  500-1000:      %3d (%2d%%) - Cache inefficient\n", large, int(large/total*100);
      printf "  1000+ lines:   %3d (%2d%%) - Cache hostile\n\n", xlarge, int(xlarge/total*100);
      
      # 점수 계산: 작은 파일 비율이 높을수록 좋음
      small_ratio = (tiny + small) / total;
      large_ratio = (large + xlarge) / total;
      
      if (small_ratio > 0.6) {
        print "  ✓ Excellent distribution (60%+ small files)";
        exit 5;
      } else if (small_ratio > 0.4) {
        print "  ✓ Good distribution (40-60% small files)";
        exit 4;
      } else if (large_ratio < 0.2) {
        print "  ⚠️ Fair distribution (< 20% large files)";
        exit 3;
      } else if (large_ratio < 0.3) {
        print "  ⚠️ Needs improvement (20-30% large files)";
        exit 2;
      } else {
        print "  ✗ Poor distribution (> 30% large files)";
        print "  Impact: Low cache hit rate, slow operations";
        exit 0;
      }
    }
  }'

size_score=$?
score=$((score + size_score))

echo ""
```

#### 2.2 대용량 파일 상세 분석

```bash
echo "Large files analysis (> 500 lines):"

large_files=$(find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.tsx" -o -name "*.jsx" -o -name "*.py" \) \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/dist/*" \
  -not -path "*/build/*" \
  -exec wc -l {} \; 2>/dev/null | \
  awk '$1 > 500 {print $1 " " $2}' | \
  sort -rn)

if [ -z "$large_files" ]; then
  echo "  ✓ No large files found"
else
  count=$(echo "$large_files" | wc -l)
  echo "  Found $count large files:"
  echo ""
  echo "$large_files" | head -10 | awk '{printf "  %5d lines: %s\n", $1, $2}'
  
  if [ $count -gt 10 ]; then
    echo "  ... and $((count - 10)) more"
  fi
  
  echo ""
  recommendations+=("Split large files into smaller modules (< 500 lines each)")
fi

echo ""
```

### Step 3: CLAUDE.md 안정성 분석 (3점)

```bash
echo "━━━ 2. CLAUDE.md Stability (3 pts) ━━━"
echo ""
```

#### 3.1 변경 빈도 분석

```bash
claude_file=""
if [ -f .claude/CLAUDE.md ]; then
  claude_file=".claude/CLAUDE.md"
elif [ -f CLAUDE.md ]; then
  claude_file="CLAUDE.md"
fi

if [ -n "$claude_file" ]; then
  # 최근 30일 변경 횟수
  if git log --since="30 days ago" --oneline -- "$claude_file" &>/dev/null; then
    changes_30d=$(git log --since="30 days ago" --oneline -- "$claude_file" 2>/dev/null | wc -l)
    
    # 최근 7일 변경 횟수
    changes_7d=$(git log --since="7 days ago" --oneline -- "$claude_file" 2>/dev/null | wc -l)
    
    echo "CLAUDE.md change frequency:"
    echo "  Last 7 days:  $changes_7d changes"
    echo "  Last 30 days: $changes_30d changes"
    echo ""
    
    if [ $changes_30d -le 2 ]; then
      echo "  ✓ Excellent stability (≤ 2 changes/month)"
      echo "  Cache impact: Minimal"
      score=$((score + 3))
    elif [ $changes_30d -le 5 ]; then
      echo "  ✓ Good stability (3-5 changes/month)"
      echo "  Cache impact: Low"
      score=$((score + 2))
    elif [ $changes_30d -le 10 ]; then
      echo "  ⚠️ Moderate stability (6-10 changes/month)"
      echo "  Cache impact: Medium (some cache misses)"
      score=$((score + 1))
      recommendations+=("Reduce CLAUDE.md changes - move volatile rules to session prompts")
    else
      echo "  ✗ Poor stability (> 10 changes/month)"
      echo "  Cache impact: High (frequent cache invalidation)"
      echo "  Estimated cost: +20-30% token usage"
      recommendations+=("CRITICAL: Stabilize CLAUDE.md - separate stable/volatile content")
    fi
  else
    echo "  ℹ️ Not in git or no history available"
    score=$((score + 1))
  fi
else
  echo "  ℹ️ No CLAUDE.md found"
  score=$((score + 2))  # Not penalized
fi

echo ""
```

#### 3.2 최근 변경 내용 분석

```bash
if [ -n "$claude_file" ] && git log -1 --oneline -- "$claude_file" &>/dev/null; then
  echo "Recent changes:"
  
  last_change=$(git log -1 --format="%ar" -- "$claude_file" 2>/dev/null)
  echo "  Last modified: $last_change"
  
  # 마지막 변경 내용 크기
  last_diff=$(git diff HEAD~1 HEAD -- "$claude_file" 2>/dev/null | wc -l)
  
  if [ $last_diff -gt 0 ]; then
    echo "  Last change size: $last_diff lines diff"
    
    if [ $last_diff -gt 50 ]; then
      echo "  ⚠️ Large change - causes full cache invalidation"
    fi
  fi
fi

echo ""
```

### Step 4: 안정성/휘발성 분리 (3점)

```bash
echo "━━━ 3. Stable/Volatile Separation (3 pts) ━━━"
echo ""
```

#### 4.1 파일 변경 빈도 분석

```bash
if git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Analyzing file change patterns (last 30 days)..."
  
  # 자주 변경되는 파일 (5회 이상)
  volatile=$(git log --since="30 days ago" --name-only --pretty=format: 2>/dev/null | \
    grep -E '\.(ts|js|tsx|jsx|py|go)$' | \
    sort | uniq -c | sort -rn | \
    awk '$1 >= 5 {print $1 " changes: " $2}')
  
  # 안정적인 파일 (변경 없음)
  all_files=$(find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" \) \
    -not -path "*/node_modules/*" \
    -not -path "*/.git/*" \
    -not -path "*/dist/*" \
    -not -path "*/build/*" 2>/dev/null | wc -l)
  
  if [ -n "$volatile" ]; then
    volatile_count=$(echo "$volatile" | wc -l)
    
    echo "  Volatile files (5+ changes): $volatile_count"
    echo "$volatile" | head -5 | sed 's/^/    /'
    
    if [ $volatile_count -gt 5 ]; then
      echo "    ... and $((volatile_count - 5)) more"
    fi
    echo ""
    
    # 분리도 평가
    volatile_ratio=$(echo "scale=2; $volatile_count / $all_files" | bc)
    
    if (( $(echo "$volatile_ratio < 0.1" | bc -l) )); then
      echo "  ✓ Excellent separation (< 10% volatile)"
      echo "  Most files are stable - good for caching"
      score=$((score + 3))
    elif (( $(echo "$volatile_ratio < 0.25" | bc -l) )); then
      echo "  ✓ Good separation (10-25% volatile)"
      score=$((score + 2))
    elif (( $(echo "$volatile_ratio < 0.4" | bc -l) )); then
      echo "  ⚠️ Fair separation (25-40% volatile)"
      score=$((score + 1))
      recommendations+=("Consider separating frequently-changed code into dedicated modules")
    else
      echo "  ✗ Poor separation (> 40% volatile)"
      echo "  Impact: Low cache effectiveness"
      recommendations+=("REFACTOR: Separate stable interfaces from volatile implementations")
    fi
  else
    echo "  ℹ️ No recent changes or insufficient history"
    score=$((score + 2))
  fi
else
  echo "  ℹ️ Not a git repository"
  score=$((score + 2))
fi

echo ""
```

### Step 5: 타입 분리 (2점)

```bash
echo "━━━ 4. Type Separation (2 pts) ━━━"
echo ""
```

#### 5.1 TypeScript/Python 타입 분리

```bash
# TypeScript 프로젝트 체크
if find . -name "*.ts" -not -path "*/node_modules/*" | head -1 >/dev/null 2>&1; then
  echo "TypeScript project detected"
  
  # 타입 정의 파일 찾기
  type_files=$(find . \( -name "types.ts" -o -name "*.types.ts" -o -name "*.d.ts" -o -name "interfaces.ts" \) \
    -not -path "*/node_modules/*" \
    -not -path "*/.git/*" 2>/dev/null)
  
  type_count=$(echo "$type_files" | grep -v '^$' | wc -l)
  
  if [ $type_count -gt 0 ]; then
    echo "  ✓ Found $type_count type definition files:"
    echo "$type_files" | sed 's/^/    /' | head -5
    echo ""
    echo "  ✓ Good type separation"
    score=$((score + 2))
  else
    echo "  ⚠️ No dedicated type files found"
    echo "  Impact: Types mixed with implementation (cache inefficient)"
    recommendations+=("Extract shared types to separate files (types.ts, *.d.ts)")
  fi
fi

# Python 프로젝트 체크
if find . -name "*.py" -not -path "*/node_modules/*" -not -path "*/.git/*" | head -1 >/dev/null 2>&1; then
  echo "Python project detected"
  
  # typing 사용 체크
  has_typing=$(find . -name "*.py" \
    -not -path "*/.git/*" \
    -exec grep -l "from typing import\|import typing" {} \; 2>/dev/null | wc -l)
  
  if [ $has_typing -gt 0 ]; then
    echo "  ✓ Type hints used in $has_typing files"
    score=$((score + 1))
    
    # stub files (.pyi) 체크
    stub_files=$(find . -name "*.pyi" 2>/dev/null | wc -l)
    if [ $stub_files -gt 0 ]; then
      echo "  ✓ Found $stub_files stub files (.pyi)"
      score=$((score + 1))
    else
      echo "  ℹ️ No stub files (consider for large projects)"
    fi
  else
    echo "  ℹ️ No type hints detected (optional in Python)"
    score=$((score + 1))
  fi
fi

echo ""
```

### Step 6: 프로젝트 구조 (2점)

```bash
echo "━━━ 5. Project Structure (2 pts) ━━━"
echo ""
```

#### 6.1 디렉토리 구조 분석

```bash
echo "Directory organization:"

# 주요 디렉토리 깊이
max_depth=$(find . -type d \
  -not -path "*/.git/*" \
  -not -path "*/node_modules/*" \
  -not -path "*/dist/*" \
  -not -path "*/build/*" 2>/dev/null | \
  awk -F/ '{print NF}' | sort -rn | head -1)

echo "  Maximum directory depth: $max_depth"

if [ $max_depth -le 5 ]; then
  echo "  ✓ Shallow structure (≤ 5 levels) - easy to cache"
  score=$((score + 1))
elif [ $max_depth -le 8 ]; then
  echo "  ⚠️ Moderate depth (6-8 levels)"
else
  echo "  ✗ Deep nesting (> 8 levels) - cache inefficient"
  recommendations+=("Flatten directory structure to reduce nesting")
fi

# 모듈화 수준 (src/ 또는 lib/ 등)
if [ -d src ] || [ -d lib ] || [ -d pkg ]; then
  echo "  ✓ Modular structure detected"
  score=$((score + 1))
else
  echo "  ℹ️ Flat structure (consider organizing into modules)"
fi

echo ""
```

#### 6.2 파일 응집도 분석

```bash
echo "Module cohesion:"

# 각 디렉토리의 파일 수 분포
dir_files=$(find . -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" \) \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/dist/*" \
  -not -path "*/build/*" 2>/dev/null | \
  sed 's|/[^/]*$||' | \
  sort | uniq -c | sort -rn | head -10)

echo "$dir_files" | awk '{
  if ($1 > 20) 
    printf "  ⚠️ %s: %d files (consider splitting)\n", $2, $1;
  else if ($1 > 10)
    printf "  ℹ️ %s: %d files\n", $2, $1;
  else
    printf "  ✓ %s: %d files\n", $2, $1;
}'

echo ""
```

### Step 7: 종합 평가

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Cache Friendliness Score: $score/$max_score"
echo ""

# 등급
if [ $score -ge 13 ]; then
  grade="A (Excellent)"
  emoji="🚀"
  cache_estimate="75-90%"
elif [ $score -ge 10 ]; then
  grade="B (Good)"
  emoji="✓"
  cache_estimate="60-75%"
elif [ $score -ge 7 ]; then
  grade="C (Fair)"
  emoji="⚠️"
  cache_estimate="45-60%"
elif [ $score -ge 4 ]; then
  grade="D (Needs Work)"
  emoji="⚠️"
  cache_estimate="30-45%"
else
  grade="F (Critical)"
  emoji="🔴"
  cache_estimate="< 30%"
fi

echo "$emoji Grade: $grade"
echo ""
echo "📈 Estimated Cache Hit Rate: $cache_estimate"
echo ""

# 개선 제안
if [ ${#recommendations[@]} -gt 0 ]; then
  echo "🔧 Recommendations (${#recommendations[@]}):"
  echo ""
  
  for i in "${!recommendations[@]}"; do
    priority="Medium"
    rec="${recommendations[$i]}"
    
    if [[ "$rec" =~ CRITICAL ]]; then
      priority="🔴 HIGH"
    elif [[ "$rec" =~ Split\ large\ files ]]; then
      priority="🟡 HIGH"
    fi
    
    echo "  $((i + 1)). [$priority] $rec"
  done
  echo ""
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

### Step 8: 개선 임팩트 추정

```bash
if [ $score -lt 10 ]; then
  echo ""
  echo "💡 Improvement Impact:"
  echo ""
  
  current_estimate=$(echo "scale=0; 30 + ($score * 4)" | bc)
  potential_estimate=$((current_estimate + 25))
  
  echo "  Current cache hit rate: ~$current_estimate%"
  echo "  After improvements:     ~$potential_estimate%"
  echo ""
  
  # 토큰 절감 추정
  token_saving=$(echo "scale=0; ($potential_estimate - $current_estimate) * 500" | bc)
  
  echo "  Estimated token savings:"
  echo "    Per session: ~$token_saving tokens"
  echo "    Per month (50 sessions): ~$((token_saving * 50)) tokens"
  echo ""
  
  # 우선순위별 액션 플랜
  echo "📋 Action Plan (Priority Order):"
  echo ""
  
  if [ $score -lt 7 ]; then
    echo "  Week 1: Critical fixes"
    echo "    - Stabilize CLAUDE.md (reduce change frequency)"
    echo "    - Split files > 1000 lines"
    echo ""
    echo "  Week 2-3: Structure improvements"
    echo "    - Separate stable/volatile code"
    echo "    - Extract shared types"
    echo ""
    echo "  Week 4: Fine-tuning"
    echo "    - Optimize module boundaries"
    echo "    - Review directory structure"
  else
    echo "  This week:"
    echo "    - Address top 3 recommendations"
    echo ""
    echo "  This month:"
    echo "    - Gradually refactor remaining issues"
  fi
  echo ""
fi
```

</PROCEDURE>

## 예상 출력

```
=== Cache Friendliness Audit ===
Analyzing project structure for caching optimization...

━━━ 1. File Size Distribution (5 pts) ━━━

Analyzing file sizes...
Total files: 89, Average: 245 lines

  < 100 lines:    25 (28%) - Excellent for caching
  100-200:        32 (36%) - Good for caching
  200-500:        24 (27%) - OK
  500-1000:        6 ( 7%) - Cache inefficient
  1000+ lines:     2 ( 2%) - Cache hostile

  ✓ Good distribution (40-60% small files)

Large files analysis (> 500 lines):
  Found 8 large files:

   1234 lines: src/utils/helpers.ts
    956 lines: src/services/api.ts
    745 lines: src/components/Dashboard.tsx
    ... and 5 more

━━━ 2. CLAUDE.md Stability (3 pts) ━━━

CLAUDE.md change frequency:
  Last 7 days:  0 changes
  Last 30 days: 3 changes

  ✓ Good stability (3-5 changes/month)
  Cache impact: Low

Recent changes:
  Last modified: 2 weeks ago
  Last change size: 12 lines diff

━━━ 3. Stable/Volatile Separation (3 pts) ━━━

Analyzing file change patterns (last 30 days)...
  Volatile files (5+ changes): 8
    15 changes: src/api/endpoints.ts
    12 changes: src/features/auth/login.ts
     9 changes: src/components/Header.tsx
     7 changes: src/utils/validation.ts
     6 changes: src/hooks/useAuth.ts

  ✓ Excellent separation (< 10% volatile)
  Most files are stable - good for caching

━━━ 4. Type Separation (2 pts) ━━━

TypeScript project detected
  ✓ Found 6 type definition files:
    src/types/user.types.ts
    src/types/api.types.ts
    src/types/common.d.ts
    ... and 3 more

  ✓ Good type separation

━━━ 5. Project Structure (2 pts) ━━━

Directory organization:
  Maximum directory depth: 4
  ✓ Shallow structure (≤ 5 levels) - easy to cache
  ✓ Modular structure detected

Module cohesion:
  ✓ src/components: 18 files
  ✓ src/utils: 12 files
  ✓ src/services: 8 files
  ✓ src/hooks: 6 files

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Cache Friendliness Score: 12/15

✓ Grade: B (Good)

📈 Estimated Cache Hit Rate: 60-75%

🔧 Recommendations (1):

  1. [🟡 HIGH] Split large files into smaller modules (< 500 lines each)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 Improvement Impact:

  Current cache hit rate: ~58%
  After improvements:     ~83%

  Estimated token savings:
    Per session: ~12,500 tokens
    Per month (50 sessions): ~625,000 tokens

📋 Action Plan (Priority Order):

  This week:
    - Address top 3 recommendations

  This month:
    - Gradually refactor remaining issues
```

## 참고

- docs/claude-efficiency-guide.md - 섹션 8.4: 캐시 친화적 프로젝트 구조
- docs/claude-efficiency-guide.md - 섹션 7.2: 캐시 히트율 분석 및 개선
