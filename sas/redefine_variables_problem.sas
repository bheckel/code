options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: redefine_variables_problem.sas
  *
  *  Summary: Example of producing subtle errors by ignoring SAS retain
  *           behavior
  *
  *  Adapted: Thu 08 Nov 2012 12:39:26 (Bob Heckel--Jack Shostak pharma book)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data aes;
  input @1 subject $3.  @5 adverse_event $15.;
  datalines;
101 Headache
102 Rash
102 Fatal MI
102 Abdominal Pain
102 Constipation
  ;
run;

data fatal;
  input @1 subject $3.  @5 death 1.;
  datalines;
101 0
102 0
  ;
run;

data aes;
  merge fatal aes;
  by subject;
  /* DO NOT REDEFINE EXISTING VARIABLES! */
  /* DO NOT REDEFINE EXISTING VARIABLES! */
  /* DO NOT REDEFINE EXISTING VARIABLES! */
  if adverse_event eq "Fatal MI" then death = 1;
run;
title '"bug"';proc print data=_LAST_(obs=max) width=minimum; run;

endsas;
data aes;
  merge fatal aes;
  by subject;
run;
data aes;
  set aes;
  if adverse_event eq "Fatal MI" then death = 1;
run;
title 'normal'; proc print data=_LAST_(obs=max) width=minimum; run;
