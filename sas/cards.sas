
data ndcs;
  infile cards dlm=',';
  input name :$14. brand_name_code :$1. gpi8 :$8.;
  cards;
Qudexy XR,T,72600075,7260007500,7260007500F310-,00245107115-,All
Qudexy XR,T,72600075,7260007500,7260007500F310-,00245107130-,All
Topiramate,G,72600075,7260007500,72600075000320-,00832070815-,All
Topiramate,G,72600075,7260007500,72600075000330-,00832070915-,All
Topiramate,G,72600075,7260007500,72600075000340-,00832071015-,All
;
run;



 /* http://michaelraithel.blogspot.com/ */
 /* Note that the MISSOVER option is absolutely necessary in this example.
  * And, it can only be specified on an INFILE statement.  The MISSOVER option
  * is necessary because the sample data does not always contain a value for
  * AGE.  Without the INFILE statement and the MISSOVER option, SAS would not
  * know it needs to go to a new line when the INPUT statement reached past the
  * end of the current line.  So, when it got to the second line of input, it
  * would attempt to go to the third line and read “Mark” into the AGE
  * variable, resulting in a pesky note in the log
  * 
  * This means that you would not have been able to adequately test your
  * program with a DATALINES statement without the INPUT statement.
  */
data didyouknow;
  infile cards MISSOVER;
  input firstname $ age;
  datalines;
Michael 35
Minerva
Mark 25
Miranda
  ;;;;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;

endsas;
data inds;
  input clientid @@ ;
  cards;
9 14 23 27 34 35 38 41 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 
  ;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title; data;file PRINT;put '~~~~~~~~~~~~~~~~~~~~~~';put;run;



data t;
  infile datalines missover;
  input firstname $ age;
  datalines;
Michael 35
Minerva
Mark 25
Miranda
  ;
run;
proc print; run; 



endsas;

data one;
  input time TIME5.  samplenum;
  format time DATETIME13.;
  time=dhms('23nov94'd,0,0,time);
  cards;
09:01   100
10:03   101
10:58   102
11:59   103
13:00   104
14:02   105
16:00   106
;
  put 'coming after the null semi, this causes an error';
run;  /* optional when using CARDS or DATALINES */
