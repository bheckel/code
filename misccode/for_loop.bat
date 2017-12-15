::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::     Name: for_loop.bat
::
::  Summary: Demo of using the for loop construct.
::
::  Created: Mon 08 Jul 2002 15:34:49 (Bob Heckel)
:: Modified: Fri 15 May 2009 11:07:53 (Bob Heckel)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

@echo off

:: List text files in directory.
:: Must be on same line.
for %%f in (*.txt) do echo %%f


:: Echo words.
for %%w in (foobar baz) do echo %%w


for %%f in (1 2 3) do (
  echo %%f
  echo next one
)
