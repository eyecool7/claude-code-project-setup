---
description: 프로젝트 계획서 작성 프롬프트를 파일로 생성. claude.ai에서 사용.
---

# 프로젝트 계획서 작성

## 실행 절차

1. Read 도구로 아래 템플릿 파일을 읽는다:
   `~/.claude/plugins/cache/claude-code-project-setup/project-setup/1.0.0/templates/project-plan-prompt.md`

2. Write 도구로 프로젝트 루트에 `project-plan-prompt.md`로 저장한다.

3. 사용자에게 다음만 전달한다:

---

`project-plan-prompt.md` 파일을 프로젝트 루트에 생성했습니다.

**사용법:**
1. `project-plan-prompt.md`를 열어서 `[프로젝트 이름]`과 `프로젝트 개요`를 채우세요.
2. 프롬프트 전체 내용을 **claude.ai** 채팅창에 붙여넣고 대화하며 계획서를 완성하세요.
3. 완성된 계획서를 `project-plan.md`로 저장하고 프로젝트 루트에 넣으세요.
4. `/project-setup:refine` 명령어를 실행하여 다음 단계로 넘어갑니다.

---

**중요: 템플릿 내용을 화면에 출력하지 말 것. 파일 저장 + 위 안내만 출력.**
