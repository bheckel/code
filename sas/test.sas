
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: LIMS parsing macro
 *  INPUT:            Method on which to add test name
 *  PROCESSING:       Determine test name
 *  OUTPUT:           None
 *******************************************************************************
 */
%macro test(meth);
  /* These test names are used by %result() so we may have to edit there too if
   * changes are made here.  Will require customization for each method. 
   *
   * Must be followed by %result()
   */
  length test $100;

  %if &meth eq Assay %then %do;
    if &meth._Table eq 'Peak Info' then
      test = 'HPLC_Assay';
    else if &meth._Table eq 'Peak Info Impurities' then
      test = 'HPLC_Imp_' || &meth._peak_name;
  %end;

  %else %if &meth eq CU %then %do;
    if &meth._Table eq 'Peak Info' then
      test = 'Content_Uniformity_Percentage';
    else if &meth._Table eq 'Acceptance Value' then
      test = 'Content_Uniformity_Acceptance';
  %end;

  %else %if &meth eq ID_HPLC %then %do;
    if &meth._Table eq 'ID byTLC' then
      test = 'ID_by_HPTLC';
  %end;

  %else %if &meth eq Dissolution %then %do;
    if &meth._Table eq 'Percent Released Table' then
      test = 'Disso_Percent_Released';
  %end;

  %else %if &meth eq LOD %then %do;
    if &meth._Table eq 'Percent Loss on Drying' then
      test = 'LOD_Percent';
  %end;

  %else %if &meth eq CU_WEIGHT %then %do;
    if &meth._Table eq 'Calc Unifomity of Dosage' then
      test = 'Content_Unif_by_Weight_EITHER';
    else if &meth._Table eq 'Acceptance Value' then
      test = 'Content_Unif_Acceptance_Value';
  %end;
%mend test;
