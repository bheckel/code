options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sql_fulljoin.sas
  *
  *  Summary: Demo of using a FULL JOIN - an INNER JOIN that has been augmented
  *           with rows in either table that are not in the other table.
  *
  *  Created: Thu 22 Jun 2006 13:11:52 (Bob Heckel)
  * Modified: Mon 04 Mar 2013 14:31:45 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data work.large;
  input flight 3. dest num;
  cards;
132     1739 1111
132     1130 1111
132     1390 1111
        1983 2222
271     1410 2222
        1777 2222
622     1234 2222
622     5678 2222
100     6666 3333
  ;
run;
title 'large';
proc print data=_LAST_(obs=max); run;


data work.small;
  input flight  zip;
  cards;
132        07090
132        27613
271        27613
999        27613
  ;
run;
title 'small';
proc print data=_LAST_(obs=max); run;


 /* INNER keyword optional */
title 'from large A INNER JOIN small B (on flight)';
proc sql NUMBER;
  select *
  from large a INNER JOIN small b on a.flight=b.flight
  ;
quit;


title 'from large A FULL JOIN small B (on flight)';
proc sql NUMBER;
  select *
  from large a FULL JOIN small b on a.flight=b.flight
  ;
quit;


proc sort data=large; by flight; run;
proc sort data=small; by flight; run;
data t;
  merge large small;
  by flight;
run;
title 'compare with SAS merge (by flight)'; proc print data=_LAST_(obs=max) width=minimum; run;



endsas;
/* Differences */
proc sql;
create table t as
  select a.cardholderid, a.patientid, a.lastname, a.firstname, b.cardholderid, b.lastname, b.firstname, b.patientid as aid
  from bmatch a full join kmatch b on a.cardholderid=b.cardholderid
  where (a.patientid is null or aid is null) or (a.patientid^=b.patientid)
  ;
quit;
