
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: Macro
 *  INPUT:            Method to map, mapping dataset
 *  PROCESSING:       Map stability study to strength
 *  OUTPUT:           Original dataset plus strength
 *******************************************************************************
 */
%macro mapStabToStrength(meth, map);
  %abendIfDSNotExist(base_&meth);
  %abendIfDSNotExist(&map);

  /* We may already have a strength in base_&meth so two steps are required to avoid 
   * overwriting the original value (if any) 
   */
  proc sql;
    create table base_&meth as
    select b.*, m.product_lookup
    from base_&meth b LEFT JOIN &map m ON b.study=m.study_lookup
    ;
  quit;

  data base_&meth(drop=product_lookup);
    set base_&meth;
    if strength eq '' then do;
      if index(product_lookup, '500') then
        strength = '500 mg';
      else if index(product_lookup, '1000') then
        strength = '1000 mg';
      else
        strength = '';
    end;
  run;
%mend;
