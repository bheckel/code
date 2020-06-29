@echo off

set _find_cmd=%SystemRoot%\System32\find.exe


rem *** OS Detection

ver | %_find_cmd% "2003" > nul
if %ERRORLEVEL% == 0 echo ver_2003

ver | %_find_cmd% "XP" > nul
if %ERRORLEVEL% == 0 echo ver_xp

ver | %_find_cmd% "2000" > nul
if %ERRORLEVEL% == 0 echo ver_2000

pause
