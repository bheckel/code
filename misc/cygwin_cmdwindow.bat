@echo off

:: Modified: Wed 01 Sep 2010 20:01:46 (Bob Heckel)

C:
chdir C:\cygwin\bin

set HOME=c:/cygwin/home/bheckel

bash --login -i
:::start /B rxvt.exe -geometry 80x45+295+135 -fn "Andale Mono-13" -sl 10000 -sr -bg black -fg #F5DEB3 -e /bin/bash --login -i
