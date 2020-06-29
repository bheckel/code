
" To execute :so % | :call Greppy()
function! Greppy()
  " Search the first 10 lines only
  for line in readfile('junk.txt', '', 10)
    if line =~ 'findmystring' | echo line | endif
  endfor
endfu
