#!/usr/bin/env bash
# Generates window-status-format and window-status-current-format.
#
# Pill structure (spec 7.2):
#   <left cap in badge colour, over bg=default>
#   #[fg=<badge>,bg=default,reverse] #I     badge; reverse puts the text in the
#                                           terminal's own background colour,
#                                           giving automatic contrast in light
#                                           and dark themes alike
#   #[none]#[fg=default,bg=<body>] #W       body in the terminal's foreground
#   <right cap in body colour, over bg=default>
#
# #[none] clears the reverse attribute before the body, and colours are set
# explicitly straight after, so it is safe whether or not `none` also resets them.
set -eu
DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
. "$DIR/palette.sh"

# Window flags (active, last, bell, activity, zoom...). Defaults to tmux's own
# #F so flags work without a Nerd Font; override @tnb_window_flags to use glyphs.
# Referenced rather than interpolated, so changing it needs no rebuild.
if ! tnb_is_set @tnb_window_flags; then
  tmux set-option -g @tnb_window_flags "#F"
fi

build() {  # <badge_colour> <body_colour> <text_format>
  printf '%s' "$(tnb_cap_left "$1")"
  printf '#[none]#[fg=%s,bg=default,reverse]#I ' "$1"
  printf '#[none]#[fg=default,bg=%s] %s#{E:@tnb_window_flags} ' "$2" "$3"
  printf '%s' "$(tnb_cap_right "$2")"
}

num="$(tnb_color   window_number          white   overlay_2)"
body="$(tnb_color  window_body            black   surface_0)"
cnum="$(tnb_color  window_current_number  magenta mauve)"
cbody="$(tnb_color window_current_body    black   surface_1)"

tmux set-option -g window-status-format \
  "$(build "$num" "$body" '#W')"
tmux set-option -g window-status-current-format \
  "$(build "$cnum" "$cbody" '#W')"
