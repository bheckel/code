" http://www.ibm.com/developerworks/linux/library/l-vim-script-2/index.html

function Average(...)
  let sum = 0.0

  for nextval in a:000  "a:000 is the list of arguments
    let sum += nextval
  endfor

  return sum / a:0      "a:0 is the number of arguments
endfunction
