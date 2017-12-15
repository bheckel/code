options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: cntlout.sas
  *
  *  Summary: Modify a SAS format.
  *
  *  Adapted: Tue 31 Mar 2009 14:59:04 (Bob Heckel -- SUGI 041-2008)
  *---------------------------------------------------------------------------
  */
options source;

data scaleds;
  input begin $ 1-2 finish $ 5-8 amount $ 10-12;
  datalines;
0   2    1%
5   6    6%
7   8    7%
9   10   9%
11  16   13%
  ;
run;
proc print data=_LAST_(obs=max); run;


 /* Must rename to SAS keywords START, END(optional if no up rng) and LABEL */
 /*                 ___________________________________   */
data ctrl (rename= (begin=START finish=END amount=LABEL));
   set scaleds end=e;
   /*  Mandatory to name the format here */
   retain fmtname 'f_pts';  /* or '$f_pts' if it were character */
   if _N_ eq 1 then
     hlo='l';  /* keyword HLO holding l indicates LOW */
   else if e then 
     hlo='h';  /* keyword HLO holding h indicates HIGH */
   else 
     hlo=' ';
run;
proc print; run;
 	

 /* Use the dataset to build the temporary format */
proc format library=work cntlin=ctrl;
run;

title 'Print the format just created';
proc format library=work FMTLIB; run;

 /* Now edit the format */
proc format cntlout=ctrl_out;
  select F_PTS;
run;

data new_ctrl;
  length LABEL $ 21;
  set ctrl_out end=e;
  output;
  if e then do;
    HLO = ' ';
    START = 3;
    END = 4;
    LABEL = '4% (new)';
    output;
  end;
run;

title 'Print the format just modified';
proc format cntlin=new_ctrl;
  select F_PTS;
run;
