# symbols.vim

Jump to a matched strings via regular expressions with customizable expressions per filetype. Includes a CtrlP extension for fast filtering.

### Use

![](http://i.imgbox.com/OoLpMwO5.gif)

Use `:Symbol {fuzzy string}` to find any matched symbols in the current buffer and navigate to them.

Built-in filetypes:

* HTML, ERB, Mustache, Handlebars
* SCSS (with support for nested contexts)
* JavaScript, CoffeeScript
* Vim

See the <a href="#adding-definitions">Adding Definitions</a> section for information on adding additional definitions and filetypes.

### CtrlP

An extension for [CtrlP](https://github.com/kien/ctrlp.vim) is included for quick filtering to the list of gathered symbols in the current buffer.

In your `.vimrc`, add the following:

```vim
let g:ctrlp_extensions = ['symbol']
```

The `:CtrlPSymbol` command will be available in any filetype included in `g:symbol_patterns`.

### Adding Definitions

Given a filetype and a regular expression, the `:Symbol` command can jump to any line that matches that regular expression. To add a single expression for one filetype, here's an example of a line from your `.vimrc`:

```vim
let g:symbol_patterns['javascript'] = '\.prototype.\zs\w\+\ze\ = function'
```

This will match any text in a `javascript` filetype that comes after `.prototype.` but must also followed by a space, an `=`, another space, and `function`. For instance, this will match: `Thing.prototype.test = function` with `test`.

To add multiple definitions (and multiple definitions for a single filetype):

```vim
let g:symbol_patterns = {
  \ 'javascript': [
    \ 'var \zs\w\+\>\ze ='
  \ ],
  \ 'html': [
    \ 'id="\zs.\+\ze"',
    \ 'class="\zs.\+\ze"'
  \ ]
\ }
```

### Function definitions

Function defintions are also available, where the first argument will be the line and the second argument will be the line number.

Return a string to set a symbol for the line, or return `0` to ignore matching a symbol on that line.

```vim
function! CountIndent(linestr, line)
  let indent = indent(a:line)
  if indent <= 2
    return matchstr(a:linestr, '\w\+\ze\s')
  else 
    return 0
  endif
endfunction

let g:symbol_patterns['scss'] = function('CountIndent')
```

### Feedback

Let me know what you think, I'm @mattsacks on [Twitter](https://twitter.com/mattsacks) and [GitHub](https://github.com/mattsacks).
