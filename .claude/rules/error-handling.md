---
paths:
  - "src/services/**"
  - "src/api/**"
  - "src/middleware/**"
  - "app/api/**"
  - "src/lib/**"
---

# 에러 처리 규칙

## AppError 클래스

모든 에러는 AppError를 통해 처리한다.

```typescript
class AppError extends Error {
  constructor(
    public code: ErrorCode,
    public status: number,
    public details?: Record<string, unknown>,
    public isOperational: boolean = true
  ) {
    super(code);
  }
}
```

## 에러 카테고리

| 코드 | HTTP | 사용 기준 |
|------|------|----------|
| VALIDATION_ERROR | 400/422 | 입력값 형식/범위 오류 |
| AUTH_FAILED | 401 | 인증 실패 |
| FORBIDDEN | 403 | 권한 없는 리소스 접근 |
| NOT_FOUND | 404 | 리소스 미존재 |
| CONFLICT | 409 | 중복 생성, 동시성 충돌 |
| RATE_LIMITED | 429 | 호출 제한 초과 (Retry-After 헤더 필수) |
| INTERNAL_ERROR | 500 | 예상치 못한 에러 |

## 외부 API 에러 처리

외부 서비스 호출 시 반드시 fallback 전략 포함:
- 주요 서비스 실패 → 캐시/대안 데이터로 fallback
- 보조 서비스 실패 → 해당 기능만 스킵, 나머지 정상 진행
- 모든 외부 호출 → 재시도 정책 명시 (최대 횟수, 간격)

<!-- TODO: 프로젝트별 외부 API 목록 + 각각의 fallback 전략 채우기 -->

## 전역 에러 핸들러

프레임워크에 맞는 전역 에러 핸들러 미들웨어 필수 적용.

<!-- TODO: 프레임워크별 에러 핸들러 패턴 채우기 -->
<!-- Next.js → lib/api-handler.ts 래퍼 -->
<!-- Express → app.use(errorHandler) 미들웨어 -->

## RequestID

모든 API 응답에 `X-Request-Id` 헤더 포함.

## 운영 응답 보안

- stack trace 노출 금지
- SQL 쿼리 노출 금지
- API 키 노출 금지
- isOperational=false인 에러 → 일반 메시지로 대체

## 로그 필수 필드

requestId, userId, path, errorCode, stack (서버 로그에만)

## 테스트

에러 핸들링 테스트 상세 → `.claude/rules/testing.md` 참조 (에러 7종 테스트 포함)
