
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: LIMS parsing macro
 *  INPUT:            Method on which to add study code
 *  PROCESSING:       Determine study code
 *  OUTPUT:           None
 *******************************************************************************
 */
%macro study(meth);
  length study $40;

  if &meth._SampleName eq: 'SC' then do;
    study = substr(&meth._SampleName, 1, 8);
  end;
  /* T06-1066 */
  else if &meth._SampleName eq: 'T' then
    study = &meth._SampleName;
  else do;
    study = 'Release';
  end;
%mend;
