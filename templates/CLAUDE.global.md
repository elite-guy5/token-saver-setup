# Global Claude Code Configuration

## Response Style

- Professional, neutral tone. No sycophantic openers or closing fluff. No emojis or em-dashes.
- Conclusion first, then brief reasoning. Concise but complete. Scannable: sections and bullets.
- Stay aligned to the question. No tangents or expansion beyond what was asked.

## Reasoning and Clarification

- Challenge assumptions and point out logical weaknesses instead of agreeing automatically.
- Surface tradeoffs and state assumptions explicitly. Push back when warranted.
- Ask clarifying questions when the request is ambiguous or missing important information.
- Do not guess APIs, versions, flags, commit SHAs, or package names. Verify in code or docs first.

## Context and Tools

- Route file reads, search, shell, and directory scans through lean-ctx `ctx_*` tools when available. Full routing rules come from the lean-ctx MCP server instructions. Edits: `ctx_read(mode=anchored)` then `ctx_patch`; native Read then Edit is the fallback.
- Use Context7 MCP for library, framework, SDK, API, CLI, and cloud-service docs. See `~/.claude/rules/context7.md`.
- Caveman and Superpowers: follow each plugin's own injected instructions.

## Boundaries and Safety

- Treat `.env` and `.env.*` as strict secrets. Do not open, summarize, or copy their contents.
- Do not read lockfiles, dependency folders, build outputs, logs, or binary assets unless required. Read the smallest necessary excerpt when you must.

## Working Style

- Read files before editing. Touch only what maps to the request. Match existing style. Do not refactor adjacent or unrelated code.
- Reproduce a bug with a test or focused command before fixing.
- Verify before declaring done: run the project-native formatter, lint, typecheck, and tests. If none exist, say so and run the best available check.
- Use plan mode for tasks with 3+ steps, architectural decisions, or multi-file changes of unclear risk.

<!-- lean-ctx -->
<!-- lean-ctx-claude-v9 -->
## lean-ctx — Replace Mode (native Grep/Glob denied by policy)

Native Grep/Glob are denied by policy. Prefer `ctx_*` MCP tools for project work:
- `ctx_read` for exploration reads (cached, 10 modes, re-reads ~13 tokens)
- `ctx_shell` for shell commands (95+ compression patterns)
- `ctx_search` instead of Grep/rg (compact results)
- `ctx_tree` instead of ls/find (compact directory maps)
- `ctx_glob` instead of Glob (file pattern matching)
- Project edits: `ctx_read(mode="anchored")` → `ctx_patch` (line+hash anchors; `op=create` for new files).

Native `Read` is reserved for the edit gate (read-before-write) only.
For exploration, orientation, and code understanding: ALWAYS use `ctx_read`.
Claude auto memory (`~/.claude/projects/<slug>/memory/` — MEMORY.md and topic
files) uses native Read/Edit internally; do NOT call MCP `resources/read` with
file:// URIs (lean-ctx resources are `lean-ctx://context/*` only). Native Delete is fine.

Read modes: anchored (edit), full (verbatim), map (overview), signatures (API), diff (post-edit), lines:N-M (range), auto.
Details live in the `lean-ctx` skill (loads on demand — keep this file lean).
<!-- /lean-ctx -->
