options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: picture.format.sas
  *
  *  Summary: Allow use of char tags in numeric ranges.
  *
  *   %0H  The hour - 24 hrs clock - 04, 17, 23
  *   %0I  The hour - 12 hrs clock - 04, 05, 11
  *   %0M  The minute - 01, 19, 25
  *   %0S  The second - 05, 15, 35
  *   %0U  The week number of the year - 01, 52
  *   %0d  Day of the month as a decimal number - 01
  *   %0j  The day of the year - 001, 075, 352
  *   %0m  Month as a decimal - 01, 11
  *   %0y  Year without century - 05, 20
  *   %A  Full weekday name - Monday, Friday
  *   %B  Full month name - April, October
  *   %H  The hour - 24 hrs clock - 4, 17, 23
  *   %I  The hour - 12 hrs clock - 4, 5, 11
  *   %M  The minute - 1, 19, 25
  *   %S  The second - 5, 15, 35
  *   %U  The week number of the year - 1, 52
  *   %Y  Year with century - 2005, 2020
  *   %a  Abbreviated weekday name - Mon, Fri
  *   %b  Abbreviated month name - Apr, Oct
  *   %d  Day of the month as a decimal number - 1
  *   %j  The day of the year - 1, 75, 352
  *   %m  Month as a decimal - 1, 11
  *   %p  The day half - AM, PM
  *   %w  Weekday as a decimal number - 1, 5, 7
  *   %y  Year without century - 5, 20
  *
  *  Adapted: Mon 23 May 2005 13:32:05 (Bob Heckel --
  *             http://support.sas.com/91doc/getDoc/proc.hlp/a002473467.htm)
  * Modified: Mon 29 Jul 2013 13:31:41 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* V9 does this with a built-in format */
proc format;
  picture mydt LOW-HIGH = '%0d-%b-%Y' (datatype=date);
  picture mydtx LOW-HIGH = '%d-%b-%Y' (datatype=date);
run;
data _null_;
  myday = '01oct1965'd;
  /* !!!01-OCT-1965 */
  put '!!!' myday mydt11.;
  /* !!!! 1-OCT-1965 */
  put '!!!!' myday mydtx11.;
run;

endsas;
 /* Format using parenthesis:
  * ( 1.8%)
  * (62.4%)
  * ...
  */
proc format;
  picture mypct  0-1000='0009.9%)' (prefix='(')
                 Other=' ';
run;

data t;
  set sashelp.shoes;
  retpct=(returns/sales)*100;
  retpctfmttd=put(retpct, mypct.);
run;
proc print data=_LAST_(obs=10) width=minimum; run;



endsas;
 /* Since the MDYAMPMw.d format doesn't include seconds, PROC FORMAT creates a
  * custom format with output like MDYAMPMw.d format, including seconds.
  */
proc format;
  picture myfmt LOW-HIGH='%m/%d/%Y %I:%0M:%0S %p' (datatype=datetime);
  /* If you want single digit months and days to write leading zeros, change
   * the format definition to this:
   */
      /* LOW-HIGH and OTHER appear to be the same */
/***  picture myfmt OTHER='%0m/%0d/%Y %I:%0M:%0S %p' (datatype=datetime);***/
run;

/* data read with MDYAMPM and then output with the custom format */
data mine;
  input dt MDYAMPM22.;
  format dt myfmt.;
  datalines;
2/25/2010 1:30:02am
  ;
proc print; run;


endsas;
proc format;
  picture oradtt other='%0d-%b-%0y %0H:%0M:%0S' (datatype=datetime);
  /* 2010-02-04T10:59:00 */
  picture b21dtt other='%Y-%0m-%0dT%0H:%0M:%0S' (datatype=datetime);
run;



proc format;
  /* The 0 is an optional digit, the 1 is mandatory digit. */
  picture pcntsA (round) LOW-HIGH = '01.11' (mult=10000)
                         OTHER = '0.00' (noedit)
                         ;

  picture pcntsB (round) LOW-HIGH = '01.11'
                         OTHER = '0.10' (noedit)
                         ;

  picture pcntsC (round) LOW-<0.0099 = 'vlo';

  picture pcntsD (round)  LOW-<0.0099 = '<0.01' (noedit)
                          0.0100<-HIGH = '0.000'
                          ;
run;

data;
  input nums;
  cards;
0.101
0.0037
0.255
5.1
5123456
35.339
  ;
run;

title 'UNformatted';
proc print data=_LAST_; run;

title 'formatted with pcntsA';
proc print data=_LAST_; 
  format nums pcntsA.;
run;
title 'formatted with pcntsB';
proc print data=_LAST_; 
  format nums pcntsB.;
run;
title 'formatted with pcntsC';
proc print data=_LAST_; 
  format nums pcntsC.;
run;
title 'formatted with pcntsD';
proc print data=_LAST_; 
  format nums pcntsD.;
run;



 /***************/

title 'Display negative numbers in parentheses';
proc format;
  PICTURE neg
  low-<0 = '000,000.99)' (prefix='(')
  0-high = '000,000.99';
run;

data test;
  a=1; b= -2;
  format a b neg.;
run;
proc print data=_LAST_(obs=max); run;

 /***************/


title 'Determine weekday based on a date';
proc format;
  picture mylong LOW-HIGH = 'the %dth of %B is a %A ' (datatype=date);
run;
data _null_;
  myday = '30oct1965'd;
  /* "the 30th of October is a Saturday" is 33 chars wide, probably want >33
   * to handle longer strings.
   */
  put myday :mylong33.;
run;

