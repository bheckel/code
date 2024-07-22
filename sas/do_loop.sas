options nosource;
 /*---------------------------------------------------------------------------
  *      Name: do_loop_demo.sas
  *
  *   Summary: Demo from "SAS Programming" of repetitive (iterative) do loop.
  *
  *            To exit 2 or more nested loops, must use GOTO (LEAVE and
  *            CONTINUE only go out of the innermost loop).
  *
  *            See also do_over_nums_chars.sas
  *
  *  Created: Tue May 18 1999 10:42:14 (Bob Heckel)
  * Modified: Wed 16 Jun 2010 13:04:10 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* Compare interest for yearly vs. monthly compounding on a $25K investment
  * made for one yr. at 10%.
  */
data compounding;
  amount = 25000;
  rate = 0.10;
  yearly = amount * rate;
  monthly = 0;

  /* Obfuscation of the simpler  do i=1 to 12 where BY defaults to 1. */
  do i=1 to 6.5 by 0.5;
    put i=;
    monthly + (monthly + amount) * rate / 12;
    ***output;
  end;

  /* If the OUTPUT in the loop was uncommented it would be 6.5 */
  put '!!!after looping we exceed 6.5 and store 7 due to implied OUTPUT here: ' i=;
run;
proc print data=compounding NOOBS;
  format amount yearly monthly DOLLAR7.;
run;


 /* Calc range of mortgage payments based on interest rate changes. */
data work.mortgage;
  /* Commas MANDATORY. */
  /* Do over a literal list of numbers. */
  do rate = 0.07, 0.077, .42, .085;
  /* Start out irregularly, then after .085, end in even .005 intervals. */
  ***do rate=0.07, 0.077, .42, .085 to .10 by .005;
  /* This one is too weird to be useful. */
  ***do rate=0.07, 0.075, .08, .085 to .10 by .005, 5;
    put rate=;
    /*                               30yr */
    payment=mort(160000, ., rate/12, 360);
    output;
  end;
run;
proc print; run;


  /* Do over a list of constants. */
data work.paydays;
  do pday='21may98'd to '07jul00'D by 14;
    fmtpday=pday;
    output;
  end;
run;
***proc print data=work.paydays NOOBS;
  ***format fmtpday YYMMDD8.;
***run;


data work.tmp;
  array vari[*] $ v1-v5;
  do i=lbound(vari) to hbound(vari);
    /* Single observation created -- v1 thru v5 are filled with the letter N */
    vari[i] = 'N';
  end;
run;
title 'arrays';
proc print; run;


 /* The value of stop is evaluated before the first execution of the loop. */
data tmp;
  do i=3 to 1;
    put 'should not see this: ' i;
  end;
run;


title 'while x gt y';
data tmp;
  retain x 2;
  retain y 1;
  /* Do 1 to 10 as long as x is greater than y */
  do i=1 to 10  while ( x>y );
    x+2;
    y+1;
    output;
  end;
run;
proc print; run;
title 'until x lt y (SAME)';
data tmp;
  retain x 2  y 1;
  do i=1 to 10  until ( x<y );
    x+2;
    y+1;
    output;
  end;
run;
proc print; run;
title 'until x gt y (X IS GT Y!!)';
data tmp;
  retain x 2;
  retain y 1;
  /* Do 1 to 10 until x is greater than y (which is immediately but one loop
   * gets performed anyway b/c it's an UNTIL loop). 
   */
  do i=1 to 10  until ( x>y );
    x+2;
    y+1;
    output;
  end;
run;
proc print; run;


data stopexecutionearly;
  input x;
  exit=10;
  /* Careful -- could go into infinite loop if logic is wrong. */
  do i=1 to exit;
    y=x*normal(0);
    /* If y>25, changing i's value stops execution. */
    if y>25 then 
      i=exit;
    output;
  end;
   datalines;
5
000
2500
  ;
run;
title 'terminate loop';
proc print; run;



 /* Macro loops */

%macro McroDoloop;
  %local i;
  %do i=1 %to 5;
    %put here is &i;
  %end;
%mend McroDoloop;
%McroDoloop


%macro McroDoloop2;
  %local i;
  %do i=5 %to 1 %by -1;
    %put here is &i;
  %end;
%mend McroDoloop2;
%McroDoloop2


 /* FAILS!  Unlike normal SAS which allows this shell-like construct... */
%macro McroDoloop3;
  %local i;
  %do i=one two three;
    %put here is &i;
  %end;
%mend McroDoloop3;
 
 /* but...this contortion works: */
%macro McroDoloop4(s);
  %local i item;
  %global SETSTMT;

  %let i=1;
  %let item = %scan(&s, &i, ' ');

  %do %while (&item ne  );
    %put !!! each piece is available here: &item;
    %let i=%eval(&i+1);
    %let item = %scan(&s, &i, ' ');
  %end;
%mend McroDoloop4;
%McroDoloop4(split me up work on parts)

 /* or */

filename OLD 'BF19.OKX0309.NATMER';
filename NEW 'BF19.OKX0310.NATMER';
%macro BuildDs(s);
  %local i f;

  %let i=1;
  %let f=%scan(&s, &i, ' '); 

  %do %while ( &f ne  );
    %let i=%eval(&i+1);
    data WORK.&f;
      infile &f;
      input @3 certno $CHAR6.  @9 mothdobmm $CHAR2.  @11 mothdobdd $CHAR2.;
    run;
    %let f=%scan(&s, &i, ' '); 
  %end;
%mend BuildDs;
%BuildDs(OLD NEW)



 /* Avoid specifying an index or control variable */
data nums;
  input n1 n2;
  array nums _NUMERIC_;

   /* Process list, replace blanks with zeros */
  do over nums;
    if nums eq . then
      nums = 0;
  end;

  cards;
0 1
2 3
. 5
  ;
run;



%let DSETS=foo bar baz boom;

%macro ForEach(s);
  %local i f;

  %let i=1;

  %do %until (%qscan(&s, &i)=  );
    %let f=%qscan(&s, &i); 
    /*...........................................................*/
    %put !!!have &f;
    /*...........................................................*/
    %let i=%eval(&i+1);
  %end;

  %do x=1 %to &i;
    %put !!!top of another loop &x;

    %if &x eq 2 %then
      %goto continue;  /* there is no %return, %next or %continue in Macro */
    %else %if &x eq 3 %then
      %goto leave;  /* exit macro */
    %else 
      %put !!!&x is NOT 2;

    %continue:  
    /* do nothing, next loop iteration */
  %end;

  %put !!!finished looping;
  %leave:
%mend ForEach;
%ForEach(&DSETS)



 /* Compounding interest example */
 /* Multiple observations from one do loop */
data work.invest;
  do year=1990 to 2004;  /* 15 iterations */
    capital+2000;
/***    capital=capital+(capital * 0.10);***/
    /* same */
    capital+(capital*0.10);
    output;  /* IMPORTANT: only outputs  2005 $69,899.46  w/o this */
  end;
run;
proc print data=work.invest;
  format capital dollar12.2;
run;


data x;
  set sashelp.shoes;
  if product='Sandal' then do;
  paidnew=1;
  lbdinvnew=1;
  end;
else if product='R' then do;
  paidrenewal=2;
  lbdinvren=2;
  end;
run;
