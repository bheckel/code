options nosource;
 /*---------------------------------------------------------------------
  *     Name: verify.isnum.sas
  *
  *  Summary: Emulate C's isnum and isalpha functions.  Also see 
  *           index.sas if need to just find a literal string instead
  *           of a specific char or num in a list.
  *
  *           SAS v9's anydigit etc. is better than this.
  *
  *  Adapted: Tue 22 Oct 2002 13:22:20 (Bob Heckel -- Peter Crawford 
  *                                     usenet post)
  * Modified: Tue 11 Aug 2009 09:04:05 (Bob Heckel)
  *---------------------------------------------------------------------
  */
options source;

data alphandnum;
  input resultchar $10.;
  cards;
ACHAR
N/A
42
66
.
MIX3D
 0.1 
15.1347
102.7
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

data alphandnum;
  set alphandnum;
  /* The VERIFY function returns the position of the first character in source
   * that is not present in any excerpt. If VERIFY finds every character in
   * source in at least one excerpt, it returns a 0.
   * 
   * The COMPRESS is important (and use UPCASE(resultchar) if needed)
   */
  /*                                    _ catch floating point nums */
  isnum = verify(compress(resultchar), '.0123456789');
  isalp = verify(compress(resultchar), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ');
  isalphanum = verify(compress(upcase(resultchar)), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890');

  put _all_;

  if isnum ne 0 then put "at least some alphabetical " resultchar=;
  if isalp ne 0 then put "at least some numerical " resultchar=;
  if isnum eq 0 then put "pure numerical " resultchar=;  /* usually most important */
  if isalp eq 0 then put "pure alphabetical " resultchar=;
  if isalphanum eq 0 then put "!!!pure alphanumeric " resultchar=;
  put;

  /* This keeps the Log from spewing "Invalid argument to function INPUT..."
   * that occurs when just the assignment statement is used and a 'N/A' or
   * some other garbage is read.  Canonical.
   */
  if isnum eq 0 then
    itsanum = input(resultchar, F8.);
  else
    itsanum = .;
run;
proc contents;run;
proc print data=_LAST_(obs=max) width=minimum; run;



data _NULL_;
  /* Weird - returns 0 if DOES find this in that */
  x = verify('2', '0123456789');
  put x=;
run;



data scores;
  input Grade : $1. @@;
  checkAF='abcdf';
  if verify(grade,checkAF)>0 then 
    put @1 'INVALID ' grade=;
  datalines;
a b c b c d f a a q a b d d b
  ;
run;
