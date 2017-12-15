options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: delete.sql.sas
  *
  *  Summary: Comparison of deletes under SAS vs. proc sql.
  *
  *  Created: Tue 08 Jun 2004 13:01:32 (Bob Heckel)
  * Modified: Mon 28 Jan 2008 10:04:45 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source fullstimer;

%macro oradel(slist);
  %let oraid=pks;
  %let orapsw=dev123dba;
  %let orapath=usdev388;
  proc sql;
    CONNECT TO ORACLE(USER=&oraid ORAPW=&orapsw BUFFSIZE=5000 PATH="&orapath");
      EXECUTE (DELETE FROM tst_rslt_summary WHERE samp_id in(&slist)) BY ORACLE;
      EXECUTE (DELETE FROM indvl_tst_rslt WHERE samp_id in(&slist)) BY ORACLE;
      EXECUTE (DELETE FROM stage_translation WHERE samp_id in(&slist)) BY ORACLE;
      EXECUTE (DELETE FROM samp WHERE samp_id in(&slist)) BY ORACLE;
      EXECUTE (DELETE FROM tst_parm WHERE samp_id in(&slist)) BY ORACLE;
      %if &SQLXRC ^= 0 %then %do;
        %put &SQLXRC;
        %put &SQLXMSG;
        %let HSQLXRC = &SQLXRC;
        %let HSQLXMSG = &SQLXMSG;
      %end;
    DISCONNECT FROM ORACLE;
  quit;
%mend;
%oradel(188400)
%put _all_;



data tmp; set SASHELP.shoes; if Region in:('A', 'E'); run;

 /* Delete one single existing record: */
proc sql;
  delete from tmp
  where Region eq 'Africa' and Product eq 'Boot' and Subsidiary like 'Addis%'
  ;
quit;
title 'proc sql';
proc print data=_LAST_; where Region eq: 'A'; run;

data tmp;
  set tmp;
  if Region eq 'Africa' and Product eq 'Boot' and Subsidiary eq: 'Addis' then
    delete;
run;
title 'traditional SAS';
proc print data=_LAST_; where Region eq: 'A'; run;



data tmp2; set SASHELP.shoes; if Region in:('A', 'E'); run;

 /* Delete all records: */
proc sql;
  delete from tmp2
  ;
quit;

