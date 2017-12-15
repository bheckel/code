
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: Utility macro
 *  INPUT:            Filename to check for existence during runtime, type of 
 *                    data to use in case of error
 *  PROCESSING:       Determine if a file does not exist
 *  OUTPUT:           None
 *******************************************************************************
 */
%macro abendIfFileNotExist(fn, type);
  data _null_;
    if not fileexist("&fn") then do;
      put "ERROR: fail! &type &fn does not exist - aborting";
      %put _all_;
      abort abend 002;
    end;
  run;
%mend;
