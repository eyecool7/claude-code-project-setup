#!/bin/bash
# PreToolUse hook — git commit 전 빌드 검증
# Bash 도구의 모든 호출에서 실행되며, git commit인 경우에만 검증 수행.
# 실패 시 exit 2로 도구 호출 차단.

# stdin에서 JSON 입력 읽기
INPUT=$(cat)

# Bash 명령어 추출
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# git commit이 아니면 통과
if ! echo "$COMMAND" | grep -qE '^\s*git\s+commit'; then
  exit 0
fi

# typecheck + lint + test 실행
if {{TYPECHECK_CMD}} && {{LINT_CMD}} && {{TEST_CMD}}; then
  echo "✅ 검증 통과. 커밋 진행."
  exit 0
else
  echo "❌ 검증 실패. 에러를 수정하고 다시 커밋하세요."
  exit 2
fi
