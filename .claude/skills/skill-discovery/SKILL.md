---
name: skill-discovery
description: Use when you encounter a task where an existing community skill could improve quality — such as working with specific libraries (react-pdf, Remotion, Stripe), design patterns, testing frameworks, or deployment platforms. Search skill marketplaces before building from scratch.
user-invocable: true
---

# Skill Discovery & Installation

개발 중 특정 기술/라이브러리/패턴에 대한 전문 skill이 있으면 품질이 올라간다.
직접 만들기 전에 커뮤니티 skill을 먼저 검색하라.

## 검색 순서 (신뢰도 순)

### 1순위: 공식 스킬팩
```bash
# Anthropic 공식
git clone --depth 1 https://github.com/anthropics/skills /tmp/skills-anthropic
ls /tmp/skills-anthropic/skills/

# 벤더 공식 (프로젝트 스택에 해당하는 것만)
# Vercel: https://github.com/vercel/skills
# Supabase: https://github.com/supabase/skills
# Stripe: https://github.com/stripe/ai
# Hugging Face: https://github.com/huggingface/skills
# Remotion: https://github.com/remotion-dev/skills
```

### 2순위: 검증된 마켓플레이스
```bash
# Trail of Bits (보안/정적분석/리뷰)
git clone --depth 1 https://github.com/trailofbits/skills /tmp/skills-tob
ls /tmp/skills-tob/skills/

# Awesome Claude Skills (큐레이션 목록 — 여기서 링크 확인 후 개별 설치)
git clone --depth 1 https://github.com/travisvn/awesome-claude-skills /tmp/awesome-skills

# Claude Code Best Practice (설정 패턴, 스킬/에이전트/훅 레퍼런스)
git clone --depth 1 https://github.com/shanraisshan/claude-code-best-practice /tmp/best-practice
cat /tmp/awesome-skills/README.md
```

### 2.5순위: 종합 가이드 (MCP + 스킬 카탈로그)
```bash
# vive-md: MCP/Skills 종합 가이드 + 380개+ 스킬 한국어 카탈로그
git clone --depth 1 https://github.com/johunsang/vive-md.git /tmp/vive-md
# - MCP 서버 선정: /tmp/vive-md/vibe-coding/mcp/04-MCP-서버-카탈로그.md
# - MCP 설정 패턴: /tmp/vive-md/vibe-coding/mcp/03-MCP-실전-패턴-모음.md
# - 스킬 카탈로그: /tmp/vive-md/vibe-coding/resources/Awesome-Claude-Skills-한국어-가이드.md
# - 스킬 작성법: /tmp/vive-md/vibe-coding/skills/ (README + 01~03)
cat /tmp/vive-md/vibe-coding/resources/Awesome-Claude-Skills-한국어-가이드.md

# ui-ux-pro-max: UI/UX 디자인 인텔리전스 스킬 (프론트엔드 프로젝트 필수)
# - BM25 검색엔진 + 67 UI스타일, 96 팔레트, 57 타이포, 13 스택 지원
git clone --depth 1 https://github.com/nextlevelbuilder/ui-ux-pro-max-skill.git /tmp/ui-ux-pro-max-skill
# 설치: cp -r /tmp/ui-ux-pro-max-skill/.claude/skills/ui-ux-pro-max .claude/skills/
# 또는: npm install -g uipro-cli && uipro init --ai claude
ls /tmp/ui-ux-pro-max-skill/.claude/skills/
```

**규칙: 프론트엔드가 포함된 프로젝트면 ui-ux-pro-max를 무조건 설치한다.**

### 3순위: 커뮤니티 검색
```bash
# GitHub 검색 (키워드로)
# 예: react-pdf skill을 찾고 싶으면
curl -s "https://api.github.com/search/repositories?q=claude+skill+react-pdf&sort=stars" | head -50
```

## 설치 절차

### Step 1: 검색 결과 평가
skill을 찾으면 반드시 확인:
- [ ] SKILL.md가 있는가?
- [ ] description이 현재 작업과 관련 있는가?
- [ ] 스크립트가 포함되어 있다면, 악의적 코드가 없는가? (간단히 cat으로 확인)
- [ ] 라이선스가 있는가?

### Step 2: 사용자 확인 (CRITICAL)
**설치 전 반드시 사용자에게 확인받을 것.**

사용자에게 보여줄 정보:
```
🔍 관련 skill 발견:
   이름: [skill name]
   출처: [github repo URL]
   설명: [SKILL.md description]
   내용: [주요 지침 요약 2-3줄]
   
   설치하시겠습니까? (.claude/skills/에 추가됩니다)
```

사용자가 승인하면 Step 3 진행. 거부하면 중단.

### Step 3: 설치
```bash
# 프로젝트 로컬에 설치 (이 프로젝트에서만 사용)
cp -r /tmp/skills-[source]/skills/[skill-name] .claude/skills/

# 또는 글로벌에 설치 (모든 프로젝트에서 사용)
# cp -r /tmp/skills-[source]/skills/[skill-name] ~/.claude/skills/
```

기본은 **프로젝트 로컬** 설치. 글로벌 설치는 사용자가 명시적으로 요청할 때만.

### Step 4: 설치 후 확인
```bash
# frontmatter 확인
head -10 .claude/skills/[skill-name]/SKILL.md

# 기존 프로젝트 skills와 충돌 없는지 확인
ls .claude/skills/
```

### Step 5: 정리
```bash
rm -rf /tmp/skills-*
```

## 규칙

- IMPORTANT: 외부 skill 설치 전 반드시 사용자 확인. 자동 설치 금지.
- 같은 세션에서 이미 검색한 소스는 재검색하지 않는다. /tmp/skills-* 존재 여부로 판단.
- 검색은 자유롭게 하되, 설치는 확인 후에만.
- 악의적 코드 의심 시 설치하지 않고 사용자에게 경고.
- 같은 이름의 skill이 이미 있으면, 기존 것과 비교 후 사용자에게 선택 요청.
- 외부 skill은 `external-` 접두사로 설치하여 프로젝트 skill과 구분.
- 설치 후 lessons.md에 "어떤 skill을 왜 설치했는지" 기록.

## 언제 이 skill을 사용하나?

- 특정 라이브러리(react-pdf, pptxgenjs, satori, Remotion 등)의 best practice가 필요할 때
- 보안 리뷰, 성능 최적화 등 전문 영역의 체크리스트가 필요할 때
- 배포 플랫폼(Vercel, AWS 등)의 설정 가이드가 필요할 때
- "이 작업을 더 잘하는 방법이 있을 것 같다"고 판단될 때
