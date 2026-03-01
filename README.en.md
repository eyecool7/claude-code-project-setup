# Project Launch

From plan writing to auto-setup and step-by-step build guidance — a Launchpad for Claude Code projects.

[한국어](README.md)

---

## Who Is This For?

You know you need a plan but don't know what to write, setup feels overwhelming, and you lose context every session. This tool is for you.

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

1. **`/project-launch:plan`** — Plan creation: generate a project plan through a structured interview
2. **`/project-launch:refine`** — Plan refinement: complete the plan with deep technical review and skill/MCP discovery
3. **`/project-launch:setup`** — Project setup: auto-generate CLAUDE.md and config files from the plan
4. **`/project-launch:build`** — Project build: status analysis and session goals every session

```
[Session 1 — Plan]                [Session 2 — Setup]      [Session 3+ — Build]

 /plan → Generate prompt           /setup → Auto-setup      /build → Status check
   ↓                                 ↓                       ↓
 Write plan in claude.ai           CLAUDE.md                Where you left off
   ↓                               .claude/ (20 files)      Today's tasks
 /refine → Technical review        Setup record preserved   Previous context restored
   ↓
 project-plan.md complete
```

---

## Installation

**Method 1: Claude Code Plugin (Recommended)**

Add the marketplace inside Claude Code first.

```
/plugin marketplace add eyecool7/claude-code-project-launch
```

Then install the plugin.

```
/plugin install project-launch@eyecool7
```

**Method 2: Terminal CLI**

Run in a regular terminal (zsh/bash).

```bash
claude plugin marketplace add eyecool7/claude-code-project-launch
claude plugin install project-launch@eyecool7

# Verify installation
claude plugin list
```

**Requirements**

- Claude Code v1.0.33 or higher (`claude --version`)
- Update: `npm update -g @anthropic-ai/claude-code`

---

## Key Features

### 1. Airtight 2-Pass Design for a Polished Plan

Structured interview-based planning in claude.ai, then deep technical review in Claude Code. The plan itself is the differentiator.

### 2. Plan-Driven 4-Step Guide for Automated Project Setup

Follow `/project-launch:plan` → `/project-launch:refine` → `/project-launch:setup` → `/project-launch:build` and project-tailored CLAUDE.md, rules, skills, agents, and hooks are auto-generated. From CLAUDE.md length to security settings, the plan decides.

### 3. Auto-Detected Tier-Based Work Mode for Your Project Scale

| Tier | Mode | Best For |
|------|------|----------|
| 1 | Sequential | 3 or fewer features, simple projects |
| 2 | Subagents | Independent work blocks, context savings needed |
| 3 | Agent Teams | Large-scale parallel sessions, inter-agent communication needed |

### 4. Auto-Discovery from Community Skill & MCP Catalogs

During the refine step, skills and MCP servers your project needs are searched from catalogs. Installed only after user confirmation.

### 5. Cross-Session Context Continuity via Decision & Troubleshooting Logs

`decisions.md` and `lessons.md` accumulate automatically. Run `/project-launch:build` in a new session and it reads all prior records to restore context.

### 6. Validation Scripts to Catch Stack Conflicts & Security Gaps Early

Auto-detects stack/dependency conflicts and missing configs. Non-standard combos like Remotion + Next.js get early warnings.

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

> **On run:**
> 1. Open `project-plan-prompt.md` and fill in `[Project Name]` and `Project Overview`.
> 2. Paste the full prompt into **claude.ai** and complete the plan through conversation.
> 3. Save the finished plan as `project-plan.md` in the project root.
> 4. Run `/project-launch:refine` to proceed to the next step.

### Step 2. Refine Project Plan

`/project-launch:refine` → generates `project-refine-prompt.md`
Paste the prompt into **Claude Code**, run technical review + skill/MCP search → refine `project-plan.md` → save

> **On run:**
> 1. Open `project-refine-prompt.md` and paste the prompt into **Claude Code**.
> 2. Refine `project-plan.md` through conversation with Claude Code.
> 3. Save the refined plan back to `project-plan.md` in the project root.
> 4. Run `/project-launch:setup` to proceed to the next step.

### Step 3. Project Setup

`/project-launch:setup` → auto-generates CLAUDE.md + .claude/ + .mcp.json
On completion, **Section 7 (Setup Results)** is auto-appended to `project-plan.md`. Context preserved after `/clear`.

> **On run:**
> Setup complete.
>
> | Item | Result |
> |------|--------|
> | CLAUDE.md | {lines} lines |
> | .claude/ files | {count} files |
> | Work mode | Tier {1/2/3} — {mode} |
> | Community skills | {count} installed |
> | MCP servers | {count} configured |
>
> Run `/clear` then `/project-launch:build` to start plan-based development.

### Step 4. Start Building

`/project-launch:build` → plan-based status analysis + session goals output
Run at the start of every session. For re-entry (returning after days), it reads the full plan + `decisions.md`, `lessons.md`, and `git log` to determine where to continue.

> **On run:**
> 📋 **Project Status**
>
> | Phase | Status | Notes |
> |-------|:------:|-------|
> | Phase 1: Foundation | ✅/🔨/⬜ | ... |
>
> **Current Phase:** Phase N — {name}
> **Session goals:** (2–4 items from incomplete criteria)
> **Notes:** Related decisions.md + lessons.md entries
>
> 📝 Record rules: decisions.md (on tech decisions), lessons.md (on failure resolution), self-check before session end

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

### Always Generated (20 files)

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
| Templates (27) | CLAUDE.md, rules, skills, agents, commands, hooks, settings, records generation + 2 prompts |
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
