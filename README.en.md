# claude-code-project-setup

[한국어](README.md)

One plan to set up your entire Claude Code project.

Draft your plan, refine it through a deep technical interview, then follow 3 steps — /plan→/refine→/setup — to auto-generate CLAUDE.md and 19+ config files tailored to your project. Cross-session context continuity, dependency conflict detection, tier-based scaling, and community skill auto-discovery included. Stop wasting context on copy-pasted generic templates.

## Features

1. **Two-pass planning for airtight design** — Interview-based planning in claude.ai, then deep technical review in Claude Code. The plan itself is the differentiator.
2. **One plan, 3-step auto-setup** — Just follow /plan→/refine→/setup and get project-tailored CLAUDE.md, rules, skills, agents, and hooks auto-generated.
3. **Tier-based scaling** — Single agent → subagent delegation → team parallelism, expanding as your project grows.
4. **Community skill & MCP auto-discovery** — Searches 380+ skill catalogs before building from scratch. Installs only after user confirmation.
5. **Cross-session context continuity** — Technical decisions in decisions.md, lessons learned in lessons.md, auto-loaded every session via hooks.
6. **Structural error prevention** — analyze-project.sh detects stack/dependency conflicts, validate-setup.sh catches unreplaced variables, leftover TODOs, and hardcoded secrets.

---

## Usage

### Step 1. Create Project Plan

**Command** `/project-setup:plan` : Generates `project-plan-prompt.md` in project root

**User** : Paste `project-plan-prompt.md` prompt into **claude.ai** → Complete `project-plan.md` plan through interview → Save to project root

### Step 2. Refine Project Plan

**Command** `/project-setup:refine` : Generates `project-refine-prompt.md` in project root

**User** : Paste `project-refine-prompt.md` prompt into **claude code** → Refine `project-plan.md` through interview → Save

### Step 3. Project Setup

**Command** `/project-setup:setup` : Auto-generate project config based on `project-plan.md` (CLAUDE.md + .claude/ + .mcp.json)

**User** : `/clear` or new session → Enter `Start building the project` → Project setup begins based on `project-plan.md`

> **Recommended:** Run Steps 1-2 (planning) and Step 3 (implementation) in separate sessions. Planning conversation history pollutes implementation context.

---

## Installation

### Marketplace (Recommended)

```bash
claude plugin marketplace add eyecool7/claude-code-project-setup
claude plugin install project-setup@claude-code-project-setup
```

### Manual Install

```bash
git clone https://github.com/eyecool7/claude-code-project-setup.git
claude plugin marketplace add ./claude-code-project-setup
claude plugin install project-setup@claude-code-project-setup
```

---

## What the Plan Covers

| Section | Contents | Required |
|---------|----------|----------|
| 1. Product Context | One-liner, background, core features + priorities, success criteria, out of scope | ✅ Required |
| 2. Workflow | User flows, LLM vs script separation, validation + failure handling | ✅ Required |
| 3. Tool & Workflow Design | MCP server selection, skill selection, .mcp.json finalization | ✅ Required |
| 4. Implementation Design | Tech stack, agent structure, skill list, error strategy, dependencies | ✅ Required |
| 5. Technical Decisions | UI tools, data flow, URL structure, external services | ⚪ Optional |
| 6. Implementation Order | Phase-by-phase dependency roadmap | ✅ Required |

---

## What Setup Generates

**Always generated:**

| File | Contents |
|------|----------|
| **CLAUDE.md** | Based on plan, ~80 lines |
| .claude/rules/ (4) | conventions, security, error-handling, testing |
| .claude/skills/ (3) | project-directory, easy-refactoring, skill-discovery |
| .claude/agents/ (3) | test-runner, code-reviewer, debugger |
| .claude/commands/ (3) | /check, /review, /commit-push-pr |
| .claude/hooks/ (3) | session-start, edit-monitor, pre-commit-check |
| .claude/decisions.md | Technical decision log template |
| .claude/lessons.md | Mistake/solution log template |
| .claude/settings.json | Permissions/hooks config |

**Conditionally generated:**

| File | Condition |
|------|-----------|
| .claude/rules/frontend/ | Frontend project |
| .claude/rules/database.md | Backend + DB |
| .claude/skills/design-rules/ | Frontend project |
| .claude/skills/ui-ux-pro-max/ | Frontend project (external skill) |
| .claude/skills/dependencies/ | Dependency conflicts detected |
| .claude/skills/{domain-skill}/ | Plan-defined skills |
| .claude/agents/{custom-agent}.md | Tier 2+ agents (plan-defined) |
| .claude/skills/agent-teams/ | Tier 3 agent teams |
| **.mcp.json** | MCP servers selected |

---

## Project State After Setup

Always-generated base config and conditionally-generated additions based on project characteristics.

```
my-project/
├── CLAUDE.md                       ← ⭐ ~80 lines. Auto-loaded every session.
├── .claude/
│   ├── commands/ (3)               ← /review, /check, /commit-push-pr
│   ├── hooks/ (3)                  ← session-start, edit-monitor, pre-commit-check
│   ├── rules/
│   │   ├── conventions.md          ← Always: naming, import, type rules
│   │   ├── security.md             ← Always: api/auth files
│   │   ├── error-handling.md       ← Always: services/api files
│   │   └── testing.md              ← Always: test/spec files
│   ├── skills/
│   │   ├── project-directory/      ← Always: file/folder placement
│   │   ├── easy-refactoring/       ← Always: refactoring
│   │   └── skill-discovery/        ← Always: auto-search external skills
│   ├── agents/
│   │   ├── test-runner.md          ← Always: test execution
│   │   ├── code-reviewer.md        ← Always: code review
│   │   └── debugger.md             ← Always: debugging
│   ├── decisions.md                ← Technical decision log
│   ├── lessons.md                  ← Mistake/solution log
│   └── settings.json
│
│   ─── Conditionally generated ───
│
│   ├── rules/frontend/             ← Frontend project
│   ├── rules/database.md           ← Backend + DB
│   ├── skills/design-rules/        ← Frontend project
│   ├── skills/ui-ux-pro-max/       ← Frontend project (external skill)
│   ├── skills/dependencies/        ← Dependency conflicts detected
│   ├── skills/{domain-skill}/      ← Plan-defined skills
│   ├── agents/{custom-agent}.md   ← Tier 2+ agents (plan-defined)
│   └── skills/agent-teams/         ← Tier 3 agent teams
├── .mcp.json                       ← MCP servers selected
└── project-plan.md                 ← Kept for reference
```

**Useful commands:**
- `/check` — Typecheck + lint + test, one-line summary
- `/review` — Code review of changes
- `/commit-push-pr` — Commit → push → create PR

**Auto-activated:**
- **Rules** — Error/security/test/convention rules auto-load when working on matching files
- **Skills** — File placement, refactoring, design workflows auto-discovered when relevant
- **Agents** — Complex testing/review/debugging delegated to dedicated agents in independent context
- **Decisions/Lessons** — Session alerts when records accumulate, preventing repeated mistakes
- **Skill Discovery** — Auto-search and suggest external skills when needed (user confirmation before install)

---

## Plugin Structure

```
claude-code-project-setup/
├── .claude-plugin/
│   └── marketplace.json         ← Marketplace metadata
├── plugins/
│   └── project-setup/
│       ├── .claude-plugin/
│       │   └── plugin.json      ← Plugin definition
│       ├── commands/
│       │   ├── plan.md          ← /project-setup:plan
│       │   ├── refine.md        ← /project-setup:refine
│       │   └── setup.md         ← /project-setup:setup
│       ├── templates/           ← Templates referenced during generation
│       │   ├── claude-md-template.md
│       │   ├── rules/
│       │   ├── skills/
│       │   ├── agents/
│       │   ├── commands/
│       │   ├── hooks/
│       │   ├── settings.json
│       │   ├── lessons.md
│       │   └── decisions.md
│       └── scripts/             ← Analysis/validation scripts
│           ├── analyze-project.sh
│           ├── validate-env.sh
│           └── validate-setup.sh
├── README.md
├── README.en.md
└── LICENSE
```

---

## License

MIT
