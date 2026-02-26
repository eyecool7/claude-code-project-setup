---
name: design-rules
description: UI 컴포넌트 생성, 스타일링, 색상/폰트/레이아웃 결정, 반응형 구현, 다크모드, 접근성 작업 시 사용. 프론트엔드 프로젝트 전용.
user-invocable: false
---

# 디자인 규칙

> ⚠️ 조건부: 프론트엔드 포함 프로젝트에서만 생성

## 디자인 시스템

### 60-30-10 Rule
- 60% 배경: 화이트/뉴트럴
- 30% 서브: 프라이머리 계열
- 10% 포인트: 액센트 (CTA, 강조)

### 색상 제한
- 원색(순수 빨강/파랑/초록) 직접 사용 금지 → 톤 조절된 팔레트 사용

### AI 디자인 키워드 사전

> AI에게 "예쁘게 해줘"는 매번 다른 결과. 키워드를 정의하면 일관성 유지.

색상 전략 (setup 시 1개 선택):
- Monochromatic → 한 색의 명도/채도 변형만
- Neutral + Accent → 무채색 배경 + 포인트 컬러 1개
- Duotone → 2컬러 조합

아이콘 스타일 (setup 시 1개 선택):
- Monoline / Outlined / Filled / Duotone / Isometric

그라데이션 키워드:
- GrainyGradient → 노이즈 텍스처 (종이 느낌)
- AuroraBackground → 블러 처리된 컬러 볼륨
- MeshGradient → 유기적 다중 색상 흐름

### 다크모드
<!-- TODO: setup 시 결정: CSS 변수 / Tailwind dark: / 미지원 -->

---

## 테마 토큰

### 색상 토큰
<!-- TODO: tailwind.config.ts / CSS 변수 / theme.ts에서 자동 추출 -->
```
colors: {
  primary: { /* TODO */ },
  secondary: { /* TODO */ },
  accent: { /* TODO */ },
}
```

---

## 관련 Rules (자동 로드)

아래 규칙은 `.claude/rules/`에서 path 매칭으로 자동 적용된다:
- 컴포넌트 구조, Props, 접근성, 상태 관리 → `.claude/rules/frontend/react.md`
- 폰트 스케일, 브레이크포인트, 그림자/라운딩, 스페이싱 → `.claude/rules/frontend/styles.md`
