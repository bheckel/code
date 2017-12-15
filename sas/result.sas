
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: LIMS parsing macro
 *  INPUT:            Method on which to add result
 *  PROCESSING:       Determine result 
 *  OUTPUT:           None
 *******************************************************************************
 */
%macro result(meth);
  /* Must be preceded by %test() where test is assigned a 
   * string per the BR.
   * 
   * These test names are used by %test() so we may have to edit there too if
   * changes are made here.
   */
  length result $50;

  %if &METH eq Assay %then %do;
    if test eq 'HPLC_Assay' then
      result = left(trim(&meth._Vial_btl_avg));
  else if test eq: 'HPLC_Imp_' then do;
    if index(&meth._Result_loq, '<0.05') then
      delete;
    result = left(trim(&meth._Result_loq));
  end;
  %end;

  %if &METH eq CU %then %do;
    if test eq 'Content_Uniformity_Percentage' then
      result = left(trim(&meth._Vial_btl_avg));
    else if test eq 'Content_Uniformity_Acceptance' then
      result = left(trim(&meth._Name));
  %end;

  %if &METH eq ID_HPLC %then %do;
    if test eq 'ID_by_HPTLC' then
      result = left(trim(&meth._result_comment));
  %end;

  %if &METH eq Dissolution %then %do;
    if test eq 'Disso_Percent_Released' then do;
      /* Six vessel results must be transposed later, we must have some value
       * here for the unused single result field to avoid deleting the obs in a later macro. 
       */
      result = 'disso placeholder';
    end;
  %end;

  %if &METH eq LOD %then %do;
    if test eq 'LOD_Percent' then
      result = left(trim(&meth._Result_Comment));
  %end;

  %if &METH eq CU_WEIGHT %then %do;
    if test eq 'Content_Unif_by_Weight_EITHER' then do;
      /* Six vessel results must be transposed later, we must have some value
       * here to avoid deleting the obs in a later macro. 
       */
      result = 'cuweight placeholder';
    end;
    else if test eq 'Content_Unif_Acceptance_Value' then do;
      result = left(trim(&meth._Component));
    end;
  %end;
  /* Do not delete blank results here (distribAnalyst* uses blank lines) */
%mend result;
