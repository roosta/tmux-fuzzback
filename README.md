# tmux-fuzzback

tmux-fuzzback uses [fzf](https://github.com/junegunn/fzf) to search terminal
scrollback buffer, and jump to selected position.

<!-- ![](preview.gif) -->

## Attribution

This plugin would not be possible without the work done in
[copycat](https://github.com/tmux-plugins/tmux-copycat). Go download it, use
it, and give it some love. I also drew more than a little inspiration from
[tmux-fzf-url](https://github.com/wfxr/tmux-fzf-url). Huge thanks to both.

## Requirements

[tmux](https://github.com/tmux/tmux), and [fzf](https://github.com/junegunn/fzf) is required.

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

The default key-binding is `?` preceded by a prefix, it can be modified by
setting value to `@fzf-search-bind` in the tmux config like this:

``` tmux
set -g @fuzzback-bind 's'
```

## Troubleshooting

### Column movement

Moving to column is not working optimally. Fzf doesn't have a way to output the
pattern highlighted text, so instead I use `query` to try and search for column
to jump to using `awk`. This is less than ideal but it is what it is for the
moment. When fuzzback fails to get a column number it simply puts you at the
start of the line.

An example of this would be to search to items that ends with  `world$`,
fuzzback will try to find the entire query and will fail.

## License

[MIT](https://github.com/roosta/tmux-fuzzback/blob/master/LICENSE)
