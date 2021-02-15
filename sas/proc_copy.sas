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
  * Modified: Mon 15-Feb-2021 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source replace obs=5;  /* can't use obs= on the select */

/*data OLDL.shoes; set sashelp.shoes;run;*/

 /* Copy From */
libname OLDL 'c:/temp';
*libname OLDL 'BQH0.SASLIB';
*libname OLDL '/u/bqh0/saslib';

 /* Copy To */
libname NEWL 'c:/temp/t2';
*libname NEWL 'c:/temp2';
*libname NEWL 'BQH0.SASLIB';
*libname NEWL '/u/dwj2/mvds/NAT/2003';
*libname NEWL 'DWJ2.MED2003.MVDS.LIBRARY.NEW';

 /* Use SELECT to specify dataset(s) to copy to new library.  Comment out all
  * SELECTs to copy *all* datasets to new library.
  */
proc copy in=OLDL out=NEWL memtype=data;
  ***select idnew mtnew nynew;
  ***select UST2003OLDNAT;
  select shoes;
run;

title "&SYSDSN";proc print data=NEWL.shoes(obs=10) width=minimum heading=H;run;title;

