
" TODO 2008-04-09 this is just proof-of-concept at the moment  " {{{2
" $ cat t.txt
" one|addr@foo.bar
" onemore|addrmore@foo.bar
" two|addr2@foo.bar
"
" Assumes set omnifunc=OmniCompleteFunc
fu! OmniCompleteFunc(findstart, base)
  if a:findstart
    " locate start of word
    let line = getline('.')
    let start = col('.')-1
    while start > 0 && line[start-1] =~ '\a'
      let start -= 1
    endwhile
    return start
  else
    " find contact names matching 'a:base'
    let res = []
    " read in and sort
    for m in sort(readfile('/home/bheckel/t.txt'))
      if m =~ '^' . a:base
        let contactinfo = split(m, '|')
        " show names in list but insert address
        call add(res, {'word': contactinfo[1],
                       \ 'abbr': contactinfo[0] . ' <' . contactinfo[1] . '>',
                       \ 'icase': 1 })
      endif
    endfor
    return res
  endif
endfu  " }}}


