#!/usr/bin/env bash
# Runs every test_*.sh and reports a total.
DIR="$(cd "$(dirname "$0")" && pwd)"
total=0
for t in "$DIR"/test_*.sh; do
  [ -e "$t" ] || continue
  printf '\n=== %s ===\n' "$(basename "$t")"
  bash "$t"
  total=$((total + $?))
done
printf '\n=== %d failure(s) ===\n' "$total"
exit $total
