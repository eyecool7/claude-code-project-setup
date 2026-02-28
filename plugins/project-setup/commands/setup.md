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
  # fallback: CLAUDE_PLUGIN_ROOT 환경변수 직접 확인
  PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-}"
fi
if [ -z "$PLUGIN_ROOT" ]; then
  # fallback: 알려진 설치 경로에서 탐색
  for CANDIDATE in ~/.claude/plugins/project-setup ./plugins/project-setup; do
    if [ -f "$CANDIDATE/.claude-plugin/plugin.json" ]; then
      PLUGIN_ROOT="$CANDIDATE"
      break
    fi
  done
fi
if [ -z "$PLUGIN_ROOT" ]; then
  echo "❌ 플러그인 루트를 찾을 수 없습니다."
  echo "   → Claude Code를 재시작하거나, 플러그인 설치 경로를 확인하세요."
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

스크립트 출력은 내부 참조용으로만 사용한다 (사용자에게 raw 출력을 그대로 보여주지 않는다).

### Step 2: 스킬/MCP 검색

미리보기에 정확한 스킬/MCP 정보를 표시하기 위해, 파일 생성 전에 먼저 커뮤니티 검색을 수행한다.

**사용자 안내 (검색 시작 전 반드시 출력):**
```
커뮤니티 스킬/MCP를 검색 중입니다... (약 30초 소요)
```

**검색 절차:**

계획서 섹션 3 "툴 & 워크플로우 설계"를 확인한다.

1. **refine에서 이미 검색 완료된 경우** (섹션 3에 "설치"/"직접 구현" 판정이 있음):
   - 검색 생략. 기존 결과를 그대로 사용.
   - 안내 메시지도 생략.

2. **검색 미수행인 경우** (키워드만 있고 결과가 비어있음):
   - `.claude/skills/skill-discovery/SKILL.md`의 검색 절차를 실행
   - 프론트엔드 프로젝트면 ui-ux-pro-max를 무조건 포함
   - 검색 결과를 사용자에게 테이블로 보여주고 확인
   - 확인된 결과를 계획서 섹션 3에 반영 (스킬 테이블 + MCP 테이블 + 확정_MCP JSON 블록)

**정리:**
```bash
rm -rf /tmp/vive-md /tmp/skills-* /tmp/ui-ux-pro-max-skill
```

검색 결과는 Step 3 미리보기와 Step 5 파일 생성에서 참조된다.

### Step 3: 세팅 미리보기 + 승인

Step 1의 분석 결과 + 계획서 + **Step 2의 스킬/MCP 검색 결과**를 조합하여 **구조화된 미리보기**를 사용자에게 보여준다.
사용자가 결과물을 예측할 수 있는 상태에서 승인받는 것이 목적이다.

**출력 형식:**

```
지금부터 project-plan.md 계획서를 근거로 프로젝트 세팅을 시작합니다.

📁 생성될 파일 ({총 파일 수}개)
├── CLAUDE.md (약 {예상 줄 수}줄)
├── .claude/
│   ├── rules/        → {해당 규칙 파일 목록 나열}
│   ├── skills/       → {해당 스킬 목록 나열}
│   ├── agents/       → {해당 에이전트 목록 나열}
│   ├── commands/     → {해당 커맨드 목록 나열}
│   ├── hooks/        → {해당 훅 목록 나열}
│   └── settings.json, lessons.md, decisions.md
├── .mcp.json ({MCP 서버가 있으면 서버명 나열, 없으면 "생성 안 함"})
└── .gitignore ({신규 프로젝트면 표시, 기존이면 생략})

🔌 추가할 스킬 & MCP
- {커뮤니티 스킬명} (커뮤니티 → 설치)
- {커스텀 스킬명} (커뮤니티 없음 → 직접 생성)
- {MCP 서버명} (MCP 서버)
(해당 없으면: "추가 스킬/MCP 없음")

🤖 작업 방식: Tier {1/2/3} — {순차 작업 / 서브에이전트 / 에이전트 팀}
{Tier별 한 줄 설명}
(Tier 2/3이면 커스텀 에이전트 목록도 표시)

{의존성 충돌 경고가 있으면}
⚠️ 호환성 주의: {충돌 내용}

이 내용으로 세팅을 진행할까요?
```

**미리보기 생성 규칙:**
- **파일 트리**: Step 1 감지 결과(HAS_FRONTEND, HAS_BACKEND 등)와 계획서(Tier, 커스텀 스킬/에이전트)를 조합하여 실제 생성될 파일만 나열. 조건부 파일은 조건 충족 시에만 표시.
- **스킬 & MCP**: Step 2의 검색 결과에서 "설치" 판정된 커뮤니티 스킬 + "직접 구현" 판정된 커스텀 스킬 + MCP 서버를 구분하여 나열.
- **작업 방식**: 계획서 4번의 AGENT_TIER 값을 읽어 Tier 번호 + 모드명 + 한 줄 설명. Tier 2/3이면 커스텀 에이전트 이름도 나열.
- **충돌 경고**: Step 1의 CONFLICT_WARNINGS가 있으면 표시. 없으면 생략.

**승인 흐름:**
- 사용자가 승인 → Step 4로 진행
- 사용자가 수정 요청 (예: "이 스킬은 빼줘", "Tier 1로 해줘") → 반영 후 미리보기 재출력 → 재승인
- 사용자가 거부 → 세팅 중단

### Step 4: CLAUDE.md 생성

`$PLUGIN_ROOT/templates/claude-md-template.md`를 기반으로 변수를 채운다:
- **계획서** → 프로젝트명, 역할, 철학, 핵심 플로우
- **계획서 4번** → `AGENT_TIER` (1/2/3), `AGENT_TABLE` (Tier 2/3일 때 에이전트 목록)
- **Step 1 출력** → 스택 상세, 핵심 경로, 개발 명령어, 권한
- **의존성 분석** → 충돌 경고, 주의사항

CLAUDE.md 생성 핵심 규칙:
- Claude가 이미 아는 정보는 넣지 않는다
- 주요 의존성의 실제 import 경로와 설정 코드를 포함한다 ("X 사용" 수준이 아니라)
- 의존성 충돌 감지 시 핵심 규칙 섹션에 ⚠️ 경고 추가
- **검증 섹션을 핵심 규칙 바로 다음에 배치** — 가장 중요한 3줄
- 목표: 80줄 내외. 110줄 절대 초과 금지.
- 수동적 규칙은 `.claude/rules/`에 분리 (자동 로드 + path 스코프), 능동적 워크플로우는 `.claude/skills/`에 분리

**`{{AGENT_TIER_SECTION}}` 치환:** 계획서 4번의 AGENT_TIER 값에 따라:
- **Tier 1**: `직렬 구현. 한 번에 하나의 기능씩 완성 후 다음으로 이동.`
- **Tier 2**: `서브에이전트 위임 구현. 독립적인 작업은 Task 도구로 병렬 위임.` + 위임 기준, `.claude/agents/` 활용, Tier 변경 시 decisions.md 기록 규칙
- **Tier 3**: `팀 모드 구현. claude -w feature-name (worktree)으로 독립 브랜치 생성.` + worktree 필수, agents/skills 참조, Tier 변경 시 decisions.md 기록 규칙

### Step 5: .claude/ 설정 생성

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
| `skills/ui-ux-pro-max/` | Step 2에서 skill-discovery를 통해 설치 (프론트엔드 프로젝트 필수). |

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

**커뮤니티 스킬 교차 검증 (CRITICAL):**
도메인 스킬을 생성하기 전에, 섹션 3의 검색 결과를 확인한다:
- 섹션 3에서 해당 도메인의 커뮤니티 스킬이 "설치"로 판정됐으면 → **커스텀 스킬 생성 생략**. 커뮤니티 스킬이 이미 설치됨.
- 섹션 3에서 "해당 없음 — 직접 구현"으로 판정됐으면 → 계획서 기반으로 커스텀 스킬 생성.
- 섹션 3에 해당 키워드 자체가 없으면 → 계획서 기반으로 커스텀 스킬 생성하되, 사용자에게 "커뮤니티 검색을 건너뛰었습니다" 안내.

**조건부 생성 (계획서 에이전트 Tier가 2 — Subagents인 경우):**

계획서 4번의 에이전트 테이블에서 커스텀 에이전트를 `.claude/agents/`에 생성한다.
기본 3개(test-runner, code-reviewer, debugger)는 이미 항상 생성됨.

| 파일 | 커스터마이징 |
|------|------------|
| `agents/{에이전트명}.md` | 계획서의 역할·담당 범위를 기반으로 에이전트 프롬프트 작성 |

생성 규칙:
- 파일명: 계획서 에이전트명 (kebab-case, `.md`)
- 본문: 에이전트의 역할, 접근 가능 파일 범위, 사용 도구(Task subagent_type), 완료 기준
- 기본 3개와 중복되면 기본 에이전트를 확장 (새 파일 생성 X)

**조건부 생성 (계획서 에이전트 Tier가 3 — Agent Teams인 경우):**

Tier 2의 에이전트 생성을 포함하고, 추가로:

| 파일 | 커스터마이징 |
|------|------------|
| `commands/worktree.md` | 병렬 작업 시 worktree 생성·정리 가이드. |
| `skills/agent-teams/SKILL.md` | 팀 구성 가이드: TeamCreate 사용법, 태스크 분배 패턴, worktree 필수 규칙, 실험 기능 활성화 방법. |

### Step 6: 커뮤니티 스킬 설치

Step 2에서 확정된 검색 결과를 기반으로, "설치"로 판정된 커뮤니티 스킬을 `.claude/skills/`에 설치한다.
프론트엔드 프로젝트면 ui-ux-pro-max를 무조건 설치한다 (skill-discovery SKILL.md 참조).

설치 방법은 skill-discovery SKILL.md의 설치 절차를 따른다.

### Step 7: .mcp.json 생성

아래 우선순위로 소스를 탐색한다. 가장 먼저 찾은 소스를 사용:

| 우선순위 | 소스 | 위치 | 설명 |
|:-------:|------|------|------|
| 1 | 계획서 확정 `.mcp.json` | 섹션 3에 완성된 JSON 블록 | refine에서 사용자가 직접 확정한 것. 그대로 복사. |
| 2 | `확정_MCP` JSON 블록 | 섹션 3 내 ````json 확정_MCP` 코드 블록 | skill-discovery가 생성한 구조화 데이터. 그대로 복사. |
| 3 | 섹션 3 MCP 테이블 | 섹션 3 내 마크다운 테이블 | 테이블에서 서버명·설정을 추출하여 JSON 생성. |
| 4 | 섹션 5 재검색 | 섹션 5 "외부 서비스 목록" | 섹션 3이 비었을 때: 서비스명을 키워드로 skill-discovery 재실행 → MCP 선정 |
| 5 | 생략 | — | 섹션 3도 5도 비어있으면 `.mcp.json` 생성하지 않음 |

**생성 규칙:**
- API 키 등 시크릿은 반드시 `${ENV_VAR}` 형식 사용 (하드코딩 절대 금지)
- stdio 타입: `"command"`, `"args"` 구조
- HTTP 타입: `"type": "http"`, `"url"` 구조

### Step 8: Git 초기화 (신규 프로젝트)

git 저장소가 없으면 초기화한다. worktree 기반 병렬 작업(Tier 2/3)의 전제 조건.

1. `.git` 디렉토리 존재 확인
2. 없으면:
   - `git init`
   - `.gitignore` 생성 (node_modules, .env*, output/, .next/, dist/ 등)
   - 초기 커밋: `git add -A && git commit -m "chore: initial project setup"`
3. 이미 있으면: 건너뜀

**AGENT_TIER가 2 이상일 때**: git 저장소가 반드시 필요. 없으면 사용자에게 경고 후 자동 생성.

### Step 9: 검증

```bash
bash "$PLUGIN_ROOT/scripts/validate-setup.sh"
bash "$PLUGIN_ROOT/scripts/validate-env.sh"
```

검증 항목:
- CLAUDE.md 존재 여부 및 110줄 이하 확인
- 치환되지 않은 `{{변수}}` 잔존 여부
- TODO/FIXME/Placeholder 잔존 여부 (모든 생성 파일 대상)
- 필수 `.claude/rules/` 파일 존재 + frontmatter 확인
- 필수 `.claude/skills/` 디렉토리에 SKILL.md 존재 확인
- Claude가 이미 아는 패턴 경고 (⚠️ 경고만, 에러 아님)
- settings.json JSON 유효성
- .mcp.json JSON 유효성 + 하드코딩 시크릿 감지 (있을 때만)
- Hook 스크립트 실행 권한

검증 실패 시 → 문제 수정 → 검증 재실행.

### Step 10: 완료 요약

사용자에게 다음 형식으로 전달한다:

---

**세팅이 완료되었습니다.**

| 항목 | 결과 |
|------|------|
| CLAUDE.md | {줄 수}줄 |
| .claude/ 파일 | {파일 수}개 |
| 작업 방식 | Tier {1/2/3} — {모드명} |
| 커뮤니티 스킬 | {설치된 스킬 수}개 설치 |
| MCP 서버 | {서버 수}개 설정 |
| 호환성 주의 | {있으면 경고 내용 / 없으면 "없음"} |

`/clear`로 컨텍스트를 비우거나 새 창을 열고, `프로젝트 구축을 시작해`를 입력하면 계획서 기반 개발이 시작됩니다.

---

## 예시

### 예시 1: Next.js + Prisma 풀스택

사용자: "이 프로젝트 세팅해줘" (계획서 이미 존재)

**Step 3 미리보기 출력:**
```
지금부터 project-plan.md 계획서를 근거로 프로젝트 세팅을 시작합니다.

📁 생성될 파일 (22개)
├── CLAUDE.md (약 58줄)
├── .claude/
│   ├── rules/        → conventions, security, error-handling, testing
│   │                    + frontend/react, frontend/styles, database
│   ├── skills/       → project-directory, easy-refactoring, skill-discovery
│   │                    + design-rules, ui-ux-pro-max (커뮤니티)
│   ├── agents/       → test-runner, code-reviewer, debugger
│   ├── commands/     → review, check, commit-push-pr
│   ├── hooks/        → session-start, edit-monitor, pre-commit-check
│   └── settings.json, lessons.md, decisions.md
├── .mcp.json (stripe, supabase)
└── .gitignore

🔌 추가할 스킬 & MCP
- ui-ux-pro-max (커뮤니티 → 설치)
- @anthropic/mcp-stripe (MCP 서버)
- @supabase/mcp (MCP 서버)

🤖 작업 방식: Tier 1 — 순차 작업
한 번에 하나의 기능씩 완성 후 다음으로 이동.

이 내용으로 세팅을 진행할까요?
```

사용자 승인 → 세팅 진행 → 검증 통과

**Step 10 완료 출력:**

| 항목 | 결과 |
|------|------|
| CLAUDE.md | 58줄 |
| .claude/ 파일 | 22개 |
| 작업 방식 | Tier 1 — 순차 작업 |
| 커뮤니티 스킬 | 1개 설치 |
| MCP 서버 | 2개 설정 |
| 호환성 주의 | 없음 |

### 예시 2: Express API 전용

사용자: "세팅"

**Step 3 미리보기 출력:**
```
지금부터 project-plan.md 계획서를 근거로 프로젝트 세팅을 시작합니다.

📁 생성될 파일 (16개)
├── CLAUDE.md (약 48줄)
├── .claude/
│   ├── rules/        → conventions, security, error-handling, testing
│   │                    + database
│   ├── skills/       → project-directory, easy-refactoring, skill-discovery
│   ├── agents/       → test-runner, code-reviewer, debugger
│   ├── commands/     → review, check, commit-push-pr
│   ├── hooks/        → session-start, edit-monitor, pre-commit-check
│   └── settings.json, lessons.md, decisions.md
└── .gitignore

🔌 추가할 스킬 & MCP
추가 스킬/MCP 없음

🤖 작업 방식: Tier 1 — 순차 작업
한 번에 하나의 기능씩 완성 후 다음으로 이동.

이 내용으로 세팅을 진행할까요?
```

### 예시 3: Next.js + Remotion (충돌 감지 + Tier 2)

**Step 3 미리보기 출력:**
```
지금부터 project-plan.md 계획서를 근거로 프로젝트 세팅을 시작합니다.

📁 생성될 파일 (25개)
├── CLAUDE.md (약 72줄)
├── .claude/
│   ├── rules/        → conventions, security, error-handling, testing
│   │                    + frontend/react, frontend/styles
│   ├── skills/       → project-directory, easy-refactoring, skill-discovery
│   │                    + design-rules, dependencies, ui-ux-pro-max (커뮤니티)
│   ├── agents/       → test-runner, code-reviewer, debugger
│   │                    + video-renderer, content-writer
│   ├── commands/     → review, check, commit-push-pr
│   ├── hooks/        → session-start, edit-monitor, pre-commit-check
│   └── settings.json, lessons.md, decisions.md
├── .mcp.json (supabase)
└── .gitignore

🔌 추가할 스킬 & MCP
- ui-ux-pro-max (커뮤니티 → 설치)
- @supabase/mcp (MCP 서버)

🤖 작업 방식: Tier 2 — 서브에이전트
메인이 오케스트레이터, 독립 작업은 Task 도구로 병렬 위임.
- 커스텀 에이전트: video-renderer, content-writer

⚠️ 호환성 주의: Remotion은 next.config.ts에 serverExternalPackages 설정 필수

이 내용으로 세팅을 진행할까요?
```

## 문제 해결

### CLAUDE.md가 110줄을 초과할 때
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
