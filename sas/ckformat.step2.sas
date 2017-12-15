options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: ckformat.step2.sas
  *
  *  Summary: Verify totals using the "structure files"
  *
  *           Must run ckformat.step1.sas first and paste into the proc format
  *           block!!!!!
  *
  *           ___CHECK FORMATS___
  *
  *  Created: Thu 24 Feb 2005 11:41:15 (Bob Heckel)
  *  Created: Mon 04 Apr 2005 15:18:25 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter NOcenter mlogic mprint sgen NOovp NOreplace;

 /****** Edit ******/
%let E=%upcase(fet);
%let Y=2003;
%let D=minew;
%let V=td;
%let F=$V007A.;
 /* Toggle */
%let REV=R;
***%let REV=;
 /* Toggle */
%let REVISER=%str(if revtype eq 'NEW');
***%let REVISER=;
 /* Toggle */
%let REVTYPE=revtype;
***%let REVTYPE=;
 /* Toggle */
***%let ALIAS=%str(if alias eq 1 then delete);
%let ALIAS=;
 /* Toggle */
***%let VOID=%str(if void eq '1' then delete);
%let VOID=;
 /* For now, toggle the data tmp keep stmt below */
 /****** Edit ******/


libname L "/u/dwj2/mvds/&E/&Y";
***libname L "DWJ2.&E.&Y..MVDS.LIBRARY.NEW" DISP=SHR WAIT=1; /* closed yrs! */

  /* Obtained via cut 'n' paste from ckformat.step1.sas.  Don't include the
   * 'lib=FMTL part!
   */
proc format;
value $V007A
OTHER = "006 ***INVALID"
"0000"  - "0000" = "001 Midnight (0000)"
"0001"  - "0059" = "002 AM (0001-1159)"
"0100"  - "0159" = "002 AM (0001-1159)"
"0200"  - "0259" = "002 AM (0001-1159)"
"0300"  - "0359" = "002 AM (0001-1159)"
"0400"  - "0459" = "002 AM (0001-1159)"
"0500"  - "0559" = "002 AM (0001-1159)"
"0600"  - "0659" = "002 AM (0001-1159)"
"0700"  - "0759" = "002 AM (0001-1159)"
"0800"  - "0859" = "002 AM (0001-1159)"
"0900"  - "0959" = "002 AM (0001-1159)"
"1000"  - "1059" = "002 AM (0001-1159)"
"1100"  - "1159" = "002 AM (0001-1159)"
"1200"  - "1200" = "003 Noon (1200)"
"1201"  - "1259" = "004 PM (1201-2359)"
"1300"  - "1359" = "004 PM (1201-2359)"
"1400"  - "1459" = "004 PM (1201-2359)"
"1500"  - "1559" = "004 PM (1201-2359)"
"1600"  - "1659" = "004 PM (1201-2359)"
"1700"  - "1759" = "004 PM (1201-2359)"
"1800"  - "1859" = "004 PM (1201-2359)"
"1900"  - "1959" = "004 PM (1201-2359)"
"2000"  - "2059" = "004 PM (1201-2359)"
"2100"  - "2159" = "004 PM (1201-2359)"
"2200"  - "2259" = "004 PM (1201-2359)"
"2300"  - "2359" = "004 PM (1201-2359)"
"9999"  - "9999" = "005 Not Classifiable (9999)"
;
run;

data tmp;
  format &V &F;
  /* TODO */
  ***set L.&D (keep=&V void) end=e;
  set L.&D (keep=&V &REVTYPE) end=e;
  &ALIAS; 
  &VOID;
  &REVISER;
run;

proc freq data=tmp;
  table &V / nocum missing;
  ***table age*marital / nocum norow nocol nopct;
run;


  /* vim: set foldmethod=marker: */ 
