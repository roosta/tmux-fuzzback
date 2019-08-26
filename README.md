# tmux-fzf-search

tmux-fzf-search uses [fzf](https://github.com/junegunn/fzf) to search terminal scrollback buffer, and jump to selected position.

<!-- ![](preview.gif) -->

## Installation

### Using [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)

```
set -g @plugin 'roosta/tmux-fzf-search
```

### Manually
```shell
git clone https://github.com/roosta/tmux-fzf-search
```

Add this to the bottom of `.tmux.conf`
```
run-shell ~/path/to/repo/fzf_search.tmux
```

Reload TMUX env
```shell
tmux source-file ~/.tmux.conf
```

## Usage

The default key-binding is `?` preceded by a prefix, it can be modified by
setting value to `@fzf-search-bind` in the tmux config like this:

``` tmux
set -g @fzf-fzf-bind 's'
```

## Options

## Attribution
A huge thanks to
[copycat](https://github.com/tmux-plugins/tmux-copycat) and
[tmux-fzf-url](https://github.com/wfxr/tmux-fzf-url). I could not have
written this without pointers and borrowing code from these two
plugins.

## License

[MIT](https://wfxr.mit-license.org/2018) (c) Daniel Berg
