#!/bin/sh

set -o vi

stty erase ^H

alias la='ls -a'
alias ll='ls -l'

export PS1=`whoami`'@'`hostname`' '

echo sourced $0
