" Adapted http://www.ibm.com/developerworks/linux/library/l-vim-script-2/index.html?S_TACT=105AGX03&S_CMP=EDU
function CommentBlock(comment, ...)
  " If 1 or more optional args, first optional arg is introducer...
  let introducer =  a:0 >= 1  ?  a:1  :  "//"

  " If 2 or more optional args, second optional arg is boxing character...
  let box_char   =  a:0 >= 2  ?  a:2  :  "*"

  " If 3 or more optional args, third optional arg is comment width...
  let width      =  a:0 >= 3  ?  a:3  :  strlen(a:comment) + 2

  " Build the comment box and put the comment inside it...
  return introducer . repeat(box_char,width) . "\<CR>"
  \    . introducer . " " . a:comment        . "\<CR>"
  \    . introducer . repeat(box_char,width) . "\<CR>"
endfunction

imap <silent>  ###  <C-R>=CommentBlock(input("Enter comment: "),'#','#')<CR>
