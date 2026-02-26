---
description: 프로젝트 계획서(project-plan.md) 기반으로 CLAUDE.md + .claude/ 설정 자동 생성. 셋업, 세팅, init, setup, configure project 시 사용.
---

# 프로젝트 초기 세팅

프로젝트를 분석하고 Claude Code 설정 파일을 생성한다.

**전제 조건:** 프로젝트 계획서(`project-plan.md`)가 프로젝트 루트에 이미 존재해야 한다.
이 커맨드는 계획서를 만들지 않는다 — 소비할 뿐이다.
계획서 작성은 `/project-setup:plan` → `/project-setup:refine` 순서로 진행한다.

## 플러그인 경로 초기화

먼저 플러그인 루트 경로를 읽는다:

```bash
PLUGIN_ROOT=$(cat /tmp/.project-setup-root 2>/dev/null)
if [ -z "$PLUGIN_ROOT" ]; then
  echo "❌ 플러그인 루트를 찾을 수 없습니다. Claude Code를 재시작하세요."
  exit 1
fi
echo "✅ 플러그인 경로: $PLUGIN_ROOT"
```

이후 모든 템플릿/스크립트 참조는 `$PLUGIN_ROOT` 기반으로 한다.

## 세션 전략 (2-Session 워크플로우)

1. **세션 1 — 기획:** `/project-setup:plan` + `/project-setup:refine`으로 계획서 작성 → 파일 저장 → 세션 종료
2. **세션 2 — 구현:** 새 세션 시작 → `/project-setup:setup` → 이 커맨드 실행

기획 대화의 수정 히스토리가 구현 컨텍스트를 오염시키므로 반드시 분리.

## 사용 케이스

1. 계획서가 준비된 신규 프로젝트 → 분석 → CLAUDE.md + .claude/ 생성
2. Claude Code 설정이 필요한 기존 프로젝트 → 코드베이스 분석 → 설정 생성
3. 특수 의존성(Remotion, Prisma+Edge 등)이 있는 프로젝트 → 충돌 감지 → 경고 포함 설정 생성

## 워크플로우

### Step 1: 프로젝트 분석 실행

```bash
PLUGIN_ROOT=$(cat /tmp/.project-setup-root)
bash "$PLUGIN_ROOT/scripts/analyze-project.sh"
bash "$PLUGIN_ROOT/scripts/validate-env.sh"
```

스크립트가 자동 감지하는 항목:
- `HAS_FRONTEND` / `HAS_BACKEND` (프레임워크 감지)
- `PKG_MANAGER` (락파일 감지)
- `HAS_FORMATTER` + 종류 (prettier/biome/eslint)
- `HAS_AUTH` (인증 라이브러리 감지)
- `EXTERNAL_API_COUNT` (외부 의존성 수)
- `CONFLICT_WARNINGS` (알려진 호환성 문제 패턴)

`validate-env.sh`가 추가 감지하는 항목:
- `.env` 파일 내 숨겨진 제어 문자 (줄바꿈, 캐리지 리턴)
- 따옴표로 감싸진 값 (Docker/Vercel 배포 시 문제 유발)
- 빈 값, 중복 키
- SDK ↔ 환경 변수 교차 확인 (SDK는 설치되어 있으나 키가 없는 경우)

스크립트 출력을 화면에 표시한 후, **반드시 사용자에게 "이 분석 결과로 세팅을 진행할까요?"라고 묻고 승인을 받은 뒤** Step 2로 넘어간다.
잘못된 감지가 있으면 사용자가 수정 지시 → 반영 후 재확인.

### Step 2: CLAUDE.md 생성

`$PLUGIN_ROOT/templates/claude-md-template.md`를 기반으로 변수를 채운다:
- **계획서** → 프로젝트명, 역할, 철학, 핵심 플로우
- **Step 1 출력** → 스택 상세, 핵심 경로, 개발 명령어, 권한
- **의존성 분석** → 충돌 경고, 주의사항

CLAUDE.md 생성 핵심 규칙:
- Claude가 이미 아는 정보는 넣지 않는다
- 주요 의존성의 실제 import 경로와 설정 코드를 포함한다 ("X 사용" 수준이 아니라)
- 의존성 충돌 감지 시 핵심 규칙 섹션에 ⚠️ 경고 추가
- **검증 섹션을 핵심 규칙 바로 다음에 배치** — 가장 중요한 3줄
- 목표: 55줄 내외. 80줄 절대 초과 금지.
- 수동적 규칙은 `.claude/rules/`에 분리 (자동 로드 + path 스코프), 능동적 워크플로우는 `.claude/skills/`에 분리

### Step 3: .claude/ 설정 생성

`$PLUGIN_ROOT/templates/` 의 템플릿에서 복사 후 프로젝트에 맞게 커스터마이징:

**{{변수}} 치환 원칙:** Step 1의 analyze-project.sh 출력값을 사용한다.
- `{{PKG_MANAGER}}` → 락파일 감지 결과 (bun.lockb → `bun`, pnpm-lock.yaml → `pnpm`, package-lock.json → `npm`)
- `{{TEST_CMD}}` → 테스트 프레임워크 감지 결과 (vitest → `bun test`, jest → `npm test` 등)
- `{{TYPECHECK_CMD}}` → TypeScript 있으면 `{{PKG_MANAGER}} run typecheck`, 없으면 제거
- `{{LINT_CMD}}` → 포매터 감지 결과 (biome → `biome check`, eslint → `eslint .` 등)

**TODO/Placeholder 금지:** 최종 생성 파일에 `TODO`, `FIXME`, `Placeholder`, `여기에 작성` 등이 남아있으면 안 된다. 계획서에 정보가 부족하면 합리적 기본값으로 채우고 `[추정]` 표시.

**항상 생성 (기본 18파일):**

Rules (수동적 규칙 — 자동 로드):

| 파일 | 커스터마이징 |
|------|------------|
| `rules/conventions.md` | 그대로 복사. 프로젝트 추가 컨벤션 있으면 추가. |
| `rules/security.md` | 템플릿 복사 후 TODO를 계획서 보안/인증 요구사항으로 채움. paths 스코프 유지. |
| `rules/error-handling.md` | 템플릿 복사 후 TODO를 계획서 에러 전략으로 채움. AppError 구조·에러 7종은 유지. |
| `rules/testing.md` | 템플릿 복사 후 프로젝트 테스트 도구·mock 대상으로 보강. 에러 7종 테스트는 유지. |

Skills (능동적 워크플로우 — Claude 자동 발견):

| 파일 | 커스터마이징 |
|------|------------|
| `skills/project-directory/SKILL.md` | 템플릿 복사 후 TODO를 실제 프로젝트 디렉토리 구조로 채움. |
| `skills/easy-refactoring/SKILL.md` | 그대로 복사. |
| `skills/skill-discovery/SKILL.md` | 그대로 복사. |

Settings/Commands/Hooks/Agents:

| 파일 | 커스터마이징 |
|------|------------|
| `settings.json` | PKG_MANAGER 기반 권한, pre-commit hook 명령어 |
| `commands/review.md` | 그대로 복사 |
| `commands/check.md` | {{PKG_MANAGER}} 치환 |
| `commands/commit-push-pr.md` | 그대로 복사 |
| `hooks/session-start.sh` | 그대로 복사 |
| `hooks/edit-monitor.sh` | 그대로 복사 |
| `hooks/pre-commit-check.sh` | {{TYPECHECK_CMD}}, {{LINT_CMD}}, {{TEST_CMD}} 치환 |
| `agents/test-runner.md` | {{TEST_CMD}} 치환 |
| `agents/code-reviewer.md` | 그대로 복사 |
| `agents/debugger.md` | 그대로 복사 |
| `lessons.md` | 그대로 복사 (빈 템플릿) |
| `decisions.md` | 그대로 복사 (빈 템플릿) |

**조건부 생성 (HAS_FRONTEND=true):**

| 파일 | 커스터마이징 |
|------|------------|
| `rules/frontend/react.md` | 템플릿 복사 후 프로젝트 컴포넌트 구조·도메인 폴더로 채움. |
| `rules/frontend/styles.md` | 템플릿 복사 후 프로젝트 디자인 토큰으로 채움. |
| `skills/design-rules/SKILL.md` | 템플릿 복사 후 TODO를 프로젝트 팔레트·다크모드로 채움. AI 디자인 키워드는 프로젝트에 맞게 1개씩 선택. |
| `skills/ui-ux-pro-max/` | 외부 스킬 설치. 아래 명령어 실행: |

```bash
git clone --depth 1 https://github.com/nextlevelbuilder/ui-ux-pro-max-skill.git /tmp/ui-ux-pro-max-skill
cp -r /tmp/ui-ux-pro-max-skill/.claude/skills/ui-ux-pro-max .claude/skills/
rm -rf /tmp/ui-ux-pro-max-skill
```

**조건부 생성 (HAS_BACKEND=true + DB 사용):**

| 파일 | 커스터마이징 |
|------|------------|
| `rules/database.md` | ORM 감지 결과 기반으로 채움. paths 스코프를 프로젝트 DB 경로로 조정. |

**조건부 생성 (의존성 주의사항 있을 때):**

| 파일 | 커스터마이징 |
|------|------------|
| `skills/dependencies/SKILL.md` | frontmatter 유지, 계획서 의존성 호환성 메모로 재작성. |

**조건부 생성 (계획서에 도메인 스킬이 정의된 경우):**

계획서 4번 "구현 설계"의 스킬 목록 테이블에 항목이 있으면, 각 스킬을 `.claude/skills/`에 생성한다.

| 파일 | 커스터마이징 |
|------|------------|
| `skills/{스킬명}/SKILL.md` | 계획서의 역할·트리거 조건을 기반으로 frontmatter + 규칙 작성. |

생성 규칙:
- `name`: 계획서 스킬명 (kebab-case)
- `description`: 계획서의 "역할" 열 (Claude 자동 발견용, 구체적으로)
- `user-invocable`: 사용자가 직접 `/스킬명`으로 호출하면 true, Claude가 자동 판단이면 false
- 본문: 계획서의 역할·트리거 조건·관련 기능 요구사항을 구체적 규칙으로 변환. TODO 남기지 않음.

**조건부 생성 (계획서 에이전트 Tier가 3 — Agent Teams인 경우):**

| 파일 | 커스터마이징 |
|------|------------|
| `commands/worktree.md` | 병렬 작업 시 worktree 생성·정리 가이드. |
| `skills/agent-teams/SKILL.md` | 팀 구성 가이드: TeamCreate 사용법, 태스크 분배 패턴, worktree 필수 규칙, 실험 기능 활성화 방법. |

### Step 3.5: .mcp.json 생성

계획서 3번 "MCP 서버 선정" 섹션에 확정된 `.mcp.json`이 있으면 그대로 사용한다.
없으면 스택 분석 결과와 계획서의 외부 서비스 목록을 기반으로 생성한다.

**형식:**
```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "package-name"],
      "env": {
        "API_KEY": "${API_KEY}"
      }
    }
  }
}
```

**생성 규칙:**
- 계획서에 확정된 `.mcp.json`이 있으면 그대로 복사 (가장 우선)
- API 키 등 시크릿은 반드시 `${ENV_VAR}` 형식 사용 (하드코딩 절대 금지)
- stdio 타입: `"command"`, `"args"` 구조
- HTTP 타입: `"type": "http"`, `"url"` 구조
- 계획서에 MCP 서버가 없으면 `.mcp.json` 생성 생략

### Step 4: 검증

```bash
PLUGIN_ROOT=$(cat /tmp/.project-setup-root)
bash "$PLUGIN_ROOT/scripts/validate-setup.sh"
bash "$PLUGIN_ROOT/scripts/validate-env.sh"
```

검증 항목:
- CLAUDE.md 존재 여부 및 80줄 이하 확인
- 치환되지 않은 `{{변수}}` 잔존 여부
- TODO/FIXME/Placeholder 잔존 여부 (모든 생성 파일 대상)
- 필수 `.claude/rules/` 파일 존재 + frontmatter 확인
- 필수 `.claude/skills/` 디렉토리에 SKILL.md 존재 확인
- Claude가 이미 아는 패턴 경고 (⚠️ 경고만, 에러 아님)
- settings.json JSON 유효성
- .mcp.json JSON 유효성 + 하드코딩 시크릿 감지 (있을 때만)
- Hook 스크립트 실행 권한

검증 실패 시 → 문제 수정 → 검증 재실행.

### Step 5: 완료 요약

```
✅ 프로젝트 세팅 완료

📁 생성: CLAUDE.md ({{LINE_COUNT}}줄) + .claude/ ({{FILE_COUNT}}개 파일)
⚙️ 에이전트 Tier: {{SINGLE/SUBAGENTS/AGENT_TEAMS}}
{{#IF_CONFLICTS}}⚠️ 호환성 주의: {{CONFLICT_SUMMARY}}{{/IF_CONFLICTS}}

💡 다음 단계:
  1. CLAUDE.md 검토 — 55줄 내외인지 확인 (80줄 절대 초과 금지)
  2. .env 환경 변수 설정
  3. /check로 상태 확인
  4. 새 세션에서 구현 시작 (클린 컨텍스트)
```

셋업 완료 후 git init + 첫 커밋을 진행한다.

## 예시

### 예시 1: Next.js + Prisma 풀스택

사용자: "이 프로젝트 세팅해줘" (계획서 이미 존재)

1. `analyze-project.sh` → Next.js 14, Prisma, bun, prettier, has-auth, 외부 API 2개
2. CLAUDE.md 생성: 58줄
3. .claude/ 생성: 12개 파일
4. `validate-setup.sh` → ✅ 전체 통과

결과: CLAUDE.md(58줄) + .claude/(12개 파일)

### 예시 2: Express API 전용

사용자: "세팅"

1. `analyze-project.sh` → Express, MongoDB/Mongoose, npm, 프론트엔드 없음, 인증 없음
2. CLAUDE.md 생성: 48줄. design-rules 생략.
3. .claude/ 생성: 10개 파일
4. `validate-setup.sh` → ✅

결과: CLAUDE.md(48줄) + .claude/(10개 파일)

### 예시 3: Next.js + Remotion (충돌 감지)

1. `analyze-project.sh` → Remotion + Next.js 감지 → 충돌: serverExternalPackages 필요
2. CLAUDE.md에 포함: "⚠️ Remotion은 next.config.ts에 serverExternalPackages 설정 필수"
3. .claude/skills/dependencies/SKILL.md에 필수 설정 코드 포함

## 문제 해결

### CLAUDE.md가 80줄을 초과할 때
원인: 규칙이 너무 많이 인라인됨.
해결: 수동적 규칙은 `.claude/rules/`로, 능동적 워크플로우는 `.claude/skills/`로 이동.
판단 기준: "이 줄을 지우면 Claude가 실수하는가?" 아니면 → 삭제 또는 이동.

### validate-setup.sh에서 "Claude가 이미 아는 내용" 경고가 뜰 때
원인: Claude가 기본적으로 따르는 범용 모범 사례가 포함됨.
해결: 해당 줄 삭제. 프로젝트 특화 주의사항만 남긴다.

### analyze-project.sh가 프레임워크를 잘못 감지할 때
원인: 비표준 프로젝트 구조 또는 모노레포.
해결: 사용자가 변수를 직접 수정. 스크립트 출력은 제안이지 강제가 아님.

### 의존성 충돌이 감지되지 않을 때
원인: analyze-project.sh에 해당 패턴이 없음.
해결: 스크립트에 새 패턴 추가. 알려진 충돌은 유한하고 열거 가능함.

### validate-setup.sh에서 치환되지 않은 변수가 보고될 때
원인: 계획서에 필요한 정보가 누락됨.
해결: 계획서의 빈 부분을 채운 후 CLAUDE.md 재생성.
