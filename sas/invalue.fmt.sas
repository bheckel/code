options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: invalue.fmt.sas
  *
  *  Summary: Demo of user-defined informats.
  *
  *  Adapted: Mon 30 Mar 2009 15:29:28 (Bob Heckel - SUGI 041-2008)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

proc format;
  /* Not $CONVERT b/c we're storing numbers.  Max name length is 31 chars. */
  /* Handle messy data         */
  /*              ___________  */
  invalue CONVERT(UPCASE JUST)
  'A+' = 100
  'A' = 96
  'A-' = 92
  'B+' = 88
  'B' = 84
  'B-' = 80
  'C+' = 76
  'C' = 72
  'BAD','F' = 65
  OTHER = .
  ;
run;

 /* Only want the num grades */
data grades;
  input @1 id $3.  @4 grade CONVERT3.;
  datalines;
001A-
002b+
003F
004BAD
005C+
006 A
;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

 /* If want both the char & num grades */
data grades;
  input @1 id $3.  @4 grade $3.;
  numgrade = input(grade, CONVERT3.);
  datalines;
001A-
002b+
003F
004BAD
005C+
006  A
007  z
;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

 /* Best */
proc format;
  invalue READGRAD(UPCASE)
  'A' = 95
  'B' = 85
  'C' = 75
  'F' = 65
  OTHER = _SAME_;
run;

data school;
  input grade :READGRAD3. @@;
  datalines;
97 99 A C 72 f b
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;



endsas;
 /* Eliminate character garbage for a numeric field.  Wow. */
proc format;
  invalue READTMP(UPCASE)
    -999999999 - 999999999 = _SAME_
    OTHER = .
    ;
run;

data clean_numbers_only;
  input temp :READTMP9. @@;
  cards;
101 junk 97.3 69 junk2 -5 123456 whatifthisisreallylong
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
proc contents; run;
