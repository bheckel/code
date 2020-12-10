 /* Modified: 16-Oct-2020 (Bob Heckel) */

%put Active caslib=%sysfunc(GETSESSOPT(casauto, caslib));
 /* Active caslib=CASUSER(bheck) */

cas myses sessopts=(caslib=casuser timeout=1800 locale="en_US");  /* session default is CASAUTO? */

cas myses listsessions;

 /* Show e.g. Path = /casuserlibraries/bheck/ */
caslib casuser list;
 /* same */
caslib casuser(boheck) list;

 /* Make the Public caslib the active caslib */
cas sessopts=(caslib=public timeout=1800 locale="en_US");

 /* Show e.g. Path = /opt/sas/viya/config/data/cas/default/public/ */
caslib public list;

 /* Show .sashdat files like proc contents */
proc casutil; list files incaslib="public"; quit;
proc casutil; list files incaslib="casuser"; quit;

 /* Return to CASUSER */
cas sessopts=(caslib=casuser timeout=1800 locale="en_US");
proc casutil; list files /*incaslib="casuser"*/; quit;  /* default is active caslib */


 /****** Add a file and convert to an in-memory SAS dataset ******/
filename csv "/r/ge.unx.x.com/vol/vol110/u11/bheck/t.csv";

proc import datafile=csv out=mycsv dbms=csv; getnames=yes; run;
proc print data=work.mycsv(obs=10); run;

proc casutil; load data=mycsv outcaslib="CASUSER" casout="my_inmem_csv"; run;
 /* Assumes  caslib _all_ assign;  has run previously */
proc print data=casuser.my_inmem_csv; run;

data l1.my_saved_csv; set bob.my_inmem_csv;run;


 /****** Add a SAS dataset in-memory ******/
proc casutil; load data=sashelp.shoes outcaslib="CASUSER" casout="shoetbl"; run;
proc casutil; list tables incaslib='CASUSER'; run;

 /* "ERROR: Libref CASUSER is not assigned." */
proc print data=casuser.shoetbl;run;
 /* So run this first to generate the CAS libname CASUSER: */
caslib _all_ assign;
 /* or */
libname bob cas caslib="casuser";

 /* This is pretty much the same as  proc casutil; list tables incaslib='CASUSER'; run; */
proc contents data=casuser._all_ NOds; run;
proc contents data=casuser.shoetbl; run;
proc print data=casuser.shoetbl;run;
 /* or */
proc contents data=bob._all_ NOds; run;
proc print data=bob.shoetbl;run;

data _null_; put "Processed on " _threadid_= _nthreads_=; run;
data _null_ /sessref="casauto" single=no; put "Processed on " _threadid_= _nthreads_=; run;

 /* If don't want to let it drop automatically at session end: */
proc casutil; droptable casdata="shoetbl" incaslib="casuser"; quit;

 /* shu2 is actually CASUSER.shu2, not WORK.shu2 ! */
proc fedsql sessref=myses; create table shu2 as select *, put((2*sales),dollar9.2) as TotalPaid from casuser.shoetbl; quit;
proc contents data=casuser.shu2; run;
proc print data=casuser.shu2;run;

 /* Goes to both CAS & WORK */
proc format casfmtlib="formats";
  value retailfmt 0-100='Cheap Retail Price' 100<-500="Moderate Retail Price" 500<-1500='Expensive Retail Price';
run;
cas myses listfmtranges fmtname=retailfmt;

cas myses disconnect;
 /* More thorough in that it allows reconnection via cas myses sessopts=(caslib=casuser timeout=1800 locale="en_US"); */
cas myses terminate;

---

libname atlas cas caslib="MKC - Atlas (DNFS)" datalimit=ALL; proc print data=atlas.diball(obs=10);run;

