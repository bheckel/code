 /*---------------------------------------------------------------------------
  *     Name: label.sas
  *
  *  Summary: Descriptive label for dataset (viewed via proc contents) or 
  *           for variables.
  *
  *  Created: Fri, 12 Nov 1999 14:46:02 (Bob Heckel)
  * Modified: Thu 10 Sep 2009 14:43:40 (Bob Heckel)
  *---------------------------------------------------------------------------
  */

data work.demo(label='here is a dataset label to describe the data');
  infile cards MISSOVER;
  input idnum name $15.  qtr1-qtr4;
  cards;
1251 Rearden 10 12 14 20
161 Taggart . . 10 10
161 Taggart . . 10 17
482 Galt 22 14 6 25
;
run;
proc contents data=work._ALL_; run;

data tmp;
 set demo;
 label idnum='the ID Number'
       name='the Name'
       ;
run;
proc print LABEL; run;

data tmp2;
 set demo;
 /* To delete a label must use a space */
 label idnum=' ';
run;
proc print LABEL; run;



 /* Dynamic label */
data dyn;
  infile cards;
  input m1 m2 m3 num;
  cards;
1 2 3 99
6 9 12 100
  ;
run;

proc format;
  value mon 1='jan'
            2='feb'
            3='mar'
            ;
run;

%macro m;
  data dyn;
    set dyn;
    label %do i=1 %to 3;
            m&i="%sysfunc(putn(&i, mon.))"
          %end;
          ;
  run;
%mend; %m;
proc print data=_LAST_(obs=max) width=minimum LABEL; run;
