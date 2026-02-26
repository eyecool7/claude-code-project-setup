---
paths:
  - "src/api/**"
  - "src/auth/**"
  - "src/middleware/**"
  - "src/services/**"
  - "app/api/**"
---

# 보안 규칙

## 환경 변수

- `.env` 파일 직접 수정 금지 (사용자에게 안내만)
- 시크릿 하드코딩 절대 금지
- 필수 환경 변수 목록:
<!-- TODO: 프로젝트별 환경 변수 목록 채우기 -->
  - `DATABASE_URL`
  - (추가 키 목록)

## API 키 보호

- 외부 API 호출은 반드시 서버사이드에서만
- 클라이언트에 API 키 절대 노출 금지
- 프론트엔드 환경 변수 접두사에 시크릿 등록 금지
  <!-- Next.js: NEXT_PUBLIC_ / Vite: VITE_ / CRA: REACT_APP_ -->

## 입력 검증

- 모든 사용자 입력: zod/joi 스키마 검증
- 길이 제한, 형식 제한, 특수문자 새니타이징
- URL 입력: 형식 검증 + allowlist 기반

## SQL 인젝션 방어

- ORM 사용 시 raw query 최소화
- raw query 불가피하면 파라미터 바인딩 필수
- 문자열 연결로 쿼리 생성 절대 금지

## XSS 방어

- 사용자 입력 출력 시 이스케이프 처리
- dangerouslySetInnerHTML (React) 사용 금지 (불가피하면 sanitize)
- CSP 헤더 설정 권장

## CORS

<!-- TODO: 프로젝트별 CORS 정책 채우기 -->
- 기본: same-origin 유지
- 외부 접근 필요 시 명시적 allowlist

## Supabase SSL (해당 시 필수)

Supabase 프로젝트는 반드시 Postgres SSL Enforcement를 설정한다:

1. **대시보드**: Database → SSL Enforcement → Enable
2. **인증서**: Database → Connection info → Download Certificate (`prod-ca-2021.crt`)
3. **DATABASE_URL**: `?sslmode=verify-full` 파라미터 필수
4. **Prisma 사용 시**:
   ```
   DATABASE_URL="postgresql://...?sslmode=verify-full&sslrootcert=prod-ca-2021.crt"
   ```
5. **Supabase JS 클라이언트**: HTTPS 기본 적용 (추가 설정 불필요)
6. **Direct connection / Prisma / 서버 사이드 DB 접속**: 반드시 SSL 인증서 적용

미설정 시 중간자 공격(MITM)으로 DB 쿼리·응답이 도청/변조될 수 있다.

## 인증/인가

<!-- TODO: 프로젝트별 보호 경로 목록 채우기 -->
- 인증 미들웨어 필수 적용 경로 목록
- 공개 경로 명시 (화이트리스트)
