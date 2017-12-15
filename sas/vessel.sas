
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: LIMS parsing macro
 *  INPUT:            Method on which to add vessel
 *  PROCESSING:       Determine vessels
 *  OUTPUT:           None
 *******************************************************************************
 */
%macro vessel(meth);
  length vessel1 vessel2 vessel3 vessel4 vessel5 vessel6 $20;

  if &meth._Component eq 'VALACYCLOVIR' then do;
    vessel1 = &meth._Vessel1;
    vessel2 = &meth._Vessel2;
    vessel3 = &meth._Vessel3;
    vessel4 = &meth._Vessel4;
    vessel5 = &meth._Vessel5;
    vessel6 = &meth._Vessel6;
  end;
%mend vessel;
