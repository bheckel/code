" Adapted: Mon Nov 19 12:03:51 2007 (Bob Heckel -- Hacking Vim) 

" check if script is already loaded
if exists("loaded_myscript")
   finish "stop loading the script
endif

let loaded_myscript=1 
let s:global_cpo = &cpo  "store compatible-mode in local variable 
set cpo&vim              " go into nocompatible-mode

" ######## CONFIGURATION ########

" variable myscript_path
if !exists("myscript_path")
   let s:vimhomepath = split(&runtimepath,',')
   let s:myscript_path = s:vimhomepath[0]."/plugin/myscript.vim"
else
   let s:myscript_path = myscript_path
   unlet myscript_path 
endif

" variable myscript_indent
if !exists("myscript_indent")
   let s:myscript_indent = 4
else
   let s:myscript_indent = myscript_indent
   unlet myscript_indent
endif

  " ######## FUNCTIONS #########

  " this is our local function with a mapping
function s:MyfunctionA()
   echo "This is the script-scope function MyfunctionA speaking"
endfunction

" this is a global function which can be called by anyone
function MyglobalfunctionB()
   echo "Hello from the global-scope function myglobalfunctionB"
endfunction

" this is another global function which can be called by anyone
function MyglobalfunctionC()
   echo "Hello from MyglobalfuncionC() now calling locally:"
   call <SID>MyfunctionA()
endfunction

" return to the users own compatible-mode setting
:let &cpo = s:global_cpo
