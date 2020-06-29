::******************************************************************************
::                       MODULE HEADER
::------------------------------------------------------------------------------
::  PROGRAM NAME:     dpv2.bat
::
::  CREATED BY:       Bob Heckel (rsh86800)
::                                                                            
::  DATE CREATED:     21-Jul-10
::                                                                            
::  PURPOSE:          Run DataPost v2 components
::
::  INPUT:            None
::
::  PROCESSING:       Pass execution to SAS
::
::  OUTPUT:           None
::------------------------------------------------------------------------------
::                     HISTORY OF CHANGE
::-------------+---------+--------------------+---------------------------------
::     Date    | Version | Modification By    | Nature of Modification
::-------------+---------+--------------------+---------------------------------
::  16-Oct-10  |    1.0  | Bob Heckel         | Original. CCF 89125
::-------------+---------+--------------------+---------------------------------
::******************************************************************************
@echo on

if "%COMPUTERNAME%" == "PRTSAWN321" goto ON_DEV
if "%COMPUTERNAME%" == "POKSAWN557" goto ON_TST
if "%COMPUTERNAME%" == "PRTSAWN323" goto ON_PRD
:: else
goto FALLTHRU


:ON_DEV
  set sasexe="D:\SAS Institute\SAS\V8\sas.exe"
  set dpv2root=e:\DataPostArchive\DPv2
  set sascode=%dpv2root%\CODE
  %sasexe% -nosplash -sysin %sascode%\DataPost_Extract.sas -log %sascode%\DataPost_Extract.log -print %sascode%\DataPost_Extract.lst -sysparm "%dpv2root%"
  %sasexe% -nosplash -sysin %sascode%\DataPost_Transform.sas -log %sascode%\DataPost_Transform.log -print %sascode%\DataPost_Transform.lst -sysparm "%dpv2root%"
  goto THE_END


:ON_TST
  set sasexe="D:\SAS Institute\SAS\V8\sas.exe"
  set dpv2root=e:\DataPostArchive\DPv2
  set sascode=%dpv2root%\CODE
  %sasexe% -nosplash -sysin %sascode%\DataPost_Extract.sas -log %sascode%\DataPost_Extract.log -print %sascode%\DataPost_Extract.lst -sysparm "%dpv2root%"
  %sasexe% -nosplash -sysin %sascode%\DataPost_Transform.sas -log %sascode%\DataPost_Transform.log -print %sascode%\DataPost_Transform.lst -sysparm "%dpv2root%"
  goto THE_END


:ON_PRD
  set sasexe="D:\SAS Institute\SAS\V8\sas.exe"
  set dpv2root=\\PRTdsntp032\DataPostArchive\DPv2
  set sascode=%dpv2root%\CODE
  %sasexe% -nosplash -sysin %sascode%\DataPost_Extract.sas -log %sascode%\DataPost_Extract.log -print %sascode%\DataPost_Extract.lst -sysparm "%dpv2root%"
  %sasexe% -nosplash -sysin %sascode%\DataPost_Transform.sas -log %sascode%\DataPost_Transform.log -print %sascode%\DataPost_Transform.lst -sysparm "%dpv2root%"
  goto THE_END


:FALLTHRU
  set sasexe=c:\PROGRA~1\SASINS~1\SAS\V8\sas.exe
  set dpv2root=u:\projects\DPv2
  set sascode=%dpv2root%\CODE
  %sasexe% -nosplash -sysin %sascode%\DataPost_Extract.sas -log %sascode%\DataPost_Extract.log -print %sascode%\DataPost_Extract.lst -sysparm "%dpv2root%"
  %sasexe% -nosplash -sysin %sascode%\DataPost_Transform.sas -log %sascode%\DataPost_Transform.log -print %sascode%\DataPost_Transform.lst -sysparm "%dpv2root%"
  goto THE_END


:THE_END
