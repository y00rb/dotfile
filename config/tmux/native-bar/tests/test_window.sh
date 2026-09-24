#!/usr/bin/env bash
DIR="$(cd "$(dirname "$0")" && pwd)"
. "$DIR/assert.sh"
tnb_boot "$DIR/fixtures/empty.conf"

# Overwrite tmux's defaults first. Otherwise assertions like "contains #I" pass
# against the stock format "#I:#W..." before the builder has run at all, and RED
# proves nothing. The two no-hex assertions below are negative regression guards
# and cannot fail in RED by their nature; every other assertion here can.
tmux -L "$TNB_SOCKET" set-option -g window-status-format         "SENTINEL"
tmux -L "$TNB_SOCKET" set-option -g window-status-current-format "SENTINEL"

tnb_run bash "$DIR/../scripts/build-window.sh"

# Caps present, by codepoint. A terminal renders U+E0B6 as nothing without a
# Nerd Font, so eyeballing the string is not sufficient -- this is the bug that
# shipped once already.
assert_contains window-status-format          $'\xee\x82\xb6'
assert_contains window-status-format          $'\xee\x82\xb4'
assert_contains window-status-current-format  $'\xee\x82\xb6'
assert_contains window-status-current-format  $'\xee\x82\xb4'

# The badge uses reverse against bg=default; caps never do.
assert_contains window-status-format         "fg=white,bg=default,reverse"
assert_contains window-status-current-format "fg=magenta,bg=default,reverse"

# The plugin's thesis, as a test: no hex literal anywhere.
assert_not_matches window-status-format         '#[0-9a-fA-F]{6}'
assert_not_matches window-status-current-format '#[0-9a-fA-F]{6}'

# Window index must survive as a format, not be expanded at build time.
assert_contains window-status-format "#I"

# Window flags (active, last, bell, zoom...) must be rendered. The old bar showed
# them and spec 2 assumes layout parity with it; dropping them silently loses the
# marker that tells you which window is which.
assert_contains window-status-format         "@tnb_window_flags"
assert_contains window-status-current-format "@tnb_window_flags"

# Default is tmux's own #F, so the plugin needs no Nerd Font to show flags.
assert_equals @tnb_window_flags "#F"

# An override must be honoured rather than baked over.
tmux -L "$TNB_SOCKET" set-option -g @tnb_window_flags "ZZZ"
assert_contains "window-status-format" "@tnb_window_flags"
exp="$(tmux -L "$TNB_SOCKET" display -p '#{E:window-status-format}' 2>/dev/null)"
case "$exp" in
  *ZZZ*) printf 'ok: @tnb_window_flags override reaches the rendered format\n' ;;
  *) printf 'FAIL: override not rendered -- [%s]\n' "$exp" >&2
     TNB_FAILS=$((TNB_FAILS + 1)) ;;
esac

# @tnb_caps square was the one branch no test executed, and it is the only one
# that sets bg without fg -- the shape most likely to break from a later edit.
tmux -L "$TNB_SOCKET" set-option -g @tnb_caps square
tnb_run bash "$DIR/../scripts/build-window.sh"
assert_not_contains window-status-format $'\xee\x82\xb6'
assert_not_contains window-status-format $'\xee\x82\xb4'
assert_contains     window-status-format "bg=white"
assert_not_contains window-status-format "fg=,"
assert_not_matches  window-status-format '#[0-9a-fA-F]{6}'

tmux -L "$TNB_SOCKET" set-option -g @tnb_caps none
tnb_run bash "$DIR/../scripts/build-window.sh"
assert_not_contains window-status-format $'\xee\x82\xb6'
assert_contains     window-status-format "#I"

tnb_shutdown
exit $TNB_FAILS
