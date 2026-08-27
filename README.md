<div align="center">

<img src="docs/ai-assistant-stack-logo.png" alt="AI Assistant Stack" width="500">

### Your AI Assistant Stack for Smarter Development

AI Assistant Stack installs optimized AI instruction files and Git hooks that keep every repository configured for token-efficient, consistent AI-assisted development.

<p>
  <a href="#features">Features</a> •
  <a href="#installation">Installation</a> •
  <a href="#recommended-tooling-setup">Recommended Setup</a> •
  <a href="#options">Options</a>
</p>

</div>

## Features

- **Optimized AI Instruction Files** at both the global and project levels, giving AI coding assistants consistent instructions across every repository.
- **AI Instruction Project Bootstrap** installs a Git hook that automatically seeds new Git repositories with the appropriate **AGENTS.md** and/or **CLAUDE.md** project files, ensuring every project starts with an optimized AI configuration.

The installer manages instruction files and Git hooks only. Any tooling the
instruction files reference (LeanCTX, Context7, Caveman, Superpowers) is set up
separately by hand; this repository neither installs nor configures it.

## Benefits

- Reduce token consumption
- Improve AI context quality
- Standardize AI behavior across projects
- Speed up new project setup
- Keep project instructions synchronized automatically
- Eliminate repetitive AI configuration
...

## Prerequisites

| Target | Required prerequisites |
|--------|------------------------|
| `codex` | Codex CLI (`codex`) |
| `claude` | Claude Desktop, Claude Code CLI (`claude`), or both |

If a selected prerequisite is missing, the installer stops before making
changes and prints the missing prerequisite list.

The default installer auto-detects installed supported AI tools and configures
all of them. Codex and Claude are detected as first-class targets. When `claude`
is detected, either installed Claude surface satisfies the target; the missing
surface is reported as skipped instead of blocking the install.

No API keys are required. The installer does not contact any network service.

## Installation

Users do not need to clone this repository. The bootstrap script downloads a
temporary archive, verifies it when a checksum is provided, runs the installer,
and removes the temporary files when it exits.

Install Command:

```bash
curl -fsSL https://raw.githubusercontent.com/elite-guy5/ai-assistant-stack/main/scripts/bootstrap.sh | bash
```

Installer logs are written to:

```text
~/.agents/install.log
```

## What It Installs

- Codex global instructions: `~/.codex/AGENTS.md`
- Codex project template: `~/.codex/AGENTS.project-template.md`
- Claude Code global instructions: `~/.claude/CLAUDE.md`
- Claude Code project template: `~/.claude/CLAUDE.project-template.md`
- Shared seeding script: `~/.agents/scripts/seed-project-instructions.sh`
- Git template hooks:
  - `~/.agents/git-template/hooks/post-checkout`
  - `~/.agents/git-template/hooks/post-merge`

The Git template hooks seed instruction files into repositories created after
installation. During interactive install, the script also offers to seed and
install managed hooks in the current repository when it is run from inside one.

## What the Markdown Files Configure

- Global `AGENTS.md` and `CLAUDE.md` files define the baseline response style,
  verification expectations, secret handling, and token-saver context
  boundaries.
- The global files tell agents to use LeanCTX for scoped code reading, search,
  AST-aware workspace analysis, and compressed shell output.
- The global files require Caveman as a compression skill for conversational
  narrative, prompt instructions, and logs while preserving code, paths, flags,
  APIs, and error output exactly.
- The global files keep Superpowers manual-only unless the user explicitly
  requests that workflow in a session.
- Project templates give each repository a local place for purpose, language,
  commands, tests, coding standards, project-specific rules, and context
  boundaries.

## Recommended Tooling Setup

The instruction files installed by this repository assume a supporting set of
plugins and MCP servers. Set up both Claude and Codex: use Claude as the primary
harness and Codex as the fallback when Claude tokens run out. Route automated,
non-coding tasks to Codex to preserve Claude tokens.

### Token Management

Match the model to the task. Use smaller, cheaper models for simple work such as
automations, and reserve the advanced models for larger, more complex
development work. Use the ChatGPT chat interface for ideation and general
questions, which costs no harness tokens.

### Tool Overview

| Tool | Purpose |
|------|---------|
| `codeburn` | Reports token usage and spend. |
| `lean-ctx` | Reduces token spend on file reads, search, and shell output. |
| `context7` | Serves current library and framework documentation. |
| `caveman` | Compresses conversational text to reduce token usage. |
| `superpowers` | Full software development methodology for coding agents. |
| `fable-foreman` | Turns the selected Claude model into a team lead: it plans, spins up subagents, routes each task to the cheapest worker that clears the quality bar, and can use Codex when Codex is installed. |
| Azure DevOps MCP | Lets the AI tool interact with Azure DevOps. |
| Databricks MCP | Lets the AI tool interact with Databricks. |

### Install Outside Both Harnesses

Install these manually from a terminal rather than through the Claude or Codex
interface:

- lean-ctx: <https://github.com/yvgude/lean-ctx>
- codeburn: <https://github.com/getagentseal/codeburn>

### Claude

Built-in plugins, through `Customize > Plugins > Browse`, then search:

- context7
- Engineering

Built-in connectors, through `Customize > Connections > Browse`, then search:

- Azure DevOps MCP

Marketplace plugins, through `Customize > Plugins > Add > Add marketplace`, then
paste the repository URL:

- <https://github.com/obra/superpowers>
- <https://github.com/JuliusBrussee/caveman>
- <https://github.com/olsenbrands/fable-foreman>

### Codex

Built-in plugins, through `Plugins`, then search:

- superpowers
- context7

Marketplace plugins, through `Plugins > Create dropdown > Add marketplace`, then
paste the repository URL:

- <https://github.com/JuliusBrussee/caveman>

Configured outside the Codex interface:

- Azure DevOps MCP: <https://github.com/microsoft/azure-devops-mcp>

## Explicit Instruction-File Install

The `--tools` flow selects instruction files, templates, the seeding script, and
Git hooks explicitly instead of relying on target auto-detection.

Install Codex and Claude Code instruction files and hooks:

```bash
curl -fsSL https://raw.githubusercontent.com/elite-guy5/ai-assistant-stack/main/scripts/bootstrap.sh | bash -s -- --tools both
```

If you already have this repository checked out for development, you can run the
installer directly from the repository.

Install Codex and Claude Code instruction files and hooks:

```bash
bash scripts/install.sh --tools both
```

Install only Codex instruction files and hooks:

```bash
bash scripts/install.sh --tools codex
```

Install only Claude Code instruction files and hooks:

```bash
bash scripts/install.sh --tools claude
```

The installed Markdown files are:

| Selected Tool | Global File | Project Template |
|---------------|-------------|------------------|
| Codex | `~/.codex/AGENTS.md` | `~/.codex/AGENTS.project-template.md` |
| Claude Code | `~/.claude/CLAUDE.md` | `~/.claude/CLAUDE.project-template.md` |

The installed hook support files are:

- `~/.agents/scripts/seed-project-instructions.sh`
- `~/.agents/git-template/hooks/post-checkout`
- `~/.agents/git-template/hooks/post-merge`

The installer also sets:

```bash
git config --global init.templateDir ~/.agents/git-template
```

New repositories created with `git init` after installation receive the managed
template hooks automatically. Those hooks seed `AGENTS.md`, `CLAUDE.md`, or both
from the installed project templates only when neither project instruction file
already exists.

To seed an existing repository and install managed hooks into that repository's
`.git/hooks/` directory, pass `--repo`:

```bash
bash scripts/install.sh --tools both --repo /path/to/repo
```

Existing Markdown instruction files are skipped by default. Use `--overwrite`
to back up and replace existing managed target files, or use
`--overwrite-global-instructions` / `--overwrite-project-templates` to limit
replacement to one file class.

Preview the install without changing files:

```bash
bash scripts/install.sh --dry-run --non-interactive --tools both
```

## Prompted Install

Interactive install with prompts:

```bash
bash scripts/install.sh
```

Interactive and non-interactive installs auto-detect installed supported AI
tools. Use `--tools codex`, `--tools claude`, or `--tools both` to select
instruction files explicitly instead.

## Git Hook Behavior

The installer writes managed hooks into `~/.agents/git-template/hooks/` and sets
the global Git template directory:

```bash
git config --global init.templateDir ~/.agents/git-template
```

New repositories created with `git init` receive the managed hooks. The hooks
run the shared seeding script, detect the repository root, and create the
selected project instruction files only when neither project instruction file is
already present:

| Selected Tool | Project File |
|---------------|--------------|
| Codex | `AGENTS.md` |
| Claude Code | `CLAUDE.md` |
| Both | `AGENTS.md` and `CLAUDE.md` |

Existing project instruction files stop seeding by default: if either
`AGENTS.md` or `CLAUDE.md` already exists, the hook does not add another project
template file. When overwrite is explicitly requested through the seeding
script, the old file is backed up before replacement.

If a hook already exists, the installer backs it up and writes a wrapper hook
that runs the previous hook before the managed seeding command. Managed markers
prevent duplicate hook entries when the installer is rerun.

## Current Repository Setup

To seed and install managed hooks in an existing repository:

```bash
bash scripts/install.sh --tools both --repo /path/to/repo
```

Interactive installs ask whether to apply the same setup to the current
repository when the installer is run from inside a Git worktree.

## Options

| Option | Purpose |
|--------|---------|
| `--targets codex` | Optional override to configure only Codex. |
| `--targets claude` | Optional override to configure only Claude for detected Desktop and CLI surfaces. |
| `--targets codex,claude` | Optional override to configure both listed products. |
| `--tools codex` | Install only Codex instruction files and hooks. |
| `--tools claude` | Install only Claude Code instruction files and hooks. |
| `--tools both` | Install both instruction-file sets. |
| `--repo <path>` | Also seed and install managed hooks in an existing repo. |
| `--dry-run` | Print actions without changing files. |
| `--non-interactive` | Disable prompts; targets are auto-detected unless `--targets` or `--tools` is passed. |
| `--overwrite` | Back up and replace existing target files. |
| `--overwrite-global-instructions` | Back up and replace global instruction files. |
| `--overwrite-project-templates` | Back up and replace project templates. |
| `--uninstall` | Remove installer-managed files and hook entries. |

## Uninstall

Preview uninstall:

```bash
bash scripts/install.sh --dry-run --uninstall
```

Run uninstall:

```bash
bash scripts/install.sh --non-interactive --uninstall
```

Uninstall removes only artifacts recorded by this installer: managed global
instruction files, project templates, the shared seeding script, Git template
hooks, managed current-repo hook entries, and this installer's
`init.templateDir` setting. It does not delete repository-local `AGENTS.md` or
`CLAUDE.md` files after they have been created.

## Remote Bootstrap

The bootstrap script downloads a pinned archive, verifies its checksum, and
executes the local Bash installer from that archive.

```bash
bash scripts/bootstrap.sh --dry-run --non-interactive --tools both
```

Update the pinned commit and checksum together before publishing a new remote
installer snapshot.

## Development

Run syntax checks:

```bash
bash -n scripts/*.sh tests/*.sh
```

Run the regression suite:

```bash
for test in tests/*.sh; do bash "$test"; done
```

There is no compiled build and no project-native formatter configured. Preserve
the existing shell and Markdown style when editing files.

## Requirements

- macOS
- Bash
- Git
- `curl` or `wget` only when using `scripts/bootstrap.sh`

The installer requires no JavaScript runtime, no network access, and no API
keys.
