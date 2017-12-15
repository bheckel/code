::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::     Name: vbarun.bat
::
::  Summary: Run spreadsheets one at a time.  This BAT is intended to be run
::           from within a scheduling application.
::
::           It is, however, unwieldy with > 3 spreadsheets.
::
::  Created: Tue 12 Nov 2002 13:37:04 (Bob Heckel)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off

set VBA1=test1.xls
set VBA2=test2.xls
set VBA3=test3.xls

goto main

:main
  echo Running %VBA1%
  if not exist %VBA1% goto vba1filemissing
  start /WAIT %VBA1%
  if errorlevel 1 goto vba1error
  echo %VBA1% macro executed.

  echo Running %VBA2%
  if not exist %VBA2% goto vba2filemissing
  start /WAIT %VBA2%
  if errorlevel 1 goto vba2error
  echo %VBA2% macro executed.

  echo Running %VBA3%
  if not exist %VBA3% goto vba3filemissing
  start /WAIT %VBA3%
  if errorlevel 1 goto vba3error
  echo %VBA3% macro executed.
  
  echo All were run successfully.
  pause
exit

:vba1filemissing
  echo Tried unsuccessfully to find the VBA code %VBA1%.
  pause
exit

:vba2filemissing
  echo Tried unsuccessfully to find the VBA code %VBA2%.
  pause
exit

:vba3filemissing
  echo Tried unsuccessfully to find the VBA code %VBA3%.
  pause
exit

:vba1error
  echo Tried unsuccessfully to run %VBA1% code.
  pause
exit

:vba2error
  echo Tried unsuccessfully to run %VBA2% code.
  pause
exit

:vba3error
  echo Tried unsuccessfully to run %VBA3% code.
  pause
exit
