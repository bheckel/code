options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: input_statement.sas
  *
  *  Summary: Read data into SAS.
  *
  *           See also lostcard.sas for multiline gotchas
  *
  *  Created: Tue 25 May 2010 12:19:17 (Bob Heckel)
  * Modified: Wed 20 Nov 2013 13:35:51 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /*......................................................................................*/

 /* IF DATA IS NOT STORED IN DEFINED COLUMNS */
 /* Simple List input */
data t;
  /* List input scans for space(s) by default.  DELIMITER doesn't matter in
   * this e.g. b/c a single space is the default delimiter for list input. 
   */
  ***infile cards DELIMITER=' ';
  ***infile cards DLM=' ';
  /* Override the default char width of 8 */
  length name $ 12;
  input name $  score1  score2  textdt $;
  /* Data runs together on a line but must be delimited by one or more spaces.
   * Blanks must be represented a value (i.e. a period). 
   */
  list;
  datalines;
Devils  1132 1187 01JAN2010
Hurricanes . 1102.499 05JAN2010  /* .499 rounds to .50 in t */
Capitals 1016 1103 11JAN2010
  ;
run;
proc print; run;


 /* Better, date is stored properly (best of all if comma etc delimited, see DLM info above) */
data t;
  input name :$10.  score1 :8.  score2 :8.  realdt :DATE9.;
  list;
  datalines;
Devils  1132 1187 01JAN2010
Hurricanes . 1102 05JAN2010
Capitals 1016 1103 11JAN2010
  ;
run;
/***proc print; run;***/



 /*......................................................................................*/

 /* IF DATA IS STORED IN DEFINED COLUMNS */
 /* Simple Column input */
data t;
  input name $ 1-10  score1 12-15  score2 17-20  textdt $ 22-30;
  list;
  datalines;
Devils     1132 1187 01JAN2010
Hurricanes    . 1102 05JAN2010
Capitals   1016 1103 11JAN2010
  ;
run;
/***proc print; run;***/


 /* Better, date is stored properly */
data t;
  input name $10. +1 score1 4. +1 score2 4. +1 realdt DATE9.;
  list;
  datalines;
Devils     1132 1187 01JAN2010
Hurricanes    . 1102 05JAN2010
Capitals   1016 1103 11JAN2010
  ;
run;
/***proc print; run;***/


 /* Better, no numeric format hardcoding */
data t;
  /* Take away the '.' in $10. and you'll be referring to column position (not usually what you want) */
  input @1 name $10. @12 score1 @17 score2 @22 realdt DATE9.;
  list;
  datalines;
Devils     1132 1187 01JAN2010
Hurricanes    . 1102 05JAN2010
Capitals   1016 1103 11JAN2010
  ;
run;
/***proc print; run;***/


 /* Better if leading spaces are to be preserved, no numeric format hardcoding */
data t;
  input @1 name $CHAR12. @14 score1 @19 score2 @24 realdt DATE9.;
  list;
  datalines;
Devils       1132 1187 01JAN2010
  Hurricanes    . 1102 05JAN2010
Capitals     1016 1103 11JAN2010
  ;
run;
proc print; run;



 /*......................................................................................*/
 /* IF DATA IS STORED IN BOTH DEFINED AND UNDEFINED COLUMNS */

data t;
  input name $ 1-10  score1 score2  realdt DATE9.;
  list;
  datalines;
Devils    1132    1187 01JAN2010
Hurricanes    .   1102 05JAN2010
Capitals    1016  1103 11JAN2010
  ;
run;
proc print; run;



/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
options nosource;
 /*----------------------------------------------------------------------------
  *     Name: input_mixed.sas
  *
  *  Summary: Combine all three input styles
  *
  *           Also see C:\bookshelf_sas\lrcon\z0695211.htm for a summary.
  *
  *  Adapted: Thu 11 Apr 2002 14:41:23 (Bob Heckel -- Little SAS Book sect 2.7)
  * Modified: Wed 20 Nov 2013 13:16:35 (Bob Heckel)
  *----------------------------------------------------------------------------
  */
options source;

 /* All work the same except first one */
data t;
  infile cards;
  input a $ b;           /* LIST - only works for <=8 chars */
  ***input a $9. b;         /* LIST */
  ***input a :$9. b;        /* modified LIST */
  ***input a $ 1-9 b;       /* COLUMN */
  ***input a $9. +1 b;      /* FORMATTED */
  ***input @1 a $CHAR9. b;  /* FORMATTED */
  cards;
abcde     5
fghij     6
klmnop     8
qrstuvwxY 9
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;



 /* Mixing input styles (column, list and formatted): */
data simplemixedinput;
  input ssn $ 1-11          /* fixed width - COLUMN input style */
        @13 hiredt DATE7.   /* nonstandard - FORMATTED input style */
        @21 salary COMMA6.  /* nonstandard - FORMATTED input style */
        dept :$40.          /* >8 chars - so need modified LIST input style */
        phoneext            /* list input style */
        mychar $            /* list input style (if truncation is ok) */
        ;
  cards;
209-20-3721 07jan78 41,983 sales 2896 bob
223-96-8933 03may86 27,356 education 2344 heckel789
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
***proc contents;run;  /* see length.sas for good description of storage defaults */
/*
#    Variable    Type    Len    Pos
-----------------------------------
1    ssn         Char     11     24
2    hiredt      Num       8      0
3    salary      Num       8      8
4    dept        Char     40     35
5    phoneext    Num       8     16
6    mychar      Char      8     75
*/



data complexmixedinput;
  infile cards;
  ***input ParkName $ 1-22  State $  Yr  @40 Acreage COMMA9.;
  /* This better approach allows you to combine informats with the the
   * scanning feature of list input.  The colon (:$2.) indicates that the
   * value is to be read from the next nonblank column until either:
   *   1-the next blank column 
   *   2-the length of the variable as previously defined has been read 
   *   3-the end of the data line
   */

  /* With a dot, 3. means read 3 chars beginning at col52.  Without a dot, 3
   * means move to col52 but read the contents at col3.  No error message!
   * 
/***  input ParkName $ 1-22  State :$2.  Yr  @40 Acreage COMMA9.  @52 junk 3.;***/
  /* Same */
  input ParkName $ 1-22  State :$2.  Yr  @40 Acreage COMMA9.  @52 junk;

  /* This : method is the best when reading in tab delimited data that you can't
   * use '@' pointer controls on.  Keeps from having to have an informat and
   * a nearly identical input line following it.
   */
  cards;
Yellowstone           ID/MT/WY 1872    4,065,493   123
Everglades            FL 1934          1,398,800   123
Yosemite              CA 1864            760,917   123
Great Smoky Mountains NC/TN 1926         520,269   123
Wolf Trap Farm        V  1966                130   123
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;



 /* Intentional error introduced by shortening 22 to 19.  The ?? keeps it from
  * being mentioned in the Log that Yr is now screwed up.  A single ? would
  * only keep SAS Log quiet, ?? sets _ERROR_ to 0 as well so you can really
  * bury the bodies.
  */
data quietcomplexmixedinput;
  infile cards;
  input ParkName $ 1-19  State $  Yr ??  @40 Acreage COMMA9.;
  cards;
Yellowstone           ID/MT/WY 1872    4,065,493   123
Everglades            FL 1934          1,398,800   123
Yosemite              CA 1864            760,917   123
Great Smoky Mountains NC/TN 1926         520,269   123
Wolf Trap Farm        VA 1966                130   123
  ;
run;



title 'data readin is wrong, we should not have suppressed the error';
proc print data=_LAST_;
  format Acreage COMMA10.;
run;



data dose;
  input Patno Dose Ds_Date :DATE9. Cycle  @41 DoseNum $10.;
  cards;
101     50      15-Nov-05       1       Dose 1
101     50      16-Nov-05       1       Dose 2
101     50      17-Nov-05       1       Dose 3
101     80      6-Dec-05        2       Dose 1
602     100     3-Jul-07        2       Dose 1
602     100     10-Jul-07       2       Dose 2
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
