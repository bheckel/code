options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: autocall.sas
  *
  *  Summary: Predefined SAS macro library
  *
  *           Look in SAS Log header (when my autoexec.sas is being used) to
  *           determine SASROOT.
  *
  *           Then copy a macro e.g. test.sas into "!sasroot\core\sasmacro\"
  *
  *  /cygdrive/c/Program\ Files/SAS\ Institute/SAS/V8/core/sasmacro
  *
  *           %macro Test;
  *             %put hello;
  *           %mend;
  *
  *           To permanently modify your SAS installation, insert your path
  *           into the list -SET SETAUTOS in C:/Program Files/SAS/SAS
  *           9.1/nls/en/SASV9.CFG or
  *
  *  /cygdrive/c/Program\ Files/SAS\ Institute/SAS/V8/SASV8.CFG
  *  E.g.
  *  -SET SASAUTOS  ( "d:\Auto_Call" ...
  *
  *           See my autoexec.sas for another approach.
  *
  *           For that approach the system options MAUTOSOURCE
  *           must be set and SASAUTOS must be assigned. MAUTOSOURCE enables
  *           the autocall facility, and SASAUTOS specifies the autocall
  *           libraries.
  *           E.g.  options mautosource sasautos='.';
  *
  *
  *  Created: 14-Jan-2006 (Bob Heckel)
  * Modified: 03-Aug-2023 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;
options sasautos=('\\hq\root\dept\kmc\roion\test\src\macros' '\\hq\root\dept\kmc\roion\prod\src\macros' SASAUTOS);

%Test
