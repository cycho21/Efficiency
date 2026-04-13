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
     Fix: Add token rules from docs/claude-efficiency-guide.md
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

### Step 8: Quick Fix Script (Critical 이슈만)

자동 수정 가능한 Critical 이슈들에 대한 bash 스크립트 생성:

```
═══════════════════════════════════════════════════════════
                      AUTO-FIX SCRIPT
═══════════════════════════════════════════════════════════

The following script fixes auto-fixable critical issues:

```bash
#!/bin/bash
# Auto-generated efficiency fixes
# Run this to fix critical issues automatically

echo "Applying efficiency fixes..."
echo ""

# Fix 1: Create .claudeignore
if [ ! -f .claudeignore ]; then
  echo "Creating .claudeignore..."
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
*.min.js
*.bundle.js

# Logs
*.log
logs/
npm-debug.log*

# Environment files
.env
.env.*
!.env.example

# IDE settings
.idea/
.vscode/
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db

# Test coverage
coverage/
.nyc_output/
IGNOREEOF
  echo "✓ .claudeignore created"
else
  echo "⊘ .claudeignore already exists"
fi

# Fix 2: Ensure CLAUDE.md exists
if [ ! -f .claude/CLAUDE.md ] && [ ! -f CLAUDE.md ]; then
  echo "Creating basic CLAUDE.md..."
  mkdir -p .claude
  cat > .claude/CLAUDE.md << 'CLAUDEEOF'
# Project Guidelines for Claude

## Token Optimization Rules
1. Don't re-read files already accessed in the same session
2. Avoid unnecessary tool calls - verify necessity before execution
3. Execute parallel tool calls when possible - batch independent operations
4. Keep file sizes under 500 lines for better caching
5. Maintain .claudeignore actively - exclude build outputs and dependencies

## Project Info
[Add your project-specific description and rules here]
CLAUDEEOF
  echo "✓ CLAUDE.md created"
else
  echo "⊘ CLAUDE.md already exists"
fi

echo ""
echo "✓ Auto-fixes complete!"
echo ""
echo "Manual fixes still needed:"
echo "  - Split large files (> 1000 lines)"
echo "  - Review and expand CLAUDE.md content"
echo ""
echo "Re-run /efficiency-audit to verify improvements."
```

Copy and run this script:
```bash
bash /tmp/efficiency-fixes.sh
```

═══════════════════════════════════════════════════════════
```

### Step 9: 예상 개선 효과

현재 점수를 기반으로 개선 후 예상 효과 계산:

```
═══════════════════════════════════════════════════════════
                   IMPROVEMENT POTENTIAL
═══════════════════════════════════════════════════════════

If all critical + important issues are fixed:

  Current State:
    - Efficiency: ~XX%
    - Avg session tokens: ~XX,XXX
    - Monthly cost (50 sessions): ~$XXX

  After Improvements:
    - Efficiency: ~YY% (+ZZ% improvement)
    - Avg session tokens: ~YY,YYY (-Z,ZZZ tokens)
    - Monthly cost (50 sessions): ~$YYY (-$ZZ saved)

  Annual Savings: ~$ZZZ

Time Investment vs. Return:
  - Critical fixes: 30-60 minutes → 40-50% immediate improvement
  - Important fixes: 2-4 hours → additional 10-15% improvement
  - Minor fixes: 1-2 hours → additional 5% improvement

═══════════════════════════════════════════════════════════
```

### Step 10: 다음 단계 안내

```
═══════════════════════════════════════════════════════════
                       NEXT STEPS
═══════════════════════════════════════════════════════════

📋 Recommended Action Plan:

  TODAY (Critical - 30-60 min):
    1. Run auto-fix script above
    2. Add missing patterns to .claudeignore
    3. Create/expand CLAUDE.md
  
  THIS WEEK (Important - 2-4 hours):
    4. Split files > 1000 lines into modules
    5. Stabilize CLAUDE.md (reduce change frequency)
    6. Extract shared types to separate files
  
  THIS MONTH (Minor - 1-2 hours):
    7. Set up useful hooks (session-start, pre-commit)
    8. Improve documentation structure
    9. Review and optimize module boundaries

📚 Reference Documentation:

  Full guide:      docs/claude-efficiency-guide.md
  Checklists:      docs/checklists/
  Examples:        docs/examples/

  Specific sections:
    - Token optimization:    Section 2
    - Project setup:         Section 3
    - Cache optimization:    Section 8.4
    - Measurement:           Section 7

🔄 Re-Audit After Changes:

  Run /efficiency-audit again after making improvements
  to verify score increase and identify remaining issues.

═══════════════════════════════════════════════════════════

Audit complete! 🎉
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
