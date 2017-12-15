options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: lostcard.sas
  *
  *  Summary: Demo of handling bad multiple line input text data gracefully.
  *
  *  Adapted: Fri 16 Nov 2012 12:51:56 (Bob Heckel--SAS Help)
  * Modified: Mon 16 Dec 2013 13:55:08 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data inspect;
  input    id  1-3 age 8-9 
        #2 id2 1-3 loc 
        #3 id3 1-3 wt
        ;
  if id ne id2 or id ne id3 then
    do;
      put 'DATA RECORD ERROR: ' id= id2= id3=;
      /* Resynchronize the input data */
      lostcard;
    end;
  /* Only 301 & 411 have "good" records: */
  datalines;
301    32
301    61432
301    127
302    61
302    83171
400    46
409    23145
400    197
411    53
411    99551
411    139
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

endsas;
without LOSTCARD
Obs     id    age    id2     loc     id3     wt

 1     301     32    301    61432    301    127
 2     302     61    302    83171    400     46
 3     409     23    400      197    411     53

with LOSTCARD
Obs     id    age    id2     loc     id3     wt

 1     301     32    301    61432    301    127
 2     411     53    411    99551    411    139
