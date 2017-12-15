
" Adapted http://www.ibm.com/developerworks/linux/library/l-vim-script-2/index.html?ca=drs-

" 20 args max
function PrintDetails(name, title, email)
  echo 'Name:   '  a:title  a:name
  echo 'Contact:'  a:email
endfunction


" Variadic parameter list
function Average(...)
  " Must be initialized to an explicit floating-point value; otherwise, all the subsequent computations will be done using integer arithmetic
  let sum = 0.0

  for nextval in a:000      " a:000 is the list of arguments
      let sum += nextval
  endfor

  return sum / a:0          " a:0 is the number of arguments
endfunction



function ExpurgateText (text)
  let expurgated_text = a:text

  for expletive in [ 'cagal', 'frak', 'gorram', 'mebs', 'zarking']
      let expurgated_text
      \   = substitute(expurgated_text, expletive, '[DELETED]', 'g')
  endfor

  " You can specify as many separate return statements as you need. You can
  " include none at all if the function is being used as a procedure and has no
  " useful return value. However, Vimscript functions always return a value, so
  " if no return is specified, the function automatically returns zero.
  return expurgated_text
endfunction



function SaveBackup ()
  let b:backup_count = exists('b:backup_count') ? b:backup_count+1 : 1
  return writefile(getline(1,'$'), bufname('%') . '_' . b:backup_count)
endfunction
nmap <silent>  <C-B>  :call SaveBackup()<CR>

" or if you don't like Capital Letter Functions:

" Function scoped to current script file...but convention is always upcase
" function names
function s:save_backup ()
  let b:backup_count = exists('b:backup_count') ? b:backup_count+1 : 1
  return writefile(getline(1,'$'), bufname('%') . '_' . b:backup_count)
endfunction
nmap <silent>  <C-B>  :call s:save_backup()<CR>
