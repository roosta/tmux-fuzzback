#!/usr/bin/env bash

# Install needed packages
sudo apt-get update
sudo apt-get install -y git-core expect vim
sudo apt-get install -y python-software-properties software-properties-common
sudo apt-get install -y build-essential libtool autotools-dev autoconf
sudo apt-get install -y pkg-config bison
sudo apt-get install -y wget tar libevent-dev libncurses-dev

git clone https://github.com/tmux/tmux.git ~/tmux_source
cd ~/tmux_source || exit
sh autogen.sh
./configure && make && sudo make install
