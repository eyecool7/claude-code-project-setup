#!/bin/bash
# validate-setup.sh — 생성된 설정 파일을 검증한다.
# Usage: bash scripts/validate-setup.sh [project-root]
# 실패 시 구체적 에러 메시지 출력. Claude가 읽고 수정할 수 있도록.

ROOT="${1:-.}"
ERRORS=0

echo "=== Setup Validation ==="
echo ""

# --- 1. CLAUDE.md 존재 ---
if [ ! -f "$ROOT/CLAUDE.md" ]; then
  echo "❌ CLAUDE.md not found at project root"
  ERRORS=$((ERRORS + 1))
else
  # --- 2. CLAUDE.md 줄 수 ---
  LINE_COUNT=$(wc -l < "$ROOT/CLAUDE.md")
  if [ "$LINE_COUNT" -gt 80 ]; then
    echo "❌ CLAUDE.md is ${LINE_COUNT} lines (max: 80). Use @imports for detailed rules."
    ERRORS=$((ERRORS + 1))
  else
    echo "✅ CLAUDE.md: ${LINE_COUNT} lines"
  fi

  # --- 3. 미치환 변수 체크 ---
  UNREPLACED=$(grep -c '{{[A-Z_]*}}' "$ROOT/CLAUDE.md" 2>/dev/null || echo 0)
  if [ "$UNREPLACED" -gt 0 ]; then
    echo "❌ CLAUDE.md has ${UNREPLACED} unreplaced {{VARIABLE}} placeholders:"
    grep -n '{{[A-Z_]*}}' "$ROOT/CLAUDE.md"
    ERRORS=$((ERRORS + 1))
  else
    echo "✅ No unreplaced variables"
  fi

  # --- 3a. TODO/Placeholder 잔존 체크 ---
  TODO_COUNT=0
  for CHECK_FILE in "$ROOT/CLAUDE.md" "$ROOT"/.claude/skills/*/SKILL.md "$ROOT"/.claude/agents/*.md "$ROOT"/.claude/hooks/*.sh "$ROOT"/.claude/commands/*.md; do
    if [ -f "$CHECK_FILE" ]; then
      FOUND=$(grep -cinE '(TODO|FIXME|PLACEHOLDER|여기에 작성|여기를 채)' "$CHECK_FILE" 2>/dev/null || echo 0)
      if [ "$FOUND" -gt 0 ]; then
        echo "❌ TODO/Placeholder found in $(basename "$CHECK_FILE"):"
        grep -niE '(TODO|FIXME|PLACEHOLDER|여기에 작성|여기를 채)' "$CHECK_FILE" | head -3
        TODO_COUNT=$((TODO_COUNT + FOUND))
      fi
    fi
  done
  if [ "$TODO_COUNT" -gt 0 ]; then
    ERRORS=$((ERRORS + 1))
  else
    echo "✅ No TODO/Placeholder残留"
  fi

  # --- 3b. Skills frontmatter 검증 ---
  for SKILL_DIR in "$ROOT"/.claude/skills/*/; do
    SKILL_FILE="$SKILL_DIR/SKILL.md"
    if [ -f "$SKILL_FILE" ]; then
      if ! grep -q "^---" "$SKILL_FILE"; then
        echo "❌ Missing YAML frontmatter: $SKILL_FILE"
        ERRORS=$((ERRORS + 1))
      elif ! grep -q "^description:" "$SKILL_FILE"; then
        echo "❌ Missing description in frontmatter: $SKILL_FILE (Claude can't auto-discover)"
        ERRORS=$((ERRORS + 1))
      fi
    fi
  done
  SKILL_COUNT=$(find "$ROOT/.claude/skills" -name "SKILL.md" 2>/dev/null | wc -l)
  if [ "$SKILL_COUNT" -gt 0 ]; then
    echo "✅ Skills: ${SKILL_COUNT} found with frontmatter"
  fi

  # --- 3c. Claude가 이미 아는 패턴 감지 ---
  KNOWN_PATTERNS=(
    "하드코딩.*금지"
    "import 순서"
    "kebab.case"
    "any.*금지"
    "PascalCase"
    "mobile.first"
    "alt.*img"
    "aria-label"
    "server.*측.*검증.*필수"
    "ORM.*파라미터.*바인딩"
  )
  KNOWN_COUNT=0
  for PATTERN in "${KNOWN_PATTERNS[@]}"; do
    if grep -qiE "$PATTERN" "$ROOT/CLAUDE.md" 2>/dev/null; then
      echo "⚠️ Claude-already-knows: '$PATTERN' — remove if not causing mistakes"
      KNOWN_COUNT=$((KNOWN_COUNT + 1))
    fi
  done
  if [ "$KNOWN_COUNT" -eq 0 ]; then
    echo "✅ No Claude-already-knows patterns found"
  fi
fi

# --- 4. settings.json 유효성 ---
SETTINGS="$ROOT/.claude/settings.json"
if [ ! -f "$SETTINGS" ]; then
  echo "❌ .claude/settings.json not found"
  ERRORS=$((ERRORS + 1))
else
  if command -v python3 &>/dev/null; then
    if python3 -c "import json; json.load(open('$SETTINGS'))" 2>/dev/null; then
      echo "✅ settings.json is valid JSON"
    else
      echo "❌ settings.json is invalid JSON"
      ERRORS=$((ERRORS + 1))
    fi
  elif command -v node &>/dev/null; then
    if node -e "JSON.parse(require('fs').readFileSync('$SETTINGS','utf8'))" 2>/dev/null; then
      echo "✅ settings.json is valid JSON"
    else
      echo "❌ settings.json is invalid JSON"
      ERRORS=$((ERRORS + 1))
    fi
  else
    echo "⚠️ Cannot validate JSON (no python3 or node). Skipping."
  fi
fi

# --- 5. 필수 파일 존재 ---
REQUIRED_FILES=(
  ".claude/commands/review.md"
  ".claude/commands/check.md"
  ".claude/commands/commit-push-pr.md"
  ".claude/hooks/session-start.sh"
  ".claude/hooks/edit-monitor.sh"
  ".claude/hooks/pre-commit-check.sh"
  ".claude/skills/error-handling/SKILL.md"
  ".claude/skills/security/SKILL.md"
  ".claude/skills/testing/SKILL.md"
  ".claude/agents/test-runner.md"
  ".claude/agents/code-reviewer.md"
  ".claude/agents/debugger.md"
  ".claude/lessons.md"
  ".claude/decisions.md"
)

for FILE in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$ROOT/$FILE" ]; then
    echo "❌ Missing: $FILE"
    ERRORS=$((ERRORS + 1))
  fi
done

echo "✅ Required files: checked ${#REQUIRED_FILES[@]} paths"

# --- 6. Hook 실행 권한 ---
for HOOK in "$ROOT"/.claude/hooks/*.sh; do
  if [ -f "$HOOK" ] && [ ! -x "$HOOK" ]; then
    echo "⚠️ Hook not executable: $HOOK (run: chmod +x $HOOK)"
  fi
done

# --- 7. CLAUDE.md 내 참조 경로 검증 ---
if [ -f "$ROOT/CLAUDE.md" ]; then
  # .claude/ 경로 참조 추출 후 존재 여부 확인
  REFS=$(grep -oE '`\.claude/[^`]+`' "$ROOT/CLAUDE.md" | sed 's/`//g' | sort -u)
  for REF in $REFS; do
    if [ ! -e "$ROOT/$REF" ]; then
      echo "❌ CLAUDE.md references '$REF' but file not found"
      ERRORS=$((ERRORS + 1))
    fi
  done
fi

# --- 결과 ---
echo ""
if [ "$ERRORS" -eq 0 ]; then
  echo "✅ All checks passed"
else
  echo "❌ ${ERRORS} error(s) found. Fix and rerun."
fi

exit $ERRORS
