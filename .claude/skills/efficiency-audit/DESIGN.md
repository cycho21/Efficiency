# Efficiency Audit Skill - Design Document

## 목적
Claude Efficiency Guide를 기반으로 현재 프로젝트의 토큰 효율성, 캐시 최적화, 프로젝트 설정 상태를 자동으로 검사하고 개선 제안을 제공하는 스킬

## 스킬 구조

### 파일 분산 전략
문서를 기능별로 5개 파일로 분산하여 유지보수성과 가독성 향상

```
.claude/skills/efficiency-audit/
├── DESIGN.md                           # 이 문서 (설계 문서)
├── efficiency-audit.md                 # 메인 스킬 (200-300 lines)
├── efficiency-audit-check-tokens.md    # 토큰 최적화 검사 (300-400 lines)
├── efficiency-audit-check-setup.md     # 프로젝트 설정 검사 (250-350 lines)
├── efficiency-audit-check-cache.md     # 캐시 친화성 검사 (200-300 lines)
└── efficiency-audit-report.md          # 리포트 생성 (200-250 lines)
```

### 각 파일의 역할

#### 1. efficiency-audit.md (메인 오케스트레이터)
- **역할**: 전체 검사 프로세스 조율
- **내용**:
  - 스킬 설명 및 사용법
  - 검사 옵션 (전체/부분 검사)
  - 각 checker 순차 실행
  - 결과 통합 및 report 생성 호출
- **출력**: 없음 (다른 파일들 호출만)

#### 2. efficiency-audit-check-tokens.md
- **역할**: 토큰 최적화 21개 체크리스트 자동 검사
- **검사 항목**:
  - Project Setup (6 items)
    - [ ] .claudeignore 존재 및 내용
    - [ ] CLAUDE.md 존재 및 크기
    - [ ] 큰 파일 제외 설정
    - [ ] 빌드 산출물 제외
    - [ ] node_modules 등 의존성 제외
    - [ ] IDE 설정 파일 제외
  - Session Management (4 items)
    - [ ] 평균 파일 크기 (읽기 효율성)
    - [ ] 중복 읽기 가능성 (같은 파일 여러 위치)
    - [ ] 압축 가이드 존재 (progress.md 템플릿)
  - Caching (4 items)
    - [ ] CLAUDE.md 안정성 (최근 수정 빈도)
    - [ ] 공유 타입 분리
    - [ ] 작은 파일 구조
  - File Management (3 items)
    - [ ] 대용량 파일 (1000+ lines) 개수
    - [ ] 로그 파일 제외
  - Prompting (4 items)
    - [ ] 템플릿 파일 존재
    - [ ] 문서화된 워크플로우
- **출력**: JSON 형식 검사 결과

#### 3. efficiency-audit-check-setup.md
- **역할**: 프로젝트 기본 설정 검사
- **검사 항목**:
  - CLAUDE.md
    - [ ] 파일 존재
    - [ ] 토큰 최적화 규칙 포함 여부
    - [ ] 프로젝트별 규칙 존재
    - [ ] 크기 적정성 (너무 크면 캐시 미스 유발)
  - .claudeignore
    - [ ] 파일 존재
    - [ ] 기본 패턴 포함 (node_modules, dist, .env 등)
    - [ ] 프로젝트별 패턴
  - Hooks
    - [ ] .claude/settings.local.json 존재
    - [ ] 유용한 hooks 설정 (pre-commit, session-start 등)
- **출력**: JSON 형식 검사 결과

#### 4. efficiency-audit-check-cache.md
- **역할**: 캐시 친화적 구조 평가
- **검사 항목**:
  - 파일 크기 분포
    - 1000+ lines 파일 개수 및 위치
    - 500-1000 lines 파일 비율
    - 평균 파일 크기
  - 안정성/휘발성 분리
    - 자주 변경되는 파일과 안정적인 파일 혼재 여부
    - CLAUDE.md의 변경 빈도 (git log 분석)
  - 의존성 방향
    - 순환 참조 가능성 (간단한 import 분석)
  - 타입 분리
    - 공유 타입 파일 존재
- **출력**: JSON 형식 검사 결과

#### 5. efficiency-audit-report.md
- **역할**: 검사 결과 통합 및 리포트 생성
- **기능**:
  - 각 checker 결과 JSON 파싱
  - 총점 계산 (100점 만점)
  - 등급 부여 (A+/A/B/C/D/F)
  - 우선순위별 개선 제안 정렬
  - 자동 수정 가능 항목 스크립트 생성
- **출력 형식**:
  ```markdown
  # Project Efficiency Audit Report
  
  ## Overall Score: 75/100 (B)
  
  ## Summary
  - Token Optimization: 18/21 ✓
  - Project Setup: 8/10 ✓
  - Cache Friendliness: 12/15 ⚠️
  
  ## Critical Issues (Fix Immediately)
  1. [SETUP] .claudeignore missing - 큰 파일들이 컨텍스트에 로딩됨
     - Impact: High (20,000+ tokens waste)
     - Fix: [Auto-fix available]
  
  ## Important Issues (Fix This Week)
  ...
  
  ## Auto-Fix Script
  ```bash
  # Run this to fix auto-fixable issues
  ...
  ```
  ```

## 검사 프로세스

```
User invokes: /efficiency-audit

1. efficiency-audit.md
   ├─> Read efficiency-audit-check-tokens.md
   │   └─> Execute token checks
   │       └─> Return JSON results
   ├─> Read efficiency-audit-check-setup.md
   │   └─> Execute setup checks
   │       └─> Return JSON results
   ├─> Read efficiency-audit-check-cache.md
   │   └─> Execute cache checks
   │       └─> Return JSON results
   └─> Read efficiency-audit-report.md
       └─> Generate final report
           ├─> Calculate scores
           ├─> Prioritize issues
           └─> Generate auto-fix script
```

## 데이터 형식

### Checker 출력 JSON
```json
{
  "category": "token-optimization",
  "score": 18,
  "max_score": 21,
  "checks": [
    {
      "id": "claudeignore-exists",
      "name": ".claudeignore 파일 존재",
      "status": "pass|fail|warning",
      "impact": "high|medium|low",
      "auto_fixable": true,
      "details": "...",
      "fix_script": "echo '...' > .claudeignore"
    }
  ]
}
```

### 최종 리포트 데이터
```json
{
  "timestamp": "2026-04-13T...",
  "overall_score": 75,
  "grade": "B",
  "categories": {
    "token_optimization": { "score": 18, "max": 21 },
    "project_setup": { "score": 8, "max": 10 },
    "cache_friendliness": { "score": 12, "max": 15 }
  },
  "issues": [
    {
      "priority": "critical|important|minor",
      "category": "...",
      "title": "...",
      "impact": "...",
      "fix": "..."
    }
  ],
  "auto_fix_script": "#!/bin/bash\n..."
}
```

## 사용 예시

### 기본 사용
```
/efficiency-audit
```
→ 전체 검사 실행 및 리포트 출력

### 특정 영역만 검사
```
/efficiency-audit tokens
/efficiency-audit setup
/efficiency-audit cache
```

### 자동 수정 적용
```
/efficiency-audit --fix
```
→ 검사 후 자동 수정 가능한 항목 즉시 적용

## 구현 우선순위

1. **Phase 1** (MVP):
   - efficiency-audit.md (기본 구조)
   - efficiency-audit-check-tokens.md (가장 영향 큰 검사)
   - efficiency-audit-report.md (기본 리포트)

2. **Phase 2**:
   - efficiency-audit-check-setup.md
   - Auto-fix 스크립트 생성

3. **Phase 3**:
   - efficiency-audit-check-cache.md
   - 고급 분석 (git history, import graph)

## 참조 문서
- docs/checklists/token-optimization.md (21개 체크리스트)
- docs/claude-efficiency-guide.md (섹션 3: 프로젝트 설정)
- docs/claude-efficiency-guide.md (섹션 7: 측정 및 개선)
- docs/claude-efficiency-guide.md (섹션 8.4: 캐시 친화적 구조)
