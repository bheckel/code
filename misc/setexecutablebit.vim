
fu! SetExecutableBit()
  " Set executable bit without doing  :!chmod +x %  (and losing undo history).
  " TODO not working on sdf
  let fname = expand("%:p")
  :checktime
  exec "au FileChangedShell " . fname . " :echo"
  :silent !chmod a+rx %
  :checktime
  exec "au! FileChangedShell " . fname
endfu
command! -nargs=0 Xbit call SetExecutableBit()


