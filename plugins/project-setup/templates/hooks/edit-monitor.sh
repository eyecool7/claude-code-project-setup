#!/bin/bash
# PostToolUse hook — 수정 패턴 모니터링
# stdin에서 JSON 입력을 받아 파일 경로를 추출한다.

EDIT_LOG=".claude/cache/edit-log.jsonl"
mkdir -p "$(dirname "$EDIT_LOG")"

# stdin에서 파일 경로 추출
INPUT=$(cat)
CURRENT_FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

# 파일 경로가 없으면 종료
if [ -z "$CURRENT_FILE" ]; then
  exit 0
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# 기록
echo "{\"file\":\"$CURRENT_FILE\",\"time\":\"$TIMESTAMP\"}" >> "$EDIT_LOG"

# 10분 내 같은 파일 3회 이상 수정 → 재검토 제안
TEN_MIN_AGO=$(date -u -v-10M +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -d '10 minutes ago' +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null)
if [ -n "$TEN_MIN_AGO" ]; then
  RECENT_COUNT=$(grep "\"$CURRENT_FILE\"" "$EDIT_LOG" 2>/dev/null | awk -F'"time":"' '{print $2}' | cut -d'"' -f1 | awk -v cutoff="$TEN_MIN_AGO" '$1 >= cutoff' | wc -l)
  if [ "$RECENT_COUNT" -ge 3 ]; then
    echo "💡 이 파일을 10분 내 ${RECENT_COUNT}회 수정했습니다."
    echo "   → 에러 메시지를 다시 읽어보세요"
    echo "   → 접근 방식 자체가 틀렸을 수 있습니다 (Plan Mode 전환 고려)"
  fi
fi

exit 0
