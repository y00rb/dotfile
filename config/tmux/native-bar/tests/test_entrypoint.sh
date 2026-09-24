#!/usr/bin/env bash
DIR="$(cd "$(dirname "$0")" && pwd)"
. "$DIR/assert.sh"
tnb_boot "$DIR/fixtures/empty.conf"

run_entry() { tnb_run bash "$DIR/../native-bar.tmux"; }

# Seed sentinels so every assertion below can fail in RED rather than passing
# against a tmux default or an unset option.
tmux -L "$TNB_SOCKET" set-option -g status-style "SENTINEL"

run_entry
assert_equals   status-style "bg=default,fg=default"
assert_contains @tnb_status_session   "@tnb_module_session_text"
assert_contains @tnb_status_directory "@tnb_module_directory_text"

# Spec 13: the plugin must not own layout. status-justify keeps tmux's default.
assert_equals status-justify "left"

# Review Focus 4: idempotent. A second run must not change anything.
# Anchored first: comparing two runs is vacuous when both did nothing, so assert
# the builder actually produced a cap before capturing the baseline.
assert_contains window-status-format $'\xee\x82\xb6'
before_w="$(tnb_get window-status-format)"
before_s="$(tnb_get @tnb_status_session)"
run_entry
assert_equals window-status-format "$before_w"
assert_equals @tnb_status_session  "$before_s"

# A user's own module value must survive re-seeding. The paired assertion proves
# the entrypoint ran; otherwise "cyan is still cyan" holds trivially.
tmux -L "$TNB_SOCKET" set-option -g @tnb_module_session_color cyan
run_entry
assert_equals   @tnb_module_session_color "cyan"
assert_contains @tnb_status_session "@tnb_module_session_text"

# A user must be able to say "no icon" / "no flags" by setting the option EMPTY.
# seed() testing with -gqv + [ -z ] cannot tell set-to-empty from unset, so it
# writes its default back over the user's deliberate choice -- on first load and
# again on every prefix+M. This is the one contract the entrypoint promises.
tmux -L "$TNB_SOCKET" set-option -g @tnb_module_session_icon ""
tmux -L "$TNB_SOCKET" set-option -g @tnb_window_flags ""
run_entry
assert_equals @tnb_module_session_icon ""
assert_equals @tnb_window_flags ""

# Spec 13: the plugin owns none of these. Captured before and compared after,
# rather than asserted against literals -- the point is that the entrypoint does
# not touch them, whatever their value happens to be.
sl_before="$(tnb_get status-left)"
sr_before="$(tnb_get status-right)"
sp_before="$(tnb_get status-position)"
sj_before="$(tnb_get status-justify)"
run_entry
assert_equals status-left     "$sl_before"
assert_equals status-right    "$sr_before"
assert_equals status-position "$sp_before"
assert_equals status-justify  "$sj_before"

tnb_shutdown
exit $TNB_FAILS
