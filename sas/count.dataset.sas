options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: count.dataset.sas
  *
  *  Summary: Simple record count of a dataset (NOT a textfile!)
  *
  *           There are more efficient ways to do this w/o running thru ds but
  *           useful if you have to read the ds anyway.
  *
  *  Created: Tue 02 Nov 2004 12:12:13 (Bob Heckel)
  * Modified: Fri 14 Apr 2006 15:34:51 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter fullstimer;


data tmp;
  set SASHELP.shoes SASHELP.shoes SASHELP.shoes END=e;
  if e then
    call symput ('COUNT', _n_);
run;
%put !!! &COUNT;


data _null_;
  set SASHELP.shoes SASHELP.shoes SASHELP.shoes NOBS=o;
  call symput ('COUNT', o);
run;
%put !!! &COUNT;
