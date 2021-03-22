## surround.nvim

> Warning this is a beta and my first plugin. I won't be responsible for broken codes because the parser failed or something. You are encouraged to test this and report bugs and
feature requests.

## Features
### Key mappings
### There are two keymap modes for normal mode mappings.

- sandwich and surround and they can be set using the options mentioned below.


#### Normal Mode - Sandwich Mode
1. Provides key mapping to add surrounding characters.( visually select then press `s<char>` )
2. Provides key mapping to replace surrounding characters.( `sr<from><to>` )
3. Provides key mapping to delete surrounding characters.( `sd<char>` )
4. `ss` repeats last surround command.

#### Normal Mode - Surround Mode
1. Provides key mapping to add surrounding characters.( visually select then press `s<char>` )
2. Provides key mapping to replace surrounding characters.( `cs<from><to>` )
3. Provides key mapping to delete surrounding characters.( `ds<char>` )

#### Insert Mode

- `<c-s><char>` will insert both pairs in insert mode.
- `<c-s><char><space>` will insert both pairs in insert mode with surrounding whitespace.
- `<c-s><char><c-s>` will insert both pairs on newlines insert mode.

### IDK I was bored

1. Cycle surrounding quotes type. (`stq`)
1. Cycle surrounding brackets type. (`stb`)
1. Use `<char> == f` for adding, replacing, deleting functions.

## Installation

1. vim-plug: `Plug 'blackcauldron7/surround.nvim'`
1. minPlug:  `MinPlug blackcauldron7/surround.nvim`

- Put this somewhere in your init.vim: `lua require"surround".setup{}`

## Configuration

### Format: for **vimscript** `let g:surround_<option>` and for **lua** `vim.g.surround_<option>`

- pairs: dictionary or lua table of form `{ nestable: {{},...}, linear: {{},....} }` where linear is an array of arrays which contain non nestable pairs of surrounding characters first opening and second closing like ", ' and nestable is an array of arrays which contain nestable pairs of surrounding characters like (, {, [. `(default: { nestable = { {"(", ")"}, {"[", "]"}, {"{", "}"} }, linear = { {"'", "'"}, {'"', '"'} } })`
- context\_offset: number of lines to look for above and below the current line while searching for nestable pairs. `(default: 100)`
- load_\_autogroups: whether to load inbuilt autogroups or not. `(default: false)`
- mappings\_style: "surround" or "sandwich" `(default: sandwich)`
- load_\_keymaps: whether to load inbuilt keymaps or not. `(default: true)`
- quotes: an array of items to be considered as quotes while cycling through them. `(default: ["'", '"']`
- brackets: an array of items to be considered as brackets while cycling through them. `(default: ["(", "{", "["]`

## Caveats

1. Only supports neovim and always will because it's written in lua which is neovim exclusive.
1. Doesn't support python docstrings and html tags yet.
1. No vim docs(idk how to make them. Need help)
2. Beta plugin not tested too much.(Help would be appreciated by testing and reporting bugs)
1. No `.` repeat support(idk how to achieve this help would be appreciated.) (although there is a mapping `ss` only available in sandwich mode which repeats last surround command.)

## Note:

In a recent commit, the lua files were moved to the `lua/surround` directory, so
be careful.

This is because the helper files (`lua/parser.lua` and `lua/utils.lua`) would
clash with files the user might have in their configuration directory.


## Contributing
You are more than welcome to submit PR for a feature you would like to see or bug fixes.

