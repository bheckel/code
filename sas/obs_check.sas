
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: Macro
 *  INPUT:            Dataset, low count threshold, processing step number and
 *                    severity warning level
 *  PROCESSING:       None
 *  OUTPUT:           None
 *******************************************************************************
 */
%macro obs_check(ds, warncnt, step, severity);
  /* Warn or die if an unusually low number of obs exists */
  %local dsid cnt rc;

  %let dsid=%sysfunc(open(&ds)); 
  %let cnt=%sysfunc(attrn(&dsid, NOBS)); 
  %let rc=%sysfunc(close(&dsid));

  %if &cnt le &warncnt %then %do;
    %put WARNING: OBSLOWERR ds &ds / cnt &cnt / step &step;
    /* global! */
    %let OBSLOWERR = %eval(&cnt+1);

    libname ERROUT "&DIRROOT\CODE\log";
    data ERROUT.&ds;
      set &ds;
    run;

    %if &severity eq die %then %do;
      data _null_;
        put "ERROR: fail! low or no records in input data - aborting";
        %put _all_;
        abort abend 002;
      run;
    %end;
  %end;
%mend;
