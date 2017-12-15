""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"     Name: hash.vim
"
"  Summary: Demo of associative arrays, ahem, dictionaries
"
"           :echo {'a':1, 100:'foo',}[a]
"           :echo {'a':1, 100:'foo',}[100]
"
"  Adapted: Fri 16 Mar 2012 15:34:22 (Bob Heckel--Damian Conway http://www.ibm.com/developerworks/linux/library/l-vim-script-4/index.html)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let daytonum = { 'Sun':0, 'Mon':1, 'Tue':2, 'Wed':3, 'Thu':4, 'Fri':5, 'Sat':6 }

let diagnosis = {
    \   'Perl'   : 'Tourettes',
    \   'Python' : 'OCD',
    \   'Lisp'   : 'Megalomania',
    \   'PHP'    : 'Idiot-Savant',
    \   'C++'    : 'Savant-Idiot',
    \   'C#'     : 'Sociopathy',
    \   'Java'   : 'Delusional',
    \}

echo diagnosis['Perl']

" Easy to add to later
let diagnosis['COBOL'] = 'Dementia'
" Or remove later
unlet diagnosis['Perl']

" Look for a missing element
" fails
"""echo diagnosis["Ruby"]

let echoesazero = get(diagnosis, 'Ruby')
echo echoesazero

let echoescorrect = get(diagnosis, 'Ruby', 'Schizophenia')
echo echoescorrect



" Alternative (better?) - really a struct:
let user = {}

let user.name    = 'Bram'
let user.acct    = 123007
let user.pin_num = '1337'


for [ next_key, next_val ] in items(diagnosis)
  let result = next_val
  echo "Result for " next_key " is " result
endfor
