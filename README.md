# tmux-fuzzback

[![Build Status](https://travis-ci.com/roosta/tmux-fuzzback.svg?branch=main)](https://travis-ci.com/roosta/tmux-fuzzback)
[![GitHub](https://img.shields.io/badge/License-MIT-%232C78BF)](https://github.com/roosta/tmux-fuzzback/blob/master/LICENSE)

tmux-fuzzback uses [fzf](https://github.com/junegunn/fzf) to search terminal
scrollback buffer, and jump to selected position.

![preview](https://raw.githubusercontent.com/roosta/assets/master/tmux-fuzzback/preview.gif)

## Attribution

This plugin would not be possible without the work done in
[copycat](https://github.com/tmux-plugins/tmux-copycat). Go download it, use
it, and give it some love. I also drew more than a little inspiration from
[tmux-fzf-url](https://github.com/wfxr/tmux-fzf-url). Huge thanks to both.

## Requirements

- [tmux](https://github.com/tmux/tmux) version >= [2.4](https://github.com/tmux/tmux/releases/tag/2.4)
- [fzf](https://github.com/junegunn/fzf)

## Installation

### Using [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)

```
set -g @plugin 'roosta/tmux-fuzzback'
```

### Manually
```shell
git clone https://github.com/roosta/tmux-fuzzback
```

Add this to the bottom of `.tmux.conf`
```
run-shell ~/path/to/repo/fuzzback.tmux
```

Reload TMUX env
```shell
tmux source-file ~/.tmux.conf
```

## Usage

To use tmux-fuzzback, start it in a tmux session by typing <kbd>prefix</kbd> +
<kbd>?</kbd>. Now you can start fuzzy searching in your scrollback buffer using
fzf.

## Options

### Key binding

The default key-binding is `?` preceded by a prefix, it can be modified by
setting value to `@fuzzback-bind` in the tmux config like this:

```tmux
set -g @fuzzback-bind 's'
```

### Enable popup

You can enable tmux popup by setting this variable in your tmux conf.  Keep in
mind that only recent versions `3.2` and above of tmux support this.

```tmux
set -g @fuzzback-popup 1
```

### Popup size

You can set the popup size with this option.

```tmux
set -g @fuzzback-popup-size "90%"
```

## Limitations

### Column movement

Depending on the complexity of the search query, fuzzback might not know what
column to move to, and will place you at the start of the line unless a literal
match can be found.

## Developing

You can run tests locally using [Vagrant](https://www.vagrantup.com/) by calling:

```sh
# cd project root
./run_tests
```

## License

[MIT](https://github.com/roosta/tmux-fuzzback/blob/master/LICENSE)
