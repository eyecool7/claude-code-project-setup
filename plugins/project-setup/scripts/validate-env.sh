#!/bin/bash
# validate-env.sh — .env 파일과 API 키의 기본 위생 검사
# Usage: bash scripts/validate-env.sh [project-root]
# 실제 API 호출은 하지 않음. 형식·인코딩 문제만 감지.
# ⚠️ 보안: 환경 변수의 키(Key) 이름만 출력. 값(Value)은 절대 출력하지 않음.

ROOT="${1:-.}"
ERRORS=0
WARNINGS=0

echo "=== Environment Validation ==="
echo ""

# --- 1. .env 파일 존재 ---
ENV_FILE="$ROOT/.env"
ENV_LOCAL="$ROOT/.env.local"
ENV_FOUND=""

if [ -f "$ENV_FILE" ]; then
  ENV_FOUND="$ENV_FILE"
elif [ -f "$ENV_LOCAL" ]; then
  ENV_FOUND="$ENV_LOCAL"
fi

if [ -z "$ENV_FOUND" ]; then
  echo "⚠️ .env 파일 없음. 환경 변수가 다른 방식으로 관리되는지 확인하세요."
  WARNINGS=$((WARNINGS + 1))
else
  echo "✅ 환경 변수 파일: $ENV_FOUND"

  # --- 2. 숨겨진 문자 감지 (줄바꿈, 탭, 캐리지 리턴) ---
  # Vercel 등에서 복사 시 \r\n이 섞이는 문제 감지
  # macOS BSD grep은 -P 미지원이므로 perl 사용
  if perl -ne 'exit 1 if /[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]/' "$ENV_FOUND" 2>/dev/null; then
    echo "✅ 숨겨진 문자 없음"
  elif [ $? -eq 1 ]; then
    echo "❌ 숨겨진 제어 문자 발견:"
    perl -nle 'if (/[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]/) { /^([^=]+=)/; print "$.: $1***" }' "$ENV_FOUND" | head -5
    echo "   → 해결: 해당 줄을 직접 타이핑으로 재입력"
    ERRORS=$((ERRORS + 1))
  fi
  # Windows 줄바꿈 감지
  if perl -ne 'exit 1 if /\r/' "$ENV_FOUND" 2>/dev/null; [ $? -eq 1 ]; then
    echo "⚠️ Windows 줄바꿈(\\r) 발견. Unix 형식으로 변환 권장:"
    echo "   → sed -i '' 's/\\r\$//' $ENV_FOUND"
    WARNINGS=$((WARNINGS + 1))
  fi

  # --- 3. 값에 감싸진 따옴표 감지 ---
  # KEY="value" 형태에서 쉘이 따옴표를 값에 포함시키는 문제
  QUOTE_ISSUES=$(grep -nE "^[A-Za-z_][A-Za-z0-9_]*=(['\"])[^'\"]*\1\s*$" "$ENV_FOUND" 2>/dev/null | grep -vE "^[A-Za-z_][A-Za-z0-9_]*=''" | grep -vE '^[A-Za-z_][A-Za-z0-9_]*=""' | wc -l)
  # 더 정확한 감지: 값이 따옴표로 시작하고 끝나되 내용에 공백이 없는 경우
  SUSPICIOUS_QUOTES=$(grep -nE '^[A-Za-z_][A-Za-z0-9_]*="[^"]*"' "$ENV_FOUND" 2>/dev/null | wc -l)
  if [ "$SUSPICIOUS_QUOTES" -gt 0 ]; then
    echo "⚠️ 따옴표로 감싸진 값 ${SUSPICIOUS_QUOTES}건 — Docker/Vercel에서 따옴표가 값에 포함될 수 있음:"
    grep -nE '^[A-Za-z_][A-Za-z0-9_]*="[^"]*"' "$ENV_FOUND" | sed 's/=.*/=***/' | head -3
    echo "   → 대부분의 경우 따옴표 제거가 안전: KEY=value (공백 없으면)"
    WARNINGS=$((WARNINGS + 1))
  fi

  # --- 4. 빈 값 감지 ---
  EMPTY_KEYS=$(grep -nE '^[A-Za-z_][A-Za-z0-9_]*=\s*$' "$ENV_FOUND" 2>/dev/null | sed 's/=.*//')
  if [ -n "$EMPTY_KEYS" ]; then
    EMPTY_COUNT=$(echo "$EMPTY_KEYS" | wc -l)
    echo "⚠️ 빈 값 ${EMPTY_COUNT}건:"
    echo "$EMPTY_KEYS" | head -5
    WARNINGS=$((WARNINGS + 1))
  fi

  # --- 5. 중복 키 감지 ---
  DUPES=$(grep -oE '^[A-Za-z_][A-Za-z0-9_]*=' "$ENV_FOUND" 2>/dev/null | sort | uniq -d)
  if [ -n "$DUPES" ]; then
    echo "❌ 중복 키 발견 (마지막 값만 적용됨):"
    echo "$DUPES"
    ERRORS=$((ERRORS + 1))
  fi

  # --- 6. .gitignore 확인 ---
  if [ -f "$ROOT/.gitignore" ]; then
    if grep -qE '\.env' "$ROOT/.gitignore" 2>/dev/null; then
      echo "✅ .env가 .gitignore에 포함됨"
    else
      echo "❌ .env가 .gitignore에 없음 — 시크릿 유출 위험!"
      ERRORS=$((ERRORS + 1))
    fi
  fi
fi

# --- 7. package.json의 외부 SDK와 .env 키 교차 확인 ---
PKG="$ROOT/package.json"
if [ -f "$PKG" ] && [ -n "$ENV_FOUND" ]; then
  echo ""
  echo "=== SDK ↔ 환경 변수 교차 확인 ==="

  # 주요 SDK → 기대 환경 변수 매핑 (bash 3.2 호환)
  SDK_NAMES="openai @anthropic-ai/sdk @google/generative-ai resend @sendgrid stripe firebase @supabase/supabase-js @prisma/client @aws-sdk"

  get_expected_keys() {
    case "$1" in
      openai) echo "OPENAI_API_KEY" ;;
      @anthropic-ai/sdk) echo "ANTHROPIC_API_KEY" ;;
      @google/generative-ai) echo "GEMINI_API_KEY|GOOGLE_API_KEY" ;;
      resend) echo "RESEND_API_KEY" ;;
      @sendgrid) echo "SENDGRID_API_KEY" ;;
      stripe) echo "STRIPE_SECRET_KEY|STRIPE_PUBLISHABLE_KEY" ;;
      firebase) echo "FIREBASE_API_KEY|FIREBASE_PROJECT_ID" ;;
      @supabase/supabase-js) echo "SUPABASE_URL|SUPABASE_ANON_KEY" ;;
      @prisma/client) echo "DATABASE_URL" ;;
      @aws-sdk) echo "AWS_ACCESS_KEY_ID|AWS_SECRET_ACCESS_KEY" ;;
    esac
  }

  for SDK in $SDK_NAMES; do
    if grep -q "\"$SDK\"" "$PKG" 2>/dev/null; then
      EXPECTED_KEYS=$(get_expected_keys "$SDK")
      FOUND_ANY=false
      OLD_IFS="$IFS"; IFS='|'
      for KEY in $EXPECTED_KEYS; do
        if grep -qE "^${KEY}=" "$ENV_FOUND" 2>/dev/null; then
          FOUND_ANY=true
        fi
      done
      IFS="$OLD_IFS"
      if [ "$FOUND_ANY" = false ]; then
        echo "⚠️ ${SDK} 설치됨 → ${EXPECTED_KEYS} 중 하나가 .env에 없음"
        WARNINGS=$((WARNINGS + 1))
      else
        echo "✅ ${SDK} → 환경 변수 확인됨"
      fi
    fi
  done

  # --- 8. Supabase SSL 검증 ---
  if grep -q '"@supabase/supabase-js"' "$PKG" 2>/dev/null || grep -q '"@prisma/client"' "$PKG" 2>/dev/null; then
    DB_URL_LINE=$(grep -E '^DATABASE_URL=' "$ENV_FOUND" 2>/dev/null | head -1)
    if [ -n "$DB_URL_LINE" ]; then
      if echo "$DB_URL_LINE" | grep -qi 'supabase'; then
        if echo "$DB_URL_LINE" | grep -qi 'sslmode'; then
          echo "✅ Supabase DATABASE_URL에 sslmode 설정됨"
        else
          echo "❌ Supabase DATABASE_URL에 sslmode 없음 — 중간자 공격(MITM) 위험!"
          echo "   → 해결: Supabase 대시보드 → Database → SSL Enforcement 활성화"
          echo "   → DATABASE_URL에 ?sslmode=verify-full 추가"
          echo "   → SSL 인증서: 대시보드 → Database → Connection info → Download Certificate"
          ERRORS=$((ERRORS + 1))
        fi
      fi
    fi
  fi
fi

# --- 결과 ---
echo ""
if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
  echo "✅ 환경 변수 검증 통과"
elif [ "$ERRORS" -eq 0 ]; then
  echo "⚠️ ${WARNINGS}건 경고. 에러는 없음."
else
  echo "❌ ${ERRORS}건 에러, ${WARNINGS}건 경고. 수정 후 재실행."
fi

exit $ERRORS
