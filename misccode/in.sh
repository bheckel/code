#!/bin/sh

# Emulate an SQL-like IN statement in shell

for s in unix perl foo; do 
  if test $s = 'unix' || test $s = 'perl'; then
    echo found $s
  fi
done



underscores=(_bashrc Xdefaults inputrc _vimrc Xmodmap)
for f in ${underscores[*]}; do
  if test $f = '_bashrc' || test $f = '_vimrc'; then
    echo p
  else
    echo ignored $f
  fi
done
