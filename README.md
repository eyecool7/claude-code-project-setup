# claude-code-project-setup

[English](README.en.md)

## 왜 이 플러그인인가?

프로젝트를 시작할 때마다 비개발자는 불안합니다. 뭔가 빠진 것 같은데, 뭐가 빠졌는지를 모르겠는 거죠.

> 계획서가 90%라는데, 어떻게 써야 잘 쓰는 건지?
> CLAUDE.md는 몇 줄이 정답이야? 누구는 58줄, 누구는 500줄이던데?
> 서브에이전트, 팀모드 — 뭘 써야 하는 건지?
> 어떤 스킬, 어떤 MCP를 골라야 하는 건지?
> 에러 처리는? 보안은? 그 외에 더 빠진 건 없는 건지?

이 플러그인은 이 질문들을 한 방에 해결해 줍니다.

1차 작성 + 2차 고도화로 빈틈 없는 계획서를 완성하고, `/plan`→`/refine`→`/setup`→`/build` 4단계를 따라가면 CLAUDE.md와 19개 이상의 설정 파일이 프로젝트에 맞게 자동 생성되고, 매 세션마다 Phase 기반 구축 킥오프가 제공됩니다. 세션 간 맥락 연속, 의존성 충돌 사전 감지, Tier별 확장, 커뮤니티 스킬 자동 검색까지 — 범용 템플릿 복붙으로 컨텍스트 낭비하는 건 이제 그만.

### 특징

1. **1차 작성 + 2차 고도화로 빈틈 없는 설계 완성** — claude.ai에서 인터뷰로 기획하고, Claude Code에서 기술 심층 리뷰까지 마치니까 계획서 자체의 완성도가 다르다.
2. **계획서 하나로 /plan→/refine→/setup→/build 4단계 완전 자동화** — 순서대로 실행만 하면 프로젝트에 맞는 CLAUDE.md, rules, skills, agents, hooks까지 자동 생성되고, 매 세션마다 Phase 기반 구축 킥오프가 제공된다.
3. **프로젝트 규모에 맞는 Tier 확장** — 혼자 직렬 → 서브에이전트 위임 → 팀 병렬까지 단계적으로 전환된다.
4. **커뮤니티 스킬·MCP 자동 검색 후 설치** — 직접 구현하기 전에 380+ 스킬 카탈로그에서 먼저 찾고, 사용자 확인 후 설치한다.
5. **세션 바뀌어도 맥락이 끊기지 않는다** — 기술 결정과 삽질 기록이 자동 축적되고, 새 세션마다 알아서 불러온다.
6. **실수를 구조적으로 차단한다** — 스택·의존성 충돌을 자동 감지하고, 빠진 설정·보안 허점까지 검증 스크립트가 잡아낸다.

---

## 설치

### 방법 1: 터미널 CLI

일반 터미널 (zsh/bash)에서 실행하세요. Claude Code 채팅창이 아닙니다.

```bash
claude plugin marketplace add eyecool7/claude-code-project-setup
claude plugin install project-setup@claude-code-project-setup

# 설치 확인
claude plugin list
```

### 방법 2: Claude Code UI

1. Claude Code 세션에서 `/manage` 입력 → **Manage plugins** 선택
2. **Marketplaces** 탭 → 입력창에 `eyecool7/claude-code-project-setup` 입력 → **Add**
3. **Plugins** 탭 → `project-setup` 옆 **Install** 클릭
4. 상단 **Restart** 클릭하여 변경사항 적용

### 요구사항

- Claude Code v1.0.33 이상 (`claude --version`으로 확인)
- 버전이 낮으면: `npm update -g @anthropic-ai/claude-code`

---

## 스킬 목록

| 스킬 | 설명 |
|------|------|
| `/project-setup:plan` | 계획서 작성 프롬프트 생성 |
| `/project-setup:refine` | 계획서 고도화 프롬프트 생성 |
| `/project-setup:setup` | 계획서 기반 프로젝트 세팅 |
| `/project-setup:build` | 구축 킥오프 — Phase 판별 + 세션 계획 |

---

## 사용 방법

### Step 1. 계획서 작성

`/project-setup:plan` : `project-plan-prompt.md`를 프로젝트 루트에 생성

**사용자** : `project-plan-prompt.md` 프롬프트를 **claude.ai**에 붙이기 → 대화를 통해 `project-plan.md` 계획서 완성 → 프로젝트 루트에 저장

### Step 2. 계획서 고도화

`/project-setup:refine` : `project-refine-prompt.md`를 프로젝트 루트에 생성

**사용자** : `project-refine-prompt.md` 프롬프트를 **claude code**에 붙이기 → 대화를 통해 `project-plan.md` 계획서 고도화 → 저장

### Step 3. 프로젝트 세팅

`/project-setup:setup` : `project-plan.md` 기반 프로젝트 세팅 (CLAUDE.md + .claude/ + .mcp.json 자동 생성)

셋업 완료 시 `project-plan.md`에 **Section 7 (셋업 결과)**이 자동 추가된다. `/clear` 후에도 셋업 맥락이 보존됨.

> **권장:** Step 4 구축 시작 전에 `/clear` 로 컨텍스트를 비운다. 기획 대화의 수정 히스토리가 컨텍스트를 오염시키므로 반드시 분리.

### Step 4. 프로젝트 구축 시작

`/project-setup:build` : 계획서 + 코드베이스 분석 → 현재 Phase 판별 → 세션 작업 계획 출력

**사용자** : `/clear` 또는 새창 → `/project-setup:build` 입력 → Phase 현황 + 이번 세션 목표 + 기록 리마인드 확인 → 구축 진행

매 세션 시작 시 실행하면 된다. 재진입(일 후 복귀) 시에도 동일하게 `/project-setup:build`로 시작하면 decisions.md, lessons.md, git log를 읽고 이어서 진행할 Phase를 판별한다.

---

## 계획서에 포함되는 내용

| 섹션 | 내용 | 필수 여부 |
|------|------|----------|
| 1. 제품 컨텍스트 | 한줄요약, 배경, 핵심기능+우선순위, 성공기준, 범위밖 | ✅ 필수 |
| 2. 워크플로우 | 사용자 플로우, LLM vs 스크립트 구분, 검증+실패처리 | ✅ 필수 |
| 3. 툴 & 워크플로우 설계 | MCP 서버 선정, 스킬 선정, .mcp.json 확정 | ✅ 필수 |
| 4. 구현 설계 | 기술스택, 에이전트구조, 스킬목록, 에러전략, 의존성 | ✅ 필수 |
| 5. 기술 결정 | UI도구, 데이터흐름, URL구조, 외부서비스 | ⚪ 선택 (미정 허용) |
| 6. 구현 순서 | Phase별 의존관계 로드맵 | ✅ 필수 |

---

## 셋업에서 생성되는 것

**항상 생성:**

| 파일 | 내용 |
|------|------|
| **CLAUDE.md** | 계획서 기반, 80줄 내외 |
| .claude/rules/ (4개) | conventions, security, error-handling, testing |
| .claude/skills/ (3개) | project-directory, easy-refactoring, skill-discovery |
| .claude/agents/ (3개) | test-runner, code-reviewer, debugger |
| .claude/commands/ (3개) | /check, /review, /commit-push-pr |
| .claude/hooks/ (3개) | session-start, edit-monitor, pre-commit-check |
| .claude/decisions.md | 기술 결정 기록 템플릿 |
| .claude/lessons.md | 실수/해결책 기록 템플릿 |
| .claude/settings.json | 권한/hooks 설정 |

**조건부 생성:**

| 파일 | 조건 |
|------|------|
| .claude/rules/frontend/ | 프론트엔드 프로젝트 |
| .claude/rules/database.md | 백엔드 + DB 사용 |
| .claude/skills/design-rules/ | 프론트엔드 프로젝트 |
| .claude/skills/ui-ux-pro-max/ | 프론트엔드 프로젝트 (외부 스킬) |
| .claude/skills/dependencies/ | 의존성 충돌 감지 시 |
| .claude/skills/{도메인-스킬}/ | 계획서에 정의된 스킬 |
| .claude/agents/{커스텀-에이전트}.md | Tier 2+ 에이전트 (계획서 정의) |
| .claude/skills/agent-teams/ | Tier 3 에이전트 팀 |
| **.mcp.json** | MCP 서버 선정 시 |

---

## 셋업 완료 후 프로젝트 상태

항상 생성되는 기본 구성과, 프로젝트 특성에 따라 추가되는 조건부 구성으로 나뉜다.

```
my-project/
├── CLAUDE.md                       ← ⭐ 80줄 내외. 매 세션 자동 로드.
├── .claude/
│   ├── commands/ (3)               ← /review, /check, /commit-push-pr
│   ├── hooks/ (3)                  ← session-start, edit-monitor, pre-commit-check
│   ├── rules/
│   │   ├── conventions.md          ← 항상: 네이밍, import, 타입 규칙
│   │   ├── security.md             ← 항상: api/auth 파일 작업 시
│   │   ├── error-handling.md       ← 항상: services/api 작업 시
│   │   └── testing.md              ← 항상: test/spec 작업 시
│   ├── skills/
│   │   ├── project-directory/      ← 항상: 파일/폴더 위치 결정 시
│   │   ├── easy-refactoring/       ← 항상: 리팩토링 수행 시
│   │   └── skill-discovery/        ← 항상: 외부 스킬 필요 시 자동 검색
│   ├── agents/
│   │   ├── test-runner.md          ← 항상: 테스트 실행 위임
│   │   ├── code-reviewer.md        ← 항상: 코드 리뷰 위임
│   │   └── debugger.md             ← 항상: 디버깅 위임
│   ├── decisions.md                ← 기술 결정 기록
│   ├── lessons.md                  ← 실수/해결책 축적
│   └── settings.json
│
│   ─── 이하 조건부 생성 ───
│
│   ├── rules/frontend/             ← 프론트엔드 프로젝트
│   ├── rules/database.md           ← 백엔드 + DB 사용
│   ├── skills/design-rules/        ← 프론트엔드 프로젝트
│   ├── skills/ui-ux-pro-max/       ← 프론트엔드 프로젝트 (외부 스킬)
│   ├── skills/dependencies/        ← 의존성 충돌 감지 시
│   ├── skills/{도메인-스킬}/       ← 계획서에 정의된 스킬
│   ├── agents/{커스텀-에이전트}.md ← Tier 2+ 에이전트 (계획서 정의)
│   └── skills/agent-teams/         ← Tier 3 에이전트 팀
├── .mcp.json                       ← MCP 서버 선정 시
└── project-plan.md                 ← 참조용 유지
```

**유용한 명령어:**
- `/check` — 타입체크 + 린트 + 테스트 한 줄 요약
- `/review` — 변경사항 코드 리뷰
- `/commit-push-pr` — 커밋 → 푸시 → PR 생성

**자동 작동:**
- **Rules** — 에러/보안/테스트/컨벤션 규칙이 관련 파일 작업 시 자동 로드
- **Skills** — 파일 배치, 리팩토링, 디자인 등 능동적 워크플로우 자동 발견
- **Agents** — 복잡한 테스트/리뷰/디버깅은 전담 에이전트가 독립 컨텍스트에서 처리
- **Decisions/Lessons** — 기술 결정·실수 기록이 쌓이면 세션마다 알림
- **Skill Discovery** — 외부 스킬이 필요하면 자동 검색·제안 (설치 전 사용자 확인)

---

## 플러그인 구조

```
claude-code-project-setup/
├── .claude-plugin/
│   └── marketplace.json         ← 마켓플레이스 메타데이터
├── plugins/
│   └── project-setup/
│       ├── .claude-plugin/
│       │   └── plugin.json      ← 플러그인 정의
│       ├── commands/
│       │   ├── plan.md          ← /project-setup:plan
│       │   ├── refine.md        ← /project-setup:refine
│       │   ├── setup.md         ← /project-setup:setup
│       │   └── build.md         ← /project-setup:build
│       ├── templates/           ← 생성 시 참조할 템플릿
│       │   ├── project-plan-prompt.md
│       │   ├── project-refine-prompt.md
│       │   ├── project-setup-prompt.md
│       │   ├── claude-md-template.md
│       │   ├── rules/
│       │   ├── skills/
│       │   ├── agents/
│       │   ├── commands/
│       │   ├── hooks/
│       │   ├── settings.json
│       │   ├── lessons.md
│       │   └── decisions.md
│       └── scripts/             ← 분석/검증 스크립트
│           ├── analyze-project.sh
│           ├── validate-env.sh
│           └── validate-setup.sh
├── README.md
├── README.en.md
└── LICENSE
```

---

## 라이선스

MIT
