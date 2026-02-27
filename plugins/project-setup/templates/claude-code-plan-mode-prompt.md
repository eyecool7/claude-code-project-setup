# 프로젝트 계획서 고도화 방법
이 문서는 사용자가 Claude Code Plan Mode에서 바로 사용 가능한 '프로젝트 계획서 고도화 프롬프트'를 제공하고 사용 방법을 설명한다.

## 사용 방법
> Claude Code에서 프로젝트 폴더를 열고, `references/claude-code-plan-mode-prompt.md`의 프롬프트를 입력한다.
> Claude Code가 `project-plan.md`를 읽고, 구현 방식·트레이드오프·우려 사항 등 기술적 관점에서 심층 인터뷰를 진행하여 계획서의 완성도를 한 단계 더 높인다.
> 충분한 인터뷰가 완료되면, 그 결과를 반영해 **완성된 스펙을 동일한 파일에 작성**한다.

## 전제 조건
- 계획서 작성이 완료되어 `project-plan.md`가 루트에 있어야 한다.

---

# 프로젝트 계획서 고도화 프롬프트 (아래 전체를 Claude Code에 전달)

```
@project-plan.md 를 읽고, AskUserQuestionTool을 사용해서 구현 방식, UI/UX, 우려 사항, 트레이드오프 등 모든 것에 대해 상세하게 인터뷰해줘. 단, 뻔한 질문은 하지 마.

충분히 깊이 있게, 완료될 때까지 계속 인터뷰한 다음, 최종 스펙을 project-plan.md에 작성해줘.
```

## 출처

- Original idea & workflow credit: **@trq212 (Thariq)**
- Source: Claude Code spec-based development workflow
