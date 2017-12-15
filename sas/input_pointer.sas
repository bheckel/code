 /*---------------------------------------------------------------------------
  *     Name: input_pointer.sas
  *
  *  Summary: Relative, +, and absolute, @, movement of the input cursor.
  *
  *           When reading formatted input, the pointer control moves to the
  *           first column FOLLOWING the field that was just read in.
  *
  *  Created: Fri, 12 Nov 1999 13:27:34 (Bob Heckel)
  * Modified: Thu 17 Jun 2010 15:39:04 (Bob Heckel)
  *---------------------------------------------------------------------------
  */

data t;
  infile cards;
  list;
  input state1 $ +2 state2num state3 $ +6 state5 $ +(-3) state5num;
  cards;
AK065 AZ101 AL092 AR078 NC077
AK062 AZ111 AL082 AR078 NC076
ME062 VT110 HI077 AR076 SC073
;
run;
proc print data=_LAST_(obs=max) width=minimum; run;



data work.demo;
  infile cards;
  list;
  input @1 (state1-state5) ($2. +4)
        @3 (farenh1-farenh5) ($3. +3);
  cards;
AK065 AZ101 AL092 AR078 NC077
AK062 AZ111 AL082 AR078 NC076
ME062 VT110 HI077 AR076 SC073
;
run;



data _NULL_;
   infile datalines N=2 LINE=the_lineptr COL=the_columnptr;
/***   input name $ 1-15 ***/
/***         #2 @3 num***/
/***         ;***/
   /* same */
   input name $ 1-15 /
         @3 num
         ;
   put the_lineptr= the_columnptr=;
   datalines;
J. Brooks
  409740
T. R. Ansen
  4032
J. R. Wing
  4034
  ;
run;



 /* Only want data from second line of each listener data. */
data radio;
  infile cards MISSOVER;   
  input / (time1-time7) ($1. +1);
  listener=_N_;
  cards;
967 32 f 5 3 5
7 5 5 5 7 0 0 0 8 7 0 0 8 0
781 30 f 2 3 5
5 0 0 0 5 0 0 0 4 7 5 0 0 0
859 39 f 1 0 5
  ;
run;
proc print; run;



 /* Only want data from the 5th line. */
data t;
  infile cards MISSOVER;   
  input ///;
  input foo $  bar $  baz $;
  cards;
one line here
2ne line here
3ne line here
4ne line here
5ne good here
6ne ignored here  /* hope that's right */
  ;
run;
proc print; run;
