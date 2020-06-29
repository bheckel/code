@echo off

:: note: no 'THEN's
if "%COMPUTERNAME%" == "SATI" goto ON_HOME
if "%COMPUTERNAME%" == "ZEBWL06A16349" goto ON_WORK

:ON_HOME
  echo home
  goto the_end

:ON_WORK
  echo on work
  :: Block structure
  if "%VS90COMNTOOLS%"=="" (
    :: Leading spaces are retained with ":"
    echo:  Visual Studio 2008 is not installed
    exit /b
  )
  goto the_end

echo neither

:the_end
  echo done
