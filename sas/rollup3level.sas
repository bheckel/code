options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: rollup3level.sas
  *
  *  Summary: Roll 4 (and higher) character codes into 3.  Originally used by 
  *           UC3ROLLUP.sas
  *
  *  Created: Tue 21 Sep 2004 15:31:02 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

options NOcenter;

libname MVDS1 "DWJ2.MED2001.MVDS.LIBRARY.NEW" DISP=SHR;

proc print data=MVDS1.caNEW; where acme_uc eq: 'Y'; run;


 /* We don't care what comes after the 3rd char. */
data tmp;
  set MVDS1.caNEW (keep=acme_uc);
  acme_uc=substr(acme_uc, 1, 3);
run;

proc sql;
  create table rolledintothrees as
  select acme_uc, count(acme_uc) as acme_uc_cnt 
  from tmp
  where acme_uc like 'Y__'
  group by acme_uc
  ;
quit;
proc print data=_LAST_; run;
