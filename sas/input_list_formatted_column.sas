options nosource;
 /*----------------------------------------------------------------------------
  *     Name: input_list_formatted_column.sas
  *
  *  Summary: Combine all three input styles
  *
  *           Also see C:\bookshelf_sas\lrcon\z0695211.htm for a summary.
  *
  *  Adapted: Thu 11 Apr 2002 14:41:23 (Bob Heckel -- Little SAS Book sect 2.7)
  * Modified: Thu 24 Jun 2010 09:53:10 (Bob Heckel)
  *----------------------------------------------------------------------------
  */
options source;

 /* All work the same except first one */
data t;
  infile cards;
  input a $;              /* LIST - only works for <=8 chars */
  ***input a $ 1-9;       /* COLUMN */
  ***input a $9.;         /* FORMATTED */
  ***input @1 a $CHAR9.;  /* FORMATTED */
  cards;
abcde
fghij
klmnop
qrstuvwxY
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
proc contents;run;  /* see length.sas for good description of storage defaults */



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
   *                                                    don't forget the dot!
   /*                                                                  _      */
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
Wolf Trap Farm        VA 1966                130   123
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

title 'data readin is wrong, should not have suppressed the error';
proc print data=_LAST_;
  format Acreage COMMA10.;
run;
