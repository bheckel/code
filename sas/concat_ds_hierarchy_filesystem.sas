options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: concat_ds_hierarchy_filesystem.sas
  *
  *  Summary: Recurse a filesystem to aggregate a common variable.
  *
  *  Created: Fri 28 Oct 2011 10:25:54 (Bob Heckel)
  * Modified: Tue 22 Jan 2013 12:52:46 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* $ find $x/datapost/data/gsk/zebulon -name 'lims*t_*.sas7bdat' */
libname lims (
  'x:/datapost/data/gsk/zebulon/soliddose/wellbutrin'
  'x:/datapost/data/gsk/zebulon/soliddose/zofran'
  'x:/datapost/data/gsk/zebulon/soliddose/zovirax'
  'x:/datapost/data/gsk/zebulon/soliddose/zyban'
  ) access=readonly;

libname lims list;

/*
Obs libname    memname                     memtype    engine    index

  1  LIMS      LIMS_0004T_VALTREX           DATA        V8       no  
  2  LIMS      LIMS_0007T_WELLBUTRIN        DATA        V8       no  
  3  LIMS      LIMS_0014T_RETROVIR          DATA        V8       no  
*/
proc sql NOPRINT;
  select memname into :DSETS separated by ' LIMS.'
  from dictionary.members
  /* Upcase! */
  where libname like 'LIMS' and index(memname, 'T_');
quit;
%put &DSETS;


data t;
  set LIMS.&DSETS;
run;

 /* Assumes test_status is common across all *T_* datasets */
proc freq data=t;
  table test_status;
run;
