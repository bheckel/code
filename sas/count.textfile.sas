options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: count.sas
  *
  *  Summary: Provide a raw count of a TEXTFILE (NOT a dataset!, see 
  *           count.dataset.sas for that)
  *
  *           Windows or MVS platforms are autodetected.
  *
  *           See countall_files.sas for counting several files.
  *           TODO delete the old confusing count .sas'
  *
  *  Created: Wed 21 Jul 2004 17:15:49 (Bob Heckel)
  * Modified: Fri 22 Oct 2004 09:23:20 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options NOnotes NOsource NOcenter NOs99nomig;

 /********** Edit **************/
%let F=BF19.OKX05003.NATMER;
***%let F=/cygwin/home/bqh0/tmp/testing/junk.txt;
 /********** Edit **************/

%macro OSck; 
  %if &SYSSCP eq OS %then 
    %do;
      options NOs99nomig;
      filename FH "&F" DISP=SHR WAIT=20;
    %end;
  %else
    %do;
      filename FH "&F";
    %end;
%mend; 
%OSck


data _NULL_;
  infile FH END=e;
  file PRINT;
  format cnt COMMA10.;
  /* Null input stmt - The data step copies records from the input file to the
   * output file without creating any SAS variables.
   */
  input;
  /* cnt is initialized to zero and auto-retained. */
  cnt+1;
  if e then
    put cnt=;
run;
