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

# Verify Codex product targets derive the codex tool selector.
target_mode_derives_codex_tools() {
  local home="$tmp/home-codex-targets"
  local output
  mkdir -p "$home/bin"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$home/bin/codex"
  chmod +x "$home/bin/codex"

  output="$(
    HOME="$home" PATH="$home/bin:$PATH" \
      bash "$ROOT/scripts/install.sh" --dry-run --non-interactive --targets codex
  )"

  assert_contains "$output" "Selected targets"
  assert_contains "$output" "OK Codex"
  assert_contains "$output" "Selected tools"
  assert_contains "$output" "OK codex"
}

# Verify mixed Codex and Claude product targets derive the both tool selector
# while showing only product-level selections.
target_mode_derives_both_tools() {
  local home="$tmp/home-both-targets"
  local output
  mkdir -p "$home/bin"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$home/bin/codex"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$home/bin/claude"
  chmod +x "$home/bin/codex" "$home/bin/claude"

  output="$(
    HOME="$home" PATH="$home/bin:$PATH" \
      bash "$ROOT/scripts/install.sh" --dry-run --non-interactive --targets codex,claude
  )"

  assert_contains "$output" "Selected targets"
  assert_contains "$output" "OK Codex"
  assert_contains "$output" "OK Claude"
  assert_contains "$output" "Selected tools"
  assert_contains "$output" "OK both"
}

# Verify old surface-level target names remain accepted as aliases while the
# normalized output stays product-level.
legacy_surface_targets_normalize_to_products() {
  local home="$tmp/home-legacy-targets"
  local output
  mkdir -p "$home/bin"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$home/bin/codex"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$home/bin/claude"
  chmod +x "$home/bin/codex" "$home/bin/claude"

  output="$(
    HOME="$home" PATH="$home/bin:$PATH" \
      bash "$ROOT/scripts/install.sh" --dry-run --non-interactive --targets codex-desktop,claude-vscode
  )"

  assert_contains "$output" "Selected targets"
  assert_contains "$output" "OK Codex"
  assert_contains "$output" "OK Claude"
  assert_contains "$output" "OK both"
}

# Verify unsupported target names are rejected during argument parsing.
invalid_target_is_rejected() {
  local home="$tmp/home-invalid-target"
  mkdir -p "$home"

  if HOME="$home" bash "$ROOT/scripts/install.sh" --dry-run --non-interactive --targets codex-mobile >"$tmp/invalid.out" 2>"$tmp/invalid.err"; then
    printf 'invalid target unexpectedly succeeded\n' >&2
    exit 1
  fi

  assert_contains "$(cat "$tmp/invalid.err")" "invalid --targets value: codex-mobile"
}

# Verify non-interactive mode auto-detects all installed supported targets.
non_interactive_auto_detects_installed_targets() {
  local home="$tmp/home-auto-detect"
  local output
  mkdir -p "$home/bin" "$home/Applications/Claude.app"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$home/bin/codex"
  chmod +x "$home/bin/codex"

  output="$(
    HOME="$home" PATH="$home/bin:/usr/bin:/bin" \
      CLAUDE_DESKTOP_APP_PATH="$home/Applications/Claude.app" \
      bash "$ROOT/scripts/install.sh" --dry-run --non-interactive
  )"

  assert_contains "$output" "Selected targets"
  assert_contains "$output" "OK Codex"
  assert_contains "$output" "OK Claude"
  assert_contains "$output" "OK both"
}

# Verify the removed VS Code target is rejected instead of silently accepted.
vscode_target_is_rejected() {
  local home="$tmp/home-vscode-target"
  mkdir -p "$home"

  if HOME="$home" bash "$ROOT/scripts/install.sh" --dry-run --non-interactive --targets vscode >"$tmp/vscode.out" 2>"$tmp/vscode.err"; then
    printf 'removed vscode target unexpectedly succeeded\n' >&2
    exit 1
  fi

  assert_contains "$(cat "$tmp/vscode.err")" "invalid --targets value: vscode"
}

# Verify installs without detectable AI tools fail before any changes.
no_detected_targets_fails() {
  local home="$tmp/home-no-targets"
  mkdir -p "$home"

  if HOME="$home" PATH="/usr/bin:/bin" CLAUDE_DESKTOP_APP_PATH="$home/missing/Claude.app" \
    bash "$ROOT/scripts/install.sh" --dry-run --non-interactive >"$tmp/no-targets.out" 2>"$tmp/no-targets.err"; then
    printf 'install without detected targets unexpectedly succeeded\n' >&2
    exit 1
  fi

  assert_contains "$(cat "$tmp/no-targets.err")" "no supported AI tools were detected"
}

# Run target parsing and derivation scenarios.
target_mode_derives_codex_tools
target_mode_derives_both_tools
legacy_surface_targets_normalize_to_products
invalid_target_is_rejected
non_interactive_auto_detects_installed_targets
vscode_target_is_rejected
no_detected_targets_fails

# Verify interactive installs auto-detect targets instead of rendering a
# selection checklist.
interactive_auto_detects_without_selector() {
  local home="$tmp/home-interactive-auto"
  local output
  mkdir -p "$home/bin"
  printf '#!/usr/bin/env bash\nexit 0\n' > "$home/bin/codex"
  chmod +x "$home/bin/codex"

  output="$(
    printf 'n\n' | HOME="$home" PATH="$home/bin:/usr/bin:/bin" \
      CLAUDE_DESKTOP_APP_PATH="$home/missing/Claude.app" \
      bash "$ROOT/scripts/install.sh" --dry-run
  )"

  assert_contains "$output" "Selected targets"
  assert_contains "$output" "OK Codex"
  case "$output" in
    *"Select targets to configure"*|*"Space toggles"*)
      printf 'target selector appeared in output:\n%s\n' "$output" >&2
      exit 1
      ;;
  esac
}

interactive_auto_detects_without_selector

printf 'install-targets.sh: OK\n'
