
/*******************************************************************************
 *                       module header
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: Utility macro
 *  INPUT:            Dataset on which to split CU results
 *  PROCESSING:       None
 *  OUTPUT:           Dataset with split CU results
 *******************************************************************************
 */
%macro splitResults(ds);
  /* Because data exists in 2 columns for one result - "2,Sample Weight (Mg)"
   * & "3,Uniformity Of Dosage (Mg)" we must split the single obs into 2.
   */
  data removeOrigWeights;
    set &ds;
    if test eq 'Content_Unif_by_Weight_EITHER' then delete;
  run;

  data stackPctMg;
    set &ds;
    if result eq 'cuweight placeholder' then do;
      do i=1 to 2;
        if i eq 1 then do;
          test = 'Content_Unif_by_Weight_pct';
          result = pct; 
          output;
        end;
        if i eq 2 then do;
          test = 'Content_Unif_by_Weight_mg';
          result = mg;
          output;
        end;
      end;
    end;
  run;

  data &ds(drop= i pct mg);
    set removeOrigWeights stackPctMg;
    result = left(trim(result));
  run;
%mend splitResults;
