options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: flip_obs_to_vars.sas
  *
  *  Summary: Flipping observations to variable (rows to columns).  Variable
  *           names are the former values of the variable PRODUCT.
  *
  *  Adapted: Thu 10 Sep 2009 15:57:47 (Bob Heckel -- SUGI 354-2009)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

data one;
  input product $ contract;
  datalines;
BE2 360
BE2 361
BE3 362
BE4 363
CE1 440
CE1 441
CE1 442
CE2 551
CE2 552
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

 /* Good demo of filling an array dynamically */
proc sql noprint;
  select distinct(product) into :varlist separated by ' '
  from one
  ;
  select count(distinct product) into :ct
  from one
  ;
quit;
 
data done(drop=product contract i);
  set one;
  by product;
  array myvar[&ct] $ &varlist;
  do i=1 to &ct;
    if product = vname(myvar(i)) then do;
      myvar[i]=left(put(contract,8.));  /* convert contract from num to char */
      put _ALL_;  /* debugging */
      leave;  /* unnecessary but apparently efficient */
    end;
  end;
run;
 /*
Obs    BE2    BE3    BE4    CE1    CE2

 1     360                            
 2     361                            
 3            362                     
 4                   363              
 5                          440       
 6                          441       
 7                          442       
 8                                 551
 9                                 552
 */
proc print data=_LAST_(obs=max) width=minimum; run;


 /* For comparison, proc transpose doesn't do it */
proc transpose data=one;
  by product;
  var contract;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
