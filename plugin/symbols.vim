" Symbols.vim - Buffer-local symbol list
" Version: 0.2
" Author: Matt Sacks <matt.s.sacks@gmail.com>

if exists('g:loaded_symbols') || v:version < 700
  finish
endif
let g:loaded_symbols = 1

" utilities {{{
function! s:gsub(str,pat,rep) abort
  return substitute(a:str,'\v\C'.a:pat,a:rep,'g')
endfunction

function! s:sortAlpha(thing, thang)
  return a:thing == a:thang ? 0 : a:thing > a:thang ? 1 : -1 
endfunction

function! s:sortShort(thing, thang)
  let thingLen = len(a:thing)
  let thangLen = len(a:thang)
  return thingLen == thangLen ? 0 :
       \ thingLen > thangLen ? 1 : -1 
endfunction

" sorts a dictionary based on the lower value of a key
function! s:sortLowest(thing, thang) dict
    return self[a:thing] - self[a:thang]
endfunction

function! s:fuzzysub(str)
  return s:gsub(s:gsub(a:str, '\w', '[&].*'), '^', '.*')
endfunction
" END utilities }}}

" current filetypes supported in the pattern dictionary
function! s:checkFiletype()
  return exists('g:symbol_patterns[&ft]')
endfunction

" gather symbols on bufread
function! s:GatherSymbols()
  " whether it's even supported
  if !s:checkFiletype()
    return ''
  endif

  " clear existing symbols
  if exists('b:symbols_gathered')
    unlet b:symbols_gathered
  endif

  let b:symbols_gathered = {}

  let patterns = g:symbol_patterns[&ft]

  if exists('g:pre_symbol_gather[&ft]')
    call g:pre_symbol_gather[&ft]()
  endif

  " match all symbols
  for line in range(0, line('$'))
    let linestr = getline(line)

    " first pattern that matches wins
    for index in range(0, len(patterns)-1)
      let type = type(patterns[index])
      if type == 1
        let match = matchstr(linestr, patterns[index])
        " the symbol that matches the Pattern is the key and the value is the
        " line number
        if !empty(match)
          let b:symbols_gathered[match] = line
          break
        endif
      elseif type == 2
        let match = patterns[index](linestr, line)
        if match !~ 0
          let b:symbols_gathered[match] = line
          break
        endif
      endif
    endfor
  endfor
endfunction

" has to return a list of completion candidates on <TAB>
function! s:SymbolGlob(arg,cmdline,cursorpos)
  if !s:checkFiletype()
    return ''
  endif

  " the symbols
  let symbols = keys(b:symbols_gathered)

  " if the user just hit tab with no symbol to search for
  if empty(a:arg)
    " sort the symbols by line number
    return sort(symbols, "s:sortLowest", b:symbols_gathered)
  endif

  " a fuzzy expression of the search
  let fuzzyArg = s:fuzzysub(a:arg)

  " filter the symbols based on the arg
  let symbols = filter(symbols, 'v:val =~ fuzzyArg')
  " return a sorted list with shortest symbol first
  return sort(copy(symbols), "s:sortShort")
endfunction

" gets passed the argument when executed
function! s:Symbol(symbol, ...)
  " nothing was passed
  if empty(a:symbol)
    return ''
  endif

  let symbols = s:SymbolGlob(a:symbol, '', '')

  " if no symbols found
  if empty(symbols)
    return ''
  endif

  " get the first one's line number
  call cursor(b:symbols_gathered[symbols[0]], 1)
  return ''
endfunction

" create a buffer listing all symbols for easy navigation
function! s:CreateSymbolWindow()
  " if the window already exists, just go to it
  " FIXME
  if exists("t:SymbolWindowOpen") && t:SymbolWindowOpen == 1
    exe t:SymbolWindowOpen . "wincmd w"
    return
  endif

  " create the window and store the win nr
  let t:SymbolWindowSource = {
        \ 'filename': bufname('%'),
        \ 'symbols': b:symbols_gathered
      \ }

  " create the SymbolList window
  vnew
  " get the winnr of the window this was called from
  let t:SymbolWindowSource.winnr = winnr('#')
  " set it's status line
  setl statusline=SymbolList:\ %{t:SymbolWindowSource['filename']}
  " get the location of the Symbol Window
  let t:SymbolWindowOpen = winnr()

  " cleanup when the buffer is hidden
  autocmd BufWinLeave <buffer>
        \ let t:SymbolWindowOpen = 0 |
        \ unlet t:SymbolWindowSource

  " when hitting enter, navigate to that symbol in the open buffer
  nnoremap <buffer> <CR> :call <SID>NavigateFromSymbolWindow()<CR>

  " for each symbol found in the buffer, spit out it's result on a new line
  let symbols = keys(t:SymbolWindowSource['symbols'])
  for symbol in symbols
    call setline(index(symbols, symbol), symbol)
  endfor
endfunction

function! s:NavigateFromSymbolWindow()
  " get the symbol from the current line
  let symbol = getline('.')
  " index it's line number
  let linenr = t:SymbolWindowSource['symbols'][symbol]
  " navigate back to the source
  exec t:SymbolWindowSource['winnr'] . 'wincmd w'
  " and go to the symbol
  call cursor(linenr, 1)
endfunction

" Symbol command
command! -nargs=? -complete=customlist,s:SymbolGlob Symbol
      \ execute s:Symbol(<f-args>)

" SymbolList command
command! -nargs=0 SymbolList call s:CreateSymbolWindow()

" autoload that shit
augroup SymbolList
  autocmd!
  autocmd BufReadPost * call s:GatherSymbols()
  autocmd InsertLeave * call s:GatherSymbols()
augroup END

" check to see if a filetype has a 
function! s:addToExisting(ft, pattern)
  if !exists('g:symbol_patterns')
    let g:symbol_patterns = {}
    let g:symbol_patterns[a:ft] = [a:pattern]
    return ''
  endif

  if exists('g:symbol_patterns[a:ft]')
    call add(g:symbol_patterns[a:ft], a:pattern)
  else
    let g:symbol_patterns[a:ft] = [a:pattern]
  endif
endfunction

" match ids and classes in an HTML-like file
let s:htmlIdPattern = "id=\"\\zs.\\{-}\\ze\""
let s:htmlClassPattern = "class=\"\\zs.\\{-}\\ze\""
call s:addToExisting('html', s:htmlIdPattern)
call s:addToExisting('html', s:htmlClassPattern)
call s:addToExisting('erb', s:htmlIdPattern)
call s:addToExisting('erb', s:htmlClassPattern)
call s:addToExisting('mustache', s:htmlIdPattern)
call s:addToExisting('mustache', s:htmlClassPattern)

" match a symbol in a vim file is the name of any top-level function
call s:addToExisting('vim', "^fun\\%(ction\\)\\=!\\=\\s\\zs.\\{-}\\ze(.\\{-})")
" match a symbol in js/coffee is any object key of indent levels 1-4
call s:addToExisting('javascript', "^\\s\\{1,6}'\\=\\zs\\w\\+\\>\\ze:")
call s:addToExisting('coffee', "^\\s\\{1,4}'\\=\\zs\\w\\+\\ze:")
" match anything nested 0-4 levels deep in sass and scss
call s:addToExisting('scss', "^\\s\\{0,4}\\zs\\S\\{-}\\ze\\s{")
call s:addToExisting('sass', "^\\s\\{0,4}\\zs\\S\\{-}\\ze$")

" vim:ft=vim:fdm=marker:
