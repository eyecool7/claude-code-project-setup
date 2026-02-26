---
paths:
  - "**/*.css"
  - "**/*.scss"
  - "**/*.module.css"
  - "tailwind.config.*"
  - "**/*.tsx"
---

# 스타일 규칙

## 60-30-10 Rule

- 60% 배경: 화이트/뉴트럴
- 30% 서브: 프라이머리 계열
- 10% 포인트: 액센트 (CTA, 강조)

## 색상 제한

- 원색(순수 빨강/파랑/초록) 직접 사용 금지 → 톤 조절된 팔레트 사용

## 폰트 사이즈 스케일

<!-- TODO: 프레임워크 기본 또는 커스텀 -->
- xs (12px) — 메타 정보
- sm (14px) — 보조 텍스트
- base (16px) — 본문
- lg (18px) — 카드 제목
- xl (20px) — 섹션 제목
- 2xl~ — 히어로/강조

## 브레이크포인트

```
sm: 640px    — 모바일
md: 768px    — 태블릿
lg: 1024px   — 데스크탑
xl: 1280px   — 와이드
```

## 그림자/라운딩

- 카드: rounded-lg shadow-sm hover:shadow-md
- 모달: rounded-lg shadow-xl
- 배지: rounded-full
- 버튼: rounded-md

## 스페이싱

- 아이템 간 간격: 최소 16px
- 섹션 간 간격: 최소 32px
- 카드/아이템 그리드: 반응형 (1/2/3열)
