## 3. 프로젝트 설정

효율적인 Claude 사용의 기반은 **올바른 프로젝트 설정**입니다. 이 섹션에서는 필수 설정 파일과 자동화 구성 방법을 다룹니다.

**왜 중요한가**:
- **비용**: 올바른 설정만으로도 토큰 사용량 30-50% 절감 가능
- **품질**: 일관된 규칙으로 팀 전체가 같은 품질의 결과물 생성
- **자동화**: Hook으로 반복 작업 자동화, 실수 방지

**설정 우선순위**:
1. **필수** (즉시): `.claudeignore` - 불필요한 파일 제외
2. **필수** (1일 내): `CLAUDE.md` - 프로젝트 규칙 정의
3. **권장** (1주 내): Hooks - 자동 검증 및 최적화

---

### 3.1 CLAUDE.md 작성 가이드

**CLAUDE.md**는 Claude Code CLI가 모든 세션에서 자동으로 로드하는 프로젝트 지침 파일입니다.

**핵심 특징**:
- **자동 로드**: `.claude/CLAUDE.md` 경로에 있으면 매 세션마다 자동으로 컨텍스트에 포함
- **캐시 가능**: 변경하지 않으면 캐시되어 비용 절감 (Claude API 기준 5분 캐시)
- **팀 공유**: Git으로 버전 관리하여 팀 전체가 같은 규칙 적용

**주의**: CLAUDE.md는 Claude Code CLI의 기능입니다. Claude API를 직접 사용하는 경우 시스템 프롬프트에 수동으로 포함해야 합니다.

---

#### 필수 섹션

**모든 CLAUDE.md가 반드시 포함해야 하는 섹션**:

##### 1. 프로젝트 개요

```markdown
# 프로젝트명

**목적**: 이 프로젝트가 해결하는 문제
**기술 스택**: 주요 언어/프레임워크
**저장소**: github.com/...
**문서**: 주요 문서 링크
```

**왜 필요한가**: Claude가 프로젝트 맥락을 이해하고 적절한 제안을 할 수 있습니다.

##### 2. 아키텍처 설명

```markdown
## 아키텍처

**구조**:
- `src/api/` - REST API 엔드포인트
- `src/models/` - 데이터 모델
- `src/services/` - 비즈니스 로직
- `src/utils/` - 공통 유틸리티

**주요 패턴**:
- MVC 패턴 사용
- 서비스 레이어에서 모든 비즈니스 로직 처리
- 컨트롤러는 얇게 유지

**중요 제약**:
- 순환 의존성 금지
- 외부 API 호출은 반드시 서비스 레이어에서
```

**왜 필요한가**: 구조를 이해하고 일관된 패턴으로 코드를 생성/수정합니다.

##### 3. 코딩 컨벤션

```markdown
## 코딩 컨벤션

**명명 규칙**:
- 파일명: kebab-case (user-service.ts)
- 클래스: PascalCase (UserService)
- 함수/변수: camelCase (getUserById)
- 상수: SCREAMING_SNAKE_CASE (MAX_RETRY_COUNT)

**코드 스타일**:
- 들여쓰기: 2 스페이스
- 최대 줄 길이: 100자
- 세미콜론: 필수
- 따옴표: 싱글 쿼트

**TypeScript 규칙**:
- any 사용 금지
- 모든 함수에 반환 타입 명시
- interface 우선, type은 필요시만
```

**왜 필요한가**: 코드 스타일 일관성 유지, 리뷰 시간 절약.

##### 4. 토큰 최적화 규칙

```markdown
## 토큰 최적화 규칙

1. **같은 세션에서 파일 재읽기 금지**
2. **대형 출력(20줄 이상)은 subagent 위임**
3. **병렬 가능한 작업은 동시 실행**
4. **컨텍스트 60% 사용시 압축**
5. **.claudeignore를 세션 중 동적 업데이트**
```

**왜 필요한가**: Claude가 자동으로 토큰 최적화를 준수합니다.

##### 5. 금지 사항

```markdown
## 금지 사항

❌ **절대 하지 말 것**:
- 프로덕션 DB에 직접 쿼리 실행
- 환경 변수 하드코딩
- 에러 무시 (빈 catch 블록)
- 민감 정보 로깅
- 테스트 스킵 (--no-verify)

❌ **프롬프트 금지 사항**:
- 커밋 메시지에 이모지 추가
- 자동으로 git push
- CHANGELOG.md 수정 (자동 생성됨)
```

**왜 필요한가**: 치명적인 실수 방지.

---

#### 선택 섹션

**프로젝트 특성에 따라 추가할 수 있는 섹션**:

##### 1. 팀 워크플로우

```markdown
## 팀 워크플로우

**브랜치 전략**:
- main: 프로덕션
- develop: 개발 메인
- feature/*: 기능 개발
- hotfix/*: 긴급 수정

**PR 프로세스**:
1. feature 브랜치 생성
2. Claude 리뷰 먼저 수행 (/review)
3. PR 생성 (템플릿 사용)
4. 2명 이상 승인 필요
5. CI 통과 후 머지

**커밋 컨벤션**:
- feat: 새 기능
- fix: 버그 수정
- refactor: 리팩토링
- docs: 문서
- test: 테스트
```

##### 2. 배포 프로세스

```markdown
## 배포

**스테이징 배포**:
1. develop 브랜치 머지
2. CI 자동 배포
3. 수동 테스트

**프로덕션 배포**:
1. main 브랜치 태그 (v1.2.3)
2. 릴리스 노트 생성
3. 승인 후 배포
4. 모니터링 30분
```

##### 3. 테스팅 전략

```markdown
## 테스팅

**테스트 구조**:
- `__tests__/unit/` - 단위 테스트
- `__tests__/integration/` - 통합 테스트
- `__tests__/e2e/` - E2E 테스트

**필수 커버리지**:
- 전체: 80% 이상
- 서비스 레이어: 90% 이상
- 유틸리티: 100%

**테스트 원칙**:
- 모든 PR은 테스트 포함
- 버그 수정시 재현 테스트 먼저 작성
- E2E 테스트는 critical path만
```

---

#### 작성 템플릿

**즉시 사용 가능한 CLAUDE.md 템플릿**:

```markdown
# 프로젝트명

## 프로젝트 개요
**목적**: [이 프로젝트가 해결하는 문제]
**기술 스택**: [주요 기술]
**저장소**: [GitHub URL]
**문서**: [문서 링크]

## 아키텍처

**디렉토리 구조**:
```
src/
├── api/          # API 엔드포인트
├── models/       # 데이터 모델
├── services/     # 비즈니스 로직
├── utils/        # 공통 유틸리티
└── config/       # 설정
```

**주요 패턴**:
- [사용하는 디자인 패턴]
- [아키텍처 원칙]

**중요 제약**:
- [반드시 지켜야 할 제약 사항]

## 코딩 컨벤션

**명명 규칙**:
- 파일명: [컨벤션]
- 클래스: [컨벤션]
- 함수: [컨벤션]

**코드 스타일**:
- 들여쓰기: [2 스페이스 / 4 스페이스 / 탭]
- 최대 줄 길이: [80 / 100 / 120]자
- 린터: [ESLint / Prettier / etc]

## 토큰 최적화 규칙

1. **같은 세션에서 파일 재읽기 금지**
2. **병렬 도구 호출 최대 활용**
3. **대형 출력(20줄+)은 subagent 위임**
4. **컨텍스트 60% 사용시 자동 압축**
5. **.claudeignore 동적 업데이트**
6. **불필요한 도구 호출 금지 - 실행 전 검증**
7. **캐시 무효화 최소화 - CLAUDE.md 안정화**

## 금지 사항

❌ **절대 하지 말 것**:
- [프로젝트별 금지 사항]
- 민감 정보 커밋
- 테스트 없이 커밋
- [추가 금지 사항]

❌ **프롬프트 금지 사항**:
- 명시적 요청 없이 git push
- [추가 프롬프트 제약]

## 팀 워크플로우 (선택)

**브랜치 전략**: [설명]
**PR 프로세스**: [단계]
**커밋 컨벤션**: [규칙]

## 배포 프로세스 (선택)

**스테이징**: [프로세스]
**프로덕션**: [프로세스]

## 테스팅 전략 (선택)

**테스트 구조**: [디렉토리 구조]
**커버리지 목표**: [%]
**테스트 원칙**: [원칙]

---

*마지막 업데이트: YYYY-MM-DD*
```

**사용법**:
1. 위 템플릿을 `.claude/CLAUDE.md`에 복사
2. [대괄호] 부분을 프로젝트에 맞게 수정
3. 선택 섹션은 필요시에만 유지
4. Git에 커밋하여 팀과 공유

---

#### 안티패턴

**흔한 실수와 해결책**:

##### ❌ 안티패턴 1: 너무 길게 작성 (2,000줄 이상)

```markdown
❌ Don't: CLAUDE.md에 모든 코드 예시 포함

# CLAUDE.md (5,000줄)

## API 엔드포인트 전체 목록
### POST /api/users
- 요청 예시: [100줄 JSON]
- 응답 예시: [100줄 JSON]
- 에러 케이스: [200줄 설명]
... (50개 엔드포인트 반복)

문제:
- 매 세션마다 5,000줄 로드 = 약 15,000 토큰
- 캐시되어도 초기 로드 비용 높음
- Claude가 중요한 정보를 놓칠 수 있음
```

```markdown
✅ Do: 핵심 원칙만, 상세는 별도 파일

# CLAUDE.md (500줄)

## API 설계 원칙
- RESTful 규칙 준수
- 모든 엔드포인트는 JSON 반환
- 에러는 RFC 7807 Problem Details 형식

상세 API 문서: docs/api-reference.md (필요시 참조)

효과:
- 500줄 = 약 1,500 토큰 (90% 절감)
- 핵심 원칙만 항상 컨텍스트에
- 필요시에만 상세 문서 읽기
```

**경험적 기준**:
- **이상적**: 300-800줄 (약 1,000-2,500 토큰)
- **허용**: 800-1,500줄 (약 2,500-4,500 토큰)
- **경고**: 1,500-2,000줄 (분할 고려)
- **위험**: 2,000줄 이상 (즉시 분할)

※ 실제 토큰 수는 언어, 코드 복잡도, 주석 비율에 따라 크게 달라질 수 있습니다. 위 수치는 일반적인 텍스트 기준 (~3 토큰/줄)이며, 코드가 많거나 특수 문자가 많으면 더 높을 수 있습니다.

---

##### ❌ 안티패턴 2: 너무 자주 수정 (캐시 무효화)

```markdown
❌ Don't: 동적 정보를 CLAUDE.md에 포함

# CLAUDE.md

## 오늘 할 일 (매일 수정)
- [ ] User API 구현
- [ ] 테스트 작성
- [x] 리뷰 완료

## 진행 상황 (하루 3번 수정)
- User 모듈: 70% 완료
- Payment 모듈: 30% 완료

## 최근 결정 사항 (수시로 추가)
- 2026-04-12: Redis 도입 결정
- 2026-04-11: PostgreSQL 선택
...

문제:
- 하루 3번 수정 → 캐시 무효화 3번
- 캐시 수명 5분 → 5분 이상 간격 작업시 히트 불가
- 히트율 30% 이하로 하락
```

```markdown
✅ Do: 불변 규칙만, 동적 정보는 별도 파일

# CLAUDE.md (안정적 - 월 1회 미만 수정)

## 아키텍처 원칙
- 마이크로서비스 아키텍처
- 각 서비스는 독립 DB
- 이벤트 기반 통신

## 코딩 컨벤션
... (변하지 않는 규칙)

---

# tasks.md (동적 - 매일 수정)
- [ ] User API 구현
- [ ] 테스트 작성

# progress.md (동적 - 수시 수정)
User 모듈: 70% 완료

# decisions/ (동적 - 추가만)
2026-04-12-redis.md
2026-04-11-postgres.md

효과:
- CLAUDE.md 캐시 유지 (주 1회 미만 수정)
- 히트율 70% 이상 유지
- 동적 정보는 필요시에만 로드
```

**수정 빈도 가이드라인**:
- **이상적**: 월 1회 미만 (캐시 최대 활용)
- **허용**: 주 1회 미만 (충분한 히트율)
- **경고**: 주 2-3회 (캐시 효과 감소)
- **위험**: 매일 (캐시 거의 무효)

---

##### ❌ 안티패턴 3: 코드 예시 과다 포함

```markdown
❌ Don't: 전체 코드를 예시로 포함

# CLAUDE.md

## 서비스 레이어 예시

```typescript
// user.service.ts 전체 (300줄)
import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './user.entity';
// ... 300줄 계속

export class UserService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}
  
  async findAll(): Promise<User[]> {
    return this.userRepository.find();
  }
  
  // ... 20개 메서드
}
```

문제:
- 300줄 코드 = 약 900 토큰
- 코드는 변경될 수 있음 → 동기화 문제
- 실제 코드 읽으면 중복
```

```markdown
✅ Do: 핵심 패턴과 원칙만, 파일 경로 제공

# CLAUDE.md

## 서비스 레이어 패턴

**구조** (`src/services/`에서 확인):
```typescript
@Injectable()
export class XxxService {
  constructor(
    @InjectRepository(Xxx) private repo: Repository<Xxx>,
  ) {}
  
  // CRUD 메서드
  // 비즈니스 로직 메서드
}
```

**원칙**:
- 모든 서비스는 @Injectable() 데코레이터
- Repository 주입으로 DB 접근
- 트랜잭션은 @Transactional() 사용

**참고**: 전체 예시는 `src/services/user.service.ts` 참조

효과:
- 20줄 = 약 60 토큰 (95% 절감)
- 실제 코드와 항상 동기화
- 필요시 실제 파일 읽기
```

**코드 예시 가이드라인**:
- **최소**: 패턴을 보여주는 5-10줄만
- **경로**: 전체 예시는 파일 경로로 참조
- **업데이트**: 코드 변경시 CLAUDE.md 동기화 불필요

---

#### CLAUDE.md 최적화 체크리스트

**작성 후 확인**:

```markdown
[ ] 길이: 2,000줄 미만 (이상적: 300-800줄)
[ ] 안정성: 동적 정보 제거 (할 일, 진행 상황 등)
[ ] 코드 예시: 최소화 (패턴만, 전체 코드 X)
[ ] 필수 섹션: 5개 모두 포함
    [ ] 프로젝트 개요
    [ ] 아키텍처 설명
    [ ] 코딩 컨벤션
    [ ] 토큰 최적화 규칙
    [ ] 금지 사항
[ ] 선택 섹션: 필요한 것만 포함
[ ] Git 커밋: .claude/CLAUDE.md 경로에 저장
[ ] 팀 공유: 팀원이 이해 가능한 내용
```

**최적화 효과 예상**:

```
Before (최적화 전):
- CLAUDE.md: 3,000줄 (약 9,000 토큰)
- 수정 빈도: 하루 3번
- 캐시 히트율: 35%

After (최적화 후):
- CLAUDE.md: 600줄 (약 1,800 토큰)
- 수정 빈도: 주 1번 미만
- 캐시 히트율: 75%

절감:
- 초기 로드: 80% 토큰 절감
- 캐시 효과: 히트율 +40%p
- 총 효과: 약 60-70% 비용 절감
```

※ 실제 효과는 프로젝트 특성, 파일 구조, 작업 패턴, CLAUDE.md 내용에 따라 달라질 수 있습니다. 위 수치는 참고용 예시입니다.

---

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
