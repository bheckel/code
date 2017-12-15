options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: MKEMPTY.sas
  *
  *  Summary: Make sure all 57 states are represented in MVDS lib.
  *
  *  Created: Tue 31 Aug 2004 10:02:44 (Bob Heckel)
  * Modified: Wed 18 Jul 2012 13:15:08 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* Purge records of existing ds */
data l.ods_0111e_sd;
  set l.ods_0111e_sd;
  delete;
run;


 /* Datastep - New empty ds using a real one as template */
options obs=0;
data emptyshoes;
  set sashelp.shoes;
run;
options obs=max;


 /* SQL - New empty ds using a real one as template */
proc sql;
  create table emptyshoes2 as
  select *
  from SASHELP.shoes
  where 0
  ;
quit;
proc contents; run;


 /* Default lengths may be too small */
data t;
  c1 = '';
  c2 = '';
  n1 = .;
run;
proc contents; run;

 /* Better */
data t2;
  length t $5;
run;
proc contents; run;


 /* Most control */
data t3;
  input one $3.
        two $20.
        three 8.
        four $8.
        mydate 8.
        ;
  format mydate MMDDYY10.;
  datalines;
  ;
run;
proc contents; run;


endsas;
%let EVT=MED;
libname LPREV "DWJ2.&EVT.2003.MVDS.LIBRARY.NEW" DISP=OLD;
***libname LCURR "DWJ2.&EVT.2004.MVDS.LIBRARY.NEW" DISP=OLD;
libname LCURR 'BQH0.SASLIB' DISP=OLD;


%macro ForEach(s);
  %local i f;

  %let i=1;
  %let f=%scan(&s, &i, ' '); 

  %do %while ( &f ne  );
    %let i=%eval(&i+1);
    /*..............................................................*/
    /* Using AKNEW as template only b/c we know it exists already. */
    data LCURR.&f;
      set LPREV.AKNEW (obs=0);
    run;
    /*..............................................................*/
    %let f=%scan(&s, &i, ' '); 
  %end;
%mend ForEach;
%ForEach(AKNEW ALNEW ARNEW ASNEW AZNEW CANEW CONEW CTNEW DCNEW DENEW 
         FLNEW GANEW GUNEW HINEW IANEW IDNEW ILNEW INNEW KSNEW KYNEW
         LANEW MANEW MDNEW MENEW MINEW MNNEW MONEW MPNEW MSNEW MTNEW
         NCNEW NDNEW NENEW NHNEW NJNEW NMNEW NVNEW NYNEW OHNEW OKNEW
         ORNEW PANEW PRNEW RINEW SCNEW SDNEW TNNEW TXNEW UTNEW VANEW
         VINEW VTNEW WANEW WINEW WVNEW WYNEW YCNEW);
