options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: varexist.sas
  *
  *  Summary: Check if a variable exists in a dataset.
  *
  *  Created: Fri 18 Feb 2005 13:05:35 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

%let NAME=;

data t; 
  do i=1 to 10; 
    lname='foo'; mname='bar'; output; 
  end; 
run;

proc print data=_LAST_(obs=max); run;

proc sql NOPRINT;
  select name into :NAME
  from dictionary.columns 
  /* Case sensitive! */
  where libname eq 'WORK' and memname eq 'T' and name eq 'lname'
  ;
quit;

%macro VarExist;
  %if &NAME ne  %then
    %do;
      %put !!!var exists;
    %end;
  %else %then
    %do;
      %put !!!var does not exist;
    %end;
%mend VarExist;
%VarExist
