options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: sql_mkempty_dataset.sas
  *
  *  Summary: Create a skeleton dataset.
  *
  *  Created: Tue 07 Jun 2005 14:52:28 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter NOreplace;

proc sql;
  create table foo like SASHELP.shoes;
quit;

proc contents data=foo; run;
