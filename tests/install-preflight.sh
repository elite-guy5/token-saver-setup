#!/usr/bin/env bash
set -euo pipefail

# Locate the repository and create an isolated temporary workspace for this test
# file.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# Assert that command output includes an expected substring.
assert_contains() {
  case "$1" in
    *"$2"*) ;;
    *)
      printf 'expected output to contain: %s\noutput was:\n%s\n' "$2" "$1" >&2
      exit 1
      ;;
  esac
}

# Assert that a path was not created.
assert_not_exists() {
  [ ! -e "$1" ] || {
    printf 'expected path not to exist: %s\n' "$1" >&2
    exit 1
  }
}

# Verify missing Codex stops the install before managed files are written.
missing_codex_stops_before_changes() {
  local home="$tmp/home-missing-codex"
  mkdir -p "$home"

  if HOME="$home" PATH="/usr/bin:/bin" \
    bash "$ROOT/scripts/install.sh" --non-interactive --targets codex >"$tmp/codex.out" 2>"$tmp/codex.err"; then
    printf 'missing codex unexpectedly succeeded\n' >&2
    exit 1
  fi

  assert_contains "$(cat "$tmp/codex.err")" "missing prerequisite for codex: codex"
  assert_contains "$(cat "$tmp/codex.err")" "No files or configuration were changed."
  assert_not_exists "$home/.codex/AGENTS.md"
  assert_not_exists "$home/.agents/scripts/seed-project-instructions.sh"
}

# Verify missing Claude surfaces stop the install before Claude files are
# written.
missing_claude_surfaces_stop_before_changes() {
  local home="$tmp/home-missing-claude"
  mkdir -p "$home"

  if HOME="$home" PATH="/usr/bin:/bin" \
    CLAUDE_DESKTOP_APP_PATH="$home/missing/Claude.app" \
    bash "$ROOT/scripts/install.sh" --non-interactive --targets claude >"$tmp/claude.out" 2>"$tmp/claude.err"; then
    printf 'missing claude unexpectedly succeeded\n' >&2
    exit 1
  fi

  assert_contains "$(cat "$tmp/claude.err")" "missing prerequisite for claude: Claude Desktop or claude CLI"
  assert_contains "$(cat "$tmp/claude.err")" "Install Claude Desktop, install the Claude Code CLI, or both."
  assert_not_exists "$home/.claude/CLAUDE.md"
}

# Verify Claude Desktop alone satisfies the Claude product target now that the
# installer only manages instruction files and Git hooks.
claude_desktop_without_cli_passes_preflight() {
  local home="$tmp/home-claude-desktop-only"
  local output
  mkdir -p "$home/bin" "$home/Applications/Claude.app"

  output="$(
    HOME="$home" PATH="$home/bin:/usr/bin:/bin" \
      CLAUDE_DESKTOP_APP_PATH="$home/Applications/Claude.app" \
      bash "$ROOT/scripts/install.sh" --dry-run --non-interactive --targets claude
  )"

  assert_contains "$output" "OK Claude"
  assert_contains "$output" "OK Claude Desktop found"
  assert_contains "$output" "Skipped Claude Code CLI not found"
  assert_contains "$output" "$home/.claude/CLAUDE.md"
}

# Verify preflight no longer requires Node.js runtimes or third-party API keys.
claude_cli_without_node_runtimes_passes_preflight() {
  local home="$tmp/home-claude-cli-only"
  local output
  mkdir -p "$home/bin"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$home/bin/claude"
  chmod +x "$home/bin/claude"

  output="$(
    HOME="$home" PATH="$home/bin:/usr/bin:/bin" \
      CLAUDE_DESKTOP_APP_PATH="$home/missing/Claude.app" \
      bash "$ROOT/scripts/install.sh" --dry-run --non-interactive --targets claude
  )"

  assert_contains "$output" "OK claude found for claude"
  assert_contains "$output" "$home/.claude/CLAUDE.md"
}

# Run the preflight scenarios.
missing_codex_stops_before_changes
missing_claude_surfaces_stop_before_changes
claude_desktop_without_cli_passes_preflight
claude_cli_without_node_runtimes_passes_preflight

printf 'install-preflight.sh: OK\n'
