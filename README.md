# tmux-fzf-search

tmux-fzf-search uses [fzf](https://github.com/junegunn/fzf) to search terminal scrollback buffer, and jump to selected position.

<!-- ![](preview.gif) -->

## Attribution
This plugin would not be possible without the work done in
[copycat](https://github.com/tmux-plugins/tmux-copycat). Go download
it, use it, and give it some love. I also drew more than a little
inspiration from
[tmux-fzf-url](https://github.com/wfxr/tmux-fzf-url). Huge thanks to
both.

## Requirements
[fzf](https://github.com/junegunn/fzf) is required, and optionally
either [ripgrep](https://github.com/BurntSushi/ripgrep), or
[ag](https://github.com/ggreer/the_silver_searcher) is required to
jump to search query column. If none of these are found
tmux-fzf-search will jump to line number but not column.

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

## License

[MIT](https://wfxr.mit-license.org/2018) (c) Daniel Berg
