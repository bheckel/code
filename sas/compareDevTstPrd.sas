options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: compareDevTstPrd.sas
  *
  *  Summary: Compare either 2 Oracle tables or 2 SAS datasets
  *
  *  Created: Fri 14 Dec 2007 09:09:19 (Bob Heckel)
  * Modified: Tue 19 Feb 2008 12:04:49 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter ls=180;


 /********** EDIT *********/
%let A=DEV;
/***%let A=TST;***/

%let B=TST;
/***%let B=PRD;***/

%let type=PEC;
/***%let type=spec;***/
 /********** EDIT *********/



%macro m;
  %global tbl vars;

  %if &type eq PEC %then %do;
    %let tbl=pks_extraction_control;
    %let vars=meth_spec_nm meth_var_nm column_nm pks_var_nm;

    libname DEV oracle user=pks password=dev123dba path=usdev388;
    libname TST oracle user=pks_user password=pksu388 path=ustst388;
    libname PRD oracle user=pks_user password=pksu409 path=usprd409;
  %end;
  %else %if &type eq spec %then %do;
    %let tbl=links_spec_file;
    %let vars=stability_samp_product short_meth_nm lab_tst_meth_spec_desc indvl_meth_stage_nm meth_peak_nm spec_group spec_type;

    libname DEV '\\rtpsawn321\d\SQL_Loader\MetaData\';
    libname TST '\\kopsawn557\SQL_Loader\MetaData\';
    libname PRD '\\rtpsawn323\SQL_Loader\MetaData\';
  %end;
%mend;
%m


title "on &A, not on &B";
proc sql;
  create table noton&B as
  select *
  from &A..&tbl
  EXCEPT
  select *
  from &B..&tbl
  ;
quit;
proc sort; by &vars; run;


title "on &A, not on &B";
proc sql;
  create table noton&A as
  select *
  from &B..&tbl
  EXCEPT
  select *
  from &A..&tbl
  ;
quit;
proc sort; by &vars; run;


data nomatch onlyon&B onlyon&A;
  merge noton&B(in=x) noton&A(in=y);
  by &vars;
  if (x + y) eq 1 then output nomatch;
  if (x eq 0 and y eq 1) then output onlyon&B;
  if (x eq 1 and y eq 0) then output onlyon&A;
run;
title "onlyon&B";
proc print data=onlyon&B(obs=max) width=minimum; run;
title "onlyon&A";
proc print data=onlyon&A(obs=max) width=minimum; run;

