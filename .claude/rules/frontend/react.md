---
paths:
  - "**/*.tsx"
  - "src/components/**"
  - "app/**/*.tsx"
  - "components/**"
---

# React 컴포넌트 규칙

## 파일 구조

```
components/
├── ui/                 # 재사용 기본 (Button, Badge, Card, Modal)
├── {{DOMAIN_A}}/       # 도메인별 그룹
├── {{DOMAIN_B}}/       # 도메인별 그룹
└── shared/             # 공통 (Header, Sidebar, Loading, ErrorBoundary)
```
<!-- TODO: setup이 프로젝트 구조 분석 후 도메인 폴더 채움 -->

## Props 네이밍

- 이벤트 핸들러: `onAction` (onClick, onSubmit, onChange)
- 불리언: `is/has` 접두사 (isActive, hasError)
- 데이터: 명사 (user, items, config)

## 상태 관리

- 서버 상태: React Query / SWR / 프레임워크 기본
- 클라이언트 상태: useState / useReducer
- 전역 상태: 필요 시에만 (Zustand / Jotai 등)
- URL 상태: 필터/정렬/페이지네이션 → searchParams

## 접근성 필수

- 모든 인터랙티브 요소에 `aria-label`
- 키보드 네비게이션 지원
- 토글 → `aria-pressed`
- 색상만으로 상태 구분 금지 (아이콘 병행)

## 컴포넌트 3상태

- loading → 빈 상태 → 에러 상태 항상 처리
