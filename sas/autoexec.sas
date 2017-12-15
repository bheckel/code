 /*---------------------------------------------------------------------------
  *     Name: autoexec.sas
  *
  *  Summary: Read by ~/bin/sasrun at startup if sas.exe is provided an
  *           '-autoexec autoexec.sas' switch at startup or by magic if this
  *           file is in the same directory from which PC SAS is invoked
  *           (e.g. C:\Program Files\SAS\SAS 9.1\ or
  *                 C:\Program Files\SAS Institute\SAS\V8 )
  *
  *           To control further, use something like this:
  *
  * "d:\SAS Institute\SAS\V8\SAS.EXE" -config "d:\SAS institute\SAS\V8\LGI.cfg" -autoexec "d:\SAS_Programs\lelimsgist.sas" -altlog "d:\SQL_Loader\Logs\LGI.log"
  *
  *  Created: Thu 26 Sep 2002 13:48:46 (Bob Heckel)
  * Modified: Tue 01 Jun 2010 10:59:19 (Bob Heckel)
  *---------------------------------------------------------------------------
  */

  /* TODO do a version check to be able to e.g. use mprintnest if v9 */
options linesize=max pagesize=32767 NOcenter NOdate NOnumber replace
        source NOsource2 notes obs=max errors=3 datastmtchk=allkeywords
        symbolgen mprint mprint mlogic mlogic serror merror 
        NOstimer NOfullstimer compress=no formdlim=' ' formchar='|--+' NOovp
        /*     additional index, merge & sort info */
        /*     ----------                          */
        fmterr msglevel=I printmsglist
        ;
        /* Options like -NOautoecho must be set in sasrun.sh */

 /* Uncomment this for some fireworks... */
 /*** options mautosource; 
      sasautos=('c:/cygwin/home/bheckel/code/sas/') ***/

 /* stimer and fullstimer must be set via the commandline.  They may be
  * ENABLED in this file but without the commandline directives -nostimer and
  * -nofullstimer, they cannot be DISABLED.
  */

 /* Reset just in case */
title; footnote;

%put NOTE: (autoexec.sas): SASROOT is %sysget(SASROOT);
%put NOTE: (autoexec.sas): SASHOME is %sysget(SASHOME);

***%put International Date Format: %SYSFUNC(GETOPTION(DFLANG));
***%put AUTOEXEC: SASAUTOS is set to: %sysfunc(getoption(sasautos));

***libname _ALL_ list;
%put NOTE: (autoexec.sas): WORK lib is:;
libname WORK list;

 /* My (l)ocal (l)ibname for pwd */
libname l '.';

%macro gskonly;
  options ls=209 /*emailsys=VIM emailhost=smtphub.glaxo.com*/;
  /* Can't use gsk lic num b/c they vary */
  /*                   parsfal       */
  %if &SYSSITE ne 0040223003 %then
    %do;
      libname S 's:/sql_loader';
    %end;
%mend;

/***data _null_;***/
/***  call symput ('origmprint', getoption('mprint'));***/
/***  call symput ('origmlogic', getoption('mlogic'));***/
/***  call symput ('origsgen', getoption('sgen'));***/
/***run;***/
/***%gskonly***/
 /* Restore original sas option settings */
/***options &origmprint &origmlogic &origsgen;***/
 /* Can't use %local above for some reason so use this hack for now to avoid
  * polluting code following this 
  */
/***%let origmprint=;***/
/***%let origsgen=;***/

 /* For Vim's foldmethod=marker.  Fold opened in ~/bin/sasrun, closed here. */
/***%put NOTE: }}};***/
