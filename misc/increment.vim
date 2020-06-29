" File:   increment.vim
" Author: Srinath Avadhanula
" Email:  srinath@eecs.berkeley.edu
"
" This script provides a way to quickly create incremented lists (either
" increasing or decreasing) using the visual block mode. 
" 
" Synopsis:
" =========
" 1. Suppose you have a column of the following form:
"     array(1) = 3;
"     array(1) = 3;
"     array(1) = 3;
"     array(1) = 3;
"     array(1) = 3;
" 2. Choose the column of '1's using Ctrl-V and then run the command Inc (you
"    should see "'<,'>Inc" on the command line at this point)(if you do not
"    have any other user commands starting with 'I', just I will suffice).
"    This will tranform the text as:
"     array(1) = 3;       array(1) = 3;
"     array(1) = 3;       array(2) = 3;
"     array(1) = 3;  -->  array(3) = 3;
"     array(1) = 3;       array(4) = 3;
"     array(1) = 3;       array(5) = 3;
" 3. You can then choose the column of '3's (again using Ctrl-V) and run the
"    command "Inc 3" to generate another incremented list. This will
"    generate:
"     array(1) = 3;        array(1) =  3;
"     array(2) = 3;        array(2) =  6;
"     array(3) = 3;  -->   array(3) =  9;
"     array(4) = 3;        array(4) = 12;
"     array(5) = 3;        array(5) = 15;
" 	
" 	Note: increment.vim automatically pads the numbers in the the column
" 	with spaces in order to get them right aligned. This is useful in most
" 	cases, but for cases when this might be bad, use IncN which doesnt do
" 	any alignment. 
" 
" Commands:
" =========
" 1. Inc : generates a column of increasing numbers with RIGHT  alignment.
" 2. IncN: generates a column of increasing numbers with NO     alignment.
" 3. IncL: generates a column of increasing numbers with LEFT   alignment
" 
" Tip:
" A mapping which goes well with this command is the following:
" 
" vnoremap <c-a> :Inc<CR>
" 
" With this mapping, select a column of numbers and press Ctrl-A, which will
" get them in increasing order. I use <c-a> because its similar to the <c-a>
" command in normal mode which increments the number under the cursor.
" 
" Last Modification: Dec 17 2001 00:59:09
" Adapted: Tue Apr 22 11:06:52 2003 (Bob Heckel)
" TODO add arg to determine whether to use zero to left pad (it's the default
" now)

"=========================================================================== 
" (Bob Heckel) default align right
com! -ra -nargs=? Inc :call IncrementColumn(1, <args>)
"""com! -ra -nargs=? IncR :call IncrementColumn(2,<args>)
" (Bob Heckel) align left
" TODO Using the zero char for padding left is not a good idea.  E.g. 1
" becomes 100
com! -ra -nargs=? IncL :call IncrementColumn(4, <args>)
" (Bob Heckel) no padding
com! -ra -nargs=? IncN :call IncrementColumn(0, <args>)

"=========================================================================== 
" (Bob Heckel)
" E.g. for zero pads, return a 0
" Accepts str to use for left padding (if necessary) and number of times to
" repeat that str (e.g. 2 times for 001).
function! StrRepeat(str, count)
	let i = 1
	let retStr = ""
	while i <= a:count
		let retStr = retStr . a:str
		let i = i + 1
	endwhile
  """echo 'DEBUG ' retStr
	return retStr
endfunction


" first argument is either 0 or 1 or 2 depending on whether padding with
" spaces is desired (pad = 1,2) or not. the second argument contains the
" counter increment. its optional. if not specified, its assumed to be 1.
function! IncrementColumn(pad, ...)
  " (Bob Heckel)
  echon 'increment.vim:  Align style == ' a:pad

	if a:0 == 0
		let incr = 1
	elseif a:0 == 1
		let incr = a:1
    " (Bob Heckel)
    echon "\t\tIncrement == " a:1
	else
		return
	end

	let c1 = col("'<")
	let c2 = col("'>")
	let c1v = virtcol("'<")
	let c2v = virtcol("'>")
	let clen = c2v - c1v
	if c1 > c2
		let temp = c1
		let c1 = c2
		let c2 = temp
	end

	let r1 = line("'<")
	let r2 = line("'>")
	if r1 > r2
		let temp = r1
		let r1 = r2
		let r2 = temp
	end

	exe r1

	exe "let presNum = ".strpart(getline('.'), c1-1, clen+1)

	let lastnum = presNum + incr*(r2-r1)
	" a simple way to find the number of digits in a number (including decimal
	" points, - signs etc).
	let maxstrlen = strlen("".lastnum)

	let r = r1
	exe 'normal '.c1v.'|'
	while (r <= r2)
		let cnow = col(".")
		let linebef = strpart(getline('.'), 0, cnow-1)
		let lineaft = strpart(getline('.'), cnow+clen, 1000)

		" find the number of padding spaces required for left/rigth alignment
		if a:pad
			let preslen = strlen("".presNum)
      " (Bob Heckel) 
      " Changed from "" to zero char for padding.
			let padspace = StrRepeat("0", maxstrlen - preslen)
		else
			let padspace = ""
		end

		" the final line is made up of 
		" 1. the part of the line before the number
		" 2. the padding spaces.
		" 3. the present number
		" 4. the part of the line after the number
		" the padding spaces are either before or after the current number
		" depending on whether the pad argument is 1 or 2 (respectively).
		if a:pad == 1
			let lineset = linebef.padspace.presNum.lineaft
		elseif a:pad == 2
			let lineset = linebef.presNum.padspace.lineaft
		else
			let lineset = linebef.presNum.lineaft
		end

		call setline('.', lineset)
		let presNum = presNum + incr
		normal j
		let r = r + 1
	endwhile
	normal `<
endfunction
