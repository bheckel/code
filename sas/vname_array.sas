options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: vname_array.sas
  *
  *  Summary: CALL VNAME allows you to create a character variable whose value
  *           is the (var)name (not the value) of another variable.
  *
  *  Adapted: Mon 17 May 2010 11:08:04 (Bob Heckel--SUGI 146-2010)
  * Modified: Wed 09 Oct 2013 14:40:25 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

 /* Want to transpose BE2... to be varnames */
data t;
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

 /* This won't work */
proc transpose;
  by product;
  id contract;
  var product;
run;
/*
Obs    product    _NAME_     360    361    362    363    440    441    442    551    552

 1       BE2      product    BE2    BE2                                                 
 2       BE3      product                  BE3                                          
 3       BE4      product                         BE4                                   
 4       CE1      product                                CE1    CE1    CE1              
 5       CE2      product                                                     CE2    CE2
*/

proc sql NOprint;
  select distinct(product) into :varlist separated by ' '
  from t;
  select count(distinct product) into :cnt
  from t;
quit;

data t(drop= product contract i);
  set t;
  by product;

  /* Because an array is a temporary grouping of variables, each array element
   * is assumed to be a variable name.  But at this point in the datastep there
   * are technically no variables (yet) named CE1 etc so they're all missing
   * values.  Assignment happens in the do loop.
   */
/***  array a[5] $ BE2 BE3 BE4 CE1 CE2;***/
  array a[&cnt] $ &varlist;

  do i=1 to dim(a);
    /* If the array variable's name, e.g. for a[4] it's CE1, is the same as
     * product...
     */
    if product eq vname(a[i]) then do;
      /* ...then assign its value, e.g. 440, into that variable, e.g. a[4] or
       * CE1
       */
      a[i] = put(contract, 8. -L);
      leave;  /* optional, save some time */
    end;
  end;
run;
proc print data=_LAST_(obs=max) width=minimum; run;
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



endsas;
data foo;
  /* ... */
  array arr amountpeakinfo initialwt emptywt wtofsusp freeconc;
  do i=1 to dim(arr);
    vess = i;
    result = arr{i};
    short_test_name_level2 = left(trim(PEAKNAME_)) || '-' || vname(arr{i}) ;
    if not missing(result) then output;
  end;
  /* ... */
run;
    


data t;
  input var1 var2 var3 charvar1 $;
  cards;
1 -100 99 abc
 -2 200 999 def
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

data _null_;
  set t ;
  length badvar $32;  /* max len of a SAS varname */

  array numarr[*] _numeric_;  /* now we don't have to specify all num vars */

  do i=1 to dim(numarr);
    put 'looking at value ' numarr[i] ': '  _all_;
    /* Check if array element's *value* is negative (i.e. a BAD var) */
    if numarr[i] lt 0 then do;
      /* CALL VNAME sets variable BADVAR to *name* of current array element. */
      call vname(numarr[i], badvar);
      put '!!!WARNING: Observation: ' _N_ 'Variable: ' badvar ' Value: ' numarr[i];
    end;
  end;
run;
