---
name: review
description: 코드 리뷰. 변경사항을 아래 체크리스트로 검토.
---

1. `git diff --cached` (staged) 또는 `git diff` (unstaged)로 변경사항 수집
2. 아래 체크리스트로 리뷰:

**타입 안전성**
- `any` 사용 여부 → `unknown` + 타입 가드로 대체
- ORM 생성 타입 재사용 여부

**에러 처리**
- 새 API 엔드포인트에 에러 핸들링 누락 여부
- 외부 API 호출에 try-catch + fallback 존재 여부
- AppError 코드 올바르게 사용 여부

**보안**
- 하드코딩된 시크릿/API 키 여부
- 사용자 입력 검증 누락 여부
- SQL 인젝션 가능 여부 (raw query 사용 시)
- 인가(Authorization) 처리 누락 여부

**구조**
- API Route/Controller에 비즈니스 로직 직접 작성 여부
- 파일이 200줄 초과 시 분리 필요 여부

**테스트**
- 변경된 로직에 대한 테스트 존재/필요 여부

3. 이슈 발견 시 `파일:라인` 형식으로 출력하고 수정 제안
