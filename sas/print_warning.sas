
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: Macro
 *  INPUT:            Column name to check for valid data
 *  PROCESSING:       None
 *  OUTPUT:           None
 *******************************************************************************
 */
%macro print_warning(colnm);
  %local f;

  %let f = &DIRROOT\CODE\log\&currmeth._&colnm._Error.txt;

  /* An empty file will be produced if no errors.  That can be used to verify 
   * the last run time of DataPost.
   */
  file "&f";
  put "&SYSDATE &SYSTIME WARNING UNEXPECTED INPUT DATA: " (_all_)(=);
  put '0D'x;

  file LOG;
%mend print_warning;
