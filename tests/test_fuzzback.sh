#!/usr/bin/env bash

TEST_STATUS="success"

fail_helper() {
	local message="$1"
	echo "$message" >&2
	TEST_STATUS="fail"
}

# Do tests with expect
/app/tests/expect_fuzzback.exp || fail_helper "Testing failed!"

if [ "$TEST_STATUS" == "fail" ]; then
  echo "FAIL!"
  echo
  exit 1
else
  echo "SUCCESS"
  echo
  exit 0
fi
