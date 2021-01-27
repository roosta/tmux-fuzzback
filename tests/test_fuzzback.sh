#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH=$PATH:~/.fzf/bin

# bash helpers provided by 'tmux-test'
# shellcheck source=helpers/helpers.sh
. "$CURRENT_DIR/helpers/helpers.sh"

# installs plugin from current repo in Vagrant (or on Travis)
install_tmux_plugin_under_test_helper

TERM="tmux-256color"

# Do tests with expect
"$CURRENT_DIR/expect_fuzzback.exp" || fail_helper "Testing failed!"

# sets the right script exit code ('tmux-test' helper)
exit_helper
