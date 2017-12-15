options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: spedis.sas
  *
  *  Summary: Fuzzy match based on spelling distance
  *
  *  Created: Wed 21 Dec 2016 10:08:11 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data t;
  length string1 $ 15;
  input string1 ;
  penalty = spedis('Friedman', string1);
  datalines;
Friedman
Freedman
Xriedman
Freidman
Friedmann
Alfred
FRIEDMAN
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;



 /* Use a cartesian to check for misspellings etc */
proc sql;
  select subj, h.name as health_name, i.Name as insurance_name
  from demographic as h, insurance as i
  where spedis(health_name, insurance_name) le 25
  ;
quit;
