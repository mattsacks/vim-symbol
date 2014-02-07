# symbols.vim

Jump to a matched regular expression. <something something about filetypes?>

#### Use

<gif>

Use `:Symbol {fuzzy string}` to find any matched symbols in the current buffer and navigate to them.

Built-in filetypes:
* HTML, ERB, Mustache, Handlebars
* SCSS (with support for nested contexts)
* JavaScript, CoffeeScript
* Vim

The plugin supports defining your own regular expressions as well.

#### CtrlP

An extension for [CtrlP](https://github.com/kien/ctrlp.vim) is included for quick filtering to the list of gathered symbols in the current buffer.

In your `.vimrc`, add the following:

```vim
let g:ctrlp_extensions = ['symbol']
```

The `:CtrlPSymbol` command will be available in any filetype included in `g:symbol_patterns`.

#### Adding Definitions

Given a filetype and a regular expression, the `:Symbol` command can jump to any line that matches that regular expression.

```vim
let g:symbol_patterns['javascript'] = '\.prototype.\zs\w\+ze\ = function'
```

<add walkthrough>
