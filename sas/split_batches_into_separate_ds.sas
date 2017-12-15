options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: split_batches_into_separate_ds.sas
  *
  *  Summary: Read each unique batch number into its own dataset
  *
  *  Created: Wed 04 Sep 2013 09:12:12 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter dsoptions=note2err;

%macro splitBatches(ds, libnm);
  %local c n i j;

  proc sql NOPRINT;
    select count(distinct batchnum) into :c
    from &ds
    ;
  quit;
  %let c = %sysfunc(compress(&c));  /* 3 */

  proc sql NOPRINT;
    select distinct batchnum into :sBatchCode1 thru :sBatchCode&c
    from &ds
    ;
  quit;
  %let n = &SQLOBS;  /* 3 */

  data %do i=1 %to &n; &libnm..&&sBatchCode&i(drop=batchnum) %end; ;
    set &ds;
    %do j=1 %to &n;
      if batchnum eq "&&sBatchCode&j" then output &libnm..&&sBatchCode&j;
    %end;
  run;
%mend; 


options ls=180 ps=max; libname l '.';
data t;
  input batchnum $ x $;
  cards;
a1XM2345 foo
a1XM2345 bar
a1XM6789 foo
a9XM0000 foo
  ;
run;
%splitBatches(t, l);

proc print data=l.A1XM2345(obs=max) width=minimum; run;
