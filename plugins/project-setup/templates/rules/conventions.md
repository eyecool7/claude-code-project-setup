# 코딩 컨벤션

## 네이밍 규칙

TypeScript/React 표준 따름 (PascalCase 컴포넌트, camelCase 함수/변수, UPPER_SNAKE 상수).
**프로젝트 추가 규칙:**
- 파일: kebab-case 필수 (`user-service.ts`, `article-card.tsx`)
- 디렉토리 네이밍 → `project-directory` skill 위임

## Import 순서

```typescript
// 1. 프레임워크/런타임
// 2. 외부 라이브러리
// 3. 내부 모듈 (절대 경로)
// 4. 타입
// 5. 스타일 (있으면)
```

## 타입 정의

- API 응답/요청: `type` 사용
- 컴포넌트 props: `interface` 사용 (extends 활용)
- ORM 생성 타입 재사용 우선
- `any` 사용 금지 → `unknown` + 타입 가드

## 주석 규칙

- 모든 파일 첫 줄에 역할/목적 한 줄 주석 필수:
  ```typescript
  // 사용자 인증 및 세션 관리 서비스
  export class AuthService { ... }
  ```
- TODO 형식: `// TODO: [설명] — [날짜 또는 이슈 번호]`
- 복잡한 비즈니스 로직에만 JSDoc
