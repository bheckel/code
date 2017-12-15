echo off
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::     Name: cp_b2020.bat
::
::  Summary: Copy one directory of Beyond 20/20 files to another directory.
::
::  Created: Fri 24 Oct 2003 13:40:48 (Bob Heckel)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set CMORDIR=C:\BTTMOR
set IMORDIR=I:\MORDATA

set CNATDIR=C:\BTTNAT
set INATDIR=I:\NATDATA

echo Ready to copy B2020 files from C: to I:?
pause

if exist %CMORDIR% if exist %IMORDIR% goto domorcopy
echo One or more directory does not exist.  Exiting.
pause
exit

if exist %CNATDIR% if exist %INATDIR% goto donatcopy
echo One or more directory does not exist.  Exiting.
pause
exit

:domorcopy
copy %CMORDIR%\*.ivd %IMORDIR%
copy %CMORDIR%\*.ivx %IMORDIR%
echo Mortality file copy done.
echo.

:donatcopy
copy %CNATDIR%\*.ivd %INATDIR%
copy %CNATDIR%\*.ivx %INATDIR%
echo Natality file copy done.
echo.

pause
