
 /* Add the adjustments in p3b_input to p3a_input, match on hospital and make sure admission in p3a_input
  * is withing the date range of p3b_input
  */
data p3a_input;
  format admission DATE9.;
  infile cards;
  input patient :$6. hospital :$6. @33 admission ANYDTDTE11.;
  cards;
A00001        000001            Jan 31 2006
A00001        000001            Feb 11 2006
A00002        000001            Aug 23 2006
  ;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;

data p3b_input;
  format fromdt todt DATE9.;
  infile cards;
  input hospital :$6. @22 fromdt ANYDTDTE11. @44 todt ANYDTDTE11. adj;
  cards;
000001               Jan 1 2006            Jan 15 2006              1.00
000001               Jan 16 2006           Jun 30 2006              1.01
000001               Jan 31 2006           May 13 2006              0.02
000001               Jul 1 2006            Dec 31 2006              1.05
000002               Jan 1 2006            Aug 17 2006              1.07
000002               Aug 18 2006           Dec 31 2006              1.02
  ;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;

proc sort; by hospital fromdt; run;

proc sql;
  create table p3 as
  select distinct a.hospital, a.patient, b.adj
  from p3a_input a left join p3b_input b on a.hospital=b.hospital
  where fromdt <= admission <= todt
  group by a.hospital, a.patient
  ;
quit;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;
/*
WORK    P3                              

Obs    hospital    patient     adj

 1      000001     A00001     0.02
 2      000001     A00001     1.01
 3      000001     A00002     1.05
*/ 

proc sql;
  create table p3_final as
  select hospital, patient, sum(adj) as adj_tot
  from p3 
  group by hospital, patient
  ;
quit;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;
/* 
WORK    P3_FINAL                        

Obs    hospital    patient    adj_tot

 1      000001     A00001       1.03 
 2      000001     A00002       1.05 
*/
