 /* Auto-allocation of a file that can hold a 2003+ medical file.  Using
  * Connect. 
  */

filename OUT 'BQH0.BYTES407' LRECL=407 DISP=NEW;

data _NULL_;
  file OUT;
  put ' ';
run;
