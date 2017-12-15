OBSOLETE
@echo off

:: Created: Tue 08 Dec 2009 12:47:32 (Bob Heckel) 
:: Modified: Sat 16 Apr 2011 09:34:30 (Bob Heckel)

set USER=bheckel

:::set HOME=l:\cygwin\home\bheckel
:::set PATH=l:\cygwin
:::set HOME=C:/Users/bheckel_2/Documents/MyDrop~1/Public/USB/Liberkey/MyApps/cygwin/home/bheckel
:::set HOME=C:/Users/bheckel_2/Documents/MyDrop~1/Public/USB/cygwin/home/bheckel
:::set PATH=C:/Users/bheckel_2/Documents/MyDrop~1/Public/USB/Liberkey/MyApps/cygwin/bin:C:/Users/bheckel_2/Documents/MyDrop~1/Public/USB/Liberkey/MyApps/cygwin/usr/bin
:::set PATH=C:/Users/bheckel_2/Documents/MyDrop~1/Public/USB/cygwin/bin;C:/Users/bheckel_2/Documents/MyDrop~1/Public/USB/Liberkey/MyApps/cygwin/usr/bin
set PATH=C:\Dropbox\MyDrop~1\Public\USB\cygwin\bin

:::set HOME=C:\Dropbox\MyDrop~1\Public\USB\cygwin\home\bheckel
:::set HOME=C:/Users/bheckel_2/My\ Documents/My\ Dropbox/Public/USB/cygwin/home/bheckel/
:::set HOME=C:/Users/bheckel_2/MyDocu~1/MyDrop~1/Public/USB/cygwin/home/bheckel/

:::set PATH=C:\Dropbox\MyDrop~1\Public\USB\cygwin\bin
:::set PATH=C:/Users/bheckel_2/My\ Documents/My\ Dropbox/Public/USB/cygwin/bin/

:::L:
:::chdir L:\cygwin\home\bheckel
:::chdir C:/Users/bheckel_2/Documents/MyDrop~1/Public/USB/Liberkey/MyApps/cygwin
:::chdir C:/Users/bheckel_2/Documents/MyDrop~1/Public/USB/cygwin
:::chdir C:\Dropbox\MyDrop~1\Public\USB\cygwin\home\bheckel
chdir C:\cygwin\home\bheckel

:: Use cmd window
:::bash --login -i 
start /B C:\Dropbox\MyDrop~1\Public\USB\\cygwin\bin\rxvt.exe -geometry 80x45+295+135 -fn "Andale Mono-13" -sl 10000 +j +sk +si -sr -fg wheat -bg black -e C:\Dropbox\MyDrop~1\Public\USB\\cygwin\bin\bash -i
:::start /B \cygwin\bin\rxvt.exe -geometry 80x45+295+135 -fn "Courier New-14" -sl 10000 +j +sk +si -bg black -e \cygwin\bin\bash -i
:::start /B bin/rxvt.exe -geometry 80x45+295+135 -fn "Courier New-14" -sl 10000 +j +sk +si -bg black -e bin/bash -i
