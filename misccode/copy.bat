echo off
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::     Name: copy.bat
::
::  Summary: Copy one directory of Beyond 20/20 files to another.  In this
::           case from the C: to I: drives.
::
::  Created: Fri 24 Oct 2003 13:40:48 (Bob Heckel)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set CMORDIR=c:\cygwin\home\bqh0\tmp\testing\dirjunk
set IMORDIR=c:\cygwin\home\bqh0\tmp\testing\dirjunk2

if exist %CMORDIR% if exist %IMORDIR% goto domorcopy
echo One or more directory does not exist.  Exiting.
pause
exit

:domorcopy
copy %CMORDIR%\*.ivd %IMORDIR%
copy %CMORDIR%\*.ivx %IMORDIR%
echo Done
