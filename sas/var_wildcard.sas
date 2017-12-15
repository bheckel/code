data Rawclaims_MT;
  fName='bob';
  mName='stu';
  lName='heckel';
  ignored='string';
  output;
run;

proc sql ;
  select distinct name into :vars separated by ' '
  from dictionary.columns
  /* Case sensitive!  And memname is always uppercase */
  where memname eq 'RAWCLAIMS_MT' and name like '%Name%'
  ;
quit;
proc print data=_LAST_(obs=max); var &vars; run;



endsas;
 /* Reset all formats */
data l.all_meths(drop=result rename=(resultn=result));
  set l.all_meths;
  format _all_;
run;
proc sql NOprint;
  select distinct name into :datevars separated by ' '
  from dictionary.columns
  where memname eq 'ALL_METHS' and name like '%date%'
  ;
quit;
proc sql NOprint;
  select distinct name into :datetimevars separated by ' '
  from dictionary.columns
  where memname eq 'ALL_METHS' and name like '%Date%'
  ;
quit;
data l.all_meths;
  format &datevars DATE9. &datetimevars DATETIME16.;
  set l.all_meths;
run;
proc contents;run;
