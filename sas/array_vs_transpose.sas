options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: array_vs_transpose.sas
  *
  *  Summary: Compare proc transpose with a datastep approach
  *
  * Adapted: Tue 24 Nov 2009 15:27:36 (Bob Heckel -- SUGI p60-24)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* Rows to column */
data t;
  infile cards;
  input lnm $ q1 q2 q3 q4;
  cards;
aa 1 2 3 4
bb 11 22 33 44
cc 111 222 333 444
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

 /*
Obs    lnm     q1     q2     q3     q4

 1     aa       1      2      3      4
 2     bb      11     22     33     44
 3     cc     111    222    333    444
 
Obs    lnm    _NAME_    COL1

  1    aa       q1         1
  2    aa       q2         2
  3    aa       q3         3
  4    aa       q4         4
  5    bb       q1        11
  6    bb       q2        22
  7    bb       q3        33
  8    bb       q4        44
  9    cc       q1       111
 10    cc       q2       222
 11    cc       q3       333
 12    cc       q4       444
  */
proc transpose;
  by lnm;
  var q1-q4;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

 /* Essentially the same */
data t2;
  set t;
  array a{4} q1-q4;
  do q=1 to 4;
    tot = a{q};
    output;
  end;
run;
proc print data=_LAST_(obs=max) width=minimum; run;



 /* Column to rows */
data t;
  input myname $ mydate $;
  cards;
Amy  Date#A1
Amy  Date#A2
Amy  Date#A3
Bob  Date#B1
Bob  Date#B2
Bob  Date#B3
Bob  Date#B4
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


 /**************************************/
proc transpose out=t2 prefix=DATE;
  by myname;
  var mydate;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
 /*
Obs    myname    _NAME_     DATE1      DATE2      DATE3      DATE4

 1      Amy      mydate    Date#A1    Date#A2    Date#A3           
 2      Bob      mydate    Date#B1    Date#B2    Date#B3    Date#B4
  */
 /**************************************/


 /**************************************/
%macro m;
   /* Determine largest number of observations for any MYNAME */
   /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
  proc freq data=t order=FREQ;
    tables myname / /*NOprint*/ out=tmp;
  run;
  proc print data=_LAST_(obs=max) width=minimum; run;
  data _null_;
    set tmp;
    call symput('N', compress(put(COUNT,8.)));
    stop;
  run;
   /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

  data t2(keep=myname date1-date&N);
    array arrdates{&N} $ date1-date&N;
    do i=1 to &N until (LAST.myname);
      set t;
      by myname;
      arrdates{i} = mydate;
    end;
  run;
  title 'same'; proc print data=_LAST_(obs=max) width=minimum; run;
%mend;
 /*
Obs     date1      date2      date3      date4     myname

 1     Date#A1    Date#A2    Date#A3                Amy  
 2     Date#B1    Date#B2    Date#B3    Date#B4     Bob  
  */
%m;
 /**************************************/

