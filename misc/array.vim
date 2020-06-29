""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"     Name: array.vim
"
"  Summary: Hacking vimscript arrays
"
"           :help function-list
"           :so %
"
"  Adapted: Fri 02 Mar 2012 14:59:33 (Bob Heckel--http://www.ibm.com/developerworks/linux/library/l-vim-script-3/index.html)
" Modified: Tue 13 Mar 2012 13:19:57 (Bob Heckel)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""
" List
let data = [1,2,3,4,5,6,"seven"]
"""echo data[0]                 
let data[1] = 42            
let data[2] += 99          
let data[6] .= ' samurai' 
"""echo data[6]
"""echo data[-1]

" List copy
let data2 = data
let data2[2] = 100
" Hey the original got whacked due to reference aliasing...
echo data[2]
echo data2[2]
" ...so use shallow copy
let data3 = copy(data)
let data3[2] = 101
echo data[2]
echo data3[2]


""""""""""""""""
" Nested list
let pow = [
\   [ 1, 0, 0, 0  ],
\   [ 1, 1, 1, 1  ],
\   [ 1, 2, 4, 8  ],
\   [ 1, 3, 42, 27 ],
\]
"       row col
"        x  y
echo pow[3][2]

let pow2 = pow
let pow2[3][2] = 'indeterminate'
" Hey the original got whacked!
echo pow[3][2]
echo pow2[3][2]
let pow3 = deepcopy(pow)
let pow3[3][2] = 'determinate'
echo pow[3][2]
echo pow3[3][2]


""""""""""""""""
" Functions

let list_length   = len(data)
let list_is_empty = empty(data)     " same as: len(a_list) == 0

" Numeric minima and maxima...
let greatest_elem = max(data)
let least_elem    = min(data)

" Index of first occurrence of value or pattern in list...
let value_found_at = index(data, 'seven samurai')      " uses == comparison
echo value_found_at

let pat_matched_at = match(data, 7)    " uses =~ comparison
echo pat_matched_at

let list_of_numbers = [1,2,3]
" you almost always want copy() to avoid whacking list_of_numbers
let increased_numbers = map(copy(list_of_numbers), 'v:val + 1')
echo increased_numbers


""""""""""""""""
" Other
let week = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat']
let weekdays = week[1:5]
echo weekdays


echo

let list_of_lists = [
\   [ 0, 1, 2 ],
\   [ 3, 4, 5 ],
\   [ 6, 7, 8 ],
\]
" Iterating over nested lists
for nested_list in list_of_lists
  let name   = nested_list[0] 
  let rank   = nested_list[1] 
  let serial = nested_list[2] 
    
  echo rank . ' ' . name . '(' . serial . ')'
endfor

echo 'same'

" but Vimscript has a much cleaner shorthand for it:
for [name, rank, serial] in list_of_lists
  echo rank . ' ' . name . '(' . serial . ')'
endfor

