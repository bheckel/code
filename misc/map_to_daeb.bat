::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::     Name: map_to_daeb.bat
::
::  Summary: Map a free drive to /tmp on daeb so that Vitalnet output files
::           can be used under Windows.
::
::           Assumption is that drives Y: or S: will probably be free on the
::           statitician's machines, based on the way CDC normally configures
::           Windows boxes.
::
::           TODO allow user to pass in the directory letter to map
::           TODO allow more drive letter tries (modular design required)
::           TODO replace this whole thing with a VB app that detects free
::                drives
::
::  Created: Tue 02 Jul 2002 10:32:20 (Bob Heckel)
:: Modified: Fri 05 Jul 2002 12:41:55 (Bob Heckel -- must hardcode daeb IP 
::                                     address)
:: Modified: Mon 22 Jul 2002 08:18:05 (Bob Heckel -- change login message)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
@echo off

:: These letters are highly likely to be free on CDC machines.
set drive1=Y:
set drive2=S:
:: The file that uniquely identifies \\daeb to avoid being fooled by another
:: share that may have been mapped to Y:
set markerfile=VITALNET_OUTPUT_FOLDER.txt
:: The directory setup for Vitalnet output only.
set explorer_dir=vitalnet_output
set ignore_pw_msg=NO PASSWORD REQUIRED.  Simply press enter if prompted for a password
set waiting_msg=Please wait ... mapping drive

:: This will almost never be used since most people are going to doubleclick a
:: shortcut instead of running from the command line.
if "%1" == "-h" goto usage
if "%1" == "--help" goto usage

:: Start with the preferred drive.  Is it already mapped?
goto is_d1_mapped


:::::::::
:: Does the user have Y: mapped to daeb or any other machine?
:is_d1_mapped
  if exist %drive1% goto is_daeb_drive_d1
  if not exist %drive1% goto d1_is_available
exit

:: Prove the user is mapped to OUR daeb machine.  This assumes that
:: the file Y:/DO_NOT_DELETE exists as a marker on \\daeb.
:is_daeb_drive_d1
  if exist %drive1%\%explorer_dir%\%markerfile% goto d1_is_available
  :: Can't use drive1, someone else got to it before we did.
  if not exist %drive1%\%explorer_dir%\%markerfile% goto is_d2_mapped
exit

:d1_is_available
  :: So map it.  But don't try to map an already mapped drive.
  if not exist %drive1% goto do_map_d1
  if exist %drive1% goto do_not_map_d1
exit

:do_map_d1
  echo %waiting_msg% %drive1%
  echo %ignore_pw_msg%
  net use %drive1% \\158.111.250.128\public /persistent:no *
  explorer %drive1%\%explorer_dir%
exit

:do_not_map_d1
  explorer %drive1%\%explorer_dir%
exit
:::::::::

:::::::::
:: If we get here, we know Y: is already in use but it's not daeb's Y:, so
:: let's try X:
:is_d2_mapped
  if exist %drive2% goto is_daeb_drive_d2
  if not exist %drive2% goto d2_is_available
exit

:is_daeb_drive_d2
  if exist %drive2%\%explorer_dir%\%markerfile% goto d2_is_available
  if not exist %drive2%\%explorer_dir%\%markerfile% goto failed_to_map
exit

:d2_is_available
  :: So map it.  But don't try to map an already mapped drive.
  if not exist %drive2% goto do_map_d2
  if exist %drive2% goto do_not_map_d2
exit

:do_map_d2
  echo %waiting_msg% %drive2%
  echo %ignore_pw_msg%
  net use %drive2% \\158.111.250.128\public /persistent:no *
  explorer %drive2%\%explorer_dir%
exit

:do_not_map_d2
  explorer %drive2%\%explorer_dir%
exit
:::::::::

:failed_to_map
  echo Tried unsuccessfully to map drives %drive1% and %drive2%
  echo You'll have to run this command 'net use %drive2% \\158.111.250.128\public /persistent:no *'
  echo using a free drive letter on your machine (i.e. replacing T with your free
  echo drive letter).  Or contact LMITHELP@cdc.gov for assistance.
  pause
exit

:usage
  echo Usage: map_to_daeb [-h]
  echo                     -h  This help message
  echo        Attempts to map a Unix directory to your Windows machine then
  echo        open Windows Explorer.
  echo        Will try mapping %drive1% first, then %drive2% if %drive1% was unsuccessful.
  echo        If you are already using drives %drive1% and %drive2% it will quit with a message.
  echo        If you have already mapped to \\158.111.250.128, it will simply open a 
  echo        Windows Explorer window in the %explorer_dir% directory
  echo        From there you can print, save, etc. as you normally would with
  echo        normal Windows files.
  echo        Contact LMITHELP@cdc.gov for further assistance
exit
