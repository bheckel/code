options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sql_innerjoin.sas
  *
  *  Summary: Demo of using an inner join (NOT a left inner join which is a
  *           syntax error).  The INNER JOIN returns all rows from both tables
  *           where there is a match.
  *
  *           Records from 2 tables are combined and added to the qry results
  *           only if the values of the joined fields meet certain specified
  *           criteria.
  *
  *           See sql_outerjoin.sas
  *
  *  Created: Thu 03 Apr 2003 19:42:02 (Bob Heckel)
  * Modified: Tue 23 Jun 2009 14:02:40 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data work.large;
  input flight 3. dest num;
  cards;
132     1739 1111
132     1478 1111
132     1130 1111
132     1390 1111
        1983 2222
622     1124 2222
271     1410 2222
        1777 2222
622     1433 2222
622     1352 2222
100     6666 3333
  ;
run;
title 'large';
proc print data=_LAST_(obs=max); run;


data work.small;
  input flight  word $  zip;
  cards;
132     bobh     07090
132     bobi     27613
271     bobj     27613
999     bohk     27613
000     bobl     27613
  ;
run;
title 'small';
proc print data=_LAST_(obs=max); run;


title 'from large A INNER JOIN small B on flight';
proc sql NUMBER;
  /* For each match on large, repeat it as many times as you find it here.
   * So for 132, repeat the large pieces 4 times (3 in each, or 12) since
   * there are 4 132's on large and 3 132's on small.
   */
  select A.flight, B.zip, B.flight
  from large as A INNER JOIN small as B ON A.flight = B.flight
  ;
quit;

title 'from small A INNER JOIN large B on flight (no difference)';
proc sql NUMBER;
  /* For each match on large, repeat it as many times as you find it here.
   * So for 132, repeat the large pieces 4 times (3 in each, or 12) since
   * there are 4 132's on large and 3 132's on small.
   */
  select A.flight, A.zip, B.flight
  from small as A INNER JOIN large as B ON A.flight=B.flight
  ;
quit;


title 'from large A, small B WHERE flight (no difference)';
proc sql NUMBER;
  /* For each match on large, repeat it as many times as you find it here.
   * So for 132, repeat the large pieces 4 times (3 in each, or 12) since
   * there are 4 132's on large and 3 132's on small.
   */
  select A.flight, B.zip, B.flight
  from large A, small B
  WHERE A.flight=B.flight
  ;
quit;


title 'COMPARE - from large A LEFT JOIN small B on flight';
proc sql NUMBER;
  select A.flight, B.zip, B.flight
  from large as A LEFT JOIN small as B ON A.flight = B.flight
  ;
quit;
