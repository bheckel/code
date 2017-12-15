options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: delete.sas
  *
  *  Summary: Deleting SAS dataset(s).  Also see proc_datasets.sas
  *
  *           May want to first run cp.sas to send a copy to HFS.
  *
  *     !!!!!!!!!!!!!!!!!!!! KILL ignores delete statments !!!!!!!!!!!!!!!!!!!
  *
  *           Can't use wildcards, have to use Vim to insert names between the
  *           DELETE and the ';'
  *
  *  Created: Mon 31 Mar 2003 12:57:52 (Bob Heckel)
  * Modified: Fri 06 May 2005 09:35:25 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

libname L 'BQH0.SASLIB';
***libname L 'BQH0.TEMP.SASLIB';
***libname L 'DWJ2.MED2000.MVDS.LIBRARY.NEW' DISP=OLD;
***libname L 'DWJ2.USTOT.SASLIB';
***libname L 'DWJ2.MOR2003.MVDS.LIBRARY.NEW' DISP=OLD;
***libname L 'DWJ2.MED2003.MVDS.LIBRARY.NEW' DISP=OLD;
***libname L 'dwj2.b2020.saslib';
***libname L 'DWJ2.FET2003.MVDS.LIBRARY.NEW' DISP=OLD;

 /* W/o any delete statements, does a proc contents, may want to do that first
  * to see what's out there.
  *
  * To delete all: proc datasets KILL library=L; w/o any delete statments.
  */

 /* Toggle */
 /*!!!!!!!!!!!!!!!!!!!! KILL ignores delete statments !!!!!!!!!!!!!*/
 /*!!!!!!!!!!!!!!!!!!!! KILL ignores delete statments !!!!!!!!!!!!!*/
 /*!!!!!!!!!!!!!!!!!!!! KILL ignores delete statments !!!!!!!!!!!!!*/
***proc datasets KILL library=L;
 /*!!!!!!!!!!!!!!!!!!!! KILL ignores delete statments !!!!!!!!!!!!!*/
 /*!!!!!!!!!!!!!!!!!!!! KILL ignores delete statments !!!!!!!!!!!!!*/
 /*!!!!!!!!!!!!!!!!!!!! KILL ignores delete statments !!!!!!!!!!!!!*/
proc datasets library=L;
  ***delete NBNEW;
  /* Must run repair first (can't combine run w/delete) if damaged */
  ***repair tmp;
  delete tmp;
  ***delete UST2002OLDNAT1;
  ***delete UST2003NEWFET;
run;
