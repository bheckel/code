options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: dynamic_fileexist_quarters.sas
  *
  *  Summary: Dynamically determine which files to use based on current
  *           quarter and how many years back to start from.
  *
  *           Better?
  *           data _null_; mycurrentquarter = floor((mynumericmonth-1)/3)+1; put mycurrentquarter=; run;
  *           data _null_; mycurrentquarter = floor((month(date())-1)/3)+1; put mycurrentquarter=; run;
  *
  *  Created: Wed 09 Jul 2008 12:32:18 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter NOmlogic NOsgen;

%let DIRROOT = &HOME\projects\datapost\tmp\ADVAIR_HFA;
%let INPAEROS = &DIRROOT\INPUT_DATA_FILES\AEROSOL SAMPLING SYSTEM;

%macro qtrs;
  %local q y;

  %let thisyr = %sysfunc(year("&SYSDATE"d));
  %let minyr = %eval(&thisyr-3);
  %put _all_;

  %do y=&minyr %to &thisyr;
    %do q=1 %to 4;
      %if %sysfunc(fileexist("&INPAEROS/asampext_Q&q.&y..csv")) %then %do;
        %put !!! asampext_Q&q.&y..csv;
      %end;
    %end;
  %end;
%mend;
%qtrs;
