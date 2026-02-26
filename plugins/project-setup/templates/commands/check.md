---
name: check
description: 빠른 상태 체크. 타입+린트+테스트 한 줄 요약.
---
빠른 상태 체크:
1. 타입 체크 (`{{PKG_MANAGER}} run typecheck` 또는 `npx tsc --noEmit`)
2. 린트 (`{{PKG_MANAGER}} run lint`)
3. 테스트 (`{{PKG_MANAGER}} run test`)

한 줄 요약: "✅ 전체 통과" 또는 "❌ typecheck 실패 (3건)"
실패 시 핵심 에러만 요약하고 수정 제안.
