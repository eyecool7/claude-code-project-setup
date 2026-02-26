# claude-code-project-setup

Automated Claude Code project setup skill. Generate a refined project plan from a single project description, then produce tailored CLAUDE.md + rules + skills + agents + mcps + hooks based on that plan.

| Step | Where | How |
|------|-------|-----|
| **Step 1** Write plan | claude.ai | Fill in Project Overview in `claude-ai-project-plan-prompt.md`, send entire prompt → Claude interviews → save as **project-plan.md** |
| **Step 2** Refine plan | Claude Code (Plan mode) | Enter `claude-code-plan-mode-prompt.md` prompt → deep technical interview refines **project-plan.md** |
| **Step 3** Install skill | Local machine | Clone this repo → copy needed files ([install↓](#step-3-install-skill--local-machine)) |
| **Step 4** Run setup | Claude Code | Enter `setup-prompt.md` prompt → generates CLAUDE.md + .claude/ + .mcp.json |
| **Step 5** Start dev | Claude Code | `/clear` → `Start project development` |

---

### What the Plan Covers (Step 1)

| Section | Contents | Required |
|---------|----------|----------|
| 1. Product Context | One-liner, background, core features + priorities, success criteria, out of scope | ✅ Required |
| 2. Workflow | User flows, LLM vs script separation, validation + failure handling | ✅ Required |
| 3. Tool & Workflow Design | MCP server selection, skill selection, .mcp.json finalization | ✅ Required |
| 4. Implementation Design | Tech stack, agent structure, skill list, error strategy, dependencies | ✅ Required |
| 5. Technical Decisions | UI tools, data flow, URL structure, external services | ⚪ Optional |
| 6. Implementation Order | Phase-by-phase dependency roadmap | ✅ Required |

---

## Step 3: Install Skill — Local Machine

### Quick Install (git clone)

```bash
cd my-project  # Navigate to your project folder

# Clone this repo temporarily
git clone https://github.com/YOUR_USERNAME/claude-code-project-setup.git /tmp/setup-skill

# Copy only the needed files
cp /tmp/setup-skill/SKILL.md .
cp -r /tmp/setup-skill/.claude .
cp -r /tmp/setup-skill/references .
cp -r /tmp/setup-skill/scripts .

# Remove temp clone
rm -rf /tmp/setup-skill
```

### Manual Install (zip download)

Download the zip from GitHub and copy these files to your project folder:

```
Repo contents                          →    Place in my-project/
───────────────────────────────         ──────────────────
SKILL.md                          →    my-project/SKILL.md
.claude/                          →    my-project/.claude/
references/                       →    my-project/references/
scripts/                          →    my-project/scripts/
```

### Folder State After Step 3

```
my-project/
│
│  ── Setup skill (deleted after setup) ─────────────────
├── SKILL.md                     ← Setup instructions for Claude Code
├── references/
│   ├── claude-md-template.md    ← Template for CLAUDE.md generation
│   ├── claude-ai-project-plan-prompt.md    ← Planning prompt
│   ├── claude-code-plan-mode-prompt.md    ← Plan mode interview prompt
│   └── setup-prompt.md          ← Setup prompt
├── scripts/
│   ├── analyze-project.sh       ← Project analysis automation
│   ├── validate-env.sh          ← Environment variable hygiene check
│   └── validate-setup.sh        ← Setup result validation
│
│  ── .claude/ (template state) ─────────────────────────
├── .claude/
│   ├── commands/
│   │   ├── check.md             ← /check command
│   │   ├── commit-push-pr.md    ← /commit-push-pr command
│   │   └── review.md            ← /review command
│   ├── hooks/
│   │   ├── session-start.sh     ← Auto-run on session start
│   │   ├── edit-monitor.sh      ← Repeated edit detection (hint)
│   │   └── pre-commit-check.sh  ← ⚠️ Still has {{variables}}
│   ├── rules/                   ← ⚠️ Still TODO templates (passive rules)
│   │   ├── conventions.md       ← Always loaded
│   │   ├── security.md          ← Path-scoped (api, auth, middleware)
│   │   ├── error-handling.md    ← Path-scoped (services, api)
│   │   ├── testing.md           ← Path-scoped (test/spec files)
│   │   ├── frontend/react.md    ← (Frontend) path-scoped (tsx, components)
│   │   ├── frontend/styles.md   ← (Frontend) path-scoped (css, scss)
│   │   └── database.md          ← (Backend+DB) path-scoped (db, prisma)
│   ├── skills/                  ← ⚠️ Still TODO/{{variable}} templates (active workflows)
│   │   ├── dependencies/SKILL.md
│   │   ├── design-rules/SKILL.md
│   │   ├── easy-refactoring/SKILL.md
│   │   ├── project-directory/SKILL.md
│   │   └── skill-discovery/SKILL.md
│   ├── agents/
│   │   ├── test-runner.md       ← ⚠️ {{TEST_CMD}} etc. still templated
│   │   ├── code-reviewer.md
│   │   └── debugger.md
│   ├── lessons.md               ← Empty template (populated during dev)
│   └── settings.json
│
│  ── Planning output (from Steps 1-2) ──────────────────
└── project-plan.md
│
│  ── Not yet created ───────────────────────────────────
│  (CLAUDE.md — created in Step 4)
│  (.git — initialized in Step 4)
```

---

## Step 4: What Happens During Setup

| File | Change |
|------|--------|
| **CLAUDE.md** | ⭐ **Created** — Based on plan, ~55 lines |
| .claude/rules/error-handling | 📝 **TODOs filled** — Based on plan's error strategy |
| .claude/rules/security | 📝 **TODOs filled** — Based on plan's auth/security model |
| .claude/rules/testing | 📝 **TODOs filled** — Project test tools & mock targets |
| .claude/rules/conventions | 📝 As-is (additions if project has extra conventions) |
| .claude/rules/frontend/* | 📝 **TODOs filled** — Frontend projects only |
| .claude/rules/database | 📝 **TODOs filled** — Backend+DB projects only |
| .claude/skills/project-directory | 📝 **TODOs filled** — Actual directory structure |
| .claude/skills/easy-refactoring | 📝 As-is |
| .claude/skills/skill-discovery | 📝 As-is |
| .claude/skills/design-rules | 📝 **TODOs filled** — Frontend projects only |
| .claude/skills/dependencies | 📝 **TODOs filled** — Only when dependency gotchas exist |
| **.mcp.json** | ⭐ **Created** — Based on plan's MCP servers (skipped if none) |
| .claude/agents/test-runner | 📝 **Modified** — {{TEST_CMD}} substituted |
| .claude/hooks/pre-commit-check.sh | 📝 **Modified** — Project validation commands |
| .claude/commands/check.md | 📝 **Modified** — Package manager commands |
| .claude/settings.json | 📝 **Modified** — Permissions/hooks config |
| .git/ | ⭐ **Created** — git init + first commit |
| SKILL.md | 🗑️ **Deleted** |
| references/ | 🗑️ **Deleted** |
| scripts/ | 🗑️ **Deleted** |
| README.md | 🗑️ **Deleted** |

---

## Folder State After Step 5

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

## License

MIT
