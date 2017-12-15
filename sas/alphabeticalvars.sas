options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: alphabeticalvars.sas
  *
  *  Summary: Reorder variables in a dataset alphabetically.
  *
  *  Adapted: Fri 04 Jun 2004 16:13:37 (Bob Heckel -- 'You Could Look It Up
  *                                     SUGI Michael Davis)
  *---------------------------------------------------------------------------
  */
options source;

data tmp;
  zebra=5; alpha="betical"; cat=9; beta="cal";
  output;
run;
proc print data=_LAST_; run;

proc sql NOPRINT;
  select name into :vars separated by ', '
  from dictionary.columns
  /* Case sensitive!  Generally uppercase I think */
  where libname eq 'WORK' and memname eq 'TMP'
  order by name
  ;

  create table tmp as
  select &vars
  from tmp
  ;
quit;

proc print data=tmp; run;
