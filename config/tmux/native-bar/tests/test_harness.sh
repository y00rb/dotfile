#!/usr/bin/env bash
# Proves the harness reports failures rather than silently passing.
DIR="$(cd "$(dirname "$0")" && pwd)"
. "$DIR/assert.sh"

tnb_boot "$DIR/fixtures/empty.conf"

tmux -L "$TNB_SOCKET" set-option -g @tnb_probe "hello"
assert_equals       @tnb_probe "hello"
assert_contains     @tnb_probe "ell"
assert_not_contains @tnb_probe "zzz"
assert_not_matches  @tnb_probe "[0-9]"

# A deliberately wrong assertion must increment TNB_FAILS.
before=$TNB_FAILS
assert_equals @tnb_probe "wrong" 2>/dev/null
if [ "$TNB_FAILS" -eq $((before + 1)) ]; then
  TNB_FAILS=$before
  printf 'ok: harness detects failures\n'
else
  printf 'FAIL: harness did not detect a wrong assertion\n' >&2
  TNB_FAILS=$((before + 1))
fi

tnb_shutdown
exit $TNB_FAILS
