
/* HAS_A_READMISSION is 1 in the current admission record if the person has
 * another record with an admission date that is within 30 days after the
 * current record’s discharge date */
data p4a_input;
  format admission_date discharge_date DATE9.;
  infile cards;
  input person_ID :$6. admission_date :DATE. discharge_date :DATE.;
  cards;
A00001 01JUN17 02JUN17
A00001 20JUN17 21JUN17
A00002 01JUN17 01JUL17
A00003 01JAN17 02JAN17
A00003 20JUN17 21JUN17
  ;
run;

proc sort; by person_ID admission_date; run;

data p4(drop=daysgap);
  set p4a_input;
  by person_ID;

  if first.person_ID and last.person_ID then do;
    has_a_readmission = 0;
  end;
  else do;
    daysgap = admission_date - lag(discharge_date);
    put (_all_)(=);
    if daysgap <= 30 then has_a_readmission=1; else has_a_readmission=0;
  end;

  if last.person_ID then output;
run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;
/*
WORK    P4                              

       admission_    discharge_    person_       has_a_
Obs       date          date         ID       readmission

 1     20JUN2017     21JUN2017     A00001          1     
 2     01JUN2017     01JUL2017     A00002          0     
 3     20JUN2017     21JUN2017     A00003          0     
*/
