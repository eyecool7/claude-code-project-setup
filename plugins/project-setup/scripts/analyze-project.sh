#!/bin/bash
# analyze-project.sh — 프로젝트를 결정론적으로 분석하여 변수를 출력한다.
# Usage: bash scripts/analyze-project.sh [project-root]
# Output: KEY=VALUE 형식 (Claude가 파싱하여 CLAUDE.md 생성에 사용)

ROOT="${1:-.}"
PKG="$ROOT/package.json"

echo "=== Project Analysis ==="
echo ""

# --- 패키지 매니저 ---
if [ -f "$ROOT/bun.lockb" ] || [ -f "$ROOT/bun.lock" ]; then
  echo "PKG_MANAGER=bun"
elif [ -f "$ROOT/pnpm-lock.yaml" ]; then
  echo "PKG_MANAGER=pnpm"
elif [ -f "$ROOT/yarn.lock" ]; then
  echo "PKG_MANAGER=yarn"
else
  echo "PKG_MANAGER=npm"
fi

# --- 프론트엔드 감지 ---
HAS_FRONTEND=false
if [ -f "$PKG" ]; then
  if grep -qE '"(react|next|vue|svelte|angular|nuxt|remix|solid-js)"' "$PKG" 2>/dev/null; then
    HAS_FRONTEND=true
  fi
fi
# next.config 존재로도 감지
if [ -f "$ROOT/next.config.js" ] || [ -f "$ROOT/next.config.ts" ] || [ -f "$ROOT/next.config.mjs" ]; then
  HAS_FRONTEND=true
fi
echo "HAS_FRONTEND=$HAS_FRONTEND"

# --- 백엔드 감지 ---
HAS_BACKEND=false
if [ -f "$PKG" ]; then
  if grep -qE '"(express|fastify|nest|koa|hono|@trpc)"' "$PKG" 2>/dev/null; then
    HAS_BACKEND=true
  fi
fi
# Next.js app router의 api/ 존재로도 감지
if [ -d "$ROOT/src/app/api" ] || [ -d "$ROOT/app/api" ] || [ -d "$ROOT/pages/api" ]; then
  HAS_BACKEND=true
fi
echo "HAS_BACKEND=$HAS_BACKEND"

# --- 모노레포 감지 ---
IS_MONOREPO=false
if [ -f "$ROOT/turbo.json" ] || [ -f "$ROOT/lerna.json" ] || [ -f "$ROOT/pnpm-workspace.yaml" ]; then
  IS_MONOREPO=true
fi
echo "IS_MONOREPO=$IS_MONOREPO"

# --- 포맷터 감지 ---
HAS_FORMATTER=false
FORMATTER_TYPE="none"
if ls "$ROOT"/.prettierrc* "$ROOT"/prettier.config.* 2>/dev/null | grep -q .; then
  HAS_FORMATTER=true
  FORMATTER_TYPE="prettier"
elif [ -f "$ROOT/biome.json" ] || [ -f "$ROOT/biome.jsonc" ]; then
  HAS_FORMATTER=true
  FORMATTER_TYPE="biome"
fi
echo "HAS_FORMATTER=$HAS_FORMATTER"
echo "FORMATTER_TYPE=$FORMATTER_TYPE"

# --- 인증 시스템 감지 ---
HAS_AUTH=false
if [ -f "$PKG" ]; then
  if grep -qE '"(next-auth|@auth/|@clerk|lucia|passport|jsonwebtoken|jose|bcrypt)"' "$PKG" 2>/dev/null; then
    HAS_AUTH=true
  fi
fi
echo "HAS_AUTH=$HAS_AUTH"

# --- ORM/DB 감지 ---
ORM_TYPE="none"
if [ -f "$ROOT/prisma/schema.prisma" ]; then
  ORM_TYPE="prisma"
elif [ -f "$PKG" ] && grep -qE '"drizzle-orm"' "$PKG" 2>/dev/null; then
  ORM_TYPE="drizzle"
elif [ -f "$PKG" ] && grep -qE '"mongoose"' "$PKG" 2>/dev/null; then
  ORM_TYPE="mongoose"
elif [ -f "$PKG" ] && grep -qE '"typeorm"' "$PKG" 2>/dev/null; then
  ORM_TYPE="typeorm"
fi
echo "ORM_TYPE=$ORM_TYPE"

# --- 외부 API 수 추정 ---
EXTERNAL_API_COUNT=0
if [ -f "$PKG" ]; then
  # 주요 외부 서비스 SDK 패턴 카운팅
  EXTERNAL_API_COUNT=$(grep -cE '"(openai|@anthropic|resend|@sendgrid|stripe|@aws-sdk|@google-cloud|@supabase|firebase|twilio|@slack)"' "$PKG" 2>/dev/null || echo 0)
fi
echo "EXTERNAL_API_COUNT=$EXTERNAL_API_COUNT"

# --- 테스트 프레임워크 감지 ---
TEST_FRAMEWORK="none"
if [ -f "$PKG" ]; then
  if grep -qE '"vitest"' "$PKG" 2>/dev/null; then
    TEST_FRAMEWORK="vitest"
  elif grep -qE '"jest"' "$PKG" 2>/dev/null; then
    TEST_FRAMEWORK="jest"
  elif grep -qE '"@playwright"' "$PKG" 2>/dev/null; then
    TEST_FRAMEWORK="playwright"
  fi
fi
echo "TEST_FRAMEWORK=$TEST_FRAMEWORK"

# --- 의존성 호환성 충돌 감지 ---
echo ""
echo "=== Compatibility Checks ==="

CONFLICTS=""

if [ -f "$PKG" ]; then
  # Remotion + Next.js → serverExternalPackages 필요
  if grep -qE '"remotion"' "$PKG" 2>/dev/null && grep -qE '"next"' "$PKG" 2>/dev/null; then
    CONFLICTS="${CONFLICTS}REMOTION_NEXTJS: Remotion + Next.js detected. Add serverExternalPackages: ['remotion', '@remotion/cli'] to next.config.\n"
  fi

  # Prisma + Edge Runtime
  if grep -qE '"@prisma/client"' "$PKG" 2>/dev/null; then
    # edge runtime 사용 여부는 코드 스캔 필요하지만, 경고만 출력
    if grep -rqE "runtime.*=.*['\"]edge['\"]" "$ROOT/src" 2>/dev/null; then
      CONFLICTS="${CONFLICTS}PRISMA_EDGE: Prisma + Edge Runtime detected. Use @prisma/adapter-* or prisma generate --accelerate.\n"
    fi
  fi

  # Sharp + Vercel/Serverless
  if grep -qE '"sharp"' "$PKG" 2>/dev/null && grep -qE '"next"' "$PKG" 2>/dev/null; then
    CONFLICTS="${CONFLICTS}SHARP_NEXTJS: Sharp + Next.js detected. May need outputFileTracing config for serverless deployment.\n"
  fi

  # Tailwind v4 + PostCSS tailwindcss plugin (중복 처리)
  if grep -qE '"tailwindcss".*"4\.' "$PKG" 2>/dev/null; then
    if [ -f "$ROOT/postcss.config.js" ] || [ -f "$ROOT/postcss.config.mjs" ]; then
      if grep -qE "tailwindcss" "$ROOT"/postcss.config.* 2>/dev/null; then
        CONFLICTS="${CONFLICTS}TAILWIND_V4_POSTCSS: Tailwind v4 + PostCSS tailwindcss plugin detected. v4 handles PostCSS internally; remove plugin.\n"
      fi
    fi
  fi
fi

if [ -z "$CONFLICTS" ]; then
  echo "NO_CONFLICTS"
else
  echo -e "$CONFLICTS"
fi

# --- 핵심 디렉토리 ---
echo ""
echo "=== Key Directories ==="
# src 하위 2레벨까지 디렉토리 출력
if [ -d "$ROOT/src" ]; then
  find "$ROOT/src" -maxdepth 2 -type d | head -15
elif [ -d "$ROOT/app" ]; then
  find "$ROOT/app" -maxdepth 2 -type d | head -15
else
  find "$ROOT" -maxdepth 2 -type d -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/.next/*' | head -15
fi

echo ""
echo "=== Analysis Complete ==="
