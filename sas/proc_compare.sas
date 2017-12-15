options nosource;
 /*---------------------------------------------------------------------------
  *     Name: proc_compare.sas
  *
  *  Summary: Demo of proc compare.  A messy, verbose diff for datasets.
  *
  *  Created: Wed 30 Oct 2002 13:26:14 (Bob Heckel)
  * Modified: Fri 19 Dec 2014 11:12:15 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source replace ls=180;

data emp95;
  input #1 idnum $4. @6 name $15.
        #2 address $42.
        #3 salary 6.;
  datalines;
2388 James Schmidt
100 Apt. C Blount St. SW Raleigh NC 27693
92100
2457 Fred Williams
99 West Lane  Garner NC 27509
33190
3888 Kim Siu
5662 Magnolia Blvd Southeast Cary NC 27513
77558
;
run;
proc sort data=emp95 out=emp95_byidnum;
  by idnum;
run;


data emp96;
  input #1 idnum $4. @6 name $15.
        #2 address $42.
        #3 salary 6.;
  datalines;
2388 James Schmidt
100 Apt. C Blount St. SW Raleigh NC 27693
92100
2457 Fred Williams
99 West Lane  Garner NC 27509
33190
6544 Roger Monday
3004 Crepe Myrtle Court Raleigh NC 27604
47007
;
run;
proc sort data=emp96 out=emp96_byidnum;
  by idnum;
run;

proc compare base=emp95_byidnum compare=emp96_byidnum
             out=result outnoequal outbase outcomp outdif noprint;
  id idnum;
run;

proc print data=result noobs;
  by idnum;
  id idnum;
run;



 /* Unrelated example */
libname bobh 'c:\TEMP';

data bobh.sample (label= 'the first one');
  input fname $ 1-10  lname $ 15-25  numb;
  datalines;
larry         wall           345
mario         lemieux        123
richard       dawkins        345
richard       feynman        678
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;


data bobh.sample2;
  ***input fname $ 1-10  lname $ 15-25  numb;
  input fname $ 1-10  lname $ 15-25  numb  onlyhere;
  label fname='First Name';
  datalines;
larry         SCHWARTZ       346 111
mario         lemieux        123 111
richard       dawkins        345 111
richard       feynman        678 111
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

***proc compare base=bobh.sample compare=bobh.sample2;
***proc compare base=bobh.sample compare=bobh.sample2 BRIEFSUMMARY;

proc compare base=bobh.sample compare=bobh.sample2 /*outstats=t*/ out=t;
  var lname;  /* compare just lnames */
/***  by numb;***/
/***  id fname;***/
  /* Would need this if lname wasn't same in both ds */
  ***with lname;
run;

 /* Good visualization of obs where there's a diff: */
proc print data=t(obs=max) width=minimum; run;
