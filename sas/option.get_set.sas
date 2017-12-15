
%macro getoption(option) ;
  %sysfunc(getoption(&option))
%mend getoption ;


%macro getandset(option,value) ;
  %* make macro variable available outside this macro program ;
  %global _old_&option ;
  %* assign the current value of the option to a new macro variable ;
  %let _old_&option=%getoption(&option) ;
  * set the option to its new value ;
  options &option=&value ;
%mend getandset ;


%macro reset(option) ;
  %* if there is no value then exit ;
  %* set the option to its old value ;
  options &option=&&_old_&option ;
  * delete the macro variable ;
  %symdel _old_&option ;
%mend reset ;


%getandset(validvarname,any) ;
%put Current option=%getoption(validvarname);
%put _old_validvarname=%superq(_old_validvarname) ;

%reset(validvarname)
%put Current option=%getoption(validvarname);
