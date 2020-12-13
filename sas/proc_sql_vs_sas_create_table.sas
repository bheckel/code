 /*---------------------------------------------------------------------------
  *     Name: proc_sql_vs_sas.sas
  *
  *  Summary: Comparison of SQL vs. The SAS System in creating tables/datasets.
  *
  *  Adapted: Thu 11 Apr 2002 14:41:23 (Bob Heckel--Little SAS Book)
  * Modified: Tue 29 Oct 2002 12:24:06 (Bob Heckel)
  *---------------------------------------------------------------------------
  */

 /* SQL approach: */
proc sql NUMBER;
  create table work.customer (
    CustNumber   num,
    Name         char(14),
    Address      char(16)
  )
  ;

  insert into work.customer
    values (1001, 'Murphys Sports', '115 Main St.')
    values (1002, 'Sun N Ski', '123 Newberry Ave.')
    values (1003, 'Modells', '654 Hort St.')
    ;

  title 'Sports Customer Data';
  select * from work.customer;
quit;


 /* SAS approach: */
data work.customer;
  infile datalines dlm=',|' dsd;
  ***length CustNumber 3  Name $14  Address $16;
  ***input CustNumber Name Address;
  /* Better */
  input CustNumber:3. Name:$14. Address:$16.;
  datalines;
1001, Murphys Sports, 115 Main St.
1002, Sun N Ski| 123 Newberry Ave.
1003, Modells| 635 Hort St.
  ;
run;
proc print data=work.customer;
  title 'Sports Customer Data';
run;

 /***/

options fullstimer;

data testdata1;
  do id=1 to 10000000;
    x = ceil(ranuni(0) * 100);
    charx = put(x,Z2. -L);
    output;
  end;
run;

data t;
  set testdata1;
run;

proc sql;
  create table t2 as
    select * from testdata1;
quit;
