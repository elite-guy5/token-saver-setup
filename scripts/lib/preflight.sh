#!/usr/bin/env bash

# Report a missing prerequisite and stop before the installer changes files.
preflight_die() {
  local target="$1"
  local prerequisite="$2"
  shift 2

  printf 'error: missing prerequisite for %s: %s\n' "$target" "$prerequisite" >&2
  for instruction in "$@"; do
    printf '%s\n' "$instruction" >&2
  done
  printf 'No files or configuration were changed.\n' >&2
  printf 'Log: %s\n' "$install_log" >&2
  log_line "preflight_failure target=$target prerequisite=$prerequisite"
  exit 1
}

# Verify one command required by one target surface is available on PATH.
require_command_for_target() {
  local target="$1"
  local command_name="$2"
  local instructions="$3"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    preflight_die "$target" "$command_name" "$instructions"
  fi

  log_line "preflight_ok target=$target command=$command_name"
  status_ok "$command_name found for $target"
}

# Check that at least one Claude product surface is available so installed
# instruction files have a consumer.
preflight_claude() {
  local has_cli=0
  local has_desktop=0

  claude_cli_available && has_cli=1
  claude_desktop_available && has_desktop=1

  if [ "$has_cli" = "0" ] && [ "$has_desktop" = "0" ]; then
    preflight_die "claude" "Claude Desktop or claude CLI" "Install Claude Desktop, install the Claude Code CLI, or both."
  fi

  if [ "$has_cli" = "1" ]; then
    log_line "preflight_ok target=claude command=claude"
    status_ok "claude found for claude"
  else
    status_skipped "Claude Code CLI not found"
  fi

  if [ "$has_desktop" = "1" ]; then
    log_line "preflight_ok target=claude app=$(claude_desktop_app_path)"
    status_ok "Claude Desktop found"
  else
    status_skipped "Claude Desktop app not found"
  fi
}

# Check only the prerequisites needed by the selected products.
preflight_targets() {
  step "Preflight selected targets"

  if target_enabled codex; then
    require_command_for_target "codex" "codex" "Install Codex before running this installer."
  fi

  if target_enabled claude; then
    preflight_claude
  fi
}
