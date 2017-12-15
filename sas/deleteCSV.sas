
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: Utility macro
 *  INPUT:            Temporary CSV file to be deleted
 *  PROCESSING:       None
 *  OUTPUT:           None
 *******************************************************************************
 */                                                                                                                                                                                 /*}}}*/
%macro deleteCSV(csvfile);
  %if &DELCSVS eq yes %then %do;
    %sysexec "del &csvfile";
  %end;
%mend;
