### 3.3 Hooks 설정

**Hooks**는 특정 이벤트 발생시 자동으로 실행되는 스크립트입니다 (Git hooks와 유사).

**핵심 목적**:
- **자동화**: 반복 작업 자동 수행
- **검증**: 실수 방지 (커밋 전 체크)
- **최적화**: 세션 시작시 상태 요약

---

**⚠️ 중요 고지사항**:

이 섹션은 프로젝트 자동화를 위한 권장 패턴을 설명합니다. **Claude Code CLI의 `.claude/hooks/` 디렉토리를 통한 Hook 공식 지원 여부는 Claude Code 공식 문서를 확인하세요.**

**대안**:
- **Git Hooks**: `.git/hooks/`를 사용하여 동일한 검증 로직 구현 가능 (Git 기본 기능)
- **CI/CD**: GitHub Actions, GitLab CI 등으로 자동화
- **Pre-commit Framework**: [pre-commit.com](https://pre-commit.com) 사용

이 섹션의 Hook 예시는 Git hooks나 다른 자동화 도구로도 그대로 적용할 수 있습니다.

---

---

#### Hook 종류 및 목적

##### 1. pre-commit Hook

**목적**: 커밋 전 자동 검증으로 실수 방지

**트리거**: `git commit` 실행 전

**주요 용도**:
- 대용량 파일 커밋 방지 (5MB 이상)
- 민감 정보 파일 커밋 방지 (.env, *.pem)
- CLAUDE.md 토큰 최적화 규칙 위반 체크
- 코드 스타일 자동 검사

**예시 시나리오**:

```bash
# 상황: 실수로 .env 파일을 커밋하려고 함

$ git add .env
$ git commit -m "Add config"

# Hook 실행 →

⛔ pre-commit Hook 실패!

문제: .env 파일이 포함되어 있습니다.
파일: .env (민감 정보)

조치:
1. git reset HEAD .env
2. .env를 .gitignore에 추가
3. 다시 커밋

커밋 중단됨.

# 효과: 민감 정보 유출 방지
```

##### 2. post-edit Hook

**목적**: 파일 수정 후 자동 체크 및 제안

**트리거**: Claude가 파일을 수정한 직후

**주요 용도**:
- 파일 크기 경고 (500줄 이상시 분할 제안)
- 자동 .claudeignore 업데이트 제안
- 새로운 의존성 추가 감지
- 코드 품질 즉시 체크

**예시 시나리오**:

```bash
# 상황: user.service.ts를 수정했는데 600줄이 됨

Claude: user.service.ts를 수정했습니다.

# Hook 실행 →

⚠️ post-edit Hook 경고!

파일: src/services/user.service.ts
크기: 612줄 (권장: 500줄 미만)

제안:
- 파일이 커지고 있습니다. 분할을 고려하세요.
- 예: user-crud.service.ts, user-auth.service.ts로 분리

토큰 영향:
- 현재: 약 1,836 토큰
- 분할 후 (2개 파일): 각 약 900 토큰
- 효과: 필요한 부분만 읽기 가능 (50% 절감)

# 효과: 프로젝트 구조 최적화 유지
```

##### 3. session-start Hook

**목적**: 세션 시작시 프로젝트 상태 요약

**트리거**: Claude Code CLI 세션 시작시

**주요 용도**:
- 프로젝트 최적화 상태 요약
- 캐시 히트율 표시 (가능한 경우)
- 마지막 세션 이후 변경사항 요약
- 진행중인 작업 리마인더 (progress.md 기반)

**예시 시나리오**:

```bash
# 세션 시작

$ claude

# Hook 실행 →

🚀 세션 시작 (2026-04-12 14:30)

📊 프로젝트 최적화 상태:
✅ .claudeignore: 존재 (287개 파일 제외)
✅ CLAUDE.md: 최적화됨 (623줄)
⚠️ 대형 파일: 3개 발견
   - src/services/user.service.ts (612줄)
   - src/utils/helpers.ts (543줄)
   - src/api/routes.ts (501줄)

📈 캐시 현황 (최근 7일):
- 캐시 히트율: 73% (목표: 70%)
- CLAUDE.md 수정: 1회 (양호)

🔄 마지막 세션 이후 변경:
- 4개 파일 수정 (main 브랜치)
- 2개 커밋 추가
- package.json 업데이트 (의존성 1개 추가)

📋 진행중인 작업:
progress.md에서 읽음:
- [ ] User API 구현 (70% 완료)
- [ ] 테스트 작성 (30% 완료)

💡 제안:
1. 대형 파일 3개 분할 고려
2. 캐시 히트율 양호 - 현재 패턴 유지

준비 완료! 무엇을 도와드릴까요?

# 효과: 즉시 프로젝트 상태 파악
```

---

#### 각 Hook 상세 예시

**완전한 pre-commit Hook 예시**:

다음은 즉시 사용 가능한 pre-commit Hook입니다:

```bash
#!/bin/bash
# .claude/hooks/pre-commit
# 커밋 전 자동 검증으로 실수 방지

echo "🔍 pre-commit Hook 실행 중..."

# 1. 대용량 파일 체크 (5MB 이상)
echo "  - 대용량 파일 체크..."
for file in $(git diff --cached --name-only); do
  if [ -f "$file" ]; then
    size=$(wc -c < "$file" 2>/dev/null || echo 0)
    if [ $size -gt 5242880 ]; then  # 5MB
      echo ""
      echo "⛔ pre-commit Hook 실패!"
      echo ""
      echo "문제: 파일이 너무 큽니다"
      echo "파일: $file ($(($size / 1024 / 1024))MB)"
      echo ""
      echo "조치:"
      echo "  1. git reset HEAD $file"
      echo "  2. 해당 파일을 .claudeignore에 추가"
      echo "  3. Git LFS 사용 고려: git lfs track \"$file\""
      echo ""
      exit 1
    fi
  fi
done

# 2. 민감 정보 파일 체크
echo "  - 민감 정보 파일 체크..."
for file in $(git diff --cached --name-only); do
  if [[ "$file" == *.env* ]] || [[ "$file" == *.pem ]] || \
     [[ "$file" == *credentials* ]] || [[ "$file" == *.key ]]; then
    echo ""
    echo "⛔ pre-commit Hook 실패!"
    echo ""
    echo "문제: 민감 정보 파일이 감지되었습니다"
    echo "파일: $file"
    echo ""
    echo "조치:"
    echo "  1. git reset HEAD $file"
    echo "  2. .gitignore에 추가"
    echo "  3. 이미 커밋된 경우: git filter-repo 사용"
    echo ""
    exit 1
  fi
done

# 3. CLAUDE.md 크기 체크 (2000줄 초과시 경고)
if git diff --cached --name-only | grep -q "CLAUDE.md"; then
  if [ -f ".claude/CLAUDE.md" ]; then
    lines=$(wc -l < ".claude/CLAUDE.md")
    if [ $lines -gt 2000 ]; then
      echo ""
      echo "⚠️  경고: CLAUDE.md가 너무 큽니다 ($lines줄)"
      echo "   권장: 2,000줄 미만 (현재: $lines줄)"
      echo "   상세 내용은 별도 파일로 분리하는 것을 고려하세요."
      echo ""
      # 경고만 표시, 커밋은 허용
    fi
  fi
fi

echo "✅ pre-commit 검사 완료"
exit 0
```

**설치 방법**:

```bash
# 1. Hook 디렉토리 생성
mkdir -p .claude/hooks

# 2. Hook 파일 생성
cat > .claude/hooks/pre-commit << 'EOF'
[위 스크립트 내용 붙여넣기]
EOF

# 3. 실행 권한 부여
chmod +x .claude/hooks/pre-commit

# 4. 테스트
.claude/hooks/pre-commit
# 예상 출력: ✅ pre-commit 검사 완료

# 5. Git 커밋
git add .claude/hooks/pre-commit
git commit -m "Add pre-commit hook for validation"
```

**실제 동작 예시**:

```bash
# 예시 1: .env 파일 커밋 시도
$ git add .env
$ git commit -m "Add config"

🔍 pre-commit Hook 실행 중...
  - 대용량 파일 체크...
  - 민감 정보 파일 체크...

⛔ pre-commit Hook 실패!

문제: 민감 정보 파일이 감지되었습니다
파일: .env

조치:
  1. git reset HEAD .env
  2. .gitignore에 추가
  3. 이미 커밋된 경우: git filter-repo 사용

# 커밋이 차단됨 ✓

# 예시 2: 정상 커밋
$ git add src/api/user.ts
$ git commit -m "Add user API"

🔍 pre-commit Hook 실행 중...
  - 대용량 파일 체크...
  - 민감 정보 파일 체크...
✅ pre-commit 검사 완료

[main abc1234] Add user API
 1 file changed, 50 insertions(+)
```

**추가 Hook 예시**:

post-edit, session-start 등 다른 Hook의 상세 구현 예시는 향후 `examples/hooks-examples.md` 파일에서 제공 예정입니다. 위의 pre-commit Hook 패턴을 참고하여 필요한 Hook을 직접 작성할 수 있습니다.

---

#### 설정 방법 (Claude Code CLI)

**Hook 디렉토리 구조**:

```
.claude/
├── CLAUDE.md
└── hooks/
    ├── pre-commit          # 실행 가능한 스크립트
    ├── post-edit           # 실행 가능한 스크립트
    └── session-start       # 실행 가능한 스크립트
```

**단계별 설정**:

**Step 1**: Hook 디렉토리 생성

```bash
mkdir -p .claude/hooks
```

**Step 2**: Hook 스크립트 작성

```bash
# 예: pre-commit Hook 생성
touch .claude/hooks/pre-commit
chmod +x .claude/hooks/pre-commit
```

**Step 3**: Hook 스크립트 내용 작성

```bash
#!/bin/bash
# .claude/hooks/pre-commit

# 대용량 파일 체크 (5MB 이상)
for file in $(git diff --cached --name-only); do
  if [ -f "$file" ]; then
    size=$(wc -c < "$file")
    if [ $size -gt 5242880 ]; then  # 5MB
      echo "⛔ 파일이 너무 큽니다: $file ($(($size / 1024 / 1024))MB)"
      echo "   .claudeignore에 추가하거나 Git LFS 사용을 고려하세요."
      exit 1
    fi
  fi
done

# 민감 정보 파일 체크
for file in $(git diff --cached --name-only); do
  if [[ "$file" == *.env* ]] || [[ "$file" == *.pem ]] || [[ "$file" == *credentials* ]]; then
    echo "⛔ 민감 정보 파일 감지: $file"
    echo "   이 파일을 정말 커밋하시겠습니까?"
    exit 1
  fi
done

echo "✅ pre-commit 검사 통과"
exit 0
```

**Step 4**: Git 커밋 및 팀 공유

```bash
git add .claude/hooks/pre-commit
git commit -m "Add pre-commit hook"
```

**Step 5**: 팀원 설정

팀원이 저장소를 clone한 후:

```bash
# Hook 실행 권한 설정
chmod +x .claude/hooks/*

# Claude Code CLI가 자동으로 Hook 인식
```

---

#### 주의사항

**Hook은 빠르게 실행되어야 함 (< 1초)**

```markdown
❌ Don't: 느린 Hook

#!/bin/bash
# 전체 프로젝트 린트 (30초 소요)
npm run lint

# 모든 테스트 실행 (2분 소요)
npm run test

# 문제: 커밋할 때마다 2분 30초 대기
# 결과: 개발자가 Hook을 비활성화하게 됨
```

```markdown
✅ Do: 빠른 Hook

#!/bin/bash
# 변경된 파일만 빠른 체크 (< 1초)

# 1. 간단한 파일 크기 체크 (매우 빠름)
for file in $(git diff --cached --name-only); do
  # ... 크기 체크 로직
done

# 2. 민감 정보 패턴 체크 (빠름)
# ... 패턴 매칭

# 무거운 작업은 CI에서 수행
echo "✅ 빠른 체크 완료 (전체 검증은 CI에서 수행)"
exit 0

# 효과: 1초 미만, 개발 흐름 방해 없음
```

**성능 가이드라인**:
- **pre-commit**: 최대 1초 (이상적: 0.5초)
- **post-edit**: 최대 0.5초 (거의 즉시)
- **session-start**: 최대 2초 (한 번만 실행)

---

**실패시 명확한 메시지**

```markdown
❌ Don't: 모호한 에러 메시지

#!/bin/bash
# Hook 실패
exit 1

# 출력:
# Hook failed.

# 문제: 무엇이 문제인지 알 수 없음
```

```markdown
✅ Do: 명확한 메시지와 해결 방법

#!/bin/bash

echo "⛔ pre-commit Hook 실패!"
echo ""
echo "문제: .env 파일이 커밋에 포함되어 있습니다."
echo "파일: .env (민감 정보)"
echo ""
echo "조치:"
echo "  1. git reset HEAD .env"
echo "  2. .env를 .gitignore에 추가"
echo "  3. 다시 커밋"
echo ""
exit 1

# 출력: 문제 + 해결 방법 명확
```

---

**Hook 비활성화 옵션 제공**

```bash
# 긴급시 Hook 스킵 가능하도록

# Git hook의 경우 (Git 기본 기능)
git commit --no-verify -m "Emergency fix"

# Claude Code hook의 경우 (예시, 실제 구현 확인 필요)
# export CLAUDE_SKIP_HOOKS=1
# claude ...
# 
# 또는 Hook 스크립트 내부에서 환경 변수 체크 구현:
# if [ "$SKIP_HOOKS" = "1" ]; then
#   echo "⚠️ Hook 스킵됨"
#   exit 0
# fi
```

**가이드라인**: 
- 일반적으로는 Hook 실행
- 긴급 상황에서만 스킵 옵션 사용
- Hook을 스킵한 경우 나중에 반드시 재검증

---

#### Hooks 최적화 체크리스트

```markdown
[ ] Hook 설정: .claude/hooks/ 디렉토리 존재
[ ] 기본 Hook: 최소 session-start Hook 설정
[ ] 권한: chmod +x로 실행 권한 부여
[ ] 성능: 각 Hook 1초 미만 실행
[ ] 메시지: 실패시 명확한 메시지와 해결 방법
[ ] Git 커밋: Hook 스크립트 버전 관리
[ ] 팀 공유: 팀원이 동일한 Hook 사용
[ ] 테스트: Hook이 올바르게 작동하는지 검증
```

**검증 방법**:

```bash
# Hook 수동 실행 테스트
.claude/hooks/pre-commit
# 예상: ✅ 또는 ⛔ 메시지

# Hook 실행 시간 측정
time .claude/hooks/session-start
# 예상: real 0m0.5s (1초 미만)
```

---

#### 설정 효과 예상

```markdown
Before (Hooks 없음):
- 실수로 .env 커밋: 발생 가능 (높은 위험)
- 대형 파일 커밋: 발생 가능
- 세션 시작시 상태 파악: 수동 (시간 소요)
- 파일 분할 타이밍: 수동 판단 (놓치기 쉬움)

After (Hooks 설정):
- 실수로 .env 커밋: 자동 차단 (위험 제거)
- 대형 파일 커밋: 자동 경고
- 세션 시작시 상태 파악: 자동 (2초)
- 파일 분할 타이밍: 자동 제안 (최적 유지)

효과:
- 보안: 민감 정보 유출 위험 제거
- 효율: 세션 시작 시간 30초 → 2초
- 품질: 프로젝트 구조 자동 최적화 유지
- 비용: 장기적으로 10-20% 토큰 절감
```

---

### 섹션 3 요약

**프로젝트 설정 체크리스트**:

```markdown
Phase 1: 즉시 (30분)
[ ] .claudeignore 생성 및 필수 항목 추가
    - node_modules, .git, dist, .env
    - 프로젝트별 패턴 추가
[ ] .claudeignore Git 커밋

Phase 2: 1일 내
[ ] CLAUDE.md 작성
    - 필수 섹션 5개 포함
    - 2,000줄 미만 유지
    - 동적 정보 제거
[ ] CLAUDE.md Git 커밋
[ ] 팀원과 공유

Phase 3: 1주 내
[ ] session-start Hook 설정 (최소)
[ ] pre-commit Hook 설정 (권장)
[ ] post-edit Hook 설정 (선택)
[ ] Hook Git 커밋 및 팀 공유

Phase 4: 지속적
[ ] .claudeignore 동적 업데이트
[ ] CLAUDE.md 안정성 유지 (주 1회 미만 수정)
[ ] Hook 성능 모니터링 (< 1초)
```

**예상 총 효과**:

```
Before (설정 전):
- 토큰 낭비: node_modules 등 불필요한 파일
- 규칙 부재: 일관성 없는 작업
- 수동 체크: 실수 가능성 높음

After (설정 완료):
- .claudeignore: 95% 토큰 절감 (파일 스캔)
- CLAUDE.md: 60-70% 토큰 절감 (캐싱)
- Hooks: 10-20% 추가 절감 (최적화 유지)

총 효과:
- 비용: 약 70-80% 토큰 절감
- 품질: 일관된 고품질 결과
- 시간: 자동화로 반복 작업 제거
- 보안: 민감 정보 자동 보호
```

---

## 다음 섹션 예고

**4. 프롬프팅 베스트 프랙티스**
- 4.1 공통 원칙
- 4.2 코딩 작업용 프롬프팅
- 4.3 문서 작성용 프롬프팅
- 4.4 리팩토링/리뷰용 프롬프팅

다음 섹션에서는 Claude와 효과적으로 소통하는 방법을 다룹니다.

---

---


---

**이전**: [2. 토큰 최적화 전략](02-token-optimization.md)  
**다음**: [4. 프롬프팅 베스트 프랙티스](04-prompting.md)

---

**이전**: [3.2 .claudeignore 설정](03-2-claudeignore.md) | **다음**: [4. 프롬프팅](../04-prompting/04-1-common.md)
