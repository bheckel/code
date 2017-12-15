
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process LIMS data
 *  DESIGN COMPONENT: Utility macro
 *  INPUT:            Method on which to process 'description'
 *  PROCESSING:       None
 *  OUTPUT:           None
 *******************************************************************************
 */
%macro description(meth);
  length description $200;

  description = &meth._Description;

  if description ne: 'Val' and description ne 'TSR' and description ne: 'Technical' then do;
    %print_warning(description);
    delete;
  end;
%mend;
