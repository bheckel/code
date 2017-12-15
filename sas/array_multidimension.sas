options nosource;
 /*---------------------------------------------------------------------------
  *     Name: array_multidimension.sas
  *
  *  Summary: Demo of multi-dimensional arrays.
  *
  *  Adapted: Fri 21 Feb 2003 17:17:33 (Bob Heckel -- Phil Mason SAS Tips & Techniques,
  *                                     Ron Cody Learning SAS)
  * Modified: Wed 21 Dec 2016 13:49:48 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source replace;

 /* Efficient table lookup of benzene exposure based on worker's job code from
  * a table that is actually a multi-dim array:
  */

data workers;
  input worker $ year jobcode $;
  cards;
001 1944 B
002 1948 E
003 1947 C
  ;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;

data look_up;
  array level{1944:1949, 5} _TEMPORARY_;  /* 6 x 5 = 30 (memory-only so faster) elements auto-retained in the PDV */

  /* Populate the array */
  if _n_ = 1 then do Year = 1944 to 1949;
    do Job = 1 to 5;
      input level{Year,Job} @;
    end;
  end;
  set workers;

  /* Compute the job code index from the JobCode value then do a char2num conversion */
  Job = input(translate(Jobcode,'12345','ABCDE'), 1.);
  Benzene = level{Year,Job};

  /*        A   B   C   D   E 
   * 1944: 220 180 210 110 90
   * 1945: 202 170 208 100 85
   * ...
   */
  datalines;
220 180 210 110 90
202 170 208 100 85
150 110 150 60 50
105 56 88 40 30
60 30 40 20 10
45 22 22 10 8
;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;



endsas;
data t;
  infile cards;
  input (Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec) (1.);
  cards;
111222333444
222333444555
333444555666
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

 /* Convert months into four new summed quarter variables */
data t2(drop=Jan--Dec);
  set t;

  /*         R C           */
  array marr{4,3} Jan--Dec;
  array qarr{4};

  do i=1 to 4;  /* over 4 months */
    qarr{i}=0;
    do j=1 to 3;  /* over 3 quarters */
      qarr{i}+marr{i,j};  /* accumulator */
    end;
  end;
run;
proc print data=_LAST_(obs=max) width=minimum; run;



endsas;
 /* Build a demo ds with 2 obs. */
data work.tmp;
  infile cards;
  /* Use range to do the input.  All array elements must be the same type. */
  input (name1-name12) ($)  @@;
  datalines;
aoA boA coA doA
eoB foB goB hoB
ioC joC koC laC
AOA BOA COA DOA
EOB FOB GOB HOB
IOC JOC KOC LAC
  ;
run;
proc print; run;


data _NULL_;
  set work.tmp;

  /* Create a 3 row x 4 col array (therefore, you need 12 pieces of data to
   * fill the array).  Each obs will be its own multidimensional array as the
   * dataset iterates. 
   *
   * SAS places variables into a two-dimensional array by filling all rows in
   * order, beginning at the upper-left corner of the array (known as
   * row-major order).
   */
  ***array multi[3,4] name1-name12;
  /* Better -- using the colon wildcard, don't have to worry about max
   * variable number changing in the future.  '$' is optional since name1-12
   * have already been defined as char.
   */
  array multi[3,4] $ name: ;

  do r=1 to 3;
    do c=1 to 4;
      put "R" r +(-1) "C" c "is " multi[r,c]  @;
    end;
    put;
  end;
  put;
run;
