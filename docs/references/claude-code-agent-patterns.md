# Claude Code Agent Patterns & Best Practices

> Source: https://code.claude.com/docs/en/how-claude-code-works
> Fetched: 2026-03-13
> Related pages: best-practices, common-workflows, memory, sub-agents, features-overview, skills, headless, agent-teams

---

## Table of Contents

1. [The Agentic Loop](#1-the-agentic-loop)
2. [Models and Tools](#2-models-and-tools)
3. [Context Window Management](#3-context-window-management)
4. [CLAUDE.md and Memory Systems](#4-claudemd-and-memory-systems)
5. [Skills System](#5-skills-system)
6. [Subagents](#6-subagents)
7. [Agent Teams](#7-agent-teams)
8. [Best Practices for Agent-First Development](#8-best-practices-for-agent-first-development)
9. [Working Effectively with Claude Code](#9-working-effectively-with-claude-code)
10. [Common Failure Patterns](#10-common-failure-patterns)
11. [Automation and Scaling](#11-automation-and-scaling)
12. [Headless / Programmatic Usage (Agent SDK)](#12-headless--programmatic-usage-agent-sdk)
13. [Session Management](#13-session-management)
14. [Permissions and Safety](#14-permissions-and-safety)
15. [Feature Comparison Matrix](#15-feature-comparison-matrix)

---

## 1. The Agentic Loop

Claude Code is an **agentic assistant** -- it doesn't just answer questions, it acts. The core architecture is a loop with three blending phases:

### Three Phases

1. **Gather context** -- search files, read code, understand the codebase
2. **Take action** -- edit files, run commands, create new files
3. **Verify results** -- run tests, check outputs, validate changes

These phases are not sequential steps; they blend together. Claude uses tools throughout, whether searching files to understand code, editing to make changes, or running tests to check its work.

### How the Loop Adapts

- A **question about your codebase** might only need context gathering
- A **bug fix** cycles through all three phases repeatedly
- A **refactor** might involve extensive verification
- Claude decides what each step requires based on what it learned from the previous step, **chaining dozens of actions together and course-correcting along the way**

### Human-in-the-Loop

You're part of this loop. You can interrupt at any point to:
- Steer Claude in a different direction
- Provide additional context
- Ask it to try a different approach

Claude works autonomously but stays responsive to your input.

### Agentic Harness

Claude Code serves as the **agentic harness** around Claude: it provides the tools, context management, and execution environment that turn a language model into a capable coding agent. The loop is powered by two components:
- **Models** that reason
- **Tools** that act

---

## 2. Models and Tools

### Models

- **Sonnet**: handles most coding tasks well
- **Opus**: provides stronger reasoning for complex architectural decisions
- Switch with `/model` during a session or start with `claude --model <name>`

### Tool Categories

| Category | What Claude can do |
|---|---|
| **File operations** | Read files, edit code, create new files, rename and reorganize |
| **Search** | Find files by pattern, search content with regex, explore codebases |
| **Execution** | Run shell commands, start servers, run tests, use git |
| **Web** | Search the web, fetch documentation, look up error messages |
| **Code intelligence** | Type errors/warnings after edits, jump to definitions, find references |

### Example Tool Chain

When you say "fix the failing tests," Claude might:
1. Run the test suite to see what's failing
2. Read the error output
3. Search for the relevant source files
4. Read those files to understand the code
5. Edit the files to fix the issue
6. Run the tests again to verify

Each tool use gives Claude new information that informs the next step -- this is the agentic loop in action.

### Extending Capabilities

- **Skills**: extend what Claude knows
- **MCP**: connect to external services
- **Hooks**: automate workflows (deterministic, no LLM involved)
- **Subagents**: offload tasks to isolated context
- **Plugins**: bundle and distribute feature sets

---

## 3. Context Window Management

> **The most critical resource to manage.** Most best practices trace back to one constraint: Claude's context window fills up fast, and **performance degrades as it fills**.

### What Fills Context

- Conversation history
- File contents Claude reads
- Command outputs
- CLAUDE.md files
- Loaded skills
- MCP tool definitions
- System instructions

### Auto-Compaction

When context approaches the limit, Claude Code:
1. Clears older tool outputs first
2. Summarizes the conversation if needed
3. Preserves your requests and key code snippets
4. May lose detailed instructions from early in conversation

### Controlling Compaction

- Add a **"Compact Instructions"** section to CLAUDE.md
- Run `/compact <instructions>` (e.g., `/compact focus on the API changes`)
- Run `/context` to see what's using space
- Run `/mcp` to check per-server context costs
- Use `Esc + Esc` or `/rewind` to selectively summarize from a checkpoint

### Context Cost by Feature

| Feature | When it loads | Context cost |
|---|---|---|
| **CLAUDE.md** | Session start | Every request |
| **Skills** | Session start (descriptions) + when used (full content) | Low until used |
| **MCP servers** | Session start | Every request (all tool definitions) |
| **Subagents** | When spawned | Isolated from main session |
| **Hooks** | On trigger | Zero (runs externally) |

### Key Strategy: Use Subagents for Context Isolation

Subagents get their own fresh context, completely separate from your main conversation. Their work doesn't bloat your context. When done, they return a summary.

```
Use subagents to investigate how our authentication system handles token
refresh, and whether we have any existing OAuth utilities I should reuse.
```

---

## 4. CLAUDE.md and Memory Systems

### Two Complementary Systems

| | CLAUDE.md files | Auto memory |
|---|---|---|
| **Who writes it** | You | Claude |
| **What it contains** | Instructions and rules | Learnings and patterns |
| **Scope** | Project, user, or org | Per working tree |
| **Loaded into** | Every session | Every session (first 200 lines) |
| **Use for** | Coding standards, workflows, project architecture | Build commands, debugging insights, preferences |

### CLAUDE.md File Locations (Priority Order)

| Scope | Location | Purpose |
|---|---|---|
| **Managed policy** | `/Library/Application Support/ClaudeCode/CLAUDE.md` (macOS) | Organization-wide |
| **Project** | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Team-shared, checked into git |
| **User** | `~/.claude/CLAUDE.md` | Personal preferences across all projects |

### Writing Effective Instructions

**Size**: target under 200 lines per CLAUDE.md file.

**Structure**: use markdown headers and bullets.

**Specificity**: write concrete, verifiable instructions:
- "Use 2-space indentation" (good) vs. "Format code properly" (bad)
- "Run `npm test` before committing" (good) vs. "Test your changes" (bad)

**Consistency**: conflicting rules cause Claude to pick one arbitrarily.

### What to Include vs. Exclude

| Include | Exclude |
|---|---|
| Bash commands Claude can't guess | Anything Claude can figure out by reading code |
| Code style rules that differ from defaults | Standard conventions Claude already knows |
| Testing instructions and preferred test runners | Detailed API documentation (link instead) |
| Repository etiquette (branch naming, PR conventions) | Information that changes frequently |
| Architectural decisions specific to your project | Long explanations or tutorials |
| Developer environment quirks | Self-evident practices like "write clean code" |

### Importing Files

```markdown
See @README.md for project overview and @package.json for available npm commands.

# Additional Instructions
- Git workflow: @docs/git-instructions.md
- Personal overrides: @~/.claude/my-project-instructions.md
```

### Path-Specific Rules (.claude/rules/)

Rules can be scoped to specific file patterns:

```markdown
---
paths:
  - "src/api/**/*.ts"
---

# API Development Rules
- All API endpoints must include input validation
- Use the standard error response format
```

### Auto Memory

- Stored at `~/.claude/projects/<project>/memory/`
- `MEMORY.md` acts as an index (first 200 lines loaded every session)
- Topic files (e.g., `debugging.md`, `api-conventions.md`) loaded on demand
- Plain markdown you can edit or delete at any time
- Toggle with `/memory` or `autoMemoryEnabled` setting

---

## 5. Skills System

Skills extend what Claude can do. Create a `SKILL.md` file with instructions, and Claude adds it to its toolkit.

### Bundled Skills

- **`/simplify`**: reviews recently changed files for code reuse, quality, and efficiency; spawns three parallel review agents
- **`/batch <instruction>`**: orchestrates large-scale changes across a codebase in parallel (5-30 independent units, each in isolated git worktree)
- **`/debug [description]`**: troubleshoots current session by reading the session debug log
- **`/loop [interval] <prompt>`**: runs a prompt repeatedly on an interval
- **`/claude-api`**: loads Claude API reference material for your project's language

### Creating Skills

```yaml
---
name: api-conventions
description: REST API design conventions for our services
---
# API Conventions
- Use kebab-case for URL paths
- Use camelCase for JSON properties
- Always include pagination for list endpoints
```

### Skill Types

**Reference content**: knowledge Claude applies to current work (conventions, patterns, style guides).

**Task content**: step-by-step instructions for a specific action (deploy, commit, code generation).

### Key Frontmatter Fields

| Field | Description |
|---|---|
| `name` | Display name, becomes `/slash-command` |
| `description` | When to use it (Claude uses this for auto-loading) |
| `disable-model-invocation` | `true` = only user can invoke (for side-effect workflows) |
| `user-invocable` | `false` = only Claude can invoke (background knowledge) |
| `allowed-tools` | Tools Claude can use without asking permission |
| `context` | `fork` = run in a forked subagent context |
| `agent` | Which subagent type to use when `context: fork` |

### String Substitutions

- `$ARGUMENTS` -- all arguments passed when invoking
- `$ARGUMENTS[N]` or `$N` -- specific argument by index
- `${CLAUDE_SESSION_ID}` -- current session ID
- `${CLAUDE_SKILL_DIR}` -- directory containing the SKILL.md

### Dynamic Context Injection

The `` !`command` `` syntax runs shell commands before the skill content is sent to Claude:

```yaml
---
name: pr-summary
description: Summarize changes in a pull request
context: fork
agent: Explore
---

## Pull request context
- PR diff: !`gh pr diff`
- PR comments: !`gh pr view --comments`
```

---

## 6. Subagents

Subagents are specialized AI assistants that handle specific tasks. Each runs in its own context window with a custom system prompt, specific tool access, and independent permissions.

### Built-in Subagents

- **Explore**: fast, read-only (Haiku model), for codebase search and analysis
- **Plan**: research agent for plan mode, read-only tools
- **General-purpose**: all tools, inherits model, for complex multi-step tasks

### Why Subagents Matter

- **Preserve context**: keep exploration out of main conversation
- **Enforce constraints**: limit which tools a subagent can use
- **Reuse configurations**: share across projects
- **Specialize behavior**: focused system prompts for specific domains
- **Control costs**: route tasks to faster, cheaper models like Haiku

### Subagent Configuration Example

```markdown
---
name: code-reviewer
description: Expert code review specialist. Use proactively after code changes.
tools: Read, Grep, Glob, Bash
model: inherit
---

You are a senior code reviewer ensuring high standards.

When invoked:
1. Run git diff to see recent changes
2. Focus on modified files
3. Begin review immediately
```

### Subagent Scope (Priority Order)

1. `--agents` CLI flag (current session only, highest priority)
2. `.claude/agents/` (current project)
3. `~/.claude/agents/` (all your projects)
4. Plugin's `agents/` directory (lowest priority)

### Key Configuration Options

| Field | Description |
|---|---|
| `tools` / `disallowedTools` | Control tool access |
| `model` | `sonnet`, `opus`, `haiku`, full model ID, or `inherit` |
| `permissionMode` | `default`, `acceptEdits`, `dontAsk`, `bypassPermissions`, `plan` |
| `maxTurns` | Maximum agentic turns before stop |
| `skills` | Preloaded skills (full content injected at startup) |
| `memory` | Persistent memory scope: `user`, `project`, or `local` |
| `background` | `true` = always run as background task |
| `isolation` | `worktree` = run in temporary git worktree |
| `hooks` | Lifecycle hooks scoped to this subagent |
| `mcpServers` | MCP servers available (inline or by reference) |

### Foreground vs Background

- **Foreground**: blocks main conversation; permission prompts pass through to you
- **Background**: runs concurrently; pre-approves permissions upfront; auto-denies anything not pre-approved

Press **Ctrl+B** to background a running task.

### Effective Patterns

**Isolate high-volume operations**: tests, log processing, documentation fetching.

**Run parallel research**: spawn multiple subagents for independent investigations.

**Chain subagents**: use subagents in sequence for multi-step workflows.

### Persistent Memory for Subagents

```yaml
---
name: code-reviewer
description: Reviews code for quality and best practices
memory: user
---
Update your agent memory as you discover codepaths, patterns, library
locations, and key architectural decisions.
```

---

## 7. Agent Teams

> Experimental feature. Enable with `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`.

Agent teams coordinate multiple independent Claude Code sessions. Unlike subagents (which report back to caller only), teammates share a task list and communicate directly with each other.

### Architecture

| Component | Role |
|---|---|
| **Team lead** | Creates team, spawns teammates, coordinates |
| **Teammates** | Separate Claude Code instances working on assigned tasks |
| **Task list** | Shared work items that teammates claim and complete |
| **Mailbox** | Messaging system for inter-agent communication |

### Best Use Cases

- **Research and review**: investigate different aspects simultaneously
- **New modules/features**: each teammate owns a separate piece
- **Debugging with competing hypotheses**: test different theories in parallel
- **Cross-layer coordination**: frontend, backend, tests each owned by different teammate

### Subagents vs Agent Teams

| | Subagents | Agent teams |
|---|---|---|
| **Context** | Own window; results return to caller | Own window; fully independent |
| **Communication** | Report back to main agent only | Message each other directly |
| **Coordination** | Main agent manages all work | Shared task list with self-coordination |
| **Best for** | Focused tasks, only result matters | Complex work requiring discussion |
| **Token cost** | Lower | Higher (each teammate is separate instance) |

### Team Sizing

- Start with **3-5 teammates** for most workflows
- **5-6 tasks per teammate** keeps everyone productive
- Token costs scale linearly with teammates

### Competing Hypotheses Pattern

```
Users report the app exits after one message instead of staying connected.
Spawn 5 agent teammates to investigate different hypotheses. Have them talk to
each other to try to disprove each other's theories, like a scientific
debate. Update the findings doc with whatever consensus emerges.
```

The debate structure fights anchoring bias -- sequential investigation tends to over-commit to the first plausible theory.

---

## 8. Best Practices for Agent-First Development

### #1: Give Claude a Way to Verify Its Work

> This is the **single highest-leverage thing you can do**.

Claude performs dramatically better when it can check its own work.

| Strategy | Before | After |
|---|---|---|
| **Provide verification criteria** | "implement validateEmail" | "write validateEmail. Test cases: user@example.com -> true, invalid -> false. Run tests after." |
| **Verify UI visually** | "make the dashboard look better" | "[paste screenshot] implement this design. Screenshot result and compare." |
| **Address root causes** | "the build is failing" | "the build fails with [error]. Fix it and verify. Address root cause, don't suppress." |

### #2: Explore First, Then Plan, Then Code

Separate research and planning from implementation.

Four-phase workflow:
1. **Explore** (Plan Mode): read files, ask questions, no changes
2. **Plan**: create detailed implementation plan
3. **Implement** (Normal Mode): code against the plan
4. **Commit**: commit with descriptive message, create PR

Press `Ctrl+G` to open the plan in your text editor for direct editing.

> **Skip planning when the scope is clear**: fixing a typo, adding a log line, renaming a variable. Planning is most useful when uncertain about approach, when change modifies multiple files, or when unfamiliar with the code.

### #3: Provide Specific Context

| Strategy | Example |
|---|---|
| **Scope the task** | "write a test for foo.py covering the edge case where user is logged out. avoid mocks." |
| **Point to sources** | "look through ExecutionFactory's git history and summarize how its api came to be" |
| **Reference patterns** | "look at HotDogWidget.php as an example. Follow the pattern for a new calendar widget." |
| **Describe symptoms** | "users report login fails after session timeout. check auth flow in src/auth/, especially token refresh." |

### #4: Let Claude Interview You

For larger features, have Claude interview you first:

```
I want to build [brief description]. Interview me in detail using the
AskUserQuestion tool.

Ask about technical implementation, UI/UX, edge cases, concerns, and
tradeoffs. Don't ask obvious questions, dig into the hard parts I might
not have considered.

Keep interviewing until we've covered everything, then write a complete
spec to SPEC.md.
```

Then start a fresh session to execute the spec (clean context focused on implementation).

### #5: Delegate, Don't Dictate

Think of delegating to a capable colleague:

```
The checkout flow is broken for users with expired cards.
The relevant code is in src/payments/. Can you investigate and fix it?
```

You don't need to specify which files to read or what commands to run.

### #6: Course-Correct Early and Often

- **`Esc`**: stop mid-action, context preserved
- **`Esc + Esc`** or **`/rewind`**: rewind to previous checkpoint
- **`"Undo that"`**: have Claude revert changes
- **`/clear`**: reset context between unrelated tasks

> If you've corrected Claude more than **twice** on the same issue, the context is cluttered with failed approaches. Run `/clear` and start fresh with a better prompt.

---

## 9. Working Effectively with Claude Code

### It's a Conversation

You don't need perfect prompts. Start with what you want, then refine:
```
Fix the login bug
```
[Claude investigates, tries something]
```
That's not quite right. The issue is in the session handling.
```
[Claude adjusts approach]

### Interrupt and Steer

If Claude is going down the wrong path, just type your correction and press Enter. Claude stops and adjusts. You don't have to wait or start over.

### Use Rich Content

- **`@file`**: reference files directly
- **Paste images**: drag and drop or copy/paste
- **Give URLs**: documentation and API references
- **Pipe data**: `cat error.log | claude`
- **Let Claude fetch**: tell Claude to pull context itself

### Quick Questions Without Context Cost

Use `/btw` for side questions. The answer appears in a dismissible overlay and never enters conversation history.

---

## 10. Common Failure Patterns

### The Kitchen Sink Session
**Problem**: Start with one task, then ask unrelated things, context full of irrelevant info.
**Fix**: `/clear` between unrelated tasks.

### Correcting Over and Over
**Problem**: Claude does something wrong, you correct, still wrong, correct again. Context polluted.
**Fix**: After two failed corrections, `/clear` and write a better initial prompt.

### The Over-Specified CLAUDE.md
**Problem**: CLAUDE.md too long, Claude ignores half of it.
**Fix**: Ruthlessly prune. If Claude already does it correctly without the instruction, delete it.

### The Trust-Then-Verify Gap
**Problem**: Plausible-looking implementation that doesn't handle edge cases.
**Fix**: Always provide verification (tests, scripts, screenshots). If you can't verify it, don't ship it.

### The Infinite Exploration
**Problem**: Ask Claude to "investigate" without scoping. Reads hundreds of files, fills context.
**Fix**: Scope investigations narrowly or use subagents.

---

## 11. Automation and Scaling

### Non-Interactive Mode (`claude -p`)

```bash
# One-off queries
claude -p "Explain what this project does"

# Structured output
claude -p "List all API endpoints" --output-format json

# Streaming
claude -p "Analyze this log file" --output-format stream-json
```

### Writer/Reviewer Pattern

| Session A (Writer) | Session B (Reviewer) |
|---|---|
| `Implement a rate limiter for our API endpoints` | |
| | `Review the rate limiter in @src/middleware/rateLimiter.ts. Look for edge cases, race conditions.` |
| `Here's the review feedback: [Session B output]. Address these issues.` | |

### Fan-Out Pattern

For large migrations or analyses, distribute work across parallel invocations:

```bash
for file in $(cat files.txt); do
  claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
    --allowedTools "Edit,Bash(git commit *)"
done
```

1. Generate a task list
2. Write a script to loop through the list
3. Test on a few files, then run at scale

### Claude as Unix Utility

```json
// package.json
{
  "scripts": {
    "lint:claude": "claude -p 'you are a linter. look at changes vs. main and report issues related to typos.'"
  }
}
```

```bash
# Pipe data through Claude
cat build-error.txt | claude -p 'concisely explain the root cause' > output.txt
```

---

## 12. Headless / Programmatic Usage (Agent SDK)

### Basic Usage

```bash
claude -p "Find and fix the bug in auth.py" --allowedTools "Read,Edit,Bash"
```

### Structured Output with JSON Schema

```bash
claude -p "Extract the main function names from auth.py" \
  --output-format json \
  --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}'
```

### Continuing Conversations

```bash
# First request
claude -p "Review this codebase for performance issues"

# Continue the most recent conversation
claude -p "Now focus on the database queries" --continue

# Resume a specific session
session_id=$(claude -p "Start a review" --output-format json | jq -r '.session_id')
claude -p "Continue that review" --resume "$session_id"
```

### Custom System Prompts

```bash
gh pr diff "$1" | claude -p \
  --append-system-prompt "You are a security engineer. Review for vulnerabilities." \
  --output-format json
```

---

## 13. Session Management

### Session Commands

- `claude --continue`: resume most recent conversation
- `claude --resume`: open session picker or resume by name
- `claude --from-pr 123`: resume sessions linked to a PR
- `claude --continue --fork-session`: branch off without affecting original

### Naming Sessions

```bash
/rename auth-refactor   # Name current session
claude --resume auth-refactor  # Resume by name later
```

### Git Worktrees for Parallel Sessions

```bash
# Start Claude in isolated worktrees
claude --worktree feature-auth
claude --worktree bugfix-123

# Auto-generated name
claude --worktree
```

Worktrees are created at `<repo>/.claude/worktrees/<name>` and branch from the default remote branch.

Add `.claude/worktrees/` to `.gitignore`.

### Session Picker Shortcuts

| Shortcut | Action |
|---|---|
| `Up/Down` | Navigate sessions |
| `Right/Left` | Expand/collapse grouped sessions |
| `Enter` | Select and resume |
| `P` | Preview session |
| `R` | Rename session |
| `/` | Search/filter |
| `A` | Toggle all projects |
| `B` | Filter by current branch |

---

## 14. Permissions and Safety

### Permission Modes (Shift+Tab to cycle)

- **Default**: asks before file edits and shell commands
- **Auto-accept edits**: edits without asking, still asks for commands
- **Plan mode**: read-only tools only, creates plans for approval

### Checkpoints

- Every file edit is reversible
- `Esc` twice to rewind to previous state
- Checkpoints are local to session, separate from git
- Only cover file changes (not external side effects)

### Sandboxing

- OS-level isolation for filesystem and network access
- `--dangerously-skip-permissions` bypasses all checks (only use in sandboxed environments)

---

## 15. Feature Comparison Matrix

### When to Use What

| Feature | What it does | When to use it |
|---|---|---|
| **CLAUDE.md** | Persistent context loaded every conversation | "Always do X" rules |
| **Skill** | Instructions, knowledge, workflows | Reusable content, reference docs, repeatable tasks |
| **Subagent** | Isolated execution context | Context isolation, parallel tasks, specialized workers |
| **Agent teams** | Coordinate multiple independent sessions | Parallel research, competing hypotheses, cross-layer work |
| **MCP** | Connect to external services | External data or actions |
| **Hook** | Deterministic script on events | Predictable automation, no LLM involved |

### CLAUDE.md vs Skill vs Rules

| Aspect | CLAUDE.md | `.claude/rules/` | Skill |
|---|---|---|---|
| **Loads** | Every session | Every session or when matching files opened | On demand |
| **Scope** | Whole project | Can be scoped to file paths | Task-specific |
| **Best for** | Core conventions | Language/directory-specific guidelines | Reference material, repeatable workflows |

### Skill vs Subagent

| Aspect | Skill | Subagent |
|---|---|---|
| **What it is** | Reusable instructions/workflows | Isolated worker with own context |
| **Key benefit** | Share content across contexts | Context isolation |
| **Best for** | Reference material, invocable workflows | Tasks that read many files, parallel work |

### Subagent vs Agent Team

| Aspect | Subagent | Agent team |
|---|---|---|
| **Context** | Own window; results return to caller | Own window; fully independent |
| **Communication** | Reports back to main agent only | Message each other directly |
| **Coordination** | Main agent manages all work | Shared task list, self-coordination |
| **Token cost** | Lower | Higher |

---

## Quick Reference

### Essential Commands

| Command | Purpose |
|---|---|
| `/init` | Generate starter CLAUDE.md |
| `/agents` | Manage subagents |
| `/memory` | Browse memory files, toggle auto memory |
| `/context` | See what's using context space |
| `/compact` | Manually compact context |
| `/clear` | Reset context between tasks |
| `/rewind` | Rewind to previous checkpoint |
| `/rename` | Name current session |
| `/resume` | Switch to different conversation |
| `/btw` | Side question without context cost |
| `/hooks` | Configure hooks interactively |
| `/doctor` | Diagnose common issues |
| `Shift+Tab` | Cycle permission modes |
| `Ctrl+G` | Open plan in text editor |
| `Ctrl+B` | Background a running task |
| `Ctrl+O` | Toggle verbose mode (see thinking) |

### Environment Variables

| Variable | Purpose |
|---|---|
| `CLAUDE_CODE_EFFORT_LEVEL` | Control thinking depth (low, medium, high) |
| `MAX_THINKING_TOKENS` | Limit thinking budget |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | Trigger compaction earlier |
| `CLAUDE_CODE_DISABLE_AUTO_MEMORY` | Disable auto memory |
| `CLAUDE_CODE_DISABLE_BACKGROUND_TASKS` | Disable background tasks |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | Enable agent teams |
| `SLASH_COMMAND_TOOL_CHAR_BUDGET` | Override skill description budget |

---

## Source URLs

- Main: https://code.claude.com/docs/en/how-claude-code-works
- Best Practices: https://code.claude.com/docs/en/best-practices
- Common Workflows: https://code.claude.com/docs/en/common-workflows
- Memory: https://code.claude.com/docs/en/memory
- Skills: https://code.claude.com/docs/en/skills
- Subagents: https://code.claude.com/docs/en/sub-agents
- Agent Teams: https://code.claude.com/docs/en/agent-teams
- Features Overview: https://code.claude.com/docs/en/features-overview
- Headless / Agent SDK: https://code.claude.com/docs/en/headless
- Permissions: https://code.claude.com/docs/en/permissions
- Hooks: https://code.claude.com/docs/en/hooks
- Hooks Guide: https://code.claude.com/docs/en/hooks-guide
- Plugins: https://code.claude.com/docs/en/plugins
- Model Config: https://code.claude.com/docs/en/model-config
- Settings: https://code.claude.com/docs/en/settings
- CLI Reference: https://code.claude.com/docs/en/cli-reference
- MCP: https://code.claude.com/docs/en/mcp
- Costs: https://code.claude.com/docs/en/costs
- GitHub Actions: https://code.claude.com/docs/en/github-actions
- Desktop App: https://code.claude.com/docs/en/desktop
- VS Code: https://code.claude.com/docs/en/vs-code
- JetBrains: https://code.claude.com/docs/en/jetbrains
- Chrome Extension: https://code.claude.com/docs/en/chrome
- Sandboxing: https://code.claude.com/docs/en/sandboxing
- Checkpointing: https://code.claude.com/docs/en/checkpointing
- Agent SDK (Platform): https://platform.claude.com/docs/en/agent-sdk/overview
