
 /*     _______ keyword */
libname LIBRARY '.';
proc format lib=LIBRARY;  /* formats.sas7bcat magically appears */
  /* MS SQLServer 2011-01-21 15:46:59 */
  picture aerodtt other='%0Y-%0m-%0d %0H:%0M:%0S' (datatype=datetime);
  /* Standard date per Brad Flynn May 2011  */
  picture stddt other='%Y-%0m-%0d' (datatype=date);  /* THIS WILL ERROR */
  /* Standard datetime per Brad Flynn May 2011  */
  picture stddtt other='x%Y-%0m-%0d %0H:%0M:%0S' (datatype=datetime);
run;

data _allado;
  batch_time=datetime();
run;

 /* Use DP standard date format instead of existing format */
data _allado(drop=TMP:);
  set _allado(rename=(batch_time=TMPbatch_time));
/***  batch_time = put(TMPbatch_time, AERODTT19.);***/
  batch_time = put(TMPbatch_time, stddtt.);  /* now it's a char */
run;
proc print data=_LAST_(obs=max) width=minimum; run;
proc contents data=_allado;run;
