options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: input_ampersand.sas
  *
  *  Summary: "&" format modifier indicates that a char input may contain one
  *           or more single embedded blanks and is to be read starting from
  *           the next nonblank column until: 1-two consecutive blanks or 2-the
  *           length of the variable is reached or 3-the end of the line is
  *           reached
  *
  *  Created: Thu 23 Aug 2012 10:42:07 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

data t;
  length name $13;
  input name &  score1  score2;
  /* Ampersand list input modifier accepts a single embedded space so data must be
   * delimited by TWO or more spaces (no other delimiter works).
   */
  datalines;
Devils  1132 1187
Hurri Canes  .  1102
Long   Gap . .
ExtralongwordExceed13Len Foo . .
Capitals  1016 1103
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

 /* Same but using informat */
data t2;
  input name &$13.  score1  score2;
  datalines;
Devils  1132 1187
Hurri Canes  .  1102
Long   Gap . .
ExtralongwordExceed13Len Foo . .
Capitals  1016 1103
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
