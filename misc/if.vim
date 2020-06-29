
" :se ft=foo or :se ft=
" :so %
" :call Iffy()
" or just:
" :so % | call Iffy()
fu! Iffy()
  " Should always use  ==#  for string comparisons
  """if &ft ==# 'foo'
  if &ft ==# ''
    """echo 'foo is the filetype'
    echo 'blank is the filetype'
  else
    echo 'unknown is the filetype'
  endif
endfu
