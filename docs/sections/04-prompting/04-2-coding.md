### 4.2 코딩 작업용 프롬프팅

코딩 작업은 가장 흔한 사용 케이스입니다. 작업 유형별로 효과적인 프롬프팅 방법을 다룹니다.

#### 리팩토링

리팩토링은 동작을 유지하면서 구조를 개선하는 작업입니다.

**핵심 요소**:
1. 목표와 제약 명확히
2. 변경 범위 한정
3. 테스트 유지 요구

**❌ Bad**:
```
이 코드를 리팩토링해줘
```

**문제점**:
- 리팩토링 목표 불명확 (가독성? 성능? 구조?)
- 범위 모호
- 동작 보존 보장 없음

**토큰 영향**: 불필요한 변경 + 재작업 → 5,000-8,000 토큰

**✅ Good**:
```
src/services/order.service.ts의 processOrder 메서드를 리팩토링해줘.

목표:
- 현재 200줄 함수를 작은 단위로 분리
- 각 단계별 책임 명확히 (검증, 계산, 저장)
- 테스트 가능성 향상

제약:
- 기존 public API 유지 (processOrder 시그니처 동일)
- 모든 기존 테스트 통과
- 동작 변경 없음 (순수 리팩토링)

방향:
- 검증 로직 → validateOrder()
- 가격 계산 → calculateTotalPrice()
- DB 저장 → saveOrderToDatabase()
- 각 함수는 private 메서드로

리팩토링 후:
- 기존 테스트 실행해서 통과 확인
- 변경 사항 요약
```

**개선 효과**:
- 명확한 목표 → 정확한 리팩토링
- 테스트 보존 → 안전성 보장
- 범위 한정 → 불필요한 변경 방지

**토큰 영향**: 정확한 리팩토링 + 검증 → 2,500-3,500 토큰 (50-60% 절감)

**Before/After 비교**:

```typescript
// Before: 200줄 단일 함수
async processOrder(orderData: OrderInput) {
  // 검증 로직 50줄
  // 계산 로직 80줄
  // 저장 로직 40줄
  // 에러 처리 30줄
}

// After: 작은 함수들로 분리
async processOrder(orderData: OrderInput) {
  const validated = await this.validateOrder(orderData);
  const calculated = await this.calculateTotalPrice(validated);
  return await this.saveOrderToDatabase(calculated);
}

private async validateOrder(data: OrderInput) { /* 50줄 */ }
private async calculateTotalPrice(data: ValidatedOrder) { /* 80줄 */ }
private async saveOrderToDatabase(data: CalculatedOrder) { /* 40줄 */ }
```

---

#### 버그 수정

버그 수정은 재현 단계와 예상 동작이 중요합니다.

**핵심 요소**:
1. 재현 단계 제공
2. 예상 vs 실제 동작 설명
3. 관련 파일만 언급

**❌ Bad**:
```
장바구니가 안 돼. 고쳐줘.
```

**문제점**:
- "안 된다"가 무엇인지 불명확
- 재현 방법 없음
- 디버깅을 처음부터 시작

**토큰 영향**: 전체 장바구니 시스템 분석 + 추측 → 8,000-15,000 토큰

**✅ Good**:
```
장바구니에서 수량 업데이트시 총 가격이 갱신되지 않는 버그를 수정해줘.

재현 단계:
1. 상품을 장바구니에 추가 (정상 작동)
2. 장바구니 페이지에서 수량을 2 → 5로 변경
3. 수량은 업데이트되지만 총 가격은 수량 2 기준으로 유지됨

예상 동작:
- 수량 변경시 총 가격 = (단가 × 새 수량)으로 즉시 갱신

실제 동작:
- 수량만 변경되고 총 가격은 이전 값 유지
- 페이지 새로고침하면 정상 가격 표시 (서버는 정상)

관련 파일:
- src/components/Cart.tsx (UI 컴포넌트)
- src/hooks/useCart.ts (상태 관리)

추측:
- updateQuantity 호출시 total 재계산 누락?
```

**개선 효과**:
- 정확한 재현 → 빠른 버그 발견
- 예상 동작 명시 → 정확한 수정
- 관련 파일 한정 → 토큰 절약

**토큰 영향**: 필요한 파일만 분석 + 수정 → 1,500-2,500 토큰 (80% 절감)

**수정 프로세스**:

```typescript
// Before: 버그 있는 코드
const updateQuantity = (itemId: string, quantity: number) => {
  setItems(items.map(item => 
    item.id === itemId ? { ...item, quantity } : item
  ));
  // total 재계산 누락!
};

// After: 수정된 코드
const updateQuantity = (itemId: string, quantity: number) => {
  const updatedItems = items.map(item => 
    item.id === itemId ? { ...item, quantity } : item
  );
  setItems(updatedItems);
  
  // total 재계산 추가
  const newTotal = calculateTotal(updatedItems);
  setTotal(newTotal);
};
```

---

#### 새 기능 추가

새 기능은 명세를 먼저 작성하고 단계별로 진행합니다.

**핵심 요소**:
1. 명세 우선 작성
2. 단계별 구현 요청
3. 테스트와 함께 진행

**❌ Bad**:
```
즐겨찾기 기능을 추가해줘
```

**문제점**:
- 기능 스펙 불명확
- UI/UX 정의 없음
- 테스트 계획 없음

**토큰 영향**: 불완전한 구현 + 재작업 → 10,000-20,000 토큰

**✅ Good (2단계 접근)**:

**Step 1: 명세 작성**
```
즐겨찾기 기능 명세를 작성해줘.

요구사항:
- 사용자가 상품을 즐겨찾기에 추가/제거
- 즐겨찾기 목록 페이지
- 상품 카드에 즐겨찾기 아이콘 표시

고려사항:
- 로그인 필수 (비로그인 시 로그인 유도)
- 즐겨찾기 상태 실시간 반영
- 서버/클라이언트 상태 동기화

명세 형식:
- 기능 설명
- API 스펙 (엔드포인트, 파라미터, 응답)
- UI 컴포넌트 목록
- 상태 관리 방법
- 테스트 시나리오

명세 작성 후 구현은 내가 승인한 다음에 진행해줘.
```

**Step 2: 명세 승인 후 구현**
```
✅ 명세 승인함. 이제 단계별로 구현해줘.

Phase 1: 백엔드 API 구현
- POST /api/favorites (추가)
- DELETE /api/favorites/:id (제거)
- GET /api/favorites (목록 조회)
- 테스트 작성 및 실행

Phase 1 완료 후 확인하고 Phase 2 진행.

Phase 2: 프론트엔드 상태 관리
- useFavorites 훅 구현
- API 연동
- 낙관적 업데이트(optimistic update) 적용

Phase 3: UI 컴포넌트
- 즐겨찾기 버튼 컴포넌트
- 즐겨찾기 목록 페이지
- 로딩/에러 상태 처리
```

**개선 효과**:
- 명세 우선 → 방향 검증 후 구현
- 단계별 진행 → 중간 검증 가능
- 테스트 포함 → 품질 보장

**토큰 영향**: 명세 1,500 + 구현 Phase별 2,000-3,000 → 총 7,500-10,500 토큰 (고품질 보장)

---

#### 코드 리뷰

코드 리뷰는 범위와 우선순위를 명확히 해야 합니다.

**핵심 요소**:
1. 리뷰 범위 지정 (보안/성능/가독성 중 선택)
2. 변경 사항에만 집중
3. 자동 수정 vs 제안만 구분

**❌ Bad**:
```
이 PR 리뷰해줘
```

**문제점**:
- 리뷰 관점 불명확
- 전체 파일 vs 변경사항 모호
- 자동 수정 여부 불명확

**토큰 영향**: 전체 파일 읽기 + 포괄적 리뷰 → 8,000-15,000 토큰

**✅ Good**:

**일반 리뷰**:
```
PR #123의 변경사항을 리뷰해줘.

리뷰 범위:
1. 보안 (높은 우선순위)
   - SQL Injection 가능성
   - XSS 취약점
   - 인증/인가 누락
2. 버그 가능성 (중간 우선순위)
   - Null/undefined 처리
   - 에러 핸들링
   - Edge case
3. 코드 품질 (낮은 우선순위)
   - 가독성
   - 중복 코드

제외:
- 스타일/포매팅 (ESLint가 처리)
- 타이포 (별도로 확인함)

출력 형식:
각 이슈별로:
- [심각도] 파일명:라인 - 문제 설명
- 이유
- 수정 제안

자동 수정 안 함. 제안만 해줘.
```

**긴급 보안 리뷰**:
```
PR #123을 보안 관점에서만 긴급 리뷰해줘.

집중 항목:
- SQL Injection
- XSS
- CSRF
- 인증/인가 우회
- 민감 정보 노출

변경된 파일만:
- src/api/users.controller.ts
- src/middleware/auth.ts

발견시 즉시 리포트하고, Critical 이슈는 수정 제안까지.

다른 항목 (성능, 가독성 등)은 나중에 별도 리뷰.
```

**자동 수정 포함 리뷰**:
```
src/utils/validators.ts의 변경사항을 리뷰하고 문제 발견시 자동 수정해줘.

자동 수정 허용 항목:
- Null 체크 누락
- 에러 핸들링 개선
- 타입 안정성 강화
- 명백한 버그

수정 후:
- 변경 내용 요약
- 테스트 실행
```

**개선 효과**:
- 범위 한정 → 집중 리뷰
- 우선순위 명확 → 중요한 것 먼저
- 자동 수정 여부 명시 → 작업 흐름 명확

**토큰 영향**: 
- 전체 리뷰: 8,000-15,000 토큰
- 범위 한정 리뷰: 2,000-4,000 토큰 (70% 절감)

---

#### 코딩 작업 프롬프팅 체크리스트

```markdown
리팩토링:
[ ] 리팩토링 목표 명시 (가독성/성능/구조)
[ ] 변경 범위 한정
[ ] 기존 테스트 유지 요구
[ ] Public API 보존 명시

버그 수정:
[ ] 재현 단계 제공
[ ] 예상 vs 실제 동작 설명
[ ] 관련 파일만 명시
[ ] 추측 포함 (있다면)

새 기능:
[ ] 명세 우선 작성 요청
[ ] 명세 승인 후 구현
[ ] 단계별 진행 (Phase 1, 2, 3...)
[ ] 각 단계에 테스트 포함

코드 리뷰:
[ ] 리뷰 범위 지정 (보안/성능/품질)
[ ] 우선순위 명시
[ ] 변경 파일만 vs 전체 선택
[ ] 자동 수정 vs 제안만 구분
```

---


---

**이전**: [4.1 공통 원칙](04-1-common.md) | **다음**: [4.3 문서 작성용](04-3-documentation.md)
