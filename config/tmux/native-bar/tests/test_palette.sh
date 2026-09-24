#!/usr/bin/env bash
DIR="$(cd "$(dirname "$0")" && pwd)"
. "$DIR/assert.sh"
tnb_boot "$DIR/fixtures/empty.conf"

# Initialise TNB_BIN in THIS shell. probe() runs inside a command substitution,
# which is a subshell, so a TNB_BIN created there would not survive to be cleaned
# up by tnb_shutdown -- one leaked temp dir per probe.
tnb_run true

check() {  # <description> <expected> <actual>
  if [ "$3" = "$2" ]; then
    printf 'ok: %s\n' "$1"
  else
    printf 'FAIL: %s -- expected [%s] got [%s]\n' "$1" "$2" "$3" >&2
    TNB_FAILS=$((TNB_FAILS + 1))
  fi
}

probe() {  # runs a palette.sh expression against the scratch server
  tnb_run bash -c '. "'"$DIR"'/../scripts/palette.sh"; '"$1"
}

check "ansi is the default palette" "magenta" \
  "$(probe 'tnb_color window_current_number magenta mauve')"

# Review Focus 1: catppuccin mode with @thm_* absent must fall back, never empty.
tmux -L "$TNB_SOCKET" set-option -g @tnb_palette catppuccin
check "catppuccin falls back when @thm_mauve is unset" "magenta" \
  "$(probe 'tnb_color window_current_number magenta mauve')"

tmux -L "$TNB_SOCKET" set-option -g @thm_mauve "#ca9ee6"
check "catppuccin bridge reads @thm_mauve" "#ca9ee6" \
  "$(probe 'tnb_color window_current_number magenta mauve')"

tmux -L "$TNB_SOCKET" set-option -g @tnb_window_current_number_color blue
check "user override beats the bridge" "blue" \
  "$(probe 'tnb_color window_current_number magenta mauve')"

# Review Focus 3: a typo'd @tnb_caps must still produce a cap.
tmux -L "$TNB_SOCKET" set-option -g @tnb_caps "Round-ed"
case "$(probe 'tnb_cap_left green')" in
  *$'\xee\x82\xb6'*) printf 'ok: unknown caps value falls back to rounded\n' ;;
  *) printf 'FAIL: typo caps produced no glyph\n' >&2; TNB_FAILS=$((TNB_FAILS + 1)) ;;
esac

# caps=none must emit nothing -- but "" == "" is also what a MISSING palette.sh
# produces, so the probe also echoes TNB_CAP_L. That makes the expected value the
# glyph alone: empty cap, but proof the file loaded.
tmux -L "$TNB_SOCKET" set-option -g @tnb_caps none
check "caps=none emits nothing (and palette.sh loaded)" $'\xee\x82\xb6' \
  "$(probe 'printf "%s%s" "$TNB_CAP_L" "$(tnb_cap_left green)"')"

tnb_shutdown
exit $TNB_FAILS
