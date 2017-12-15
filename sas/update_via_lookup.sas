options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: update_via_lookup.sas
  *
  *  Summary: Update a master table with the contents of a lookup table 
  *           where data is missing and keys are duplicated in the master
  *           table.  Using one SQL and three SAS approaches.
  *
  *  Created: Thu 04 Aug 2005 16:40:17 (Bob Heckel)
  * Modified: Fri 11 Oct 2013 15:13:08 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data sched(drop=ignoreme);
  input ignoreme 3.  +5  dt date7.  +2  dest $3.  +3  flight 4.;
  informat dt date7.;
  cards;
132     01MAR94  USA   1739
132     01MAR94        2478
        01MAR94  GER   3222
622     02MAR94  FRA   2478
271     07MAR94        1739
        07MAR94  PAR   8777
622     07MAR94  WTF   9433
622     07MAR94  WTF   1035
  ;
run;
title 'sched'; proc print data=_LAST_(obs=max); run;


 /* dest is lowercased to prove that these are being used to replace
  * existing values each time s.flight is the same as l.flight.
  */
data lookuphere;
  input dest $3.  flight;
  cards;
usa   1739
fra   2478
ger   3222 
non   9999
  ;
run;
title 'lookuphere'; proc print data=_LAST_(obs=max); run;


 /* Approach #1 */

title 'BEST.  SQL - dest is filled as needed by the lookup table';
proc sql;
  UPDATE sched s
  /* use lookuphere's l.dest if matching dest is available... */ 
  SET dest = COALESCE( (SELECT DISTINCT l.dest
                        FROM lookuphere l
                        WHERE s.flight=l.flight), 
  /*                    ...otherwise leave as is, s.dest      */
                        s.dest )
  ;
quit;
proc print data=sched(obs=max); run;



 /* Approach #2 */

 /* Restore sched */
data sched(drop=ignoreme);
  input ignoreme 3.  +5  dt date7.  +2  dest $3.  +3  flight 4.;
  informat dt date7.;
  cards;
132     01MAR94  USA   1739
132     01MAR94        2478
        01MAR94  GER   3222
622     02MAR94  FRA   2478
271     07MAR94        1739
        07MAR94  PAR   8777
622     07MAR94  WTF   9433
622     07MAR94  WTF   1035
  ;
run;

title 'SAS split-sort-sort-merge - dest is filled as needed by the lookup table';
data destmiss destfilled;
  set sched;
  if dest eq '' then 
    output destmiss;
  else 
    output destfilled;
run;

proc sort data=lookuphere NODUPKEY; by flight; run;
proc sort data=destmiss; by flight dest; run;

data patchedmiss;
  merge destmiss(in=in1) lookuphere(in=in2);
  by flight;
  if in1;
run;

data sched; 
  /* Concatenate the ones that were ok originally with what was filled
   * (patched) using the lookup table.
   */
  set destfilled patchedmiss; 
run;
proc print data=_LAST_(obs=max); run;



 /* Approach #3 */

title 'dest is filled as needed by proc format lookup';

 /* Restore sched */
data sched(drop=ignoreme);
  input ignoreme 3.  +5  dt date7.  +2  dest $3.  +3  flight 4.;
  informat dt date7.;
  cards;
132     01MAR94  USA   1739
132     01MAR94        2478
        01MAR94  GER   3222
622     02MAR94  FRA   2478
271     07MAR94        1739
        07MAR94  PAR   8777
622     07MAR94  WTF   9433
622     07MAR94  WTF   1035
  ;
run;

data formats;
  set lookuphere(rename=(flight=START dest=LABEL));
  FMTNAME = 'f_look';
run;

proc format cntlin=formats; run;
proc format library=WORK FMTLIB; run;

data sched;
  set sched;
  if dest eq '' then dest=put(flight, f_look.);
run;
proc print data=_LAST_(obs=max) width=minimum; run;



 /* Approach #4 */

title 'update statement';

 /* Restore sched */
data sched(drop=ignoreme);
  input ignoreme 3.  +5  dt date7.  +2  dest $3.  +3  flight 4.;
  informat dt date7.;
  cards;
132     01MAR94  USA   1739
132     01MAR94        2478
        01MAR94  GER   3222
622     02MAR94  FRA   2478
271     07MAR94        1739
        07MAR94  PAR   8777
622     07MAR94  WTF   9433
622     07MAR94  WTF   1035
  ;
run;
proc sort; by flight; run;

data sched;
  update sched lookuphere;
  by flight;
run;
title 'surprisingly fails until we remove duplicate flight keys or do a hack like 
Approach 2 (but we do get a Log WARNING)';
proc print data=_LAST_(obs=max) width=minimum; run;

