options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: libname.sas
  *
  *  Summary: Assign, deassign and concatenate libnames.
  *
  *           See dictionary_proc_sql.sas for interrogating libnames
  *
  *  Created: Mon 22 Mar 2004 14:12:35 (Bob Heckel)
  * Modified: Thu 10 Mar 2011 14:31:02 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

libname RO 'c:/temp/' access=readonly;
libname RW 'c:/temp/';
 /* Specify engine */
libname B v6 'c:/cygwin/tmp/';
 /* libname concatenation.  Works on z/OS too.  
  * Only a WARNING: for idontexist/ 
  */
libname MULTI ('c:/temp' 'c:/cygwin/tmp/' 'c:/idontexist');
libname MULTI list;

 /* Fails as expected */
data RO.foo;
  set SASHELP.shoes;
run;

***libname _ALL_ list;
***libname _ALL_ clear;
 /* Fails!  Must do one at a time (or _ALL_ at once). */
***libname RO RW clear; 
