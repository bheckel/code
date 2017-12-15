options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: count_occurrence_of_char.sas
  *
  *  Summary: Count instances of a char in a string.
  *
  *  Adapted: Wed 11 Feb 2004 16:59:59 (Bob Heckel--West Addison '95 Usenet post)
  * Modified: Tue 12 Nov 2013 11:04:47 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data t;
 input x $;
 cards;
YYNNN
YNYYY
NNNNN
 ;
run;


 /* V9+ */
data t2;
  set t;
  c = countc(x, 'Y');
run;
proc print data=_LAST_(obs=max) width=minimum; run;


 /* V8 */
 /* Count the number of instances of ch in str.  The macro works by removing
  * all characters except ch from String and returning the length of the
  * resulting string.  The rather inelegant concatenation of '.' and
  * subtraction of 1 in the macro was necessary to handle the case where ch is
  * the space character, because the length function returns the position of
  * the rightmost NONBLANK character in its argument. 
  */
%macro CharCnt(str,ch);
  /* collate assumes ASCII, EBCDIC uses somewhere around 129,233  */
  length(compress(&str,compress(collate(0,127),&ch))||'.')-1
%mend CharCnt;

data t3;
  set t;
  cntY = %CharCnt(x, 'Y');
  /* Same */
  ***cntY = length(compress(upcase(x),compress(collate(0,127),'Y'))||'.')-1;
run;
proc print; run;


endsas;
data _null_;
  s='count, the commas, in this string';
  l1=length(s);
  s=compress(s, ',');
  l2=length(s);
  n=l1-l2;
  put 'removed ' n= 'commas' ;
run;
