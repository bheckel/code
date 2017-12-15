options nosource;
 /*---------------------------------------------------------------------------
  *     Name: sysprod.sas
  *
  *  Summary: Demo of determining if a SAS product is licensed.
  *           
  *           See proc_setinit.sas for a list of all products available.
  *
  *  Adapted: Fri 21 Feb 2003 17:17:33 (Bob Heckel -- SAS Tips & Techniques
  *                                     Phil Mason)
  *---------------------------------------------------------------------------
  */
options source;

data _NULL_;
  if sysprod('graph') eq 1 then
    put '!!! SAS Graph is licensed (but not necessarily installed)';
  else
    put '!!! SAS Graph is NOT licensed';
run;
