" Vim syntax file ADAPTED FROM DOSINI.VIM
" Language: Results of bgrep queries.
" Modified: Wed, 29 Mar 2000 08:25:45 (Bob Heckel)

set nohlsearch

syn clear

syn case ignore

syn match  bgrepLabel   "^.\{-}="
syn region bgrepHeader  start="^" end=" "
syn match  bgrepComment "^[#,;].*$"

if !exists("did_bgrep_syntax_inits")
  let did_bgrep_syntax_inits = 1
  " The default methods for highlighting.  Can be overridden later
  hi link bgrepHeader Type
  hi link bgrepComment Comment
  hi link bgrepLabel Type
endif

let b:current_syntax = "bgrep"

" vim:ts=8
