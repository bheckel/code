options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: on_one_not_other.simple.sql.sas (s/b symlinked as leftjoin.sas)
  *
  *  Summary: Find flight numbers on larger ds that is not on smaller one (and
  *           compare approaches).  LEFT JOIN.
  *
  *           See also sql_vs_merge.sas
  *
  *           Benefits over the datastep:
  *              1- no sorting
  *              2- var names need not be the same
  *
  *           Note: the comma is replaced with "LEFT JOIN":
  *
  *  Created: Mon 17 Apr 2006 12:28:18 (Bob Heckel)
  * Modified: Fri 02 Nov 2007 13:53:46 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter fullstimer;

data work.large;/*{{{*/
  input flight 3. dest num;
  cards; /* {{{ */
132     1739 1111
132     1130 1111
        1983 2222
271     1410 2222
622     1433 2222
622     1352 2222
132     1390 1111
100     6666 3333
  ; 
  /* }}} */
run;
proc print data=_LAST_(obs=max); run;


data work.small;
  input flight  word $  zip;
  cards; /* {{{ */
132     bobh     07090
132     bobi     27613
271     bobj     27613
999     bohk     27613
000     bobl     27613
  ; 
  /* }}} */
run;
proc print data=_LAST_(obs=max); run;
/*}}}*/


 /* same for all of the next 3 

  flight
--------
       .
     100
     622
     622
 */
title 'SQL - IS NULL';
proc sql;
  select a.flight
  from large a LEFT JOIN small b  ON a.flight=b.flight
  where b.flight IS NULL
  ;
quit;


title 'same - SQL - WHERE NOT';
proc sql;
  select flight
  from large
  where not (flight in(select flight
                       from small))
  ;
quit;


title 'same - SAS sort-sort-merge-in';
proc sort data=large; by flight; run;
proc sort data=small; by flight; run;
data foo;
  merge large(in=inl) small(in=ins);
  by flight;
  if inl and not ins;
run;
proc print data=_LAST_(obs=max); var flight; run;





  /* vim: set foldmethod=marker: */ 
