
/*******************************************************************************
 *                       module header
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: LIMS parsing macro
 *  INPUT:            Method on which to add status
 *  PROCESSING:       Filter status
 *  OUTPUT:           None
 *******************************************************************************
 */
%macro status(meth);
  length status $2;

  status = &meth._Status;

  if status not in('A','IP') then do;
    %print_warning(status);
    delete;
  end;
%mend status;
