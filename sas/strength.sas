
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: LIMS parsing macro
 *  INPUT:            Method on which to add strength
 *  PROCESSING:       Determine strength
 *  OUTPUT:           None
 *******************************************************************************
 */
%macro strength(meth);
  /* This only fills unambiguous strengths */
  length strength $20;

  if index(&meth._Description, '500 and 1000') then
    strength = '';  /* filled via map study to batch later */
  else if index(&meth._Description, '500') then
    strength = '500 mg';
  else if index(&meth._Description, '1000') then
    strength = '1000 mg';
  else if index(&meth._Description, 'Technical Service Request') then
    strength = '';
  else if index(&meth._Description, 'TSR') then
    strength = '';
  else
    strength = '';
%mend strength;
