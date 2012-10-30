# symbols.vim

A buffer-local symbol-list that has fuzzy-completion.

Not totally a finished plugin yet.

#### What

Adds the `:Symbol` command that takes a single argument, whatever symbol you're
looking to jump to. Currently it only works with javascript and coffeescript,
but hopefully it will be extensible to any language in the future.

#### How

It wouldn't be Vim if you didn't have to have the right default settings first.
If you haven't already, make sure you have the `wildmenu` option set (just
type `:set wildmenu`). Then, use bash-style completion with `:set
wildmode=list:longest,full`.

Now we can begin.

After opening up any javascript or coffeescript buffer, type `:Symbol`,
`<Space>`, and then hit the Tab key. You should see a list showing all the
different symbols available to jump to. Symbols are typically defined at the
2nd indentation level and are object properties. An example:

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

#### License
The MIT License
