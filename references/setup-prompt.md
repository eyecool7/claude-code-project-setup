# 프로젝트 셋업 방법
이 문서는 사용자가 Claude Code에서 바로 사용 가능한 '프로젝트 셋업 프롬프트'를 제공하고 사용 방법을 설명한다.

## 사용 방법
> Claude Code에서 프로젝트 폴더를 열고, `references/setup-prompt.md`의 프롬프트를 입력한다.

## 전제 조건
- 스킬 설치가 완료되어 `.claude/`, `references/`, `scripts/`, `SKILL.md`가 루트에 있어야 한다.
- 계획서 작성 + 고도화가 완료되어 `project-plan.md`가 루트에 있어야 한다.

---

# 프로젝트 셋업 프롬프트 (아래 전체를 Claude Code에 전달)

```
@SKILL.md 를 읽고, @project-plan.md 를 기반으로 이 프로젝트를 세팅해줘.

SKILL.md에 정의된 워크플로우(Step 1→5)대로 진행해:

Step 1: scripts/analyze-project.sh + scripts/validate-env.sh 실행 → 프로젝트 분석
Step 2: references/claude-md-template.md 기반으로 CLAUDE.md 생성 (55줄 내외, 80줄 절대 초과 금지)
Step 3: .claude/rules/ 및 .claude/skills/ 템플릿의 TODO를 project-plan.md 기반으로 채우고, hooks/agents/commands의 {{변수}}를 실제 값으로 치환
Step 3.5: 계획서의 MCP 서버 설정으로 .mcp.json 생성 (MCP 서버가 없으면 생략)
Step 4: scripts/validate-setup.sh + scripts/validate-env.sh 실행 → 검증
Step 5: 세팅 결과 요약 출력

검증 통과 후:
- git init + 첫 커밋
- 세팅 전용 파일 삭제: SKILL.md, references/ 폴더, scripts/ 폴더, README.md
  (이 파일들은 세팅에만 쓰이는 스캐폴딩. 프로젝트에 남을 필요 없음.)

세팅 결과를 요약해줘:
- 생성된 CLAUDE.md 줄 수
- 채워진 rules/skills 목록
- 치환된 변수 목록
- .mcp.json 생성 여부
- 검증 결과
```

