# Hook 설정 예시 모음

이 문서는 Claude Code 워크플로우 자동화를 위한 실전 Hook 예시를 제공합니다. 각 Hook은 실제 프로젝트에서 즉시 활용 가능한 스크립트와 설정 방법을 포함합니다.

---

## 1. Pre-commit Hook (커밋 전 체크)

### 목적
커밋 전에 대용량 파일, 민감한 정보(.env, .secret), CLAUDE.md 토큰 최적화 규칙 위반을 자동으로 감지하여 실수를 방지합니다.

### 트리거 조건
`git commit` 명령 실행 시 자동으로 실행됩니다. 검사 실패 시 커밋이 중단됩니다.

### 스크립트 코드

```bash
#!/bin/bash
# .git/hooks/pre-commit

set -e

echo "🔍 Pre-commit checks..."

# 1. 대용량 파일 체크 (5MB 이상)
MAX_SIZE=$((5 * 1024 * 1024))  # 5MB in bytes
large_files=$(
    while read file; do
        if [ -f "$file" ]; then
            size=$(wc -c < "$file")
            if [ "$size" -gt "$MAX_SIZE" ]; then
                size_mb=$(( size / 1024 / 1024 ))
                echo "$file (${size_mb}MB)"
            fi
        fi
    done < <(git diff --cached --name-only --diff-filter=ACM)
)

if [ -n "$large_files" ]; then
    echo "❌ Large files detected (>5MB):"
    echo "$large_files"
    echo ""
    echo "Tip: Add to .claudeignore or use Git LFS"
    exit 1
fi

# 2. 민감 정보 파일 체크
sensitive_patterns=("\.env$" "\.secret$" "\.pem$" "\.key$" "credentials\.json$" "\.password$")
for pattern in "${sensitive_patterns[@]}"; do
    sensitive_files=$(git diff --cached --name-only --diff-filter=ACM | grep -E "$pattern" || true)
    if [ -n "$sensitive_files" ]; then
        echo "❌ Sensitive files detected:"
        echo "$sensitive_files"
        echo ""
        echo "These files should not be committed!"
        exit 1
    fi
done

# 3. CLAUDE.md 토큰 최적화 규칙 위반 체크
if git diff --cached --name-only | grep -q "CLAUDE.md"; then
    # 줄 수 체크 (100줄 초과 시 경고)
    lines=$(wc -l < ".claude/CLAUDE.md" 2>/dev/null || echo "0")
    if [ "$lines" -gt 100 ]; then
        echo "⚠️  Warning: CLAUDE.md has $lines lines (recommended: <100)"
        echo "Consider moving detailed content to separate files"
    fi
fi

# 4. 코드 스타일 자동 검사 (선택적)
# Uncomment if you have linters installed
# if command -v eslint &> /dev/null; then
#     git diff --cached --name-only --diff-filter=ACM | grep '\.js$' | xargs eslint --max-warnings 0
# fi

echo "✅ Pre-commit checks passed!"
```

### 설정 방법

```bash
# 1. Hook 스크립트 생성
cat > .git/hooks/pre-commit << 'EOF'
[위의 스크립트 내용 붙여넣기]
EOF

# 2. 실행 권한 부여
chmod +x .git/hooks/pre-commit

# 3. 테스트
git commit -m "test" --allow-empty
```

### 출력 예시

**성공 케이스:**
```
🔍 Pre-commit checks...
✅ Pre-commit checks passed!
[main a1b2c3d] feat: add new feature
 2 files changed, 50 insertions(+)
```

**실패 케이스 (대용량 파일):**
```
🔍 Pre-commit checks...
❌ Large files detected (>5MB):
videos/demo.mp4 (8MB)
dist/bundle.js (6MB)

Tip: Add to .claudeignore or use Git LFS
```

### 주의사항
- Hook은 로컬에만 적용되며, 팀원이 각자 설정해야 합니다
- `.git/hooks/`는 git에 추적되지 않으므로 프로젝트 루트에 `hooks/` 폴더를 만들어 공유하세요
- 긴급 상황에서는 `git commit --no-verify`로 우회 가능 (권장하지 않음)

### 토큰 영향도
- **직접 영향**: 없음 (커밋 전 실행)
- **간접 영향**: 높음 (5MB+ 파일, .env 파일이 커밋되면 캐시 무효화 및 토큰 낭비)

---

## 2. Session-start Hook (세션 시작 시)

### 목적
세션 시작 시 프로젝트 최적화 상태, 진행 중인 작업, 마지막 세션 이후 변경사항을 자동으로 요약하여 컨텍스트를 빠르게 복원합니다.

### 트리거 조건
Claude Code 세션 시작 시 자동으로 실행됩니다. `settings.json`의 `hooks.sessionStart` 설정 필요.

### 스크립트 코드

```bash
#!/bin/bash
# scripts/hooks/session-start.sh

set -e

echo "🚀 Session Start Summary"
echo "========================"
echo ""

# 1. 프로젝트 최적화 상태 체크
echo "📊 Optimization Status:"

# .claudeignore 존재 여부
if [ -f ".claudeignore" ]; then
    ignored_count=$(wc -l < .claudeignore)
    echo "  ✅ .claudeignore exists ($ignored_count rules)"
else
    echo "  ⚠️  .claudeignore missing - create one to reduce token usage"
fi

# CLAUDE.md 존재 여부
if [ -f ".claude/CLAUDE.md" ]; then
    lines=$(wc -l < .claude/CLAUDE.md)
    echo "  ✅ CLAUDE.md exists ($lines lines)"
    if [ "$lines" -gt 100 ]; then
        echo "     ⚠️  Consider splitting into separate files"
    fi
else
    echo "  ⚠️  CLAUDE.md missing - add project instructions"
fi

# 대용량 파일 체크 (500줄 이상)
large_files=$(find . -type f \( -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.md" \) \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/venv/*" \
  -not -path "*/dist/*" \
  -exec wc -l {} + 2>/dev/null | awk '$1 > 500 {print "     - " $2 " (" $1 " lines)"}' | head -5)
if [ -n "$large_files" ]; then
    echo "  ⚠️  Large files detected (>500 lines):"
    echo "$large_files"
fi

echo ""

# 2. 마지막 세션 이후 변경사항
echo "📝 Recent Changes:"
recent_commits=$(git log --oneline --since="24 hours ago" 2>/dev/null || echo "")
if [ -n "$recent_commits" ]; then
    echo "$recent_commits" | head -5
else
    echo "  No commits in the last 24 hours"
fi

echo ""

# 3. 진행 중인 작업 리마인더
echo "🎯 Current Context:"
current_branch=$(git branch --show-current 2>/dev/null || echo "unknown")
echo "  Branch: $current_branch"

if [ -f "progress.md" ]; then
    echo "  📋 Progress file found:"
    echo ""
    head -20 progress.md | sed 's/^/     /'
else
    echo "  No progress.md file"
fi

echo ""

# 4. Git 상태
uncommitted=$(git status --short 2>/dev/null | wc -l)
if [ "$uncommitted" -gt 0 ]; then
    echo "⚠️  $uncommitted uncommitted changes"
fi

echo ""
echo "========================"
echo "Ready to work! 🎉"
```

### 설정 방법

```bash
# 1. 스크립트 생성
mkdir -p scripts/hooks
cat > scripts/hooks/session-start.sh << 'EOF'
[위의 스크립트 내용 붙여넣기]
EOF
chmod +x scripts/hooks/session-start.sh

# 2. settings.json에 Hook 등록
# .claude/settings.json 또는 ~/.claude/settings.json
{
  "hooks": {
    "sessionStart": "bash scripts/hooks/session-start.sh"
  }
}

# 3. 테스트
bash scripts/hooks/session-start.sh
```

### 출력 예시

```
🚀 Session Start Summary
========================

📊 Optimization Status:
  ✅ .claudeignore exists (42 rules)
  ✅ CLAUDE.md exists (67 lines)
  ⚠️  Large files detected (>500 lines):
     - src/components/Dashboard.tsx (823 lines)
     - src/utils/helpers.js (612 lines)

📝 Recent Changes:
a1b2c3d docs: add token optimization checklist
e4f5g6h feat: add claude files
i7j8k9l first commit

🎯 Current Context:
  Branch: feature/optimization
  📋 Progress file found:

     ## In Progress
     - [ ] Implement session-start hook
     - [ ] Add .claudeignore rules for node_modules

     ## Completed
     - [x] Create CLAUDE.md
     - [x] Configure token optimization rules

⚠️  3 uncommitted changes

========================
Ready to work! 🎉
```

### 주의사항
- 대규모 프로젝트에서는 `find` 명령이 느릴 수 있으므로 범위를 제한하세요 (예: `src/` 폴더만)
- **Windows 환경**: `find` 성능이 특히 느릴 수 있으므로 경로를 명시적으로 제한하는 것이 중요합니다
- `progress.md` 파일은 수동으로 관리해야 합니다
- 캐시 히트율은 API 로그 접근 권한이 있어야 계산 가능합니다

### 토큰 영향도
- **직접 영향**: 낮음 (출력이 200줄 이하로 제한됨)
- **간접 영향**: 높음 (최적화 상태를 빠르게 파악하여 토큰 낭비 방지)

---

## 3. Post-edit Hook (파일 수정 후)

### 목적
파일 수정 후 파일 크기 증가를 감지하고, 500줄 이상 파일에 대해 분할을 제안하며, .claudeignore 업데이트가 필요한지 자동으로 확인합니다.

### 트리거 조건
파일 저장 후 자동으로 실행됩니다. `settings.json`의 `hooks.postEdit` 설정 필요.

### 스크립트 코드

```bash
#!/bin/bash
# scripts/hooks/post-edit.sh

# 편집된 파일 경로는 $1으로 전달됨
EDITED_FILE="$1"

if [ -z "$EDITED_FILE" ] || [ ! -f "$EDITED_FILE" ]; then
    exit 0
fi

# 1. 파일 크기 경고 (500줄 이상)
lines=$(wc -l < "$EDITED_FILE")
if [ "$lines" -gt 500 ]; then
    echo "⚠️  File Size Warning: $EDITED_FILE"
    echo "   Lines: $lines (recommended: <500)"
    echo ""
    echo "   Consider splitting into:"
    
    # 파일 타입별 분할 제안
    ext="${EDITED_FILE##*.}"
    case "$ext" in
        "js"|"ts"|"jsx"|"tsx")
            echo "   - Separate components/utilities"
            echo "   - Extract large functions"
            ;;
        "py")
            echo "   - Split into modules"
            echo "   - Extract classes to separate files"
            ;;
        "md")
            echo "   - Split into sections (section-1.md, section-2.md)"
            echo "   - Use TOC with links"
            ;;
        *)
            echo "   - Smaller, focused files"
            ;;
    esac
    echo ""
fi

# 2. .claudeignore 제안
# 새로운 패턴 감지 (예: build 폴더, 로그 파일)
should_ignore=false
ignore_reason=""

# 빌드 출력물
if [[ "$EDITED_FILE" =~ (dist|build|out|target)/.*\. ]]; then
    should_ignore=true
    ignore_reason="build output"
fi

# 로그 파일
if [[ "$EDITED_FILE" =~ .*\.log$ ]]; then
    should_ignore=true
    ignore_reason="log file"
fi

# 미니파이된 파일
if [[ "$EDITED_FILE" =~ .*\.min\.(js|css)$ ]]; then
    should_ignore=true
    ignore_reason="minified file"
fi

# 패키지 락 파일
if [[ "$EDITED_FILE" =~ (package-lock\.json|yarn\.lock|pnpm-lock\.yaml)$ ]]; then
    should_ignore=true
    ignore_reason="package lock file"
fi

if [ "$should_ignore" = true ]; then
    echo "💡 .claudeignore Suggestion:"
    echo "   File: $EDITED_FILE"
    echo "   Reason: $ignore_reason"
    echo ""
    
    # .claudeignore에 이미 있는지 체크
    if [ -f ".claudeignore" ]; then
        # 파일 경로의 패턴 추출
        pattern=$(echo "$EDITED_FILE" | sed -E 's|[^/]+$|*|')
        if ! grep -q "^$pattern" .claudeignore; then
            echo "   Add to .claudeignore:"
            echo "   echo '$pattern' >> .claudeignore"
            echo ""
        fi
    else
        echo "   Create .claudeignore and add:"
        echo "   echo '$EDITED_FILE' > .claudeignore"
        echo ""
    fi
fi

# 3. 새로운 의존성 추가 감지
if [[ "$EDITED_FILE" =~ package\.json$ ]]; then
    # package.json이 변경된 경우
    echo "📦 Package Dependency Change Detected"
    echo "   Run: npm install (or yarn/pnpm)"
    echo "   Consider: Update .claudeignore to exclude node_modules"
    echo ""
fi

if [[ "$EDITED_FILE" =~ requirements\.txt$ ]]; then
    echo "📦 Python Dependency Change Detected"
    echo "   Run: pip install -r requirements.txt"
    echo "   Consider: Update .claudeignore to exclude venv/"
    echo ""
fi
```

### 설정 방법

```bash
# 1. 스크립트 생성
mkdir -p scripts/hooks
cat > scripts/hooks/post-edit.sh << 'EOF'
[위의 스크립트 내용 붙여넣기]
EOF
chmod +x scripts/hooks/post-edit.sh

# 2. settings.json에 Hook 등록
{
  "hooks": {
    "postEdit": "bash scripts/hooks/post-edit.sh {{file}}"
  }
}

# 3. 테스트
bash scripts/hooks/post-edit.sh src/components/LargeComponent.tsx
```

### 출력 예시

**대용량 파일 경고:**
```
⚠️  File Size Warning: src/components/Dashboard.tsx
   Lines: 823 (recommended: <500)

   Consider splitting into:
   - Separate components/utilities
   - Extract large functions
```

**.claudeignore 제안:**
```
💡 .claudeignore Suggestion:
   File: dist/bundle.js
   Reason: build output

   Add to .claudeignore:
   echo 'dist/*' >> .claudeignore
```

**의존성 변경 감지:**
```
📦 Package Dependency Change Detected
   Run: npm install (or yarn/pnpm)
   Consider: Update .claudeignore to exclude node_modules
```

### 주의사항
- 파일 경로는 `{{file}}` 변수로 전달되어야 합니다
- 모든 에디터가 post-edit hook을 지원하는 것은 아닙니다
- 출력이 너무 자주 나오면 방해가 될 수 있으므로 임계값 조정이 필요할 수 있습니다

### 토큰 영향도
- **직접 영향**: 낮음 (출력은 몇 줄 이내)
- **간접 영향**: 중간 (대용량 파일 분할 유도로 캐시 효율 개선)

---

## 4. Pre-push Hook (푸시 전)

### 목적
원격 저장소에 푸시하기 전에 테스트, 린트, 민감 정보를 자동으로 검사하여 CI/CD 실패를 사전에 방지합니다.

### 트리거 조건
`git push` 명령 실행 시 자동으로 실행됩니다. 검사 실패 시 푸시가 중단됩니다.

### 스크립트 코드

```bash
#!/bin/bash
# .git/hooks/pre-push

set -e

echo "🚀 Pre-push checks..."
echo ""

# 1. 린트 검사
echo "🔍 Running linters..."

# JavaScript/TypeScript (eslint)
if [ -f "package.json" ] && grep -q "eslint" package.json; then
    if command -v npm &> /dev/null; then
        npm run lint --if-present || {
            echo "❌ Lint failed! Fix errors before pushing."
            exit 1
        }
        echo "  ✅ Lint passed"
    fi
fi

# Python (flake8, black)
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    if command -v flake8 &> /dev/null; then
        flake8 . --max-line-length=100 --exclude=venv,env,.venv || {
            echo "❌ Flake8 failed! Fix errors before pushing."
            exit 1
        }
        echo "  ✅ Flake8 passed"
    fi
fi

echo ""

# 2. 테스트 자동 실행
echo "🧪 Running tests..."

# JavaScript/TypeScript
if [ -f "package.json" ] && grep -q "\"test\"" package.json; then
    npm test || {
        echo "❌ Tests failed! Fix before pushing."
        exit 1
    }
    echo "  ✅ Tests passed"
fi

# Python
if [ -f "pytest.ini" ] || [ -f "pyproject.toml" ]; then
    if command -v pytest &> /dev/null; then
        pytest || {
            echo "❌ Tests failed! Fix before pushing."
            exit 1
        }
        echo "  ✅ Tests passed"
    fi
fi

echo ""

# 3. 민감 정보 재확인
echo "🔐 Checking for sensitive data..."

sensitive_found=false

# .env 파일
if git diff origin/main...HEAD --name-only | grep -E '\.env$|\.secret$|\.pem$|\.key$'; then
    echo "❌ Sensitive files detected in commits!"
    echo "   These should not be pushed to remote."
    sensitive_found=true
fi

# 하드코딩된 시크릿 패턴 체크
secret_patterns=(
    "password\s*=\s*['\"][^'\"]+['\"]"
    "api_key\s*=\s*['\"][^'\"]+['\"]"
    "secret\s*=\s*['\"][^'\"]+['\"]"
    "token\s*=\s*['\"][^'\"]+['\"]"
    "AKIA[0-9A-Z]{16}"  # AWS Access Key
)

for pattern in "${secret_patterns[@]}"; do
    matches=$(git diff origin/main...HEAD | grep -E "$pattern" || true)
    if [ -n "$matches" ]; then
        echo "⚠️  Potential hardcoded secret detected:"
        echo "$matches" | head -3
        echo ""
        echo "   Review carefully before pushing!"
        sensitive_found=true
    fi
done

if [ "$sensitive_found" = false ]; then
    echo "  ✅ No sensitive data detected"
fi

echo ""

# 4. 브랜치 보호 체크
current_branch=$(git branch --show-current)
remote="$1"
url="$2"

# main/master 직접 푸시 경고
if [[ "$current_branch" == "main" ]] || [[ "$current_branch" == "master" ]]; then
    echo "⚠️  WARNING: You are pushing to $current_branch branch"
    echo "   Consider using a feature branch and PR workflow"
    echo ""
    read -p "   Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Push cancelled"
        exit 1
    fi
fi

echo ""
echo "✅ All pre-push checks passed!"
echo "🚀 Pushing to remote..."
```

### 설정 방법

```bash
# 1. Hook 스크립트 생성
cat > .git/hooks/pre-push << 'EOF'
[위의 스크립트 내용 붙여넣기]
EOF

# 2. 실행 권한 부여
chmod +x .git/hooks/pre-push

# 3. 테스트 (실제로 푸시하지는 않음)
bash .git/hooks/pre-push origin https://github.com/user/repo.git
```

### 출력 예시

**성공 케이스:**
```
🚀 Pre-push checks...

🔍 Running linters...
  ✅ Lint passed

🧪 Running tests...
 PASS  src/utils/helpers.test.js
 PASS  src/components/Dashboard.test.tsx
  ✅ Tests passed

🔐 Checking for sensitive data...
  ✅ No sensitive data detected

✅ All pre-push checks passed!
🚀 Pushing to remote...
```

**실패 케이스 (테스트 실패):**
```
🚀 Pre-push checks...

🔍 Running linters...
  ✅ Lint passed

🧪 Running tests...
 FAIL  src/utils/helpers.test.js
  ● sum › should add two numbers
    expect(received).toBe(expected)
    Expected: 5
    Received: 4

❌ Tests failed! Fix before pushing.
```

**경고 케이스 (main 브랜치 푸시):**
```
⚠️  WARNING: You are pushing to main branch
   Consider using a feature branch and PR workflow

   Continue anyway? (y/N)
```

### 주의사항
- 테스트가 오래 걸리면 푸시가 지연될 수 있습니다 (빠른 테스트만 실행 권장)
- CI/CD와 중복되는 검사는 제거하여 시간 절약 가능
- 긴급 상황에서는 `git push --no-verify`로 우회 가능 (권장하지 않음)
- 시크릿 패턴 체크는 false positive가 있을 수 있으므로 패턴 조정 필요
- **브랜치 보호 제한**: `read -p` 대화형 프롬프트는 IDE 통합 및 CI 환경에서 작동하지 않습니다. 비대화형 환경에서는 환경 변수(예: `ALLOW_MAIN_PUSH=true`)로 제어하거나 항상 차단하도록 수정하는 것을 권장합니다

### 토큰 영향도
- **직접 영향**: 없음 (푸시 전 실행)
- **간접 영향**: 낮음 (코드 품질 유지로 디버깅 세션 감소)

---

## Hook 활용 팁

### 1. Hook 공유하기
`.git/hooks/`는 git에 추적되지 않으므로 팀원과 공유하려면:

```bash
# 프로젝트 루트에 hooks 폴더 생성
mkdir -p hooks
cp .git/hooks/pre-commit hooks/
cp .git/hooks/pre-push hooks/

# README에 설치 방법 추가
echo "## Setup Hooks" >> README.md
echo "bash hooks/install.sh" >> README.md

# 설치 스크립트 생성
cat > hooks/install.sh << 'EOF'
#!/bin/bash
cp hooks/pre-commit .git/hooks/
cp hooks/pre-push .git/hooks/
chmod +x .git/hooks/pre-commit .git/hooks/pre-push
echo "✅ Hooks installed!"
EOF
chmod +x hooks/install.sh
```

### 2. Hook 비활성화 (디버깅 시)
```bash
# 일시적으로 비활성화
git commit --no-verify
git push --no-verify

# 영구 비활성화
chmod -x .git/hooks/pre-commit
```

### 3. Hook 로그 남기기
```bash
# Hook 스크립트에 추가
exec 1>> .git/hooks/pre-commit.log 2>&1
echo "[$(date)] Pre-commit hook executed"
```

### 4. 조건부 실행
```bash
# CI 환경에서는 스킵
if [ -n "$CI" ]; then
    echo "Running in CI, skipping hook"
    exit 0
fi

# 특정 브랜치에서만 실행
current_branch=$(git branch --show-current)
if [[ "$current_branch" != "main" ]]; then
    echo "Not on main branch, skipping strict checks"
    exit 0
fi
```

---

## 참고 자료

- [Git Hooks Documentation](https://git-scm.com/docs/githooks)
- [Claude Code Settings Reference](https://docs.anthropic.com/claude/docs/claude-code-settings)
- [Token Optimization Checklist](../checklists/token-optimization.md)
