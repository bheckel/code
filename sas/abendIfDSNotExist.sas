
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: Utility macro
 *  INPUT:            Dataset to check for existence during runtime
 *  PROCESSING:       Determine if a dataset does not exist
 *  OUTPUT:           None
 *******************************************************************************
 */
%macro abendIfDSNotExist(ds);
  %local cnt;

  proc sql NOPRINT;
    select count(*) into :cnt
    from dictionary.columns 
    where memname eq upcase("&ds");
    ;
  quit;
  %if &cnt eq 0 %then %do;
    data _NULL_; 
      put "ERROR: WORK.&ds does not exist";
      abort abend 002; 
    run;
  %end;
%mend;
