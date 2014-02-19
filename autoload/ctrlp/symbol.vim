" Load things found by the GatherSymbols function into CtrlPSymbol

if exists('g:loaded_ctrlp_symbol') && g:loaded_ctrlp_symbol
  finish
end
let g:loaded_ctrlp_symbol = 1

call add(g:ctrlp_ext_vars, {
	\ 'init': 'ctrlp#symbol#init()',
	\ 'accept': 'ctrlp#symbol#accept',
	\ 'lname': 'symbol',
	\ 'sname': 'symbol',
	\ 'type': 'line'
	\ })

function! ctrlp#symbol#init()
  let s:buf_symbols = getbufvar(s:symbol_buffer, 'symbols_gathered')
  return keys(s:buf_symbols)
endfunction

function! ctrlp#symbol#accept(mode, symbol)
  call ctrlp#acceptfile(a:mode, bufnr(s:symbol_buffer), s:buf_symbols[a:symbol])
  normal 0
endfunction

" unique id for the command
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)
function! ctrlp#symbol#id()
  return s:id
endfunction
