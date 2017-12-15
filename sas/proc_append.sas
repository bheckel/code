options nosource;
 /*---------------------------------------------------------------------------
  *     Name: proc_append.sas
  *
  *  Summary: Demo of efficiently adding records to a dataset without using a
  *           datastep.
  *
  *           Datasets do not have to be identical but must use FORCE to tell
  *           SAS to go ahead anyway.
  *
  *           If base dataset doesn't exist, it'll be created automatically.
  *
  *           TODO can use drop/keep dataset options?
  *
  *           See also proc_append_loop_all_datasets_in_lib.sas
  *
  *  Created: Mon 04 Nov 2002 15:39:35 (Bob Heckel)
  * Modified: Thu 10 Jun 2004 14:43:21 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source replace compress=yes;  /* compress=yes is important */

libname bobh 'c:\temp';

 /* If master doesn't exist, it will be created with the contents of txn. */
data bobh.master;
  input fname $1-10  lname $15-25  @30 numb 3.;
  datalines;
mario         lemieux        123
ron           francis        123
jerry         garcia         123
berry         barcia         123
  ;
run;

data work.txn;
  input fname $1-10  lname $15-25;
  datalines;
larry         wall
richard       dawkins
  ;
run;

title 'before';
proc print data=bobh.master; run;

 /* BASE= is the larger one.  Each observation from the smaller data set is
  * applied one at a time to the end of the BASE= data set.
  */
proc append base=bobh.master data=work.txn FORCE;
run;
 /* To append more than one ds to the end of BASE, must run multiple 
  * proc appends using the same BASE= and different DATA=
  */

title 'after';
proc print data=bobh.master; run;
