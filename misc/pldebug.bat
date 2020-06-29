@echo off
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::    Name: pldebug.bat (symlinked as pdb)
::
::  Summary: Run ActiveState Perl with TKDB Debugger.  
::
::           Assumes Tk has NOT been installed under Cygwin.
::           If it has been, just use this command:
::           $ perl -d:ptkdb foo.pl
::
::           Otherwise:
::           Must do it this way in order to have the command line 
::           available during a debugging session (otherwise bash hangs).
::
::           Sample call from Cygwin Bash shell:
::           $ pdb "grget.bat swtest103"
::
::           Assumes  $ ln -s ~/bin/pldebug.bat ~/bin/pdb  has been
::           preconfigured.
::
::  Created: Thu, 21 Dec 2000 15:50:38 (Bob Heckel)
:: Modified: Wed 12 Jun 2002 16:10:28 (Bob Heckel)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

echo Using ActiveState Perl
echo If script is not in PWD, use this form c:/cygwin/home/foo/...

:: If no parameter is passed, exit or this pgm will hang Perl.exe.
if a%1 == a goto bailout

:::set PERLLIB=c:\cygwin\home\bheckel\perllib
set PERLLIB=%HOME%\perllib

:: Hopefully nine is enough.
c:\Perl\bin\perl.exe -d:ptkdb "%1" "%2" "%3" "%4" "%5" "%6" "%7" "%8" "%9"

goto endme

:bailout
echo Must pass a filename as a parameter.  Exiting.
:endme
