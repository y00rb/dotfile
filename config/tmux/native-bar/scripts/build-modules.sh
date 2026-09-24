#!/usr/bin/env bash
# Discovers @tnb_module_<name>_text options and generates @tnb_status_<name>.
#
# The generated value is a TEMPLATE, not a snapshot: it references
# #{@tnb_module_<name>_color} rather than interpolating the colour, so retuning a
# module needs no rebuild. Only adding or removing a module name does.
#
# Legal names are [A-Za-z0-9_]+. Anything else is skipped rather than half-built.
set -eu
DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
. "$DIR/palette.sh"

# Role is "pill_body", not "module_body": @tnb_module_body_color would collide
# with the @tnb_module_<name>_color pattern for a module actually named "body".
body="$(tnb_color pill_body black surface_0)"

names="$(tmux show-options -g 2>/dev/null \
  | sed -n 's/^@tnb_module_\([A-Za-z0-9_]*\)_text .*$/\1/p' \
  | sort -u)"

# Drop generated options whose module no longer exists, so the rebuild binding
# does not leave stale pills behind.
existing="$(tmux show-options -g 2>/dev/null \
  | sed -n 's/^@tnb_status_\([A-Za-z0-9_]*\) .*$/\1/p' \
  | sort -u)"
for old in $existing; do
  found=no
  for n in $names; do
    if [ "$n" = "$old" ]; then found=yes; break; fi
  done
  if [ "$found" = no ]; then
    tmux set-option -gu "@tnb_status_$old" 2>/dev/null || true
  fi
done

for name in $names; do
  color="$(tnb_mod_color "$name")"
  value="$(tnb_cap_left "$color")"
  # No leading space before the icon: the badge would otherwise be a column wider
  # than the bar this replaces. Matches build-window.sh's number badge.
  # #{E:...} for the icon, matching _color and _text: an icon may itself be a
  # format, and plain substitution would print it literally.
  value="$value#[none]#[fg=$color,bg=default,reverse]#{E:@tnb_module_${name}_icon} "
  value="$value#[none]#[fg=default,bg=$body] #{E:@tnb_module_${name}_text} "
  value="$value$(tnb_cap_right "$body")"
  tmux set-option -g "@tnb_status_$name" "$value"
done
