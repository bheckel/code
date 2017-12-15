
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: LIMS parsing macro
 *  INPUT:            Method on which to add market
 *  PROCESSING:       None
 *  OUTPUT:           None
 *******************************************************************************
 */
%macro market(meth);
  length market $40;

  /* We want 'CANADA' anywhere or 'CAN' at end of string e.g. "Valtrex Caplets 500 mg Can" */
  if (index(upcase(&meth._Description), 'CANADA')) or (reverse(upcase(left(trim(&meth._Description)))) eq: 'NAC ') then
    market = 'Canada';
  else
    market = 'USA';
%mend market;
