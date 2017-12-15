options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: dups.sas
  *
  *  Summary: Identify duplicate and nonduplicate observations in a data 
  *           set and write each to the appropriate data set.
  *
  *           Strategy: Use FIRST.variable and LAST.variables made available
  *           in BY group processing.
  *
  *           Simple  proc sort NODUPKEY; by foo; run  might be easier if you
  *           don't care about *only* finding dups.
  *
  *  Adapted: Mon, 21 Feb 2000 15:29:43 (Bob Heckel)
  * Modified: Fri 30 Oct 2009 14:59:30 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data work.clasdata;
  /* id is ignored in this example */
  input id name $ c $;
  cards;
3456 Amber Chem101
3456 Amber Math102
3456 Amber Math102
4567 Denise ENGL201
4567 Denise ENGL201
2345 Ginny CHEM101
2345 Ginny ENGL201
2345 Ginny MATH102
1234 Lynn CHEM101
1234 Lynn CHEM101
1234 Lynn MATH102
5678 Rick CHEM101
5678 Rick HIST300
5678 Rick HIST300
  ;
run;
title "Original data";
proc print; run;

 /* Mandatory! */
proc sort; 
  by name c; 
run;

data work.duplicat work.noduplic;
  set work.clasdata;
  by name c;
  /* Compare the values of the FIRST.CLASS and LAST.CLASS variables.
   * Write an observation to work.duplicate or work.noduplic, depending on the
   * outcome of the comparison. 
   */
  if first.c and last.c then 
    output work.noduplic;
  else 
    output work.duplicat;
run;

title "these have only one entry";
proc print data=work.noduplic;
run;

title "these have more than one entry";
proc print data=work.duplicat;
run;


%macro m;
  proc contents data=clasdata out=t(keep= name type); run;
  proc sql NOprint;
    select name into :vnms separated by ','
    from t
    ;
  quit;
  title 'proc sql';
  proc sql;
    select monotonic(), *
    from clasdata
  /***  group by name, c***/
    group by &vnms
    having count(*) gt 1
    order by name
    ;
  quit;
%mend; %m;
