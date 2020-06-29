" Adapted http://www.ibm.com/developerworks/linux/library/l-vim-script-2/index.html?S_TACT=105AGX03&S_CMP=EDU

" Runs once per line
" :1,$call DeAmperfy()
function DeAmperfy()
  "Get current line...
  let curr_line   = getline('.')

  "Replace raw ampersands...
  let replacement = substitute(curr_line,'&\(\w\+;\)\@!','&amp;','g')

  "Update current line...
  call setline('.', replacement)
endfunction



" With the range modifier specified after the parameter list, any time DeAmperfyAll() is called with a range such as:
"
" :1,$call DeAmperfyAll()
"
" then the function is invoked only once, and two special arguments,
" a:firstline and a:lastline, are set to the first and last line numbers in the
" range. If no range is specified, both a:firstline and a:lastline are set to
" the current line number.
function DeAmperfyAll() range
  "Step through each line in the range...
  for linenum in range(a:firstline, a:lastline)
    "Replace loose ampersands (as in DeAmperfy())...
    let curr_line   = getline(linenum)
    let replacement = substitute(curr_line,'&\(\w\+;\)\@!','&amp;','g')
    call setline(linenum, replacement)
  endfor

  "Report what was done...
  if a:lastline > a:firstline
    echo "DeAmperfied" (a:lastline - a:firstline + 1) "lines"
  endif
endfunction
