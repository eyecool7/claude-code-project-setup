---
paths:
  - "**/*.test.*"
  - "**/*.spec.*"
  - "tests/**"
  - "__tests__/**"
---

# 테스트 규칙

## 필수 테스트 범위

### 단위 테스트
- 모든 비즈니스 로직 (services/)
- 유틸리티 함수 (lib/)
- 외부 API 호출 → mock 처리 필수

### 통합 테스트
- API 엔드포인트 전체 (요청 → 응답 사이클)
- DB 쿼리 → 테스트 DB 사용 (프로덕션 DB 접근 금지)

### 에러 7종 전용 테스트 (error-handling rule 연동)
각 에러 코드별 최소 1개 테스트 케이스:
- VALIDATION_ERROR: 잘못된 입력
- AUTH_FAILED: 인증 실패
- FORBIDDEN: 권한 없음
- NOT_FOUND: 존재하지 않는 리소스
- CONFLICT: 중복 데이터
- RATE_LIMITED: 외부 API 429 응답 처리
- INTERNAL_ERROR: 예상치 못한 예외

### 외부 API 테스트
- msw / nock 등으로 mock 처리
- fixture 데이터 사용
- 실제 외부 API 호출 금지

## 금지 사항

- happy path만 있는 테스트 → 리젝트
- 실제 외부 API 호출하는 테스트 금지
- 테스트에서 `.env` 값 직접 참조 금지 (테스트 환경 변수 분리)
- 테스트 간 상태 공유 금지 (각 테스트 독립)

## 네이밍 컨벤션

```
describe('{ServiceName}')
  it('should {expected behavior} when {condition}')
  it('should throw {ErrorCode} when {error condition}')
```
