---
name: project-directory
description: 새 파일/폴더 생성 위치 결정, 디렉토리 구조 변경, 파일 배치 시 사용.
user-invocable: false
---

# 프로젝트 디렉토리 규칙

## 디렉토리 구조

<!-- TODO: setup 1단계에서 프로젝트 분석 후 실제 구조로 채우기 -->
```
project-root/
├── src/
│   ├── {{APP_DIR}}/          # 라우팅/페이지
│   ├── {{COMPONENTS_DIR}}/   # UI 컴포넌트 (프론트엔드 시)
│   ├── services/             # 비즈니스 로직
│   ├── lib/                  # 유틸리티
│   ├── types/                # 타입 정의
│   └── hooks/                # 커스텀 훅 (프론트엔드 시)
├── {{DB_DIR}}/               # DB 스키마/마이그레이션
├── tests/
│   ├── unit/
│   ├── integration/
│   └── fixtures/
└── .claude/
```

## 파일 배치 원칙

- API 엔드포인트 → 라우터/컨트롤러 디렉토리
- 비즈니스 로직 → services/ (API 핸들러에 로직 직접 안 씀)
- DB 쿼리 → services 안에서 ORM 직접 호출 (별도 repository 불필요한 경우)
- 공통 유틸 → lib/
- 컴포넌트 → components/{도메인}/

## 금지 패턴

- 순환 참조: services 간 서로 import 금지 → 공통 로직은 lib/로
- 3단계 이상 중첩 디렉토리 금지 (components/a/b/c/ ❌)
- API 핸들러에 비즈니스 로직 직접 작성 금지 → services/ 호출만

## 새 디렉토리 생성 시

- 기존 구조에 맞는 위치인지 먼저 확인
- 파일 3개 미만이면 디렉토리 생성 대신 기존 폴더에 배치
