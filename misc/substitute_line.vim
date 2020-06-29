" Adapted: Tue 21 Feb 2012 14:26:37 (Bob Heckel -- " http://www.ibm.com/developerworks/linux/library/l-vim-script-2/index.html)
"
" In your file:
" :so substitute_line.vim
" :call setline('.', ExpurgateText(getline('.')) )

function! ExpurgateText(text)
   let expurgated_text = a:text

   for expletive in [ 'replicant', 'frak', 'gorram' ]
     let expurgated_text
     \   = substitute(expurgated_text, expletive, '[DELETED]', 'g')
   endfor

   return expurgated_text
endfunction
