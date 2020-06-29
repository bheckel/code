@echo off

C:
chdir C:\cygwin\bin

:::bash --login -i

::                               left+down
start /B rxvt.exe -geometry 85x45+295+105 -fn "Andale Mono-13" -sl 10000 -sr -bg black -fg #F5DEB3 -e /bin/bash --login -i

