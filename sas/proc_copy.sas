options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: proc_copy.sas
  *
  *  Summary: Copy dataset(s) (not code) in a library to another library.  
  *           Good for fast backup before doing a destructive data step.
  *
  *           Restrictions:
  *           - can't copy a dataset to the same library (i.e. no renaming)
  *
  *             so to copy into a new dataset use
  *             proc append base=newdstocreate data=oldds
  *             newname is created on the fly
  *
  *           - can't change the ds name as it makes the copy so for a full
  *             rename see rename.dataset.sas (i.e. proc datasets)
  *
  *           - can't glob '*' must use colon wildcard ':'
  *
  *
  *  Created: Wed 14 May 2003 10:50:55 (Bob Heckel)
  * Modified: Mon 20 Jun 2005 15:52:18 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source replace;

 /* Copy From */
libname OLDL 'd:/_TD2908';
***libname OLDL 'BQH0.SASLIB';
***libname OLDL '/u/bqh0/saslib';

 /* Copy To */
libname NEWL 'n:/mo07';
***libname NEWL 'c:/temp2';
***libname NEWL 'BQH0.SASLIB';
***libname NEWL '/u/dwj2/mvds/NAT/2003';
***libname NEWL 'DWJ2.MED2003.MVDS.LIBRARY.NEW';

 /* Use SELECT to specify dataset(s) to copy to new library.  Comment out all
  * SELECTs to copy *all* datasets to new library.
  */
proc copy in=OLDL out=NEWL memtype=data;
  ***select idnew mtnew nynew;
  ***select UST2003OLDNAT;
run;
