#!/usr/bin/env bash
# tmux-native-bar entrypoint.
# TPM sources this in phase 2; for now tmux.conf loads it with `run`.
# Re-running it is the documented rebuild path after adding a module, so it must
# be idempotent and must not clobber values the user has set.
set -eu
DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
. "$DIR/scripts/palette.sh"

# seed <option> <value> -- only when the user has not set it AT ALL.
# Uses tnb_is_set, not [ -z "$(show-option -gqv ...)" ]: setting an option to the
# empty string is how a user says "no icon" / "no flags", and the -gqv form
# reports that identically to unset, so the default was written back over the
# user's choice on every run.
seed() {
  if ! tnb_is_set "$1"; then
    tmux set-option -g "$1" "$2"
  fi
}

# The bar itself: the terminal's own background and foreground.
tmux set-option -g status-style "bg=default,fg=default"

# Built-in modules, defined through the same public contract as user modules.
# Icons are plain ASCII here; override them with Nerd Font glyphs in tmux.conf.
seed @tnb_module_session_icon    "S"
seed @tnb_module_session_color   "#{?client_prefix,red,green}"
seed @tnb_module_session_text    "#S"
seed @tnb_module_directory_icon  "D"
seed @tnb_module_directory_color "white"
seed @tnb_module_directory_text  "#{b:pane_current_path}"

"$DIR/scripts/build-window.sh"
"$DIR/scripts/build-modules.sh"
