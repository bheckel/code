 /* Use Data step */
data p1_input;
  infile cards;
  input patientid numerator denominator;
  cards;
4567                 1.4754                     2.9485
1234                 0                          1
1234                 .                          .
1234                 1.4567                     5.3948
4567                 1                         2.1111
4567                 0                          1.3700
2345                 1                          1
3456                 0                          0
1234                 1                          9
  ;
run;

data p1_input;
  set p1_input;

  /* Avoid any "missings propagate" problems */
  array nums _numeric_;
  do over nums;
    if nums eq . then nums=0;
  end;
run;

proc sort data=p1_input;
  by patientid;
run;

data p1(drop= numerator denominator);
  format ratio 8.4;
  set p1_input;
  by patientid;
  
  if first.patientid then do;
    numerator_sum=numerator;
    denominator_sum=denominator;
  end;
  else do;
    numerator_sum+numerator;
    denominator_sum+denominator;
  end;

  if numerator_sum gt 0 and denominator_sum gt 0 then
    ratio = numerator_sum/denominator_sum;

  if last.patientid;
run;


 /* Use Proc */
proc means data=p1_input NOprint;
  class patientid;
  var numerator denominator;
  output out=p1b sum=;
run;

data p1b/*(drop= _:)*/;
  format ratio 8.4;
  set p1b;
  
  if _type_ eq 1;

  ratio = numerator/denominator;
run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;


data p1a_final;
  retain patientid numerator_sum denominator_sum ratio;
  set p1;
run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;

data p1b_final;
  retain patientid numerator denominator ratio;
  set p1b;
  rename numerator=numerator_sum
         denominator=denominator_sum
  ;
run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;
