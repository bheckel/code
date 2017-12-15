/*---------------------------------------------------------------------
 *  Program Name: dft.sas    
 *          
 *       Summary: Sample dataset testing SAS features.
 *                Read in a DAT file, manipulate data and fmts.
 *                Use SQL.
 *
 *     Generated:  19Aug98 (Bob Heckel)
 *       Revised:  28Aug98 (Bob Heckel - minor clarifications)
 *                 09Sep98 (Bob Heckel - SQL, etc.)
 *                 01Oct98 (Bob Heckel - minor wording, input style.)
 *     Modified: Tue Mar 30 1999 14:37:14 (Bob Heckel--cleanup, condense)
 *     Modified: Tue Apr 20 1999 10:53:09 (Bob Heckel--add raw data text,
 *                                         missover)
 *---------------------------------------------------------------------
 */
options linesize=80 pagesize=32767 nodate source source2 notes mprint
        symbolgen mlogic obs=max errors=3 number stimer;

/* Alternative is to type the fully qualified path after infile statement. */
filename MYINPUT  '~/dfw/DFWLAX.DAT';
filename MYOUTFIL '~/dfw/dfwout.txt'; 
filename MYOUTPRC '~/dfw/dfwproctabulout.txt'; 
filename MYINCUST '~/dfw/CUST.DAT';  /* Tab-delim */
filename MYINCSV  '~/dfw/ITWIN.CSV'; 
filename MYALDIN  '~/dfw/ALDSAMPLE.DAT'; 

/* Custom formats */
proc format;
  value $bobfmt 'LAX' = 'LosAng'
                'DFW' = 'DalFw'
                OTHER = 'SASKeywDeflt'
                ;
  value $gradfmt 'A'       = 'Vgood'
                 'B' - 'D' = 'NotGo'
                 OTHER     = 'Deflt'
                 ;
  picture prot    low- -1E5 = '-Overflow!' (noedit)
               -99999.99-<0 = '000,009.99' (prefix='-' fill='*')
			 0-999999.99 = '000,009.99' (fill='*')
			    1E6-high = 'Overflow!' (noedit)
			;
  picture drcr low-<0 = '00,009.99DR'
               0-high = '00,009.99CR';
  picture dolk 0-high = '00,009K' (mult=.001);
run;


/* To create a dataset from an external raw data file:
 * DATA statement to start the data step and name the output dataset.
 * INFILE statement to point to the external file you want to read.
 * INPUT statement to describe how to read the data fields from each record.
 */

/* Sample data from file DFWLAX.DAT:
 * ----+----1----+----2----+----3----+----4----+----5----+----6----+----7----
 * 43903139512:16LGALAX2,475 334 165135 22  2159210      A
 * 43103129518:50LGALAX2,475 364 193 77 26  6109210      A
 */
data work.dfwlax;
  /* MISSOVER prevents 'NOTE: SAS went to a new line when INPUT statement
   * reached past the end of a line'
   * It prevents loading another record.
   * It assigns missing values to remaining values.
   */
  infile MYINPUT MISSOVER obs=20;
  /* Column input format.
   * Intentionally not capturing all possible variables from DAT file.
   */
  input @1 flight $3.
        @4 datein mmddyy6.
        @18 dest $3.
        @34 boarded 3.
        @37 trans 3.
        @40 nonrev 3.
        @55 graded $1.
        ;
  /* Show input data record (in Log).
   * Only works for raw input, not datasets.  Useful for printing suspicious
   * input records e.g. if myobs=. then list;
   */
  list;
  totalz = sum(boarded, trans, nonrev);
  pct = (nonrev / totalz);
  /* Want to eventually compare with another dataset that will have a 2 */
  ident = 1;
  if totalz <= 50 then delete;
  /* Testing the eclectic SAS subsetting IF without THEN, similar to a reverse
   * delete statement (but shorter).
   */
  if graded ^= 'Z';
run;

proc sort data=work.dfwlax;
  by flight;
run;

/* Overwrite dfwlax.ssd01 */
data work.dfwlax;
  set work.dfwlax;
    if totalz > 110 then
    do;
      newvari = 'whoa';
    end;
run;

/* Pt. 1 of 2 */
proc printto print=MYOUTFIL NEW; /* Appends to file if don't use NEW */
run;

/* Must use the word ' label ' in proc print statement -- SAS bug patch. */
proc print data=work.dfwlax(obs=17) split='*' label ; 
  format datein date7.
         /* Bobh custom format */
         dest $bobfmt.
         nonrev 3.2
         /* Exceeds available length */
         trans dollar4.2
         pct percent5. 
         /* Bobh custom format */
         graded $gradfmt.
         newvari $best4.
         ;
  /* Uses split char '*' */
  label flight = 'Thanks*for flying vim';
  /* Use only after proc sort */
  by flight;
  /* Give different output if use id -- doesn't use OBS */
  /***id flight;***/
  /* Don't need pageby unless printing output */
  /***pageby flight;***/
  sum trans totalz;
  /* No nonrev -- otherwise don't need this line if include all vars */
  var flight datein dest boarded trans totalz graded newvari;
  /* Outputs Second line, Third line, Fifth line       Sixth line */
  title 'Testing an input file and procs';
  title1 'Second line';
  title2 'Third line';
  title4 'Fourth line';
  title3 'Fifth line';
  title5 'Sixth line';
run;

/* Pt. 2 of 2.  Route output back to standard output file. */
proc printto; run;

/* Begin proc tabulate */
/* Appends to file if don't use NEW */
proc printto print=MYOUTPRC NEW; run;

proc tabulate data=work.dfwlax;
  class flight graded;
  /*
   * comma = by
   * blank = next to
   * asterisk = within
   * grade within flight (goes right to left)
   */
  table flight*graded;
run;

/* Route output back to standard output file. */
proc printto; run;
/* End proc tabulate */

/* Dataset structure info */
proc contents data=work.dfwlax; run;
proc contents data=work._all_; run;

/* One-way */
proc freq data=work.dfwlax;
  /* Shows Frequency Missing */
  tables flight / missprint;
run;

/* Two-way */
proc freq data=work.dfwlax;
  /* 1st var forms rows, 2nd var forms cols */
  tables flight*datein;
  format datein date8.;
run;

proc means data=work.dfwlax;
  var boarded totalz;
  class flight;
run;


data _null_;
  tadae = today();
  /* Days since 1/1/60 */
  put tadae;
  /* Includes dashes */
  put tadae yymmdd8.;
  put tadae yymmdd5.;
  /* Concatenate today's date for file name. */
  derivdt = tadae || ' days from 1/60.';
  put derivdt;
  /* Date constant. */
  ystrdae = '02Jan60'D;
  put ystrdae;
run;


/* No infile used.  Combo of column and list input formats. */
data work.employee;
  input empnum
        empname $
        empyears
        empcity $ 20-34
        emptitle $ 36-45
        empboss
        #2
        catg1 $
        catg2 $
	   ;
    /* Show observations in Log. */
    list;
    /* a.k.a. cards.  Can't have space before 1st obs.
     * Two lines of data per obs.  Intentional error at 213.
     * Nothing can come after datalines except data.     
     */
    datalines;
101   Herb     28  Ocean City      president     .
numa numb
201   Betty     8  Ocean City      manager     101
numc numd
  213   Joe       2  Virginia Beach  salesrep    201
  numa numb
214   Jeff      1  Virginia Beach  salesrep    201
numh numg
216   Fred      6  Ocean City      salesrep    201
numa numb
301   Sally     9  Wilmington      manager     101
numa numb
314   Marvin    5  Wilmington      salesrep    301
numa numb
401   Chuck    12  Charleston      manager     101
numa numb
417   Sam       7  Charleston      salesrep    401
numx numz
;
run;

data work.employe2;
  input empnum
        empname $
	   empyears
	   empcity $ 20-34
	   emptitle $ 36-45
	   empboss
	   ;
  cards; 
101   Herb     28  Ocean City      president     .
201   Betty     8  Ocean City      manager     101
213   Joe       2  Virginia Beach  salesrep    201
219   Joenull   2  .               salesrep    201
214   Jeff      1  Virginia Beach  salesrep    201
210   Jeffrey   1  Virginia Beach  salesrep    201
215   Wanda    10  Ocean City      salesrep    201
216   Fred      6  Ocean City      salesrep    201
301   Sally     9  Wilmington      manager     101
302   Salla    99  Wilmington      manager     101
303   Sallb   100  Wilmington      manager     101
304   Sallc   102  Wilmington      manager     101
314   Marvin    5  Wilmington      salesrep    301
318   Nick      1  Myrtle Beach    salesrep    301
401   Chuck    12  Charleston      .           101
417   Sam       7  Charleston      salesrep    401
;
run;

data work.employe3;
  set work.employe2;
  if empname = 'Wanda' then put _all_;
  if empname = 'Wanda' then empyears = 90;
  if empname = 'Wanda' then put _all_;
run;  

proc print data=work.employe3;
  title2 'Does The SAS System show as title?';
  var _all_;
run;


/* Same as above just to demo different input style. */
data work.employeX;
  input empnum +2
        empname $    /* Don't know exactly how many to 'plus'. */
	   empyears +2  /* Shows error of cutting off first letter. */
	   empcity $
	   ;
  cards; 
101   Herb     28  Ocean City      president     .
201   Betty     8  Ocean City      manager     101
213   Joe       2  Virginia Beach  salesrep    201
401   Chuck    12  Charleston      .           101
417   Sam       7  Charleston      salesrep    401
;
run;


/* Begin SQL samples.
 * This SELECT statement performs summation, grouping, sorting, 
 * and row selection.  It also executes the query without using 
 * the RUN statement and automatically displays the query's results 
 * without using the PRINT procedure.  The 'order by' sorts ascending.
 */

proc sql;
title2 'TOTAL SERVICE YEARS';
title3 'Computed with PROC SQL';
select empcity, sum(empyears) as totyears
  from work.employe2
    where emptitle = 'salesrep'
      group by empcity
        order by totyears;
quit;

/* View is not generated until called by other code e.g. proc print
 * This is a Virtual table vs. a Base table.  Like assigning a name to 
 * a particular SELECT query.  Think of how user wants to see database
 * and then give user a set of views that make it look like the database were
 * designed for their applications only.  Physically in darttmp as foo.ssv01
 * View can't be created if an .ssd01 has same name.
 * SAS Procedures can use views the same as real datasets.
 */
proc sql;
  title2 'EMPLOYEES WHO RESIDE IN OCEAN CITY';
    create view work.ocity as
      select empname, empcity, emptitle, empyears
        from employee
          where empcity = 'Ocean City';
quit;

proc print data=work.ocity;
  sum empyears;
run;

proc sql feedback;
title1; title2; title3 'Testing *, feedback';
select *
  from work.employe2
quit;

proc sql feedback;
title1 'Meaningless calc (no field name unless specified, called 2 here)';
  proc sql;
    select empcity, (empnum - empyears) / empnum
      from work.employe2
	 /* Sort descending on the unnamed field '2' */
	 order by 2 desc;
quit;

/* This is an example of a COMPOUND predicate.  */
proc sql feedback;
  title1 'EMPLOYEES WHO DO NOT LIVE IN OCEAN CITY NOR FUNCTION';
  title2 'AS A SALESREP BUT HAVE MORE THAN TEN YEARS OF SERVICE';
  title3 'Or are named Marv...' ;
  title4 'Or are named Jeffrey but not Jeff' ;
  title5 'Or have 99, 100 or 102 yrs of svc.';
  title6 'Or empcity is missing';
  select empname, emptitle, empcity, empyears
    from work.employe2
      where (not (empcity = 'Ocean City' or emptitle = 'salesrep')) and 
            (empyears > 10) or
		  empname like 'Marv%'or
		  empname like '____rey'or
		  empyears in (99, 100, 102) or
		  empcity is null;
  /* Turn off */
  reset feedback;
quit;


/* Sample data that is in file CUST.DAT (using filename MYINCUST):
 * Position of data is irrelevant b/c tab delim.
 * ----+----1----+----2----+----3----+----4----+----5----+----6----+----7----
 * Beach Land	16	Ocean City
 * Coast Shop	3	Myrtle Beach
 * Coast Shop	5	Myrtle Beach
 * Del Mar	3	Folly Beach
 */
data work.customer;
  /* Tab delim testing.
   * Use '&' to read char values containing embedded blanks-not demonstrated
   * because spaces in variables are not allowed using list format. Two spaces
   * required as delim if '&' is used.
   */
  infile MYINCUST delimiter='09'x; 
  input custname $  custnum  custcity $;
run;

/* The HAVING clause can be considered a "where clause" that is
 * applied to the groups formed by the GROUP BY clause.
 */
title1 'Customers that have more than one store';
  proc sql;
    select custname, custnum, custcity
      from work.customer
        group by custname
          having count(custname) > 1
            order by 1, 2, 3;
quit;

proc sql;
  /* Check syntax without running query */
  validate
  select custname, custnum, custcity
    from work.customer
	 group by custname
	   having count(custname) > 1
		order by 1, 2, 3;
quit;

/* Test multiple dataset creation */
data work.first work.second work.third;
  infile MYINCUST delimiter='09'x; 
  length custcity $11;
  input custname $ 
        custnum
	   custcity $;
  output work.first;
  if custname = 'DelMar' then output work.second;
  /* All but DelMar included */
  else output work.third;
run;

/* Use an Excel CSV file, ITWIN.CSV */
data work.comsep;
  /* 'dsd' forces quoted variable to not show its quotes in the dataset. */
  infile MYINCSV dsd delimiter=',';
  /* Must come before input stmt. */
  format char1 $varying10.;
  input char1 $  char2 $  char3 $  num1;
  /* Make a note of potential problems write to the Log Window. */
  if num1 = . then put "uhoh";
run;

/* Take approximately 10% random sample of a dataset */
data work.randm;
  set work.customer;
    if ranuni(0) > 0.9;
run;

/* Try to set a macrovariable as a constant.  
 * Be sure to use option symbolgen. 
 */
title 'variable test &SYSDATE';
%let bob = 'DelMar';
proc print data=work.customer;
  var _all_;
    where custname = &bob;
run;


/* The view derives a column for AGE from the persons bithday. */
data work.birthday;
  input name $ bday date7.;
    format bday date7.;
	 cards;
Jenny 04feb63
Sally 10feb66
Bob 30oct65
;
run;

proc sql;
  create view work.bday as
    select name, bday, ((today() - bday) / 365.25) as age format=6.3
  from work.birthday
    order by name;
  title 'data set with ages computed';
    select * from work.bday;
quit;

/* Output view description to Log */
proc sql;
  describe view work.bday;
quit;


/* Demonstrate picture formats above.  Incl overflow error trap prot. */
data work.acctg;
  input name $ 
        xx 
	   cred 
	   tot
	   junk $
	   junk2 $;
  /* Set debit to act as error trap. */
  put junk;
  deb=xx; prot=xx;
  format deb drcr. cred drcr. tot dolk. prot prot.;
  drop junk2;
  cards;
one 15503098 20239 20938 jun abc
two 3298 -2039 30948 junk def
three 32039 30984 30983 junkk ghi
four 32039 30984 30983 junkkk jkl
five 32039 . 30983 junkkkk mno
six 32039 30984 . junkkkkk pqr
;
run;

proc print data=work.acctg; title 'Pictures'; run;

/* Re-order variables in dataset */
data work.acctg2;
  /* All variables are kept but specifically mentioned ones are in this
   * retained order.
   */
  retain tot deb cred name;
  set work.acctg;
run;

/* Can't combine these next 2 SQLs */
proc sql;
  update work.acctg2
    set name = 'changd' where name = 'five';
quit;

proc sql;
  update work.acctg2
    set tot = 999 where tot is missing;
quit;

/* "Simple" index. */
proc sql;
 create unique index name
   on work.acctg2 (name);
quit;

/* "Composite" index if name alone is not enough to identify completely. */
proc sql;
 create unique index usetwo
   on work.acctg2 (name, junk);
quit;

/* Joins */
title 'Start Joins';
/* Contains no duplicate job_id. */
data work.ald;
  infile MYALDIN;
  input @1 rgn $4.  @5 om $4.  @10 prod $4.  @15 cls $1.  @16 job $8. 
        @24 loc $17.;
/* TODO how to use wildcard substitution on a subsetting if.  E.g. if leave
 * Ruler in .DAT file and want to select like C% to get real data ?
 */
/***  if rgn;***/
run;

/* Contains multiple same job_id */
data work.aldsm;
  infile '~/Misc/dfw/ALDSAMPLESM.DAT';
  /* Default length of 8 is ok. */
  input rgn $ om $ prod $ cls $ jobid $ loc $;
run;

/* Job HBOBER on aldsm does not appear in output. */
proc sql;
  create view work.joiner as
    select a.job,
           a.prod,
		 b.prod,
		 b.cls
    from work.ald as a,
         work.aldsm as b
    where job not like 'HX%' and
          a.job=b.jobid;
quit;

proc print data=work.joiner; title 'Straight Join w/o HX job included'; run;

/* Don't think 'where' stmts work in this type query.
 * 17 obs in ald, 8 in aldsm (w/ 4 jobid dups and one HBOBER that is not on
 * ald) therefore 21 obs in output (no HBOBER here either).
 */
proc sql;
  create view work.joiner2 as
    select a.job,
           a.prod,
		 b.prod,
		 b.cls
    from work.ald as a
         left join
         work.aldsm as b
    on a.job=b.jobid;
quit;

proc print data=work.joiner2; title 'Left Join w/ HX job included'; run;

/* Switch join direction -- aldsm on left, ald on right.  Result is 7 obs. */
proc sql;
  create view work.joiner3 as
    select a.jobid,
           a.prod,
		 b.prod as prodbig,
		 b.cls
    from work.aldsm as a
         left join
         work.ald as b
    on a.jobid=b.job;
quit;

proc print data=work.joiner3; title 'aldsm now on the left'; run;

/* nodupkey compares only the BY values, not the entire obs.
 * In this case, I actually lost valid data, should have used noduplicates.
 * which compares entire obs.
 */
proc sort nodupkey out=work.joiner4;
  by jobid;
run;

proc print data=work.joiner4; title 'Nodupkey'; run;

/* Send specific data to a headerless textfile, cols separated by a space. */
/* TODO can i specify delim=?*/
data _null_;
  set work.joiner3;
  file '~/Misc/dfw/putafile.txt';
  put jobid prod;
run;

/* Start proc compare sample */
data work.one;
  /* Random number generation */
  do r=1 to 4;
    do s=1 to 10;
	 /* If seed lt or eq 0, time of day is used as seed. */
      t = ranuni(0);
      u = arcos(t);
      output;
    end;
  end;
run;

proc print data=work.one; title 'data set work.one'; run;

/* Cause differences. */
data work.two;
  set work.one;
    if r = 1 then delete;
    if s = 1 then s = 0;
    if s = 10 then delete;
    if s = 20 then s = 10;
    if s > 15 & s < 20 then t = t+1;
    if u < t then u = 0;
run;

proc print data=work.two; title 'data set work.two'; run;

proc compare data=work.one c=work.two out=work.out allobs outnoequal brief;
  title;
    by r;
run;

proc print data=work.out; title 'data set work.out';
  /* id keeps vars r and s on first two cols */
  id r s;
run;

option linesize=80 pagesize=32767 nodate source source2 notes mprint
       symbolgen mlogic obs=max errors=3 number nostimer;

title; footnote;

filename MYINPUT  '~/Misc/dfw/DFWLAX2.DAT';

 /* Sample data from file DFWLAX.DAT:
  * ----+----1----+----2----+----3----+----4----+----5----+----6----+----7----
  * 43901316012:16LGALAX2,475 334 165135 222159210      A
  * 43100000518:50LGALAX2,475 364 193 77 266109210      A
  * 92103319517:11LGADFW1,383 353 195131 204138180      A
  */
data work.dfwlax;
  infile MYINPUT missover;
  input flight $ 1-3  @4 datein mmddyy6.  nonrev 40-43  trans 27-30;
  format datein mmddyy8.;
  label datein="Dayte";
  if _ERROR_ then put "uh oh trouble at obs "_N_" Here comes PDV...";
  if nonrev = . then list;
  /* There are 2 blank lines in .DAT -- don't want them. Use subsetting IF. */
  if flight not = .;
  /* Result is '.' if nonrev or trans is missing. */
  bobsum = nonrev + trans;
run;

/* Stops and waits for you. */
*proc fsview data=work.dfwlax; run;

/*
 * This gives 2 separate tables.  FYI--proc freq for a numeric (not a date)
 * is useless.
 */
proc freq; tables flight datein; run;

proc sql;
  create table work.kenz as
  /*
   * sum(trans) gives the tot for flights on ea. line (e.g. flightA 
   * shows tot of 620 on each line starting with flightA).  No collapsing 
   * of data.
   */
  select flight, sum(trans) as sumtrns, trans, datein, nonrev
    from work.dfwlax
    /* Must use group by or all flights get same big total. */
    group by flight
      order by flight asc;
quit;

/* Compare -- Review results of SQL */
title1 '1st run raw w/o sum or by';
proc print data=work.kenz; run;

/* Compare -- Gives subtots ---Flight=123--- and single grand tot */
title1 '2nd run w/ sum and by -- wrongly shows multiple sumtrns lines';
proc print data=work.kenz;
  sum sumtrns;
  by flight;
run;

/* Redo the query to make sure other proc prints don't interfere. */
proc sql;
  create table work.kenzx as
  /* Can't have more than the group by and sum variables. */
  select flight, sum(trans) as sumtrns
    from work.dfwlax
    /* Must use group by otherwise all flights get same big total. */
    group by flight
      order by flight asc;
quit;

title1 '3rd run w/ only sum';
/* Compare -- Gives proper subtots by flight and a single grand tot. */
proc print data=work.kenzx;
  sum sumtrns;
run;

title1;

/* Show single line with Flight and Sumtrns.  No complete dups found. */
title1 'Using noduplicates';
proc sort data=work.kenz noduplicates out=work.kenznd;
  by flight;
run;

proc print data=work.kenznd; run;

/*
 * Contrast with noduplicates.  Flight is considered the key.  Can use
 * more than one 'by' var to create the key (i.e. dupkey). 
 */
title1 'Using nodupkey -- there are 2 duplicates that have been elim.';
proc sort data=work.kenz nodupkey out=work.kenznd;
  by flight;
run;

proc print data=work.kenznd; run;

/* Can't use keep statement in proc steps.  Drop works as mirror image.
 * Contrast with keep= which _can_ be used in proc steps and can apply to
 * variables in certain ds but not others, also can e.g.
 * set myds(keep=jan--may) to do ranges. */
data work.avg;
  input name $  score1-score3;
  average = mean(of score1-score3);
  keep name average;
  cards;
bob 10 20 30
boc 11 22 33
bod 23 55 15
;
run;


/* Contrast SAS vs. SQL summing; same output. */
data work.sassql;
 infile cards;
 input student $6.  hr;
 cards;
14890   8
14890   2
14890   5
28954   12
28954   3
88965   15
;

title '!!!SAS style sum!!!';

proc sort data = work.sassql; by student; run;

data work.sassql2 (drop=hr);
  set work.sassql; 
  by student;
  if first.student then sum = 0;
  sum + hr;
  if last.student then output;
run;

proc print data = work.sassql2; run;

title '!!!SQL style sum!!!';
proc sql;
  create table work.sqlsas as
    select student, sum(hr) as shr
      from work.sassql
        group by student
          order by student;
quit;          

proc print data = work.sqlsas; run;


/* Demo PUT statements */
filename TABDELIM '~/Misc/dfw/tabdlmusingputsout.txt';

data _null_;
  set work.sassql;
  file TABDELIM;
  if _N_ = 1 then
    do;
      put 'Field One' '09'x
          'Field Two' '09'x
          ;
    end;

    put student '09'x
        hr '09'x
        ;
run;


data work.newspapr;
  input state $  morn eve yr;
  cards;
Alabama 256.3 480.5 1986
Alabama 256.3 . 1984
Alabama 256.3 480.5 1984
Maine 154.1 480 1987
Maine 254.3 480 1985
;
run;

data _null_;
  set work.newspapr;
    by state notsorted;
    /* Output to Output Window. NOTITLES makes line avail for writing text. */
    file print notitles;
    if _N_ = 1 then put @16 'Morn & Eve Newsp Circ' //
      @7 'State' @26 'Year' @51 'Thous Copies' /
      @51 'Morn  ...    Even';
    if first.state then
      do;
        mtot = 0;
        etot = 0;
        put / @7 state @;
      end;
    put @26 yr @53 morn 5.1 @66 eve 5.1;
    mtot + morn;
    etot + eve;
    if last.state then
      do;
        alltot = mtot + etot;
        put @52 '------' @65 '-----' /
          @26 'Tot for ea cat'
          @52 mtot 6.1 @65 etot 6.1 /
          @35 'Combiend tot' @59 alltot 6.1;
        end;
run;


filename REGION '~/Misc/dfw/delimtrash' lrecl=400;

data work.testing;
  input namea $  nameb $  var1-var3;
  /* $ format only captures first 8 chars in the created ds. */
    cards;
one aaa 3 6 9
two bbb 10 12 14
three ccc 15 17 19
three ccc 15 17 19
three xcc 15 17 19
four ddd 21 24 28
five ddd 32 33 34
five ddd 32 33 34
overflowed ddd 32 33 34
;
run;

data _null_;
  set work.testing;
  file REGION;
    /* Soundex */
    where nameb =* 'dee';
      trmd = trim(namea);
      if _n_=1 then
        put 'Name A' '09'x
            'Name B' '09'x
            'Var One' '09'x
            'Var Two' '09'x
            'Var Three' '09'x
            ;

        put namea '09'x
            trmd '09'x
            nameb '09'x
            var1 '09'x
            var2 '09'x
            var3 '09'x
            ;
run;


/* Financial */
data _null_;
  mymort = mort(110000,.,.0675/12,30*12);
  put mymort;
run;

/* Use notsorted or get error. */
title 'Selecting one per group';
data work.firslast;
  set work.testing;
  by namea nameb notsorted;
  if first.namea;
run;

proc print data=work.firslast; run;

