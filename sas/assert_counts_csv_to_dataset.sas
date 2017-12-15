options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: assert_counts_csv_to_dataset.sas
  *
  *  Summary: Unit test compare input records equal to output records
  *
  *  Adapted: Mon 03 Jun 2013 12:35:29 (Bob Heckel--SUGI 011-2013)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

%macro AssertCounts;
  %let csv='c:\cygwin\home\rsh86800\t.csv';
  libname l 'c:\cygwin\home\rsh86800'; %let ds=l.wtf;

  filename in pipe "c:/cygwin/bin/wc -l &csv";

  data _null_;
    /* Not interested in reading observations, just want nobs */
    set &ds nobs=outcount;

    /* Get line count from unix command */
    length incount_c $20;
    infile in;
    input incount_c $ junk $;
put '!!!' incount_c;
    incount = input(incount_c, BEST.);
put '!!!' incount;

    if incount eq outcount then
      put 'Test passed';
    else
      put 'Test failed: ' incount= outcount=;

    stop;
  run;
%mend; %AssertCounts;
