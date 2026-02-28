# Project Launch

From plan writing to auto-setup and step-by-step build guidance — a Launchpad for Claude Code projects.

[한국어](README.md)

---

## Who Is This For?

- You know a good project plan matters, but don't know what to write
- You want to start a Claude Code project but the initial setup feels overwhelming
  - You're debating whether CLAUDE.md should be 58 lines or 500
  - Subagents, team mode, skills, MCP — you don't know which to pick
  - You're not sure which skills and MCP servers your project actually needs
  - You don't know how to configure security settings properly
- You want a tool that doesn't stop at setup — one that guides every build session based on your plan
- You lose context every time a session changes and keep repeating mistakes

---

## How Does It Work?

Follow 4 commands, and project-tailored config is auto-generated.

1. **`/plan`** — Plan creation: generate a project plan through a structured interview
2. **`/refine`** — Plan refinement: complete the plan with deep technical review and skill/MCP discovery
3. **`/setup`** — Project setup: auto-generate CLAUDE.md and config files from the plan
4. **`/build`** — Project build: status analysis and session goals every session

```
Plan → Refine → Setup → Build
                          ├── CLAUDE.md (~80 lines)
                          ├── .claude/rules/      (4-7)
                          ├── .claude/skills/     (3+)
                          ├── .claude/agents/     (3+)
                          ├── .claude/commands/   (3)
                          ├── .claude/hooks/      (3)
                          ├── .claude/decisions.md
                          ├── .claude/lessons.md
                          └── .mcp.json (optional)
```

---

## Installation

### Method 1: Claude Code Plugin (Recommended)

Add the marketplace inside Claude Code first.
/plugin marketplace add eyecool7/claude-code-project-launch

Then install the plugin.
/plugin install project-launch@eyecool7

### Method 2: Terminal CLI

Run in a regular terminal (zsh/bash).

```bash
claude plugin marketplace add eyecool7/claude-code-project-launch
claude plugin install project-launch@eyecool7

# Verify installation
claude plugin list
```

### Requirements

- Claude Code v1.0.33 or higher (`claude --version`)
- Update: `npm update -g @anthropic-ai/claude-code`

---

## Key Features

### 1. Airtight 2-Pass Design

Interview-based planning in claude.ai, then deep technical review in Claude Code.
The plan itself is the differentiator.

### 2. One Plan, 4-Step Full Automation

Follow `/plan` → `/refine` → `/setup` → `/build` and project-tailored CLAUDE.md, rules, skills, agents, and hooks are auto-generated. Plan-based build kickoff every session.

### 3. Tier-Based Scaling

Work mode adapts to project size:

| Tier | Mode | Best For |
|:----:|------|----------|
| 1 | Sequential | 3 or fewer features, simple projects |
| 2 | Subagents | Independent work blocks, context savings needed |
| 3 | Agent Teams | Large-scale, inter-agent communication, parallel sessions |

### 4. Community Skill & MCP Auto-Discovery

Searches 380+ skill catalogs before building from scratch.
Installs only after user confirmation. No auto-install.

### 5. Cross-Session Context Continuity

Technical decisions (`decisions.md`) and lessons learned (`lessons.md`) auto-accumulate.
Run `/build` in a new session and it reads all prior records to restore context.

### 6. Structural Mistake Prevention

Stack/dependency conflicts auto-detected, missing configs and security gaps caught by validation scripts.
Non-standard combos like Remotion + Next.js get explicit warnings.

---

## Usage

| Command | Description |
|---------|-------------|
| `/project-launch:plan` | Generate plan creation prompt |
| `/project-launch:refine` | Generate plan refinement prompt |
| `/project-launch:setup` | Auto-generate project config from plan |
| `/project-launch:build` | Build kickoff — plan-based status analysis + session plan |

### Step 1. Create Project Plan

`/project-launch:plan` → generates `project-plan-prompt.md`

Paste the prompt into **claude.ai**, complete the plan through interview → save as `project-plan.md` in project root

### Step 2. Refine Project Plan

`/project-launch:refine` → generates `project-refine-prompt.md`

Paste the prompt into **Claude Code**, run technical review + skill/MCP search → refine `project-plan.md` → save

### Step 3. Project Setup

`/project-launch:setup` → auto-generates CLAUDE.md + .claude/ + .mcp.json

On completion, **Section 7 (Setup Results)** is auto-appended to `project-plan.md`. Context preserved after `/clear`.

> **Recommended:** Run `/clear` before Step 4. Planning conversation history pollutes build context.

### Step 4. Start Building

`/project-launch:build` → plan-based status analysis + session goals output

Run at the start of every session. For re-entry (returning after days), it reads the full plan + `decisions.md`, `lessons.md`, and `git log` to determine where to continue.

---

## What the Plan Covers

| Section | Contents | Required |
|---------|----------|:--------:|
| 1. Product Context | One-liner, background, core features + priorities, success criteria, out of scope | ✅ |
| 2. Workflow | User flows, LLM vs script separation, validation + failure handling | ✅ |
| 3. Tool Design | MCP server selection, skill selection, .mcp.json finalization | ✅ |
| 4. Implementation Design | Tech stack, agent structure, skill list, error strategy, dependencies | ✅ |
| 5. Technical Decisions | UI tools, data flow, URL structure, external services | ⚪ |
| 6. Implementation Order | Phase-by-phase dependency roadmap | ✅ |

---

## Output

### Always Generated (18 files)

| Category | Files | Role |
|----------|-------|------|
| **CLAUDE.md** | 1 | Plan-based ~80 lines. Auto-loaded every session |
| **Rules** | conventions, security, error-handling, testing | Auto-load when working on matching files |
| **Skills** | project-directory, easy-refactoring, skill-discovery | File placement, refactoring, external skill search |
| **Agents** | test-runner, code-reviewer, debugger | Delegate testing, review, debugging |
| **Commands** | /check, /review, /commit-push-pr | Typecheck+lint+test, code review, PR creation |
| **Hooks** | session-start, edit-monitor, pre-commit-check | Session init, edit watch, pre-commit validation |
| **Records** | decisions.md, lessons.md | Technical decisions + mistake/solution log |
| **Config** | settings.json | Permissions/hooks config |

### Conditionally Generated

| File | Condition |
|------|-----------|
| rules/frontend/ | Frontend project |
| rules/database.md | Backend + DB |
| skills/design-rules/ | Frontend project |
| skills/ui-ux-pro-max/ | Frontend (external skill, auto-installed) |
| skills/dependencies/ | Dependency conflicts detected |
| skills/{domain-skill}/ | Plan-defined skills |
| agents/{custom}.md | Tier 2+ agents (plan-defined) |
| skills/agent-teams/ | Tier 3 agent teams |
| .mcp.json | MCP servers selected |

---

## Project State After Setup

```
my-project/
├── CLAUDE.md                  ← ~80 lines. Auto-loaded every session
├── .claude/
│   ├── commands/              ← /review, /check, /commit-push-pr
│   ├── hooks/                 ← session-start, edit-monitor, pre-commit-check
│   ├── rules/                 ← conventions, security, error-handling, testing (+conditional)
│   ├── skills/                ← project-directory, easy-refactoring, skill-discovery (+conditional)
│   ├── agents/                ← test-runner, code-reviewer, debugger (+conditional)
│   ├── decisions.md           ← Technical decision log
│   ├── lessons.md             ← Mistake/solution log
│   └── settings.json
├── .mcp.json                  ← MCP servers (optional)
└── project-plan.md            ← Kept for reference
```

**Auto-activated:**
- **Rules** — Error/security/test/convention rules auto-load when working on matching files
- **Skills** — File placement, refactoring, design workflows auto-discovered when relevant
- **Agents** — Complex testing/review/debugging delegated to dedicated agents in independent context
- **Decisions/Lessons** — Session alerts when records accumulate, preventing repeated mistakes
- **Skill Discovery** — Auto-search and suggest external skills when needed (user confirmation before install)

---

## Components

| Component | Description |
|-----------|-------------|
| Commands (4) | `/project-launch:plan`, `refine`, `setup`, `build` |
| Templates | CLAUDE.md, rules, skills, agents, commands, hooks generation |
| Scripts (3) | analyze-project, validate-env, validate-setup |

---

## Plugin Structure

```
claude-code-project-launch/
├── .claude-plugin/marketplace.json
├── plugins/project-launch/
│   ├── .claude-plugin/plugin.json
│   ├── commands/          ← plan, refine, setup, build
│   ├── templates/         ← Templates referenced during generation
│   └── scripts/           ← Analysis/validation scripts
├── README.md
├── README.en.md
└── LICENSE
```

---

## License

MIT
