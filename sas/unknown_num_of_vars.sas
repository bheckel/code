options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: unknown_num_of_vars.sas
  *
  *  Summary: Number of COLn variables depends on the input dataset.  This
  *           approach eliminates the need to guess at the top array index
  *           e.g. arr[999]
  *
  *  Adapted: Mon 24 May 2004 16:59:07 (Bob Heckel -- Colonoscopy SUGI 054-29)
  * Modified: Wed 06 Aug 2008 12:29:33 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data tmp (keep= region product stores);
  set SASHELP.shoes (obs= 10);
  if region eq: 'A';
run;
proc print data=_LAST_; run;


proc transpose out=tmp2;
  by region;
  var stores;
run;


data tmp2 (drop= i);
  set tmp2;

  /* We take advantage of the fact that proc transpose using the convention
   * "COLn" for the var names it creates 
   */
  array arr[*] COL: ;

  do i=1 to dim(arr);
    put _ALL_;
    put '';
  end;
run;


 
 /* Alternative (worse?): */

 /* Build mvar for an unknown-until-runtime number of vars:
  * e.g. col1 || ';' || col2 || ';' ||  col3 || ';' || col4 || ';' || col5; ... 
  */
proc sql NOPRINT;
  /* Using semicolon as separator */
  select distinct(name) into :VARLIST separated by "||';'||"
  from dictionary.columns
  where libname eq 'WORK' and memname eq 'LOTLOOKUP' and name like 'COL%'
  ;
quit;
data lotlookup;
  set lotlookup;
  Vendor_Lots = &VARLIST;
  Vendor_Lots = compress(left(trim(Vendor_Lots)));
run;
data lotlookup(drop= r more);
  set lotlookup;
  r = reverse(trim(left(Vendor_Lots)));
  more = 'yes';
  do while (more eq 'yes');
    if r eq: ';' then 
      r = substr(r, 2);

    if r eq: ';' then 
      more = 'yes';
    else
      more = 'no';
  end;

  Vendor_Lots = reverse(left(trim(r)));
run;
