 /*----------------------------------------------------------------------------
  *   Name: random.sas
  *
  *  Summary: Demo of randomizing a dataset.  Also see point.sas to get every
  *           other observation.
  *
  *           See also (better?): proc_surveyselect.sas
  *
  *           For X obs by Y vars see build_dummy_ds_100_random_variables.sas
  *
  *  Created: Fri Apr 30 1999 15:37:03 (Bob Heckel)
  * Modified: Fri 26 Jan 2018 15:25:50 (Bob Heckel)
  *----------------------------------------------------------------------------
  */

data _null_;
  call streaminit(12345);  /* same rand each run */
  x=rand('NORMAL',70,10);
  put x=;
run;



data a;
  a = ranuni(7); output;
  a = ranuni(7); output;
  a = ranuni(7); output;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

 /* Same output - ranuni uses 7 as seed no matter what */
data b (drop = i);
  do i=7 to 9;
    b = ranuni(i);
    output;
  end;
run;
proc print data=_LAST_(obs=max) width=minimum; run;



data work.tmp;
  input mydept $  mydate mmddyy8.;
  cards;
ADM10 06/01/96
ADM11 06/22/97
ADM13 06/22/97
ADM18 05/02/97
ADM19 06/12/97
ADM14 06/17/97
ADM12 06/08/97
ADM13 06/08/97
ADM14 06/08/97
ADM15 06/08/97
ADM16 06/08/97
ADM107 06/08/97
ADM108 06/08/97
ADM109 06/08/97
ADM110 06/08/97
ADM111 06/08/97
ADM112 06/08/97
ADM113 06/08/97
ADM114 06/08/97
ADM115 06/08/97
ADM116 06/08/97
ADM117 06/08/97
;
run;
proc print data=work.tmp; 
  format mydate worddate15.;
run;

title 'Simple sample of about 10% of the obs';
data work.tenpct;
  set work.tmp;
  if uniform(0) le .10;
run;
proc print data=work.tenpct; run;


title 'Do surprise inspection on days between 1 and 15th days of mo.';
data work.inspect (keep=mydept date2);
  set work.tmp;
  dayt = ceil(ranuni(0) * 15);
  date2 = mdy(06, dayt, 97);
run;
proc print data=work.inspect; 
  format date2 worddate15.;
run;


data _NULL_;
  /* Same random number between 0 and 1 each time. */ 
  ***x=ranuni(42);
  ***put x=;
  /* Different random number between 0 and 1 each time.  Uses system time as
   * the seed.
   */ 
  x=ranuni(-1);
  y=uniform(-1);
  put x=;
  put y=;
run;


data case;
  retain Seed_1 Seed_2 Seed_3 45;
  do i=1 to 10;
     call ranuni(Seed_1,X1);
     call ranuni(Seed_2,X2);
     X3=ranuni(Seed_3);
     if i=5 then
        do;
           Seed_2=18;
           Seed_3=18;
        end;
     output;
  end;
run;

proc print;
  id i;
  var Seed_1-Seed_3 X1-X3;
run;
