" Adapted from http://www.ibm.com/developerworks/linux/library/l-vim-script-2/index.html?S_TACT=105AGX03&S_CMP=EDU
"
" :so %
" :call Echo()

" Only available here - script scope.  So lowercase is ok.
function! s:expurgateText(text)
  let expurgated_text = a:text

  for expletive in [ 'cagal', 'frak', 'gorram', 'mebs', 'zarking' ]
      let expurgated_text
      \   = substitute(expurgated_text, expletive, '[DELETED]', 'g')
  endfor

  return expurgated_text
endfunction


function! Echo()
  let x = s:expurgateText('foo frak bar')
  echo x
endfunction

