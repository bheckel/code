%macro bobh1310103730; /* {{{ */
 /* 1. Build formats.sas in PWD */
libname LIBRARY '.';
proc format lib=LIBRARY;
  /* 28-AUG-10 13:29:57 */
  picture ip21dtt other='%0d-%b-%0y %0H:%0M:%0S' (datatype=datetime);
  /* 2010-02-04T10:59:00 */
  picture b21dtt other='%Y-%0m-%0dT%0H:%0M:%0S' (datatype=datetime);
  /* 2009-05-21 15:46:59.727 */
  picture fwdtt other='%0Y-%0m-%0d %0H:%0M:%0S' (datatype=datetime);
run;
%mend bobh1310103730; /* }}} */

%macro bobh1310103547; /* {{{ */
 /* 2. Use ./formats.sas7bcat */
libname mylib '.';
options fmtsearch=(mylib);
data _null_;
  x=33339923;
  y=put(x, ip21dtt.);
  put y=;
run;
%mend bobh1310103547; /* }}} */

