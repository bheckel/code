#!/bin/bash

# Print colors available to tmux and vim
for i in {0..255} ; do
  printf "\x1b[38;5;${i}mcolour${i} *************************************\n"
done
