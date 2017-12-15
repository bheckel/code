options nosource;
 /*---------------------------------------------------------------------------
  *     Name: getoption.sas
  *
  *  Summary: Demo of the getoption function.
  *
  *  Adapted: Thu 21 Nov 2002 11:02:49 (Bob Heckel -- 
  *                     http://www.sas.com/service/doc/pdf/57743_pg101.pdf)
  * Modified: Thu 19 Dec 2002 11:11:45 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data _NULL_;
  x=getoption('yearcutoff');
  put x=;
  y=getoption('mlogic');
  put y=;
run;


data work.overdue;
  infile cards;
  input item $1-10 +1  checkout mmddyy6. +1  duedate mmddyy6.;
  format checkout duedate mmddyy10.;
  if _N_ = 1 then do;
    yc=getoption('YEARCUTOFF');
    ***if yc ne 1921 then do;
    if yc ne 1920 then do;
      put '*** Year cutoff not 1920';
      ***abort;
      error '*** that is a problem.' yc=;
    end;
  end;
  if today() < duedate then output;
  cards;
LIB0386    040301 050303
LIB0387    040301 071900
LIB0388    123000 013003
LIB0387    040301 071904
  ;
run;
proc print; run;
