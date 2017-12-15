options fullstimer;
proc surveyselect data=SASHELP.shoes out=stacked samprate=1 reps=10; run;

proc print data=_LAST_;
  where region =: 'Af';
run;
endsas;
proc print data=stacked(where=(region =: 'Af'));
run;
