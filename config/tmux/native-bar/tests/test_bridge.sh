#!/usr/bin/env bash
# The catppuccin bridge is the ONE place the no-hex rule is deliberately waived:
# mauve and surface_0 have no ANSI slot (spec 4.2/5). Success criterion 3 reads
# absolutely, so this test states where the boundary actually is rather than
# leaving it an undocumented gap.
DIR="$(cd "$(dirname "$0")" && pwd)"
. "$DIR/assert.sh"
tnb_boot "$DIR/fixtures/catppuccin.conf"

tnb_run bash "$DIR/../scripts/build-window.sh"
tnb_run bash "$DIR/../scripts/build-modules.sh"

# In bridge mode the off-palette colours DO appear as hex. That is the contract.
assert_contains window-status-current-format "#ca9ee6"   # mauve, no ANSI slot
assert_contains window-status-current-format "#51576d"   # surface_1

# Structure stays terminal-native even under the bridge: the bar background and
# the badge text must never be pinned to a flavour.
assert_contains window-status-format "bg=default"
assert_contains window-status-format "reverse"

# Only PUBLIC @thm_* is read. No catppuccin internal may appear anywhere.
assert_not_contains window-status-format         "@_ctp"
assert_not_contains window-status-current-format "@_ctp"
assert_not_contains window-status-format         "@catppuccin"

# A role whose @thm_* is unset falls back to its ANSI name, not to empty --
# an empty colour would emit "fg=" and tmux would drop the entire format.
assert_contains window-status-format "fg=white"
assert_not_contains window-status-format "fg=,"

tnb_shutdown
exit $TNB_FAILS
