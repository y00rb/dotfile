#!/usr/bin/env bash
DIR="$(cd "$(dirname "$0")" && pwd)"
. "$DIR/assert.sh"
tnb_boot "$DIR/fixtures/empty.conf"

build() { tnb_run bash "$DIR/../scripts/build-modules.sh"; }
S() { tmux -L "$TNB_SOCKET" set-option -g "$@"; }

S @tnb_module_git_icon  "B"
S @tnb_module_git_color yellow
S @tnb_module_git_text  " main"
build

assert_contains    @tnb_status_git $'\xee\x82\xb6'
assert_contains    @tnb_status_git $'\xee\x82\xb4'
assert_contains    @tnb_status_git "@tnb_module_git_text"
assert_not_matches @tnb_status_git '#[0-9a-fA-F]{6}'

# Review Focus 2: _color unset must default, never emit an empty colour.
S @tnb_module_bare_text " x"
build
assert_contains     @tnb_status_bare "white"
assert_not_contains @tnb_status_bare "fg=,"
assert_not_contains @tnb_status_bare "fg=]"

# Review Focus 5: an illegal module name is skipped, not half-built. The paired
# assertion on a LEGAL module proves the builder actually ran and did not simply
# abort on the illegal name -- without it, "my-git is empty" passes when nothing
# runs at all.
S "@tnb_module_my-git_text" " y"
build
assert_contains @tnb_status_git "@tnb_module_git_text"
assert_equals   @tnb_status_my-git ""

# Review Focus 4: removing a module drops its generated option. Seeded with a
# sentinel first, so this fails when the cleanup loop is missing rather than
# passing against an option that was never set.
S @tnb_status_git "SENTINEL"
tmux -L "$TNB_SOCKET" set-option -gu @tnb_module_git_text
build
assert_equals @tnb_status_git ""

tnb_shutdown
exit $TNB_FAILS
