options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: count_characters.sas
  *
  *  Summary: Count appearances of the characters "ab" in a string
  *
  *  Adapted: Thu 03 Oct 2013 14:52:21 (Bob Heckel--SUGI 031-2013)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

 /* V8 */
data t;
  char1 = "ab1 ab a344444abb555 ab 4";

  cnt = 0;  /* counter for number of occurrences */
  i = index(char1,"ab");  /* find first occurrence, use indexc for EITHER */
  do while (i ne 0);
    cnt+1;  /* count occurrences of "ab" */
    char1 = substr(char1,i+2); /* resume search after "ab", use +1 for EITHER */
    i = index(char1, "ab");  /* find next occurrence, use indexc for EITHER */
  end;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


 /* V9 */
data t2;
  cnt = count(char1, 'ab');  /* use countc for EITHER, countw(char1, ' ') for ALL 5 WORDS */
run;
