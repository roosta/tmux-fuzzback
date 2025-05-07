#!/usr/bin/env bash

TEST_STATUS="success"

fail_helper() {
	local message="$1"
	echo "$message" >&2
	TEST_STATUS="fail"
}

TERM="tmux-256color"

# Do tests with expect
tests/expect_fuzzback.exp || fail_helper "Testing failed!"

if [ "$TEST_STATUS" == "fail" ]; then
  echo "FAIL!"
  echo
  exit 1
else
  echo "SUCCESS"
  echo
  exit 0
fi
