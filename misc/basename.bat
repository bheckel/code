::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::     Name: basename.bat
::
::  Summary: Determine the basename if passed a fully qualified filename.
::           NOT WORKING
::           TODO does slash not work under W2K??
::
::  Created: Mon 08 Jul 2002 15:46:43 (Bob Heckel)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off
:::set fqname=%1
:::if "%fqname%"=="" goto done
:::echo past1
:::set tname=%fqname%® 
:::set base=
:::set char=
:::
::::lp
:::  set temp=%tname%
:::  if "%tname%"=="®" goto done
:::  echo past2 %temp%
:::  for %%a in (/%tname%) do set tname=%%a
:::  for %%a in (/%temp%) do if "%%a%tname%"=="%temp%" set char=%%a
:::  if "%char%"=="." goto done
:::  echo past3
:::  set base=%base%%char%
:::  goto lp
:::
::::done
:::  echo Fully qualified: %fqname%
:::  echo Basename:        %base%
:::  set char=
:::  set temp=
:::  set tname=
:::exit
for %%n in (\/hello there) do echo %%n

