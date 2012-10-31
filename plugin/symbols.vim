" Symbols.vim - Buffer-local symbol list
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
  let l:thingLen = len(a:thing)
  let l:thangLen = len(a:thang)
  return l:thingLen == l:thangLen ? 0 :
       \ l:thingLen > l:thangLen ? 1 : -1 
endfunction

" sorts a dictionary based on the lower value of a key
function! s:sortLowest(thing, thang) dict
    return self[a:thing] - self[a:thang]
endfunction

function! s:fuzzysub(str)
  return s:gsub(s:gsub(a:str, '\w', '[&].*'), '^', '.*')
endfunction
" END utilities }}}

" current filetypes i use
function! s:checkFiletype()
  return &ft =~ '\(javascript\|coffee\)'
endfunction

" gather symbols on bufread
function! s:GatherSymbols()
  " clear existing symbols
  if exists('b:symbols_gathered')
    unlet b:symbols_gathered
  endif

  let b:symbols_gathered = {}

  " whether it's even supported
  if !s:checkFiletype()
    return ''
  endif

  " match all symbols
  for l:line in range(0, line('$'))
    let l:linestr = getline(l:line)
    let l:indent  = indent(l:line)

    " if the line matches a symbol and is indented one or two levels down
    if l:indent == 2 && l:linestr =~ "^\\s\\+'\\=\\w\\+:"
      let l:symbol = matchstr(l:linestr, "^\\s\\+'\\=\\zs\\w\\+\\>\\ze") 
      if exists('l:symbol')
        let b:symbols_gathered[l:symbol] = l:line
      elseif
        echom 'not found ' . l:symbol
      endif
    endif
  endfor
endfunction

" has to return a list of completion candidates on <TAB>
function! s:SymbolGlob(arg,cmdline,cursorpos)
  if !s:checkFiletype()
    throw 'Unavailable for ' . &ft
  endif

  " the symbols
  let l:symbols = keys(b:symbols_gathered)

  " if the user just hit tab with no symbol to search for
  if empty(a:arg)
    " sort the symbols by line number
    return sort(l:symbols, "s:sortLowest", b:symbols_gathered)
  endif

  " a fuzzy expression of the search
  let l:fuzzyArg = s:fuzzysub(a:arg)

  " filter the symbols based on the arg
  let l:symbols = filter(l:symbols, 'v:val =~ l:fuzzyArg')
  " return a sorted list with shortest symbol first
  return sort(copy(l:symbols), "s:sortShort")
endfunction

" gets passed the argument when executed
function! s:Symbol(symbol, ...)
  " nothing was passed
  if empty(a:symbol)
    return ''
  endif

  let l:symbols = s:SymbolGlob(a:symbol, '', '')

  " if no symbols found
  if empty(l:symbols)
    return ''
  endif

  " get the first one's line number
  call cursor(b:symbols_gathered[l:symbols[0]], 0)
  return ''
endfunction

" Symbol command
command! -nargs=? -complete=customlist,s:SymbolGlob Symbol
      \ execute s:Symbol(<f-args>)

" autoload that shit
augroup SymbolList
  autocmd!
  autocmd BufReadPost *.js,*.coffee call s:GatherSymbols()
  " TODO add event based on changing the file to re-gather symbols
  " ie InsertLeave?
augroup END

" vim:ft=vim:fdm=marker:
