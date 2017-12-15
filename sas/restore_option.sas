options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: restore_option.sas
  *
  *  Summary: Determine current SAS options and restore later.
  *
  *  Created: Fri 16 Jan 2009 10:12:10 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source pagesize=20 mlogic;

 /* TODO not working */

proc sql;
/***describe table DICTIONARY.options***/
  select setting into :TMPMLOGIC
  from DICTIONARY.options
  where optname = 'MLOGIC'
  ;
quit;

options nomlogic;

data _null_;
  call execute('options ' || &TMPMLOGIC || ';');
run;

