::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::     Name: webrun.bat
::
::  Summary: Automate the running of NCHS web related jobs.
::
::  Created: Wed 17 Jul 2002 16:04:42 (Bob Heckel)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off

set SASLOCATION=C:\PROGRA~1\SASINS~1\SAS\V8\sas.exe
set SASJOB=helloworld.sas
set SASLOG=webrun_saslog
set VBA1=Txt2Excel.xls
set VBA2=OpenRefreshSave.xls

:: This will rarely be used since most people are going to doubleclick a
:: shortcut instead of running from the command line or run via Task
:: Scheduler.
if "%1" == "-h" goto usage
if "%1" == "--help" goto usage
goto main

:main
  if not exist %SASJOB% goto sasfilemissing
  echo Running %SASJOB%
  :::C:\PROGRA~1\SASINS~1\SAS\V8\sas.exe -nosplash -sysin helloworld.sas -log webrun_saslog
  %SASLOCATION% -nosplash -sysin %SASJOB% -log %SASLOG%
  :: Original errorlevel is 0.
  if errorlevel 1 goto saserror
  echo SAS job executed.

  echo.
  echo Running %VBA1%
  if not exist %VBA1% goto vba1filemissing
  start %VBA1%
  if errorlevel 1 goto vba1error
  echo %VBA1% macro executed.

  echo Running %VBA2%
  if not exist %VBA2% goto vba2filemissing
  start %VBA2%
  if errorlevel 1 goto vba2error
  echo %VBA2% macro executed.
exit

:saserror
  echo Tried unsuccessfully to run the SAS code %SASJOB%.
  :::pause
exit

:sasfilemissing
  echo Tried unsuccessfully to find the SAS code %SASJOB%.
  :::pause
exit

:vba1filemissing
  echo Tried unsuccessfully to find the VBA code %VBA1%.
  :::pause
exit

:vba2filemissing
  echo Tried unsuccessfully to find the VBA code %VBA2%.
  :::pause
exit

:: TODO can't get Excel to make the errorlevel change on error
:vba1error
  echo Tried unsuccessfully to run %VBA1% code.
  :::pause
exit

:: TODO can't get Excel to make the errorlevel change on error
:vba2error
  echo Tried unsuccessfully to run %VBA2% code.
  :::pause
exit

:usage
  echo Usage: webrun [-h]
  echo               -h  This help message
  echo        Attempts to run a SAS job and 2 VBA macros.
exit
