" Built-in symbol definitions that I've found useful

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

let s:htmlLikeFileTypes = ['html', 'erb', 'mustache', 'handlebars']
for type in s:htmlLikeFileTypes
  call s:addToExisting(type, s:htmlIdPattern)
  call s:addToExisting(type, s:htmlClassPattern)
endfor

" match a symbol in a vim file is the name of any top-level function
call s:addToExisting('vim', "^fun\\%(ction\\)\\=!\\=\\s\\zs.\\{-}\\ze(.\\{-})")

" match a symbol in js/coffee is any object key of indent levels 1-4
call s:addToExisting('javascript', "function\\s\\+\\zs\\w\\+\\ze\\s\\=(")
call s:addToExisting('coffee', "^\\s\\{1,4}'\\=\\zs\\w\\+\\ze:")

" match anything nested 0-4 levels deep in sass
call s:addToExisting('sass', "^\\s\\{0,4}\\zs\\S\\{-}\\ze$")

" this only works for SCSS (for now) because identifiers are easier to match
let s:scssSymbolMatch =  "^\\s\\{-}\\zs\\S.\\{-}\\ze\\s\\{-}{"
function! s:SCSSContext(linestr, line)
  if a:linestr =~ '{'
    let match = matchstr(a:linestr, s:scssSymbolMatch)
    silent! call add(s:scssSymbolContext, match)
  endif
  if a:linestr =~ '}'
    silent! call remove(s:scssSymbolContext, len(s:scssSymbolContext) - 1)
  endif

  if exists("match")
    return join(s:scssSymbolContext)
  else
    return 0
  endif
endfunction
function! s:PreSCSSSymbolGather()
  let s:scssSymbolContext = []
endfunction

call s:addToExisting('scss', function('s:SCSSContext'))

let g:pre_symbol_gather = {
      \ 'scss': function("s:PreSCSSSymbolGather")
      \ }
