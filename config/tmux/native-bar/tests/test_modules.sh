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

# The icon badge must not carry a leading space: that makes every module pill a
# column wider than the bar this replaces, which reads as a sizing glitch. The
# window builder has the same rule.
assert_contains     @tnb_status_git "reverse]#{@tnb_module_git_icon}"
assert_not_contains @tnb_status_git "reverse] #{@tnb_module_git_icon}"

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

# A module colour that is ITSELF a tmux format -- the session module's prefix
# conditional is exactly this -- must resolve to a real colour once the status
# line is expanded. #{@opt} substitutes the value without re-expanding it, which
# leaves "fg=#{?client_prefix,red,green}" inside a style spec: not a colour tmux
# can parse, so the style is dropped and the pill loses its colour.
S @tnb_module_dyn_color "#{?client_prefix,red,green}"
S @tnb_module_dyn_text  " z"
build
exp="$(tmux -L "$TNB_SOCKET" display -p '#{E:@tnb_status_dyn}' 2>/dev/null)"
case "$exp" in
  *"fg=green"*) printf 'ok: format-valued module colour resolves to a real colour\n' ;;
  *) printf 'FAIL: unresolved colour format -- [%s]\n' "$exp" >&2
     TNB_FAILS=$((TNB_FAILS + 1)) ;;
esac

tnb_shutdown
exit $TNB_FAILS
