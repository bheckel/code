set SVCERR=
net start "FTP Publishing Service"
if ERRORLEVEL 1 set SVCERR=%ERRORLEVEL%
if not "%SVCERR%"=="" pause

