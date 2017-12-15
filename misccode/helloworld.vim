"  Created: Thu 05 Feb 2009 10:54:44 (Bob Heckel)
" Modified: Mon 13 Feb 2012 16:20:56 (Bob Heckel)
"
" Don't reinvent the wheel
" :h functions-list
"
" To run:
" :so % 
" :call Helloworld    <---or Hell
"
" :echo v:errmsg

" Need the bang to avoid errors on re-sourcing.
fu! Helloworld(num1, num2)
  let g:helo = "Hello world"
  let g:checkme = "i reluctantly exist"
  """let imlocal = "local variable"
  " Better, s: indicates a variable local to the script.
  let s:imlocal = "local variable"

  if !exists(g:checkme)
    let g:helo2 = g:checkme
  endif

  echo g:helo "the time is" localtime() "in" getcwd() "therefore" g:helo2
  if a:num1 > a:num2
    echo s:imlocal "(no need for leading space in concatenation)"
    echo "Is there a newline character or do I have to do this?"
  endif

  " Looping demos:

  let i = 0
  while i < 5
    echo i
    let i += 1
  endwhile

  for j in range(5)
    echo j
  endfor
endfu
" Like a typedef, avoid having to prefix function call with :call
command! -nargs=* Helloworld call Helloworld(3, 2)
" Alias-like
command! -nargs=0 Hell call Helloworld(3,2)
