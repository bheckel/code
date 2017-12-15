echo off
REM *********************************************
REM This batch file will recycle all services
REM associated with LINKS.
REM *********************************************

::D:\SAS_Programs\SAS_Mail\blat.exe D:\SAS_Programs\StartStopSAS\Recycle.txt -t "jxb5376@gsk.com" -s "Killing Process" -f "RTPSAWN321@gsk.com" -server "smtphub.glaxo.com"

d:\sas_programs\startstopsas\pv.exe -kf sas.exe
d:\sas_programs\startstopsas\pv.exe -kf mtx.exe
c:/winnt/System32/net.exe stop "SAS IntrNet Load Manager"
c:/winnt/System32/net.exe stop "Simple Mail Transfer Protocol (SMTP)"
c:/winnt/System32/net.exe stop "World Wide Web Publishing Service"
c:/winnt/System32/net.exe stop "HTTP SSL"
c:/winnt/System32/net.exe stop "FTP Publishing Service"
c:/winnt/System32/net.exe stop "IIS Admin Service"
d:\sas_programs\startstopsas\pv.exe -kf inetinfo.exe 
::del /s /q /f "e:\Sas Temporary Files\*" 
::del /q /f "d:\SAS Files\V8\IntrNet\default\logs\*.log"
::rd /s /q "e:\Sas Temporary Files\" 
::md "e:\SAS Temporary Files\"

sleep 1

::D:\SAS_Programs\SAS_Mail\blat.exe D:\SAS_Programs\StartStopSAS\Start_Service.txt -t "jxb5376@gsk.com" -s "Starting Services" -f "RTPSAWN321@gsk.com" -server "smtphub.glaxo.com"

set SVCERR=
net start "IIS Admin Service"
if ERRORLEVEL 1 set SVCERR=%ERRORLEVEL%
if not "%SVCERR%"=="" pause

sleep 1

set SVCERR=
net start "HTTP SSL"
if ERRORLEVEL 1 set SVCERR=%ERRORLEVEL%
if not "%SVCERR%"=="" pause

sleep 1

set SVCERR=
net start "World Wide Web Publishing Service"
if ERRORLEVEL 1 set SVCERR=%ERRORLEVEL%
if not "%SVCERR%"=="" pause

sleep 1

set SVCERR=
net start "Simple Mail Transfer Protocol (SMTP)"
if ERRORLEVEL 1 set SVCERR=%ERRORLEVEL%
if not "%SVCERR%"=="" pause

sleep 1

set SVCERR=
net start "FTP Publishing Service"
if ERRORLEVEL 1 set SVCERR=%ERRORLEVEL%
if not "%SVCERR%"=="" pause

sleep 1

set SVCERR=
net start "SAS Intrnet Load Manager"
if ERRORLEVEL 1 set SVCERR=%ERRORLEVEL%
if not "%SVCERR%"=="" pause

sleep 1

::D:\SAS_Programs\SAS_Mail\blat.exe D:\SAS_Programs\StartStopSAS\Start_Complete.txt -t "jxb5376@gsk.com" -s "Recycle Complete" -f "RTPSAWN321@gsk.com" -server "smtphub.glaxo.com"

if  exist  e:\SQL_Loader\CkRptFlg.txt  goto  Del_Check
goto Exit

:Del_Check
del /f /q "e:\SQL_Loader\CkRptFlg.txt"
::D:\SAS_Programs\SAS_Mail\blat.exe D:\SAS_Programs\StartStopSAS\Remove_CkRptFlg.txt -t "jxb5376@gsk.com" -s "Remove CkRptFlg" -f "RTPSAWN321@gsk.com" -server "smtphub.glaxo.com"
goto Exit

:Exit
exit