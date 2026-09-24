#!/usr/bin/env bash
# Assertion helpers for tmux-native-bar. bash 3.2 compatible.
# Each test file gets its own tmux socket so tests never touch a real server.

TNB_SOCKET="tnb_test_$$"
TNB_FAILS=0

tnb_boot() {
  tmux -L "$TNB_SOCKET" kill-server 2>/dev/null
  tmux -L "$TNB_SOCKET" -f "$1" new-session -d
}

tnb_shutdown() {
  tmux -L "$TNB_SOCKET" kill-server 2>/dev/null
  [ -n "${TNB_BIN:-}" ] && rm -rf "$TNB_BIN"
  return 0
}

tnb_get() {
  tmux -L "$TNB_SOCKET" show-option -gqv "$1" 2>/dev/null
}

# tnb_run <command...>
# Runs a plugin script against the scratch server rather than the user's real
# one. A `tmux()` shell function would NOT survive into a child process, so the
# redirection has to be a real executable earlier on PATH.
tnb_run() {
  if [ -z "${TNB_BIN:-}" ]; then
    TNB_BIN="$(mktemp -d)"
    printf '#!/bin/sh\nexec %s -L %s "$@"\n' \
      "$(command -v tmux)" "$TNB_SOCKET" > "$TNB_BIN/tmux"
    chmod +x "$TNB_BIN/tmux"
  fi
  PATH="$TNB_BIN:$PATH" "$@"
}

_tnb_pass() { printf 'ok: %s\n' "$1"; }
_tnb_fail() { printf 'FAIL: %s\n' "$1" >&2; TNB_FAILS=$((TNB_FAILS + 1)); }

assert_equals() {
  local actual
  actual="$(tnb_get "$1")"
  if [ "$actual" = "$2" ]; then
    _tnb_pass "$1 == $2"
  else
    _tnb_fail "$1: expected [$2] got [$actual]"
  fi
}

assert_contains() {
  case "$(tnb_get "$1")" in
    *"$2"*) _tnb_pass "$1 contains $2" ;;
    *)      _tnb_fail "$1: missing [$2] in [$(tnb_get "$1")]" ;;
  esac
}

assert_not_contains() {
  case "$(tnb_get "$1")" in
    *"$2"*) _tnb_fail "$1: unexpectedly contains [$2]" ;;
    *)      _tnb_pass "$1 lacks $2" ;;
  esac
}

assert_not_matches() {
  if tnb_get "$1" | grep -qE "$2"; then
    _tnb_fail "$1: matches forbidden /$2/ -> [$(tnb_get "$1")]"
  else
    _tnb_pass "$1 avoids /$2/"
  fi
}
