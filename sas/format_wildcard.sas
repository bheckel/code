options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: format_wildcard.sas
  *
  *  Summary: Wildcarding the format statement.
  *
  *  Created: Mon 24 May 2004 16:45:46 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data tmp;
  set SASHELP.citiwk;
  format WS: dollar6.1;
run;

proc print data=_LAST_; run;



data Rawclaims_MT;
  fName='bob                                                ';
  mName='stu';
  lName='heckel';
  ignored='string';
  output;
run;
proc contents;run;

proc sql ;
  select distinct name into :vars separated by ' $40. '
  from dictionary.columns
  /* Case sensitive!  And memname is always uppercase */
  where memname eq 'RAWCLAIMS_MT' and name like '%Name%'
  ;
quit;

data RAWCLAIMS_MT;
  set RAWCLAIMS_MT;
  /* for trailing var */
  /*           ___    */
  format &vars $40.;
run;
proc contents;run;
