### 3.2 .claudeignore 설정

**`.claudeignore`**는 Claude가 읽지 말아야 할 파일/디렉토리를 지정하는 파일입니다 (`.gitignore`와 유사).

**핵심 목적**:
- **비용 절감**: 불필요한 파일 제외로 토큰 낭비 방지
- **보안**: 민감 정보 파일 자동 제외
- **성능**: 파일 검색/읽기 속도 향상

**위치**: 프로젝트 루트에 `.claudeignore` 파일 생성

**문법**: `.gitignore`와 동일
```bash
# 주석
node_modules/          # 디렉토리 전체
*.log                  # 패턴 매칭
dist                   # 특정 이름
!important.log         # 예외 (제외하지 않음)
```

---

#### 필수 제외 항목

**모든 프로젝트가 반드시 제외해야 하는 항목**:

```bash
# .claudeignore

# 의존성 (Dependencies)
node_modules/
vendor/
packages/
.pnp.*

# 버전 관리 (Version Control)
.git/
.svn/
.hg/

# 빌드 결과 (Build Outputs)
dist/
build/
out/
target/
*.exe
*.dll
*.so
*.dylib

# 로그 및 임시 파일 (Logs & Temp)
*.log
logs/
*.tmp
*.temp
.cache/
tmp/

# 환경 및 시크릿 (Secrets)
.env
.env.*
*.pem
*.key
credentials.json
secrets/
.aws/
.ssh/

# 미디어 파일 (Media - 큰 파일)
*.jpg
*.jpeg
*.png
*.gif
*.mp4
*.mp3
*.pdf
*.zip
*.tar
*.gz

# IDE 및 에디터 (IDE/Editor)
.vscode/
.idea/
*.swp
*.swo
.DS_Store
Thumbs.db
```

**왜 제외하는가**:

| 항목 | 이유 | 예상 토큰 절감 |
|------|------|----------------|
| `node_modules/` | 수십만 줄, 수정 불필요 | 100,000+ 토큰 |
| `.git/` | 바이너리, 불필요 | 10,000+ 토큰 |
| `dist/`, `build/` | 생성된 파일, 읽어도 무의미 | 50,000+ 토큰 |
| `*.log` | 로그는 분석용, 코딩에 불필요 | 10,000+ 토큰 |
| `.env` | 민감 정보, 보안 위험 | 100 토큰 (중요!) |
| 미디어 파일 | 바이너리, 컨텍스트 오염 | 가변 (위험!) |

**실측 예시**:

```
Before (.claudeignore 없음):
- 프로젝트 전체 파일: 12,543개
- 읽기 가능 파일: 12,543개
- 예상 토큰 (전체 읽을 경우): 약 500,000 토큰

After (.claudeignore 설정):
- 프로젝트 전체 파일: 12,543개
- 읽기 가능 파일: 287개 (97.7% 감소)
- 예상 토큰 (전체 읽을 경우): 약 25,000 토큰

절감: 95% 토큰 절감 가능
```

---

#### 프로젝트별 패턴

**언어/프레임워크별 추가 패턴**:

##### Python 프로젝트

```bash
# .claudeignore (Python 추가)

# 가상 환경 (Virtual Environments)
venv/
env/
.venv/
.env/
ENV/
virtualenv/

# Python 캐시 (Python Cache)
__pycache__/
*.pyc
*.pyo
*.pyd
.Python

# 테스트 및 커버리지 (Test & Coverage)
.pytest_cache/
.coverage
htmlcov/
.tox/

# 패키지 (Packages)
*.egg
*.egg-info/
dist/
build/
eggs/
wheels/
```

**예상 효과**: 추가로 10,000-50,000 토큰 절감

##### JavaScript/TypeScript 프로젝트

```bash
# .claudeignore (JavaScript/TypeScript 추가)

# 의존성 (Dependencies)
node_modules/
jspm_packages/
bower_components/

# 빌드 (Build)
dist/
build/
out/
.next/
.nuxt/
.output/

# 테스트 커버리지 (Test Coverage)
coverage/
.nyc_output/

# 캐시 (Cache)
.cache/
.parcel-cache/
.eslintcache
.stylelintcache

# 로그 (Logs)
npm-debug.log*
yarn-debug.log*
yarn-error.log*
pnpm-debug.log*
lerna-debug.log*
```

**예상 효과**: 추가로 50,000-200,000 토큰 절감

##### Java/Gradle 프로젝트

```bash
# .claudeignore (Java 추가)

# 빌드 (Build)
target/
build/
out/
bin/

# 클래스 파일 (Class Files)
*.class
*.jar
*.war
*.ear

# IDE (IntelliJ IDEA)
.idea/
*.iml
*.iws
*.ipr

# Gradle
.gradle/
gradle-app.setting

# Maven
.mvn/
```

**예상 효과**: 추가로 20,000-100,000 토큰 절감

##### Go 프로젝트

```bash
# .claudeignore (Go 추가)

# 바이너리 (Binaries)
*.exe
*.exe~
*.dll
*.so
*.dylib
bin/

# 테스트 (Test)
*.test
*.out

# 의존성 (Dependencies - Go 1.11 이전)
vendor/
```

**예상 효과**: 추가로 5,000-30,000 토큰 절감

---

#### 동적 업데이트 전략

**세션 중 실시간 최적화**:

##### 전략 1: 즉시 추가

**상황**: Claude가 불필요한 파일을 읽었거나 제안한 경우

```markdown
❌ 문제 발생:

Claude: "프로젝트 분석을 위해 node_modules를 읽겠습니다..."
→ .claudeignore에 누락!

✅ 즉시 조치:

사용자: "node_modules는 읽지 마. .claudeignore에 추가해줘"

Claude: 
1. .claudeignore 파일 열기/생성
2. node_modules/ 추가
3. 확인 메시지 출력

효과:
- 이후 세션에서 자동 제외
- 향후 100,000+ 토큰 절감
```

##### 전략 2: 패턴 감지

**상황**: 특정 파일 타입이 반복적으로 불필요한 경우

```markdown
예시:

세션 중:
- design.png 읽기 시도 → 유용하지 않음
- logo.svg 읽기 시도 → 유용하지 않음
- screenshot.jpg 읽기 시도 → 유용하지 않음

조치:
"이미지 파일은 모두 .claudeignore에 추가해줘"

.claudeignore 업데이트:
*.png
*.jpg
*.svg
*.gif

효과:
- 프로젝트 전체 이미지 파일 제외
- 예상 절감: 수천~수만 토큰
```

##### 전략 3: Hook 자동화

**고급**: Hook으로 자동 제안 (섹션 3.3 참조)

```bash
# post-edit hook 예시

#!/bin/bash
# 새 파일 감지시 .claudeignore 확인

if [[ $EDITED_FILE == *.log ]]; then
  echo "⚠️ 로그 파일이 추가되었습니다. .claudeignore에 추가를 권장합니다."
  echo "제안: *.log를 .claudeignore에 추가하시겠습니까? (y/n)"
fi
```

**효과**: 실수로 불필요한 파일 포함 방지

---

#### .claudeignore 템플릿

**즉시 사용 가능한 종합 템플릿**:

```bash
# .claudeignore
# Claude가 읽지 말아야 할 파일/디렉토리

# ============================================
# 필수 제외 (Essential)
# ============================================

# 의존성 (Dependencies)
node_modules/
vendor/
packages/

# 버전 관리 (Version Control)
.git/
.svn/

# 빌드 결과 (Build)
dist/
build/
out/
target/

# 환경 및 시크릿 (Secrets)
.env
.env.*
*.pem
*.key
credentials.json
secrets/

# 로그 및 캐시 (Logs & Cache)
*.log
logs/
.cache/
tmp/

# 미디어 파일 (Media)
*.jpg
*.jpeg
*.png
*.gif
*.mp4
*.mp3
*.pdf
*.zip

# ============================================
# 프로젝트별 (Project-Specific)
# ============================================

# Python (필요시 주석 해제)
# __pycache__/
# *.pyc
# venv/
# .pytest_cache/

# JavaScript/TypeScript (필요시 주석 해제)
# coverage/
# .next/
# .nuxt/

# Java (필요시 주석 해제)
# *.class
# *.jar
# .gradle/

# ============================================
# 커스텀 (Custom)
# ============================================

# 프로젝트별 추가 패턴
# 예: legacy/, deprecated/, *.backup

---

# 중요 파일 예외 (Important Exceptions)
# !important.log

# ============================================
# 업데이트 로그
# ============================================
# 2026-04-12: 초기 생성
# 2026-04-15: *.png 추가 (불필요한 이미지 제외)
```

**사용법**:
1. 프로젝트 루트에 `.claudeignore` 생성
2. 위 템플릿 복사
3. 프로젝트별 섹션 주석 해제
4. Git 커밋

---

#### .claudeignore 최적화 체크리스트

```markdown
[ ] 파일 존재: 프로젝트 루트에 .claudeignore 있음
[ ] 필수 항목: node_modules, .git, dist, .env 포함
[ ] 프로젝트별: 언어/프레임워크별 패턴 추가
[ ] 미디어 파일: *.png, *.jpg, *.mp4 등 제외
[ ] 로그 파일: *.log, logs/ 제외
[ ] Git 커밋: .claudeignore를 버전 관리에 포함
[ ] 팀 공유: 팀원이 동일한 설정 사용
[ ] 동적 업데이트: 세션 중 불필요한 파일 발견시 즉시 추가
```

**검증 방법**:

다음과 같은 명령어가 있다면 유용할 것입니다 (현재 Claude Code CLI에서 미지원, 수동 확인 필요):

```bash
# 개념적 예시 (실제 명령어가 아닐 수 있음)
# claude files --show-ignored    # 제외된 파일 목록
# claude files --stats            # 파일 통계

# 수동 확인 방법:
# 1. 전체 파일 수
find . -type f | wc -l

# 2. Git이 추적하는 파일 수
git ls-files | wc -l

# 3. .claudeignore 패턴 테스트
# .gitignore 문법과 동일하므로 git check-ignore 명령 참고
```

**최적화 효과**:

```
Before (.claudeignore 없음):
- 읽기 가능 파일: 12,543개
- 평균 세션당 파일 스캔 비용: 약 5,000 토큰
- 실수로 큰 파일 읽기 위험: 높음

After (.claudeignore 최적화):
- 읽기 가능 파일: 287개 (97.7% 감소)
- 평균 세션당 파일 스캔 비용: 약 150 토큰 (97% 감소)
- 실수로 큰 파일 읽기 위험: 없음

총 효과:
- 파일 스캔: 97% 토큰 절감
- 실수 방지: 위험 제거
- 보안: 민감 정보 자동 보호
```

---


---

**이전**: [3.1 CLAUDE.md 작성 가이드](03-1-claude-md.md) | **다음**: [3.3 Hooks 설정](03-3-hooks.md)
