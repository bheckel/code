::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::     Name: dos_errorlevel.bat
::
::  Summary: Demo of using error levels.
::
::  Created: Tue 28 Aug 2001 13:39:23 (Bob Heckel)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: Original errorlevel is 0.
if errorlevel 1 goto onelevel

:: Dummy nonexistant command.
foocommand

if errorlevel 1 goto twolevel

:: Will not reach this line.
exit

:onelevel
:: Will not call this line.
copy test.bat one.txt

:twolevel
copy test.bat two.txt
