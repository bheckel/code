::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::     Name: auto_hdg7.bat
::
::  Summary: Automate the running of SAS and VBA Excel jobs.
::
::  Created: Mon 12 Aug 2002 13:02:31 (Bob Heckel)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off

set SASLOCATION=C:\PROGRA~1\SASINS~1\SAS\V8\sas.exe
set SASJOB1=dlnat.sas
set SASLOG1=dlnat.log
set SASJOB2=runalln1.sas
set SASLOG2=runalln1.log
set SASJOB3=runalln2.sas
set SASLOG3=runalln2.log
:: HEATHER edit
set SASJOB4=MySas.sas
set SASLOG4=MySas.log
set SASJOB5=MySas2.sas
set SASLOG5=MySas2.log
:: HEATHER edit
set VBA1=MySpreadsheet.xls
set VBA2=MySpreadsheet2.xls
:: HEATHER edit

:: This will rarely be used since most people are going to doubleclick a
:: shortcut instead of running from the command line or run via Task
:: Scheduler.
if "%1" == "-h" goto usage
if "%1" == "--help" goto usage
goto main

:main
  if not exist %SASJOB1% goto sasfilemissing
  echo Running %SASJOB1%
  %SASLOCATION% -nosplash -sysin %SASJOB1% -log %SASLOG1%
  :: Original errorlevel is 0.
  if errorlevel 1 goto saserror
  echo SAS job 1 executed successfully.

  if not exist %SASJOB2% goto sasfilemissing
  echo Running %SASJOB2%
  %SASLOCATION% -nosplash -sysin %SASJOB2% -log %SASLOG2%
  :: Original errorlevel is 0.
  if errorlevel 1 goto saserror
  echo SAS job 1 executed successfully.

  if not exist %SASJOB3% goto sasfilemissing
  echo Running %SASJOB3%
  %SASLOCATION% -nosplash -sysin %SASJOB3% -log %SASLOG3%
  :: Original errorlevel is 0.
  if errorlevel 1 goto saserror
  echo SAS job 1 executed successfully.

  if not exist %SASJOB4% goto sasfilemissing
  echo Running %SASJOB4%
  %SASLOCATION% -nosplash -sysin %SASJOB4% -log %SASLOG4%
  :: Original errorlevel is 0.
  if errorlevel 1 goto saserror
  echo SAS job 1 executed successfully.

  if not exist %SASJOB5% goto sasfilemissing
  echo Running %SASJOB5%
  %SASLOCATION% -nosplash -sysin %SASJOB5% -log %SASLOG5%
  :: Original errorlevel is 0.
  if errorlevel 1 goto saserror
  echo SAS job 1 executed successfully.

  echo.
  echo Running %VBA1%
  if not exist %VBA1% goto vbafilemissing
  start %VBA1%
  if errorlevel 1 goto vbaerror
  echo %VBA1% macro executed.
  :: HEATHER edit
exit

:saserror
  echo Tried unsuccessfully to run one of the SAS jobs.
  pause
exit

:sasfilemissing
  echo Tried unsuccessfully to find one of the SAS job's source code.
  pause
exit

:: TODO can't get Excel to make the errorlevel change on error
:vbaerror
  echo Tried unsuccessfully to run one of the VBA macros.
  pause
exit

:vbafilemissing
  echo Tried unsuccessfully to find one of the VBA job's XLS file.
  pause
exit

:usage
  echo Usage: auto_hdg7.bat [-h]
  echo          -h  This help message
  echo        Attempts to run several SAS jobs and VBA macros.
  echo        Designed to be used via Windows Task Scheduler.
exit
