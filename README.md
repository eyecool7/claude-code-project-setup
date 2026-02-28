# Project Launch

계획서 작성부터 자동 세팅, 단계별 구축 가이드까지 — Claude Code 프로젝트의 Launchpad

[English](README.en.md)

---

## 이런 분을 위한 도구입니다

- 계획서의 중요성은 아는데, 뭘 적어야 할지 모르겠는 분
- Claude Code로 프로젝트를 시작하고 싶은데 첫 세팅이 막막한 분
  - CLAUDE.md를 58줄로 쓸지 500줄로 쓸지 고민되는 분
  - 서브에이전트, 팀모드, 스킬, MCP 중 뭘 골라야 할지 모르는 분
  - 어떤 스킬과 MCP가 내 프로젝트에 필요한지 감이 안 오는 분
  - 보안 설정을 어떻게 잡아야 할지 모르는 분
- 세팅에서 끝나지 않고, 매 세션마다 계획서 기반으로 구축을 가이드받고 싶은 분
- 세션이 바뀔 때마다 맥락을 잃어 같은 실수를 반복하는 분

---

## 어떻게 작동하나요?

4단계 명령어를 따라가면, 프로젝트에 맞는 설정이 자동으로 생성됩니다.

1. **`/plan`** — 계획서 작성: 구조화된 인터뷰를 통해 프로젝트 계획서 생성
2. **`/refine`** — 계획서 고도화: 기술 심층 리뷰와 스킬·MCP 탐색으로 계획서 완성
3. **`/setup`** — 프로젝트 세팅: 계획서 기반 CLAUDE.md 및 설정 파일 자동 생성
4. **`/build`** — 프로젝트 구축: 매 세션마다 현황 분석과 세션 목표 제시

---

## 설치 방법

### 방법 1: Claude Code 플러그인 (권장)

Claude Code 안에서 먼저 마켓플레이스를 추가합니다.
/plugin marketplace add eyecool7/claude-code-project-launch

그 다음 플러그인을 설치합니다.
/plugin install project-launch@eyecool7

### 방법 2: 터미널 CLI

일반 터미널 (zsh/bash)에서 아래를 복붙하여 실행하세요.

```bash
claude plugin marketplace add eyecool7/claude-code-project-launch
claude plugin install project-launch@eyecool7

# 설치 확인
claude plugin list
```

### 요구사항

- Claude Code v1.0.33 이상 (`claude --version`)
- 업데이트: `npm update -g @anthropic-ai/claude-code`

---

## 핵심 기능

### 1. 빈틈 없는 2-pass 설계로 고도화된 계획서 완성

claude.ai에서 구조화된 인터뷰로 기획하고, Claude Code에서 기술 심층 리뷰까지 수행합니다. 계획서 자체의 완성도가 다릅니다.

### 2. 계획서 기반 4단계 가이드로 프로젝트 세팅 자동화

`/plan` → `/refine` → `/setup` → `/build` 순서대로 실행하면, 프로젝트에 맞는 CLAUDE.md, rules, skills, agents, hooks가 자동 생성됩니다. CLAUDE.md 길이부터 보안 설정까지, 계획서가 결정합니다.

### 3. 프로젝트 규모에 맞는 Tier별 작업 모드 자동 판단

| Tier | 모드 | 적합한 경우 |
|------|------|-------------|
| 1 | 순차 작업 | 기능 3개 이하, 단순한 프로젝트 |
| 2 | 서브에이전트 | 독립 작업 블록이 있고 컨텍스트 절약이 필요한 경우 |
| 3 | 에이전트 팀 | 대규모 병렬 세션, 에이전트 간 소통이 필요한 경우 |

### 4. 커뮤니티 스킬·MCP 카탈로그에서 자동 탐색

refine 단계에서 카탈로그에서 프로젝트에 필요한 스킬과 MCP를 검색하고, 사용자 확인 후 설치합니다.

### 5. 기술 결정과 트러블슈팅 축적으로 세션 간 맥락 연속

`decisions.md`와 `lessons.md`가 자동으로 쌓입니다. 새 세션에서 `/build`를 실행하면 이전 기록을 전부 읽고 맥락을 복구합니다.

### 6. 검증 스크립트로 스택 충돌·보안 허점 사전 차단

스택·의존성 충돌 자동 감지부터 빠진 설정까지 잡아냅니다. Remotion + Next.js 같은 비표준 조합도 사전에 경고합니다.

---

## 사용법

| 명령어 | 설명 |
|--------|------|
| `/project-launch:plan` | 계획서 작성 프롬프트 생성 |
| `/project-launch:refine` | 계획서 고도화 프롬프트 생성 |
| `/project-launch:setup` | 계획서 기반 프로젝트 세팅 |
| `/project-launch:build` | 구축 킥오프 — 계획서 기반 현황 분석 + 세션 계획 |

### Step 1. 계획서 작성

`/project-launch:plan` → `project-plan-prompt.md` 생성

프롬프트를 **claude.ai**에 붙이고 인터뷰를 통해 `project-plan.md` 완성 → 프로젝트 루트에 저장

> <sub>**실행 시 안내:**<br>1. `project-plan-prompt.md`를 열어서 `[프로젝트 이름]`과 `프로젝트 개요`를 채우세요.<br>2. 프롬프트 전체 내용을 **claude.ai** 채팅창에 붙여넣고 대화하며 계획서를 완성하세요.<br>3. 완성된 계획서를 `project-plan.md`로 저장하고 프로젝트 루트에 넣으세요.<br>4. `/project-launch:refine`을 실행하여 다음 단계로 넘어갑니다.</sub>

### Step 2. 계획서 고도화

`/project-launch:refine` → `project-refine-prompt.md` 생성

프롬프트를 **Claude Code**에 붙이고 기술 리뷰 + 스킬/MCP 검색 → `project-plan.md` 고도화 → 저장

> <sub>**실행 시 안내:**<br>1. `project-refine-prompt.md`를 열어서 프롬프트 내용을 **Claude Code** 채팅창에 붙여넣습니다.<br>2. Claude Code와 대화하며 `project-plan.md` 계획서를 고도화하세요.<br>3. 수정된 계획서를 프로젝트 루트에 `project-plan.md`로 다시 저장합니다.<br>4. `/project-launch:setup`을 실행하여 다음 단계로 넘어갑니다.</sub>

### Step 3. 프로젝트 세팅

`/project-launch:setup` → CLAUDE.md + .claude/ + .mcp.json 자동 생성

셋업 완료 시 `project-plan.md`에 **Section 7 (셋업 결과)**이 자동 추가돼요. `/clear` 후에도 셋업 맥락이 보존됩니다.

> <sub>**실행 시 안내:**<br>세팅이 완료되었습니다.<br><br>| 항목 | 결과 |<br>| CLAUDE.md | {줄 수}줄 |<br>| .claude/ 파일 | {파일 수}개 |<br>| 작업 방식 | Tier {1/2/3} — {모드명} |<br>| 커뮤니티 스킬 | {수}개 설치 |<br>| MCP 서버 | {수}개 설정 |<br><br>`/clear`로 컨텍스트를 비우고 `/project-launch:build`를 실행하면 계획서 기반 개발이 시작됩니다.</sub>

### Step 4. 구축 시작

`/project-launch:build` → 계획서 기반 현황 분석 + 세션 목표 출력

매 세션 시작 시 실행하면 돼요. 며칠 후 재진입해도 계획서 전체 + `decisions.md`, `lessons.md`, `git log`를 읽고 현재 진행 지점을 판별합니다.

> <sub>**실행 시 안내:**<br>📋 **프로젝트 현황**<br><br>| Phase | 상태 | 비고 |<br>| Phase 1: 기반 | ✅/🔨/⬜ | ... |<br><br>**현재 Phase:** Phase N — {이름}<br>**이번 세션 목표:** (미달성 완료 기준 중 2–4개)<br>**주의사항:** decisions.md + lessons.md 관련 사항<br><br>📝 기록 규칙: decisions.md(기술 결정 즉시), lessons.md(실패 해결 즉시), 세션 종료 전 자체 점검</sub>

---

## 계획서에 포함되는 내용

| 섹션 | 내용 | 필수 |
|------|------|:----:|
| 1. 제품 컨텍스트 | 한줄요약, 배경, 핵심기능+우선순위, 성공기준, 범위밖 | ✅ |
| 2. 워크플로우 | 사용자 플로우, LLM vs 스크립트 구분, 검증+실패처리 | ✅ |
| 3. 툴 설계 | MCP 서버 선정, 스킬 선정, .mcp.json 확정 | ✅ |
| 4. 구현 설계 | 기술스택, 에이전트구조, 스킬목록, 에러전략, 의존성 | ✅ |
| 5. 기술 결정 | UI도구, 데이터흐름, URL구조, 외부서비스 | ⚪ |
| 6. 구현 순서 | Phase별 의존관계 로드맵 | ✅ |

---

## 산출물

### 항상 생성 (18개 파일)

| 카테고리 | 파일 | 역할 |
|---------|------|------|
| **CLAUDE.md** | 1개 | 계획서 기반 ~80줄. 매 세션 자동 로드 |
| **Rules** | conventions, security, error-handling, testing | 관련 파일 작업 시 자동 로드 |
| **Skills** | project-directory, easy-refactoring, skill-discovery | 파일 배치·리팩토링·외부 스킬 검색 |
| **Agents** | test-runner, code-reviewer, debugger | 테스트·리뷰·디버깅 위임 |
| **Commands** | /check, /review, /commit-push-pr | 타입체크+린트+테스트, 코드리뷰, PR 생성 |
| **Hooks** | session-start, edit-monitor, pre-commit-check | 세션 시작·편집 감시·커밋 전 검증 |
| **기록** | decisions.md, lessons.md | 기술 결정 + 실수/해결책 축적 |
| **설정** | settings.json | 권한/hooks 설정 |

### 조건부 생성

| 파일 | 조건 |
|------|------|
| rules/frontend/ | 프론트엔드 프로젝트 |
| rules/database.md | 백엔드 + DB 사용 |
| skills/design-rules/ | 프론트엔드 프로젝트 |
| skills/ui-ux-pro-max/ | 프론트엔드 (외부 스킬 자동 설치) |
| skills/dependencies/ | 의존성 충돌 감지 시 |
| skills/{도메인-스킬}/ | 계획서에 정의된 스킬 |
| agents/{커스텀}.md | Tier 2+ 에이전트 (계획서 정의) |
| skills/agent-teams/ | Tier 3 에이전트 팀 |
| .mcp.json | MCP 서버 선정 시 |

---

## 셋업 완료 후 프로젝트

```
my-project/
├── CLAUDE.md                  ← ~80줄. 매 세션 자동 로드
├── .claude/
│   ├── commands/              ← /review, /check, /commit-push-pr
│   ├── hooks/                 ← session-start, edit-monitor, pre-commit-check
│   ├── rules/                 ← conventions, security, error-handling, testing (+조건부)
│   ├── skills/                ← project-directory, easy-refactoring, skill-discovery (+조건부)
│   ├── agents/                ← test-runner, code-reviewer, debugger (+조건부)
│   ├── decisions.md           ← 기술 결정 기록
│   ├── lessons.md             ← 실수/해결책 축적
│   └── settings.json
├── .mcp.json                  ← MCP 서버 (선택)
└── project-plan.md            ← 참조용 유지
```

**자동 작동:**
- **Rules** — 에러/보안/테스트/컨벤션 규칙이 관련 파일 작업 시 자동 로드
- **Skills** — 파일 배치, 리팩토링, 디자인 워크플로우 자동 발견
- **Agents** — 복잡한 테스트/리뷰/디버깅은 전담 에이전트가 독립 컨텍스트에서 처리
- **Decisions/Lessons** — 기술 결정·실수 기록이 쌓이면 세션마다 알림
- **Skill Discovery** — 외부 스킬이 필요하면 자동 검색·제안 (설치 전 사용자 확인)

---

## 구성요소

| 구성요소 | 설명 |
|----------|------|
| 커맨드 (4개) | `/project-launch:plan`, `refine`, `setup`, `build` |
| 템플릿 | CLAUDE.md, rules, skills, agents, commands, hooks 생성용 |
| 스크립트 (3개) | analyze-project, validate-env, validate-setup |

---

## 플러그인 구조

```
claude-code-project-launch/
├── .claude-plugin/marketplace.json
├── plugins/project-launch/
│   ├── .claude-plugin/plugin.json
│   ├── commands/          ← plan, refine, setup, build
│   ├── templates/         ← 생성 시 참조할 템플릿
│   └── scripts/           ← 분석/검증 스크립트
├── README.md
├── README.en.md
└── LICENSE
```

---

## 라이선스

MIT
