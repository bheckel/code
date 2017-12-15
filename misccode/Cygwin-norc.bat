@echo off

:: This bat must be doubleclicked.  If started from bash it inherits the env
C:
chdir C:\cygwin\bin

:::bash --login -i
bash -norc
:::start /B c:\cygwin\bin\rxvt.exe -geometry 80x45+295+135 -fn "Andale Mono-13" -sl 10000 +j +sk +si -bg black -e /bin/bash -i

:::start /B rxvt.exe -geometry 80x45+295+135 -fn "Andale Mono-13" -sl 10000 +j +sk +si -bg black -fg #F5DEB3 -e /bin/bash --login -i

::start /B rxvt.exe -geometry 80x45+295+135 -fn "Andale Mono-13" -sl 10000 +sr -bg black -fg #F5DEB3 -e /bin/bash --login -i
