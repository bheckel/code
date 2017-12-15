
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: LIMS parsing macro
 *  INPUT:            Method from which to determine gsk_id
 *  PROCESSING:       None
 *  OUTPUT:           None
 *******************************************************************************
 */
%macro gsk_identifier(meth);
  if &meth._SampleName ne: 'SC' and &meth._SampleName ne: 'T' then
    gsk_identifier = scan(&meth._SampleName, 2, '-');
  else
    gsk_identifier = '';

  if length(gsk_identifier) ne 12 and gsk_identifier ne '' then do;
    %print_warning(gsk_identifier);
    delete;
  end;
%mend gsk_identifier;
