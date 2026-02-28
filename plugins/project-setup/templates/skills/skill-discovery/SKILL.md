---
name: skill-discovery
description: Use when you encounter a task where an existing community skill could improve quality — such as working with specific libraries (react-pdf, Remotion, Stripe), design patterns, testing frameworks, or deployment platforms. Search skill marketplaces before building from scratch.
user-invocable: true
---

# Skill & MCP Discovery

직접 만들기 전에 커뮤니티 스킬/MCP를 먼저 검색하라.
이 파일이 검색 소스·절차·규칙의 단일 소스다.

## 리소스 준비

```bash
git clone --depth 1 https://github.com/johunsang/vive-md.git /tmp/vive-md
```

이미 클론되어 있으면 (`ls /tmp/vive-md/ 2>/dev/null`) 재클론하지 않는다.

## 검색 소스 (우선순위 순)

| 우선순위 | 소스 | 경로/URL | 용도 |
|:-------:|------|----------|------|
| 1 | vive-md 스킬 카탈로그 | `/tmp/vive-md/vibe-coding/resources/Awesome-Claude-Skills-한국어-가이드.md` | 380+ 스킬 키워드 검색 |
| 2 | vive-md MCP 서버 카탈로그 | `/tmp/vive-md/vibe-coding/mcp/04-MCP-서버-카탈로그.md` | 스택별 MCP 서버 선정 |
| 3 | vive-md MCP 설정 패턴 | `/tmp/vive-md/vibe-coding/mcp/03-MCP-실전-패턴-모음.md` | 검증된 .mcp.json 레퍼런스 |
| 4 | Anthropic 공식 | `github.com/anthropics/skills` | 공식 스킬 |
| 5 | Trail of Bits | `github.com/trailofbits/skills` | 보안/정적분석/리뷰 |

우선순위 1~3은 vive-md 한 번 클론으로 전부 검색 가능.
4~5는 해당 분야가 프로젝트에 필요할 때만 추가 클론.

**필수 규칙: 프론트엔드가 포함된 프로젝트면 ui-ux-pro-max를 무조건 설치한다.**
```bash
git clone --depth 1 https://github.com/nextlevelbuilder/ui-ux-pro-max-skill.git /tmp/ui-ux-pro-max-skill
cp -r /tmp/ui-ux-pro-max-skill/.claude/skills/ui-ux-pro-max .claude/skills/
rm -rf /tmp/ui-ux-pro-max-skill
```

## 검색 절차

### Step 1: 키워드 추출
프로젝트 스택에서 검색 키워드를 추출한다:
- 프레임워크 (Next.js, Nuxt, SvelteKit 등)
- 주요 라이브러리 (Remotion, Stripe, Prisma 등)
- 외부 API (WordPress, Instagram, OpenAI 등)
- 도메인 (PDF, email, payment, auth, image 등)

### Step 2: 카탈로그 검색
우선순위 1~3 소스에서 키워드로 검색한다.
결과를 아래 형식으로 정리:

```
| 기능 | 검색 키워드 | 검색 결과 | 선택 |
|------|-----------|----------|------|
| (예: 영상 생성) | remotion | (스킬명 + 출처) 또는 "해당 없음" | 설치 / 직접 구현 + 이유 |
```

검색 결과가 없어도 "해당 없음 — 직접 구현"으로 명시. **검색 자체를 생략하지 말 것.**

### Step 3: MCP 서버 선정
우선순위 2~3 소스에서 프로젝트에 필요한 MCP 서버를 선정한다.
결과를 아래 형식으로 정리:

```
| 서비스 | MCP 서버 | 설정 |
|--------|---------|------|
| (예: GitHub) | @modelcontextprotocol/server-github | {"command":"npx","args":["-y","..."]} |
```

또한 아래 형식의 `확정_MCP` JSON 블록도 함께 출력한다.
이 블록은 setup 단계에서 `.mcp.json` 자동 생성에 사용된다.

````json 확정_MCP
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
````

코드 펜스 언어 태그를 반드시 `json 확정_MCP`로 지정한다 (setup 단계에서 이 태그로 블록을 식별).
테이블은 사람이 읽고, JSON 블록은 기계가 읽는다. **둘 다 출력해야 한다.**

### Step 4: 사용자 확인 (CRITICAL)
**설치 전 반드시 사용자에게 확인받을 것.**

사용자에게 보여줄 정보:
```
🔍 검색 결과:
   스킬: [발견 N개 / 해당 없음 M개]
   MCP: [발견 N개]

   [검색 결과 테이블]

   설치를 진행할까요?
```

### Step 5: 설치
```bash
# 스킬 설치 (프로젝트 로컬)
cp -r /tmp/skills-[source]/skills/[skill-name] .claude/skills/

# MCP 설치 → .mcp.json에 추가
```

### Step 6: 정리
```bash
rm -rf /tmp/vive-md /tmp/skills-* /tmp/ui-ux-pro-max-skill
```

## 규칙

- IMPORTANT: 외부 스킬 설치 전 반드시 사용자 확인. 자동 설치 금지.
- 같은 세션에서 이미 클론한 소스는 재클론하지 않는다.
- 악의적 코드 의심 시 설치하지 않고 사용자에게 경고.
- 설치 후 decisions.md에 "어떤 스킬/MCP를 왜 설치했는지" 기록.

## 이 스킬의 호출 시점

- `/project-setup:refine` 실행 시 — 계획서 섹션 3 채우기 위해
- `/project-setup:setup` 실행 시 — 계획서 섹션 3이 비어있을 때 폴백으로
- 개발 중 — 특정 라이브러리의 best practice가 필요할 때
