@echo off
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::     Name: counter.bat
::
::  Summary: Demo of using the DOS version of ++ increment 
::
::  Created: Mon 08 Jul 2002 15:34:49 (Bob Heckel)
:: Modified: Fri 15 May 2009 11:07:53 (Bob Heckel)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

setlocal enabledelayedexpansion

set /A n=1
 
echo Initial value of Counter: %n%
echo.
 
for %%f in (1 2 3) do (
  echo Counter Before increment %%f: !n!
  set /A n+=1
  echo Counter After Increment: !n!
  if !n! == 2 echo foo2
  echo.
)
 
echo Counter after for loop: %n%
