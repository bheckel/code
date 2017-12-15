options NOsource;
 /*----------------------------------------------------------------------------
  *     Name: merge_fast.sas
  *
  *  Summary: Demo of merging using traditional merge vs. an index and
  *           vs. multiple set statements
  *
  *           AVOID SORTING.
  *
  *           See also sortsortmerge.formats.sas
  *
  *  Created: Tue 06 May 2003 12:25:06 (Bob Heckel -- parts Carpenter p158-26)
  * Modified: Tue 30 Jul 2013 14:39:46 (Bob Heckel)
  *----------------------------------------------------------------------------
  */
options source;

/* Smaller lookup ds.  custid is common field. */
data work.custinfo;
  infile cards MISSOVER;
  input custid  name $  phone $12.;
  list;
  cards;
1681 Acme   919-555-1212
1682 Dey 919-555-1213
1683 Cee 919-555-1214
  ;
run;
title 'small lookup ds';
proc print; run;

 /* Larger ds.  custid is common field.*/
data work.billings;
  infile cards MISSOVER;
  input custid  product $  price;
  list;
  cards;
1681 thingz 10
1682 thingx 30
1682 thing 30
1682 thingx 99
1634 thing 40
  ;
run;
title 'large orders ds';
proc print; run;


 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
 /* Normal sort-sort-merge inner join */
proc sort data=custinfo; by custid; run;
proc sort data=billings; by custid; run;
data t;
  merge custinfo(in=ina) billings(in=inb);
  by custid;
  if ina and inb;
run;
title 'merge by';proc print data=_LAST_(obs=max) width=minimum; run;

 /* Double SET should be faster */
data t2(drop=cid);
  set billings(rename=(custid=cid));  /* cid is the lookup key */
  if cid eq custid then output;  /* true only when current cid is a dup */
  do while( cid gt custid );
    set custinfo(keep= custid phone name);
    if cid eq custid then output;
  end;
run;
title 'double set';proc print data=_LAST_(obs=max) width=minimum; run;
 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
data t;
  /*       max nobs custid            */
  array seen {1000000} $15 _TEMPORARY_;
  /* The list of custid are read sequentially, ONCE, into an array that stores
   * the customer name using the custid as the array subscript
  */
  do until (allnames);
    set custinfo end=allnames;
    seen{custid} = name;
  end;
  do until (allorders);
    set billings end=allorders;
    /* Cust name is recovered from the array */
    name = seen{custid};
    if name ne '' then output;
  end;
  stop;
run;
title 'array (could be memory hog >1M obs)'; proc print data=_LAST_(obs=max) width=minimum; run;


 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
data work.report;
  merge work.billings(where=(custid in(1682)) in=onbill) work.custinfo;
  by custid;
  if onbill;
run;
title 'old style';
proc print; run;

/* First must index since we didn't index at ds creation: data work.custinfo(index=(custid)); */
proc datasets library=work;
  modify custinfo;
  index create custid / unique;
run;

 /* Pre-sorting is not required when using index */
data work.report2;
  /* Read one row from billing ds. */
  set work.billings (where=(custid=1682));
  /* Then try to read directly the desired customer row from custinfo. */
  set work.custinfo (keep= custid name phone) key=custid / unique;

  /* OPTIONAL:
   * Value of _IORC_ is numeric return code that indicates the status of the
   * most recent I/O operation performed on an obs.  Success=0 EOF error=-1
   * and all others indicate non-match.
   *
   * This approach beats the old style method which just leaves blanks if 1682
   * isn't on custinfo ds.
   */
  /***
  if _IORC_ ne 0 then
    do;
      name = 'n/a';
      phone = 'n/a';
    end;
  ***/
run;
/* Same output as previous proc print (but s/b faster). */
title 'indexed plus double set statement plus key=';
proc print data=work.report2; run;
 /*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
