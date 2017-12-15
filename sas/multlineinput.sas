 /*----------------------------------------------------------------------------
  *    Name: multlineinput.sas
  *
  *  Summary: Demo of reading multiple lines of data input.
  *
  *  Adapted: Tue, 16 Nov 1999 09:20:57 (Bob Heckel -- Semicolon 10/99)
  * Modified: Mon 02 Jun 2003 15:29:37 (Bob Heckel)
  *----------------------------------------------------------------------------
  */

/* Assumes there will always be record starting with '03' (the indicator
 * variable). 
 */
data work.readit;
  /* Code the varis common to each input line.  rec_type is the indicator
   * variable.
   */
  input @1 rec_type $char2.
        @3 surveyno $char4.  @;
  /* Ck indicator vari to determine current record being read, then
   * conditionally code more INPUT stmts.
   */
  if rec_type = '01' then
    do;
      retain city age sex a1-a17;
      input @7 city $2.
            @9 age 2.
            @11 sex $1.
            @12 (a1-a17) (+0 1.);
    end;
  else if rec_type = '02' then
    do;
      retain a1-a18;
      input @7 (a1-a18) (+0 1.);
    end;
  else if rec_type = '03' then
    do;
      retain foo bar a1-a18;
      drop rec_type;
      input @7 foo $1.
            @8 bar $1.
            @9 (a1-a18) (+0 1.);
      /* OUTPUT the record at the last line within the obs. */
      output readit;
    end;
    /* Same cards used for all demos. */
    cards;
0103181028211234567891212223
020318122322245522343234
03031821211112232112200001
0106711341121455636388902021
020671288387378791005807
03067138387877177277474773
;
run;


/* Other (worse) options: */

/* Same -- Separate INPUT stmts. */
data work.separate;
  input @1 rec_type $char2.
        @3 surveyno $char4.
        @7 city $2.
        @9 age 2.
        @11 sex $1.
        @12 (a1-a17) (+0 1.)
        ;
  input @7 (a1-a18) (+0 1.)
        ;
  input @7 foo $1.
        @8 bar $1.
        @9 (a1-a18) (+0 1.)
        ;
  cards;
0103181028211234567891212223
020318122322245522343234
03031821211112232112200001
0106711341121455636388902021
020671288387378791005807
03067138387877177277474773
;
run;


/* Same -- Using slash '/'  The +0 in (+0 1.) is optional as demonstrated
 * here. 
 */
data work.slash;
  input @1 rec_type $char2.
        @3 surveyno $char4.
        @7 city $2.
        @9 age 2.
        @11 sex $1.
        @12 (a1-a17) (1.)
        /
        @7 (a1-a18) (1.)
        /
        @7 foo $1.
        @8 bar $1.
        @9 (a1-a18) (1.)
        ;
  cards;
0103181028211234567891212223
020318122322245522343234
03031821211112232112200001
0106711341121455636388902021
020671288387378791005807
03067138387877177277474773
;
run;


/* Same -- Using line pointers '#' */
data work.pointer;
  input #1  @1 rec_type $char2.
            @3 surveyno $char4.
            @7 city $2.
            @9 age 2.
            @11 sex $1.
            @12 (a1-a17) (+0 1.)
            
        #2  @7 (a1-a18) (+0 1.)
            
        #3 @7 foo $1.
           @8 bar $1.
           @9 (a1-a18) (+0 1.)
           ;
  ***list;
  put "!!! DEBUG: " _N_;
  cards;
0103181028211234567891212223
020318122322245522343234
03031821211112232112200001
0106711341121455636388902021
020671288387378791005807
03067138387877177277474773
;
run;
