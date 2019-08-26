# tmux-fzf-search

tmux-fzf-search uses ripgrep to search terminal scrollback buffer

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

## Tips
