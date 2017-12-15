options nosource;
 /*----------------------------------------------------------------------------
  *     Name: array.sas (see also ~/code/sas/locf.sas)
  *
  *  Summary: Demo of SAS arrays, a way of temporarily identifying a group of
  *           variables under a single name.  It is NOT a data structure.  The
  *           array's name is NOT a variable and it only exists for the life of
  *           the datastep.  It is a construction that allows you to write SAS
  *           statements referencing a group of variables.
  *
  *
  *           if height eq 999 then height= .
  *           if weight eq 999 then weight= .
  *
  *           becomes a substitution "a{i}" for "height" etc wrapped in a do loop:
  *
  *           array a{*} height weight;
  *           do i=1 to dim(a);
  *             if a{i} eq 999 then a{i}= .;
  *           end;
  *           
  *
  *
  *           Array must be all numeric or all character (default char length
  *           is 8).
  *
  *           Default element subscript is 1, not 0 but using e.g. [0:9] is
  *           more efficient.
  *
  *           Temporary arrays - Values in the temporary array are automatically retained
  *           (that is, they are not set to missing values when the DATA step iterates).
  *           Thus, they are useful places to store constant values that you need during the
  *           execution of the DATA step.
  *
  *            -  hardcoded:
  *               array rate {6} _TEMPORARY_ (0.05 0.08 0.12 0.20 0.27 0.35);
  *               if month_delinquent ge 1 and month_delinquent le 6 then balance = balance+(balance*rate{month_delinquent});
  *            
  *            -  or dynamic:
  *               array rateb {6} _TEMPORARY_;
  *               do i = 1 to 6;
  *                 rateb{i} = i*0.5;
  *               end;
  *            
  *           data _null_; array a[3] _TEMPORARY_ (1,3,6); x=sum(of a[*]); run;
  * 
  *
  *           See also ~/code/sas/array_multidimension.sas ~/code/sas/vname_array.sas for good looping example 
  *
  *  Created: Wed May 19 1999 14:14:11 (Bob Heckel)
  * Modified: Wed 21 Dec 2016 10:26:53 (Bob Heckel)
  *----------------------------------------------------------------------------
  */
options source;

data one;
  input pt_id visit1 visit2 visit3 visit4 visit5 visit6 ;
  datalines;
254 85 90 . . 101 82
577 88 80 99 . 100 101
231 85 99 100 . 101 99
333 90 . . 101 101 102
580 80 82 . . . .
221 100 . . . . .
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

title 'Fill missings with previous visit';
data two/*(drop=i prev)*/;
  set one;
  array visit[6];
  /* same but more explicit */
  /* array visit[*] visit: ; */

  do i=1 to dim(visit) ;
    if visit[i] ne . then do;
      prev=visit[i];
      continue;  /* optional in this instance */
    end;
  else visit[i]=prev;
end;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


/* Fast, no sorting */
data t2;
  /*        max nobs in t         */
  array seen {1000000} _TEMPORARY_;
  set t;
  if seen{patient} eq . then do;
    output;
    seen{patient} = 1;
  end;
run;



 /* Without arrays */
data foo;
  input ...
  celsius_temp1 = 5/9*(temp1-32);
  celsius_temp2 = 5/9*(temp2-32);
  celsius_temp3 = 5/9*(temp3-32);
  ...
  celsius_temp24 = 5/9*(temp24-32);
run;

 /* With arrays */
data foo;
  input ...
/***  array temperature_array {24} temp1-temp24;***/
  array temperature_array {24} temp: ;
  array celsius_array {24}     celsius_temp1-celsius_temp24;
  do i = 1 to 24;
    celsius_array{i} = 5/9*(temperature_array{i}-32);
  end;
run;
/* If we only wanted daytime hours: */
/***array temperature_array {6:18} temp6-temp18;***/

 /* Alternate:
  * If you omit a variable list in an ARRAY statement and you include the
  * number of elements following the array name, SAS automatically creates
  * variable names for you, using the array name as the base and adding the
  * numbers from 1 to n, where n is the number of elements in the array.
  */
data temp;
  input Fahren1-Fahren24 @@;

  array Fahren[24];
  array Celsius[24];

  do hour = 1 to 24;
    Celsius{hour} = (Fahren{hour} - 32)/1.8;
  end;

  drop Hour;
  datalines;
32 37 40 42 44 48 55 59 62 62 64 66 68 70 72 75 75
72 66 55 53 52 50 45
;
run;



filename f 't.dat';
/*
id 	Q1 	Q2 	Q3 	Q4 	Q5 	Q6 	Q7 	mode 	subdt 	 
10 	1 	5 	1 	3 	. 	. 	. 	e 	12/1/2010	 
10 	1 	5 	1 	3 	1 	7 	4 	p 	1/3/2011 	 
11 	3 	6 	2 	. 	2 	. 	5 	e 	1/7/2011 	 
11 	3 	6 	2 	. 	2 	. 	5 	p 	2/7/2011 	 
12 	4 	3 	2 	. 	1 	6 	3 	p 	1/15/2011	 
12 	4 	3 	2 	. 	. 	. 	. 	p 	4/2/2011 	 
15 	2 	4 	1 	2 	2 	. 	6 	p 	3/21/2011	 
21 	2 	3 	1 	4 	1 	3 	4 	e 	3/1/2011 	 
22 	1 	5 	2 	. 	1 	4 	5 	p 	2/2/2011 	 
*/

data t;
  infile f firstobs=2 TRUNCOVER;
  input id q1-q7 mode $ subdt $15.;
run;

data t2;
  set t;
  array mandatory(*) q1-q3 q5 q7;  /* ok for q4 and q6 to be skipped by users */
  completed=0;
  do i=1 to dim(mandatory);
    if mandatory(i) ne . then completed+1;
  end;
run;



data t;
  infile cards;
  input n1 n2 n3 n4;
  cards;
10 20 40 70
50 65 80 100
9 0 1 5
  ;
run;
data t2;
  set t;

  ***array wt{*} n1-n4;
  /* same */
  ***array wt n1-n4;
  /* same */
  array wt n:;
  ***array wtdiff{*} wd1-wd3;
  /* same except automatically names vars wtdiffN and you can't use '*' */
  array wtdiff{3};

  do i=1 to dim(wtdiff);
    wtdiff{i} = wt{i+1}-wt{i};
  end;
run;
 /*
Obs    n1    n2    n3     n4    wtdiff1    wtdiff2    wtdiff3    i

 1     10    20    40     70       10         20         30      4
 2     50    65    80    100       15         15         20      4
 3      9     0     1      5       -9          1          4      4
  */
  


 /* Fill a dataset's first (and only) obs with the same number */
data t;
  array arr x y z a b c d;
  do over arr;
    arr = 12345.6789;
  end;
run;



data implicit;
  input num1 num2 num3;
  cards;
0 1 2
3 4 5
  ;
run;
data implicit(drop=i);
  set implicit;

/***  array num{*} num1-num3;***/
  /* same but can't use '*', also more confusing for maintaining, dependency
   * on the input dataset's naming convention
   */
  array num{3};

  do i=lbound(num) to hbound(num);
    /* num{i} is an array reference here */
    /*       ______                      */
    num{i} = num{i}+1;
  end;
run;



 /* Variables to which initial values are assigned are automatically RETAINed */
data declareAndInitialize;
  ***array a[4] x1-x4 (1 2 3 4);
  /* Implicit subscript is more convenient */
  array a[*] x1-x4 (1 2 3 4);

  /* temporary for this datastep */
  put a[*]=; 
  /* same but saved in dataset.  Use _TEMPORARY_ if you don't want to have to
   * DROP x1, x2, x3, x4
   */
  put x1= x2= x3= x4=;
  ;
run;



data tmp;
  array a[10] n1-n10;
  input a[*];

  m=mean(of a[*]);
  cards;
1 2 3 4 5 6 7 8 9 0
10 20 30 40 50 60 70 80 90 100
  ;
run;



data t;
  /* Can't use '{*}' here */
  array elements{5} $2 _TEMPORARY_ ('H','He','Li','Be','B');

/***  do i=lbound(elements) to hbound(elements);***/
  /* same if array's 1st element is 1 */
  do i=1 to dim(elements);
    put '!!!' i elements[i];
  end;
run;
 /* Only writes var i.  If we want the autovivified elements (vars
  * elements1-elements5) written, remove the _TEMPORARY_
  */



data t;
  /* Default char length is 8 */
  input ltrkeep $ yr0 numkeep yr1 yr2 yr3;
  cards;
A 1 0 2 3 4
b 0 9 0 0 0
C 1 9 2 3 4
d 0 0 0 0 0
E 0 0 0 0 1
  ;
run;
proc contents;run;



 /* Wipeout only specific variable range */
data t;
  set t;
  ***array a[*] $1 yr0-yr3;
  /* Better, generic */
  array a[*] $1 yr:;
  do i=1 to dim(a);
    a[i] = '';
  end;
run;



data demo1;
  infile cards MISSOVER;
  input idnum name $  qtr1-qtr4;
  list;
  cards;
1251 Galler 10 12 14 20
161 Cix . . 10 10
482 Hall 22 14 6 25
  ;
run;
data demo2;
  set demo1;
  /* Index Range -- Must explicitly say 0 to get it as the lower bound in SAS.
   * Must know upper bound of array.
   */
  array arrqtr[0:3] qtr1-qtr4;
  /* Number of elements in array. */
  d = dim(arrqtr);
  l = lbound(arrqtr);
  /* Actual top array element SUBSCRIPT (upper bound). */
  h = hbound(arrqtr);
  put d= l= h=;
  /* Must use hbound() if using an index range e.g. [2:4] instead of {*} */
  do i=0 to hbound(arrqtr);
    arrqtr[i] = arrqtr[i]+0.01;
  end;
  format qtr1-qtr4 DOLLAR9.2;
run;



 /* Numeric array */
data demo3;
  set demo1(drop= idnum qtr2 qtr3);

  /* No QUOTES! */
  %let langs=Emacs Perl SAS C VB;

  array langs_arr(*) &langs;

  /* Use these values for each obs (uselessly the same value each time).
  /* Emacs & VB are initialized to missing, this won't work in the array
   * statement line.  Not sure this would ever be useful though...
  */
  langs_arr(2) = 42;
  langs_arr{3} = 66;
  langs_arr[4] = 99;

  if langs_arr{1} eq . then
    langs_arr(1) = 0;  /* Emacs is actually an operating system... */

  totlangs = sum(of langs_arr{*});
run;

 /* Character array */
data demo4;
  set demo1(drop= idnum qtr2-qtr3);
  /* Declare AND initialize (set defaults). */
  ***array wkdays[*] $5 mo tu we th fr ('Mon' 'Tue' 'Wed' 'Thu' 'Fri');

  /* Better */
  /*                            -----------------------------  */
  /*                                optional definition        */
  /*              mandatory for char arrays only               */
  /*              __                                           */
  array wkdays[*] $5 day1-day5 ('Mon' 'Tue' 'Wed' 'Thu' 'Fri');

  /* Twofer Tuesday. */
  wkdays[2] = 'Twofer';  /* 5 char wide */
  put wkdays[*]=;
run;
title 'Char array';
proc contents; run;



 /* Using SAS' variable list names instead of our own made-up-for-array-purposes: */
data justchars;
  set demo1;
  /* Explicitly subscripted arrays are not allowed to be operated upon by the DO OVER statement */
  array chars _CHARACTER_;
  do over chars;
    put chars=;
  end;
run;

data justnums;
  set demo1;
  array nums _NUMERIC_;
  do over nums;
    put nums=;
  end;
run;

data justnums;
  set demo1;
  array numarr[*] _NUMERIC_;
  do i=1 to dim(numarr);
    numarr[i] = (numarr[i]*2);
  end;
run;
title 'Double all numerics';



 /* Array of months: */
data _NULL_;
  /*                               evidently commas are optional   */
  array TwelveMo[*] $3 mo1-mo12 ('Jan', 'Feb', 'Mar', 'Apr', 'May', 
                                 'Jun' 'Jul', 'Aug', 'Sep', 'Oct', 
                                 'Nov', 'Dec');
  
  do i=1 to hbound(TwelveMo);
    put 'Month number: ' i ' is ' TwelveMo[i];
  end;
run;



 /* Array of checkboxes: */
data yes_no_checkboxes;
  mycode = '02';

  /* Declare but do not initialize an array of checkboxes: */
  array ckboxarr[*] $1 box1-box7;
  do i=1 to hbound(ckboxarr);
    /* Initialize all to 'no'... */
    ckboxarr[i] = 'N';
  end;

  /* ...then set the Y's where needed. */
  do i=1 to hbound(ckboxarr);
    select ( mycode ); 
      when ('01') ckboxarr[1] = 'Y';
      when ('02') ckboxarr[2] = 'Y';
      when ('42') ckboxarr[6] = 'Y';
      when ('66') ckboxarr[7] = 'Y';
      otherwise;
    end; 
  end;
run;



 /* Use a temporary array for poor-man's encryption: */
%let NUMS16 = 13 11 5 15 3 10 2 6 8 9 14 7 4 16 12 1;
data _NULL_;
  length clear crypt $16;
  /* Using _TEMPORARY_ will avoid having to use temp variables here and drop=
   * later.  It should only be used for constants.
   */
  array seq[16] _TEMPORARY_ (&NUMS16);

  clear = '6011000123456789';

  do i=1 to 16;
    put seq[i]=;
    substr(crypt, i, 1) = substr(clear, seq[i], 1);
  end;
  /* E.g. take value in position 13 of clear (i.e. 6), then take value in
   * position 11 of clear (i.e. 4) and so on, building crypt as you go.
   */
  put crypt=;
run;

data _NULL_;
  length crypt decrypt $16;
  array seq[16] _TEMPORARY_ (&NUMS16);

  /* From previous step */
  crypt = '6408130012701956';

  do i=1 to dim(seq);
    substr(decrypt, seq[i], 1) = substr(crypt, i, 1);
  end;
  /* E.g. take value in position 13 of clear (i.e. 6), then take value in
   * position 11 of clear (i.e. 4) and so on, building crypt as you go.
   */
  put decrypt=;
run;



 /* Produces a single obs */
data changecase(drop=nm:);
  /* Doesn't work so just using the DROP= */
/***  array names[10] $ _TEMPORARY_ $nm1-nm10;***/
  array names[*] $ nm1-nm10;
  array capitals[*] $ c1-c10;

  ***input names[*] @@;
  /* Same */
  input names[*];

  do i=1 to 10;
    /* Ignore every 3rd name, uppercase the others. */
    if mod(i, 3) then
      capitals[i]=upcase(names[i]);
  end;
  datalines;
ridley pivonka federov ovechkin bondra stevens 
ovechkin peters stevens juneau
  ;
run;
title 'Every Third Name Deleted, Others Uppercased';



 /* Find something in an array. */
%let searchkey = 7; 	 
data _null_; 	 
  array arr{0:9} _TEMPORARY_ (1 2 2 3 0 5 4 6 7 9); 	 

  do i=0 to 9; 	 
    if arr{i} eq &searchkey then 
      do; 	 
        put "found &searchkey at arr[" i +(-1) ']'; 	 
        stop; 	 
      end; 	 
  end; 	 
  put "&searchkey not found"; 	 
run; 	 



/* Determine the highest number from the first four variables in each observation. */
data tmp;
  input a b c d e f g;
cards;
1 9 3 4 5 22 7
2 1 1 1 5 2 9
;
run;


data tmp2;
  set tmp;

  /* Dump all the variables into an array: */
  ***array arr[*] _numeric_;
  /* Only want some of the vars: */
  array arr[*] a b c d ;

  maxnum = 0;  /* initialize */

  /* Get the max value of the first 4 numbers */
  do i = 1 to dim(arr);
    if arr[i] > maxnum then
       maxnum = arr[i];
  end; 

  /* Write to SAS Log */
  put 'The maximum number for this obs is: ' maxnum;
run;



data foo;
  drop i;
  input x1 x2 x3 x4 $ x5  x6 $ x7;
  /* Due to intervening character variables, a numbered range list (x3-x7)
   * would not work.  So use this so that character variables on the PDV between x3
   * and x7 will be ignored. 
   */
  array y[*] x3-NUMERIC-x7;
   do i=1 to dim(y);
     y[i] = y[i] * 100;
   end;
  datalines;
1 2 3 yes 4  no 5
11 22 33 abstain 44 yes 55
  ;
run;



data score_a_test;
  array ans{10} $1;
  /* Answer key elements are retained across data step iterations */
  array key{10} $1 _TEMPORARY_('A','B','C','D','E','E','D','C','B','A');
  /* If you wanted to load from first dataline of file instead of hardcode: */
  /* if _n_ = 1 then do Ques = 1 to 10; input key{Ques} $1. @; end; */

  input student (ans1-ans10)($1.);

  rawscore = 0;
  do ques = 1 to 10;
    rawscore + (key[ques] eq ans[ques]);
  end;
  percent = 100*rawscore/10;
  datalines;
123 ABCDEDDDCA
126 ABCDEEDCBA
129 DBCBCEDDEB
  ;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;



data lastvis;
  input lvisdt;
  cards;
1
1023
10000
  ;
run;

data lastq;
  set lastvis;

  /* Identify quarter of last active.  Can't use '[*]' must say 12 */
  array quart[12]  _temporary_ (1 1 1 2 2 2 3 3 3 4 4 4);
  array mon[12] $3 _temporary_ ('JAN' 'FEB' 'MAR' 'APR' 'MAY' 'JUN' 'JUL' 'AUG' 'SEP' 'OCT' 'NOV' 'DEC');

  length _lqtr $3 _lyr $5;
  /* Note when using an array created with _temporary_ you must use an explicit
    do loop, that is you can NOT use DO OVER; 
   */
  do i=1 to dim(mon);
    if substr(put(lvisdt, date9.), 3,3) eq mon[i] then
      _lqtr='Q'||trim(left(put(quart[i],1.)));
  end;

  _lyr='Y'||substr(put(lvisdt, date9.), 6);
  lastqrtr=trim(left(_lqtr))||trim(left(_lyr));
run;
proc print data=_LAST_(obs=max) width=minimum; run;
