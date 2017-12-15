options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: count_into_mvar.sas
  *
  *  Summary: Use SAS macro to count observations.
  *
  *  Created: Tue 01 Jun 2004 16:21:21 (Bob Heckel)
  * Modified: Wed 24 Jun 2009 09:52:54 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source mprint mlogic sgen;

data tmp;
  input revstate $;
  cards;
AL
CA
CA
MT
  ;
run;

proc sql NOPRINT;
  /* Won't work, gives 4 */
  /***   select distinct count(revstate) into :CNT ***/
  select count(distinct revstate) into :CNT
  from tmp
  ;
quit;
%put !!!&CNT;
%put &SQLOBS;  /* s/b 1 - this qry returns 1 row */
%put &SQLRC;
%put &SQLOOPS;

***%put !!! %trim(&CNT);
 /* or */
%macro x;
  %let CNT=%left(%trim(&CNT));
%mend;
%x;
%put !!!&CNT;



 /* Compare */

data _null_;
  set tmp end=e;
  if e then
    do;
      call symput('CNT2', _n_);
      /* Prettier, makes &CNT3 ' 4' */
      call symput('CNT3', put(_n_, 2.));
    end;
run;
%put !!!&CNT2;
%put !!!&CNT3;
