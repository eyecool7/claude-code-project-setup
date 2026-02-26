#!/bin/bash
# SessionStart hook — 컨텍스트 로드 + 설정 변경 감지

mkdir -p .claude/cache

HASH_FILE=".claude/cache/.config-hash"
CONTEXT_FILE=".claude/cache/project-context.md"

# 디렉토리 확인
echo "📂 작업 디렉토리: $(pwd)"

# Hash 체크
if [ ! -f "$HASH_FILE" ]; then
  # 최초 세션: hash 생성만, refresh 스킵
  if command -v md5sum &>/dev/null; then
    md5sum CLAUDE.md .claude/settings.json 2>/dev/null | md5sum | cut -d' ' -f1 > "$HASH_FILE"
  elif command -v md5 &>/dev/null; then
    cat CLAUDE.md .claude/settings.json 2>/dev/null | md5 > "$HASH_FILE"
  fi
  echo "📎 첫 세션 감지. 설정 hash 생성 완료."
else
  if command -v md5sum &>/dev/null; then
    CURRENT_HASH=$(md5sum CLAUDE.md .claude/settings.json 2>/dev/null | md5sum | cut -d' ' -f1)
  elif command -v md5 &>/dev/null; then
    CURRENT_HASH=$(cat CLAUDE.md .claude/settings.json 2>/dev/null | md5)
  fi
  SAVED_HASH=$(cat "$HASH_FILE" 2>/dev/null)
  if [ -n "$CURRENT_HASH" ] && [ "$CURRENT_HASH" != "$SAVED_HASH" ]; then
    echo "⚠️ 설정이 변경되었습니다. /refresh 실행을 권장합니다."
  fi
fi

# 컨텍스트 로드
if [ -f "$CONTEXT_FILE" ]; then
  LINE_COUNT=$(wc -l < "$CONTEXT_FILE")
  echo "📎 프로젝트 컨텍스트 로드 완료 (${LINE_COUNT}줄)"
fi

# Lessons 로드
LESSONS_FILE=".claude/lessons.md"
if [ -f "$LESSONS_FILE" ]; then
  LESSON_COUNT=$(grep -c "^### " "$LESSONS_FILE" 2>/dev/null || echo "0")
  if [ "$LESSON_COUNT" -gt 0 ]; then
    echo "📎 Lessons: ${LESSON_COUNT}건 — 최근 기록:"
    grep -B0 -A3 "^### " "$LESSONS_FILE" | tail -20
  fi
fi

exit 0
