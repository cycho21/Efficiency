---
name: efficiency-audit
description: 프로젝트의 Claude 사용 효율성 종합 검사 - 토큰 최적화, 설정, 캐시 (3개 영역, 46개 항목)
---

# Project Efficiency Audit

현재 프로젝트가 Claude를 얼마나 효율적으로 사용하도록 설정되어 있는지 종합 검사합니다.

## 검사 영역 (총 46개 항목)

1. **Token Optimization** (21개 항목)
   - 파일 크기, .claudeignore, 불필요한 파일 제외
   - `/efficiency-audit-tokens` 로 개별 실행 가능

2. **Project Setup** (10개 항목)
   - CLAUDE.md, .claudeignore, hooks 설정
   - `/efficiency-audit-setup` 로 개별 실행 가능

3. **Cache Friendliness** (15개 항목)
   - 파일 분포, 안정성 분리, 구조 최적화
   - `/efficiency-audit-cache` 로 개별 실행 가능

## 사용법

### 전체 검사 (권장)
```
/efficiency-audit
```
→ 모든 영역 검사 + 종합 리포트 + 개선 제안

### 특정 영역만 검사
```
/efficiency-audit-tokens     # 토큰 최적화만 (빠름: ~10초)
/efficiency-audit-setup      # 프로젝트 설정만 (빠름: ~5초)
/efficiency-audit-cache      # 캐시 친화성만 (중간: ~15초)
```

## 전체 검사 프로세스

<PROCEDURE>

### Step 1: 검사 시작

사용자에게 검사 시작 알림:

```
╔═══════════════════════════════════════════════╗
║   Project Efficiency Audit - Full Scan       ║
╚═══════════════════════════════════════════════╝

Scanning 46 efficiency items across 3 categories...

This will take ~30 seconds. Please wait...
```

### Step 2: Token Optimization 검사

efficiency-audit-tokens 스킬 실행:

```
Invoking /efficiency-audit-tokens...
```

스킬 호출 후 결과를 메모리에 저장 (점수와 등급 추출):
- Token score: X/21
- Token grade: A/B/C/D/F

### Step 3: Project Setup 검사

efficiency-audit-setup 스킬 실행:

```
Invoking /efficiency-audit-setup...
```

결과 저장:
- Setup score: X/10
- Setup grade: A/B/C/D/F

### Step 4: Cache Friendliness 검사

efficiency-audit-cache 스킬 실행:

```
Invoking /efficiency-audit-cache...
```

결과 저장:
- Cache score: X/15
- Cache grade: A/B/C/D/F
- Estimated cache hit rate: XX-XX%

### Step 5: 종합 리포트 생성

3개 영역의 결과를 통합하여 종합 평가:

```
═══════════════════════════════════════════════════════════
                  COMPREHENSIVE AUDIT REPORT
═══════════════════════════════════════════════════════════

📊 Overall Score: XX/46

Category Breakdown:
  Token Optimization:  XX/21  [Grade]
  Project Setup:       XX/10  [Grade]  
  Cache Friendliness:  XX/15  [Grade]

Overall Grade: [A+/A/B/C/D/F]

═══════════════════════════════════════════════════════════
```

### Step 6: 등급 기준 및 평가

전체 점수 기준:
- **42-46**: A+ (Excellent) - Production-ready, minimal improvements needed
- **38-41**: A (Very Good) - Well-optimized, minor tweaks recommended
- **32-37**: B (Good) - Solid foundation, some optimizations needed
- **24-31**: C (Fair) - Functional but inefficient, improvements recommended
- **16-23**: D (Needs Work) - Significant inefficiencies, priority fixes needed
- **0-15**: F (Critical) - Major issues, immediate action required

각 등급별 코멘트:

```bash
if [ $total_score -ge 42 ]; then
  echo "🏆 EXCELLENT PROJECT!"
  echo ""
  echo "Your project is highly optimized for Claude usage."
  echo "Estimated efficiency: 85-95%"
  echo "Estimated token savings vs. unoptimized: 40-50%"
  
elif [ $total_score -ge 38 ]; then
  echo "⭐ VERY GOOD!"
  echo ""
  echo "Your project follows most best practices."
  echo "Estimated efficiency: 75-85%"
  echo "Room for improvement: 5-10% token savings"
  
elif [ $total_score -ge 32 ]; then
  echo "✓ GOOD"
  echo ""
  echo "Solid baseline with optimization opportunities."
  echo "Estimated efficiency: 60-75%"
  echo "Potential improvement: 15-20% token savings"
  
elif [ $total_score -ge 24 ]; then
  echo "⚠️ FAIR"
  echo ""
  echo "Functional but with significant inefficiencies."
  echo "Estimated efficiency: 45-60%"
  echo "High-priority fixes recommended"
  echo "Potential improvement: 25-35% token savings"
  
elif [ $total_score -ge 16 ]; then
  echo "⚠️ NEEDS WORK"
  echo ""
  echo "Multiple critical issues affecting performance."
  echo "Estimated efficiency: 30-45%"
  echo "Immediate action required"
  echo "Potential improvement: 40-50% token savings"
  
else
  echo "🔴 CRITICAL"
  echo ""
  echo "Severe inefficiencies - project using 2-3x necessary tokens."
  echo "Estimated efficiency: < 30%"
  echo "URGENT: Follow quick-fix guide below"
  echo "Potential improvement: 50-70% token savings"
fi
```

### Step 7: Top Issues 요약

각 영역에서 발견된 Critical/Important 이슈들을 우선순위별로 정렬:

```
═══════════════════════════════════════════════════════════
                    TOP PRIORITY ISSUES
═══════════════════════════════════════════════════════════

🔴 Critical (Fix Immediately - High Impact):

  1. [TOKEN] .claudeignore missing
     Impact: 20,000-50,000 wasted tokens per session
     Fix: Create .claudeignore with basic patterns
     Time: 2 minutes
  
  2. [CACHE] Large files (5 files > 1000 lines)
     Impact: Low cache hit rate, slow operations
     Fix: Split into modules < 500 lines each
     Time: 2-4 hours

🟡 Important (Fix This Week - Medium Impact):

  3. [SETUP] CLAUDE.md too small
     Impact: Missing optimization guidance
     Fix: Add token rules from docs/sections/02-token-optimization/02-1-principles.md
     Time: 10 minutes
  
  4. [CACHE] CLAUDE.md unstable (15 changes/month)
     Impact: Frequent cache invalidation
     Fix: Separate stable/volatile content
     Time: 30 minutes

🟢 Minor (Fix When Available - Low Impact):

  5. [SETUP] No hooks configured
     Impact: Missing automation opportunities
     Fix: Add session-start hook
     Time: 5 minutes

═══════════════════════════════════════════════════════════
```

### Step 7.5: Extract Scores for Analysis

```bash
# Note: In a real execution, these would be captured from sub-skill outputs
# For now, set defaults if not already set
: ${token_score:=0}
: ${cache_score:=0}
: ${setup_score:=0}

# Calculate totals
total_score=$((token_score + cache_score + setup_score))

# Determine overall grade
if [ $total_score -ge 42 ]; then
  overall_grade="A+"
elif [ $total_score -ge 38 ]; then
  overall_grade="A"
elif [ $total_score -ge 32 ]; then
  overall_grade="B"
elif [ $total_score -ge 24 ]; then
  overall_grade="C"
elif [ $total_score -ge 16 ]; then
  overall_grade="D"
else
  overall_grade="F"
fi
```

### Step 8: Analyze Failed Items

```bash
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

### Step 9: Generate Solutions

```bash

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

### Step 10: Display Summary

```bash

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

</PROCEDURE>

## 개별 스킬 호출 방법

각 검사 영역은 독립적으로 실행 가능:

### 토큰 최적화만 검사
```
/efficiency-audit-tokens
```
→ 21개 항목 검사, 5-10초 소요

### 프로젝트 설정만 검사
```
/efficiency-audit-setup
```
→ 10개 항목 검사, 3-5초 소요

### 캐시 친화성만 검사
```
/efficiency-audit-cache
```
→ 15개 항목 검사, 10-15초 소요

## 출력 예시 (전체 검사)

```
╔═══════════════════════════════════════════════╗
║   Project Efficiency Audit - Full Scan       ║
╚═══════════════════════════════════════════════╝

Scanning 46 efficiency items across 3 categories...

[... 각 스킬의 상세 출력 ...]

═══════════════════════════════════════════════════════════
                  COMPREHENSIVE AUDIT REPORT
═══════════════════════════════════════════════════════════

📊 Overall Score: 35/46

Category Breakdown:
  Token Optimization:  17/21  B (Good)
  Project Setup:        8/10  B (Good)
  Cache Friendliness:  10/15  C (Fair)

Overall Grade: B (Good)

═══════════════════════════════════════════════════════════

✓ GOOD

Solid baseline with optimization opportunities.
Estimated efficiency: 60-75%
Potential improvement: 15-20% token savings

═══════════════════════════════════════════════════════════
                    TOP PRIORITY ISSUES
═══════════════════════════════════════════════════════════

🔴 Critical (Fix Immediately - High Impact):

  1. [TOKEN] 2 .env files not excluded
     Impact: Security risk + token waste
     Fix: Add .env* to .claudeignore
     Time: 30 seconds

🟡 Important (Fix This Week - Medium Impact):

  2. [CACHE] 2 files > 1000 lines
     Impact: Cache inefficiency
     Fix: Split helpers.ts and api.ts
     Time: 1-2 hours

═══════════════════════════════════════════════════════════
                      AUTO-FIX SCRIPT
═══════════════════════════════════════════════════════════

[... auto-fix script ...]

═══════════════════════════════════════════════════════════
                   IMPROVEMENT POTENTIAL
═══════════════════════════════════════════════════════════

If all critical + important issues are fixed:

  Current State:
    - Efficiency: ~65%
    - Avg session tokens: ~18,000
    - Monthly cost (50 sessions): ~$45

  After Improvements:
    - Efficiency: ~80% (+15% improvement)
    - Avg session tokens: ~14,400 (-3,600 tokens)
    - Monthly cost (50 sessions): ~$36 (-$9 saved)

  Annual Savings: ~$108

[... next steps ...]

Audit complete! 🎉
```

## 참고

이 스킬은 다음 독립 스킬들을 조율합니다:
- efficiency-audit-tokens.md - 토큰 최적화 검사
- efficiency-audit-setup.md - 프로젝트 설정 검사
- efficiency-audit-cache.md - 캐시 친화성 검사

각 스킬은 개별적으로도 실행 가능하며, 이 메인 스킬은 전체 검사 + 종합 리포트를 제공합니다.
