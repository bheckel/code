
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: Macro
 *  INPUT:            Method across which to distribute vessels
 *  PROCESSING:       Create several vessels out of one
 *  OUTPUT:           Modified input dataset
 *******************************************************************************
 */
%macro expandVessels(meth);
  data tmp(drop= i vessel1 vessel2 vessel3 vessel4 vessel5 vessel6);
    set base_&meth(where=(test='Disso_Percent_Released'));
    do i=1 to 6;
      if i eq 1 then do;
        disso_vessel = i; result=left(trim(vessel1)); output;
      end;
      if i eq 2 then do;
        disso_vessel = i; result=left(trim(vessel2)); output;
      end;
      if i eq 3 then do;
        disso_vessel = i; result=left(trim(vessel3)); output;
      end;
      if i eq 4 then do;
        disso_vessel = i; result=left(trim(vessel4)); output;
      end;
      if i eq 5 then do;
        disso_vessel = i; result=left(trim(vessel5)); output;
      end;
      if i eq 6 then do;
        disso_vessel = i; result=left(trim(vessel6)); output;
      end;
    end;
  run;

  data base_&meth(drop= vessel1 vessel2 vessel3 vessel4 vessel5 vessel6);
    set base_&meth tmp;
    /* Skip result placeholder just processed */
    if result ne 'disso placeholder';
  run;
%mend expandVessels;
