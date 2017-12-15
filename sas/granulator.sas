
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: LIMS parsing macro
 *  INPUT:            Method from which to determine granulator
 *  PROCESSING:       None
 *  OUTPUT:           None
 *******************************************************************************
 */
%macro granulator(meth);
  length granulator $40;

  /* "Valtrex Caplets 500 mg (LODIGE)" */
  /*                          ______   */
  t1 = index(&meth._Description, '(');
  t2 = index(&meth._Description, ')');
  if t1+t2 gt 0 then do;
    if not index(&meth._Description, 'TSR') then do;
      granulator = substr(&meth._Description, t1+1, t2-1-t1);
      /* "Valtrex Caplets 500 mg (Fielder-Canada)" */
      if index(granulator, '-') then
        granulator = scan(granulator, 1, '-');
    end;
  end;
  /* "Valtrex Caplets 500 mg Can" */
  else if reverse(upcase(left(trim(&meth._Description)))) eq: 'NAC ' then do;
    granulator = 'Fielder';
  end;
  else
    granulator = '';

  drop t1 t2;

  /* Dartford is not a granulator even though it looks like it: 
   * "Valtrex Caplets 1000 mg (Dartford)"
   */
  if upcase(granulator) eq 'DARTFORD' then
    granulator = '';

  if upcase(granulator) not in('FIELDER', 'LODIGE', '') then do;
    %print_warning(granulator);
    delete;
  end;
%mend granulator;
