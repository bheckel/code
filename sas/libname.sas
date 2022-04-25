options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: libname.sas
  *
  *  Summary: Assign, deassign and concatenate libnames.
  *
  *           See dictionary_proc_sql.sas for interrogating libnames
  *
  *  Created: Mon 22 Mar 2004 14:12:35 (Bob Heckel)
  * Modified: Wed 16 May 2018 14:09:32 (Bob Heckel)
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



%let bom_previous=%sysfunc(intnx(MONTH, "&SYSDATE"d, -1, B),YYMMDDN.); 
data _null_;
  if fileexist("/Drugs/TMMEligibility/BRStores/Dashboard/&bom_previous") then do;
    call execute("libname l '/Drugs/TMMEligibility/BRStores/Dashboard/&bom_previous' access=readonly;");
  end;
run;

---

libname mirror  server=mkcdata.shr1 access=readonly;
/* List all datasets in libname */
proc contents data = mirror._ALL_ NODS; run;
