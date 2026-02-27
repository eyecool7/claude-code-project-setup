# claude-code-project-setup

[한국어](README.md)

Set up your entire Claude Code project in 3 commands.

Stop wasting context on copy-pasted generic templates. This plugin refines your project plan through a 2-step interview first, then generates 18+ config files tailored to your project: CLAUDE.md (~55 lines) + path-scoped rules + auto-discovered skills + agents + hooks + MCP.

## Usage

| Step | Command | Description |
|------|---------|-------------|
| **1** | `/project-setup:plan` | Outputs planning prompt → **paste into claude.ai** → interview → save **project-plan.md** to project root |
| **2** | `/project-setup:refine` | Deep technical interview in Plan mode → refine **project-plan.md** |
| **3** | `/project-setup:setup` | Auto-generate CLAUDE.md + .claude/ + .mcp.json from plan |

> **Recommended:** Run Steps 1-2 (planning) and Step 3 (implementation) in separate sessions. Planning conversation history pollutes implementation context.

---

## Installation

### Plugin Marketplace (Recommended)

```bash
# Install from marketplace
claude plugin install claude-code-project-setup
```

### Manual Install

```bash
# Clone this repo
git clone https://github.com/johunsang/claude-code-project-setup.git

# Install as local plugin
claude plugin install ./claude-code-project-setup
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

| File | Change |
|------|--------|
| **CLAUDE.md** | ⭐ **Created** — Based on plan, ~55 lines |
| .claude/rules/ (4-7) | 📝 **TODOs filled** — conventions, security, error-handling, testing + conditional (frontend, database) |
| .claude/skills/ (3-5) | 📝 **TODOs filled** — project-directory, easy-refactoring, skill-discovery + conditional (design-rules, dependencies) |
| .claude/agents/ (3) | 📝 **Modified** — test-runner, code-reviewer, debugger |
| .claude/commands/ (3) | 📝 **Modified** — /check, /review, /commit-push-pr |
| .claude/hooks/ (3) | 📝 **Modified** — session-start, edit-monitor, pre-commit-check |
| .claude/settings.json | 📝 **Modified** — Permissions/hooks config |
| **.mcp.json** | ⭐ **Created** — Based on plan's MCP servers (skipped if none) |
| .git/ | ⭐ **Created** — git init + first commit |

---

## Project State After Setup

```
my-project/
├── CLAUDE.md                    ← ⭐ ~55 lines. Auto-loaded every session.
├── .claude/
│   ├── commands/ (3)            ← /review, /check, /commit-push-pr
│   ├── hooks/ (3)               ← session-start, edit-monitor, pre-commit-check
│   ├── rules/ (4-7)             ← ⭐ Auto-loaded. Path-scoped to relevant files.
│   │   ├── conventions.md       ← Always loaded: naming, import, type rules
│   │   ├── security.md          ← Auto-loaded for api/auth files
│   │   ├── error-handling.md    ← Auto-loaded for services/api files
│   │   ├── testing.md           ← Auto-loaded for test/spec files
│   │   ├── frontend/            ← (Frontend) auto-loaded for tsx/css files
│   │   └── database.md          ← (Backend+DB) auto-loaded for db files
│   ├── skills/ (3-5)            ← ⭐ Auto-discovered by Claude. Loaded when relevant.
│   │   ├── project-directory/   ← Always: when deciding file/folder placement
│   │   ├── easy-refactoring/    ← Always: when performing refactoring
│   │   ├── skill-discovery/     ← Always: auto-search when external skills needed
│   │   ├── design-rules/        ← (Frontend) AI design keyword workflow
│   │   └── dependencies/        ← (Gotcha) when installing/configuring packages
│   ├── agents/ (3)              ← ⭐ Auto-delegated when needed. Independent context.
│   │   ├── test-runner.md
│   │   ├── code-reviewer.md
│   │   └── debugger.md
│   ├── lessons.md               ← Accumulated mistakes/solutions during dev
│   └── settings.json
├── project-plan.md              ← Kept for reference
└── .git/
```

**Useful commands:**
- `/check` — Typecheck + lint + test, one-line summary
- `/review` — Code review of changes
- `/commit-push-pr` — Commit → push → create PR

**Auto-activated:**
- **Rules (4-7)** — Error/security/test/convention rules auto-load when working on matching files
- **Skills (3-5)** — File placement, refactoring, design workflows auto-discovered when relevant
- **Agents (3)** — Complex testing/review/debugging delegated to dedicated agents in independent context
- **Lessons** — Session alerts when mistake records accumulate, preventing repeated errors
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
