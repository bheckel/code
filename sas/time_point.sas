
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: LIMS parsing macro
 *  INPUT:            Method on which to add time point (studies only)
 *  PROCESSING:       Determine time point
 *  OUTPUT:           None
 *******************************************************************************
 */
%macro time_point(meth);
  length time_point $10;
  
  if &meth._SampleName eq: 'SC' then do;
    time_point = scan(&meth._SampleName, 3, '-');
  end;
  else do;
    time_point = '0';
  end;
%mend;
