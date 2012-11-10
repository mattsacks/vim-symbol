# symbols.vim

A buffer-local symbol-list that has fuzzy-completion.

#### What

Adds the `:Symbol` command that takes a single argument, whatever symbol you're
looking to jump to. Can be used in any filetype and match any expression.

#### Use

It wouldn't be Vim if you didn't have to have the right default settings first.
If you haven't already, make sure you have the `wildmenu` option set (just
type `:set wildmenu`). Then, use bash-style completion with `:set
wildmode=list:longest,full`.

Now we can begin.

After opening up any buffer defined in the `g:symbol_patterns`, type `:Symbol`,
`<Space>`, and then hit the Tab key. You should see a list showing all the
different symbols available to jump to. An example:

```javascript
var thing = new Class({
  initialize: function(options) {
    /* ... */
  },
  attach: function() {
    /* ... */
  },
  render: function() {
    /* ... */
  }
});
```

Would have `initialize`, `attach`, and `render` available in the symbol list.
These can be completed by typing any letters that match their string in order.
So `intl` would work for completing `initialize` (and yes, so would just `it` or
even `i`). You can tab-complete the choice or just hit enter to pick the first
result.

#### How

The interface is the `g:symbol_patterns` dictionary. Vim dictionaries are like
hashes in any other language, you give it any any and assign it some value.

The `g:symbol_patterns` dictionary can have any filetype as the key and iterates
through a list of expressions as it's value. Here's what it looks like:

```vim
" somewhere in your .vimrc
let g:symbol_patterns = { 'javascript': ['^\s\{0,3}\zs\w\+\ze:'] }
```

So this is a hash with a key 'javascript' that has an array (list) of things to
match on each line in a javascript file. The pattern might seem complex so I'll
break it down:

| Atom       | Whats goin on                                                              |
| ---------- | -------------------------------------------------------------------------- |
| `^`        | From the start of the line                                                 |
| `\s\{0,3}` | Between 0 and 3 spaces                                                     |
| `\zs`      | Start matching what we want to define as a **symbol**                      |
| `\w\+`     | At least 1 or more word characters                                         |
| `\ze`      | Stop matching what we want to match as the symbol for this line            |
| `:`        | And make sure there's a trailing `:` on the line after the word characters |

In a sense, we've defined a pattern that not only captures a symbol but also
specifies the syntax of the line to match.

There are a couple of default definitions provided to you. I don't really know
if they're even useful or not but I find them convenient. Default definitions
are for `vim`,`javascript`,`coffee`, and `sass` + `scss` filetypes.

#### License
The MIT License
