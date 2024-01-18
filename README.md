# tmux-fuzzback

[![Build Status](https://app.travis-ci.com/roosta/tmux-fuzzback.svg?branch=main)](https://app.travis-ci.com/github/roosta/tmux-fuzzback)
[![GitHub](https://img.shields.io/badge/License-MIT-%232C78BF)](https://github.com/roosta/tmux-fuzzback/blob/master/LICENSE)

tmux-fuzzback uses a fuzzy finder to search terminal scrollback buffer, and
jump to selected position.

![preview](https://raw.githubusercontent.com/roosta/assets/master/tmux-fuzzback/preview.gif)

## Attribution

This plugin would not be possible without the work done in
[copycat](https://github.com/tmux-plugins/tmux-copycat). Go download it, use
it, and give it some love. I also drew more than a little inspiration from
[tmux-fzf-url](https://github.com/wfxr/tmux-fzf-url). Huge thanks to both.

## Requirements

- [tmux](https://github.com/tmux/tmux) version >= [2.4](https://github.com/tmux/tmux/releases/tag/2.4)
- A fuzzy finder
  - [fzf](https://github.com/junegunn/fzf)
  - [skim](https://github.com/lotabout/skim) - Requires extra [configuration](#fuzzy-finder)

## Installation

### Using [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)

```
set -g @plugin 'roosta/tmux-fuzzback'
```

### Manually
```shell
git clone https://github.com/roosta/tmux-fuzzback.git
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
### Fuzzy finder

Fuzzback uses `fzf` as default, but you can set it to `sk` if you'd rather use [skim](https://github.com/lotabout/skim)

```tmux
set -g @fuzzback-finder 'sk'
```

Fuzzback was built using fzf, and only later did I add support for skim. These
two finders seem mostly comparable, although I might have missed something.
Please open an issue if you find any problems with this or other.

Additionally the popup window doesn't seem to work in sk-tmux, I'm unable to
open it on `tmux next-3.4` and `sk 0.10.2`, so it isn't currently configured to
work.

### Key binding

The default key-binding is `?` preceded by a prefix, it can be modified by
setting value to `@fuzzback-bind` in the tmux config like this:

```tmux
set -g @fuzzback-bind s
```

Make sure this setting is set before loading the plugin.

### Enable popup

You can enable tmux popup by setting this variable in your tmux conf.  Keep in
mind that only recent versions `3.2` and above of tmux support this.

```tmux
set -g @fuzzback-popup 1
```

***Only works with fzf for the time being***

### Hide preview

Preview is shown by default, but you can hide it initially by setting
`fuzzback-hide-preview` to `1`.

```tmux
set -g @fuzzback-hide-preview 1
```

You can still toggle it back with your preferred keybinding (fzf default <kbd>ctrl+p</kbd>)

### Popup size

You can set the popup size with this option.

```tmux
set -g @fuzzback-popup-size '90%'
```

### Finder layout

You can reverse the direction of selected finder by setting this variable. The
default is `default`

```tmux
set -g @fuzzback-finder-layout 'reverse'
```

### Finder bind

If you want to bind some keybinding using sk/fzf --bind that's only used in
fuzzback set this variable.

```tmux
set -g @fuzzback-finder-bind 'ctrl-y:execute-silent(echo -n {3..} | xsel -ib)+abort'
```

This will copy the line matches in selected finder to the clipboard if `xsel` is available.


Refer documentation for more:
- [fzf documentation](https://github.com/junegunn/fzf#executing-external-programs)
- [skim documentation](https://github.com/lotabout/skim#keymap)

#### Toggling sort

If you need to toggle sort on and off you could add this to your fuzzback config

- ref: https://github.com/roosta/tmux-fuzzback/issues/23

```tmux
set -g @fuzzback-finder-bind 'ctrl-s:toggle-sort'
```

### FZF colors

You can add colors to fuzzback as you do with `fzf`. 

```tmux
set -g @fuzzback-fzf-colors 'bg+:#100E23,gutter:#323F4E,pointer:#F48FB1,info:#ffe6b3,hl:#F48FB1,hl+:#63f2f1'
```

All highlight options can be found in fzf's [man page](https://www.mankier.com/1/fzf#--color).

### Keybind table

Normally the fuzzback keybind will go into the `prefix` table, but if you want
to activate fuzzback without typing the prefix, you can change the table here.
Say you wanted to activate fuzzback without prefix:

```tmux
# this is the same as bind-key -n
set -g @fuzzback-table 'root'
```
Make sure this option, same as keybind, is set before loading the plugin.

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
