
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: Macro
 *  INPUT:            Dataset(s) to process and output name
 *  PROCESSING:       Standardize batch data spreadsheets
 *  OUTPUT:           Updated dataset
 *******************************************************************************
 */
%macro parseBDatas(dsets, outname);
  data &outname;
    length strength granulator market $40;
    set &dsets;

    if index(Product, '500') then
      strength = '500 mg';
    else if index(Product, '1000') then
      strength = '1000 mg';

    t1 = index(Product, '(');
    t2 = index(Product, ')');
    t3 = t2-t1;
    if t1+t2 gt 0 then do;
      granulator = substr(Product, t1+1, t3-1);
      /* Don't want  Fielder-CANADA */
      granulator = scan(granulator, 1, '-');
    end;

     Vendor = Drug_Substance;

    /* We want 'CANADA' anywhere or 'CAN' at end of string e.g. "Valtrex Caplets 500 mg Can" */
    if (index(upcase(Product), 'CANADA')) or (reverse(upcase(left(trim(Product)))) eq: 'NAC ') then
      market = 'Canada';
    else if scan(Product, 2, '-') eq 'Canada' then
      market = 'Canada';
    else
      market = 'USA';

    keep Batch strength granulator market Material Vendor Process_order;
    rename Batch=mfg_batch;
  run;
%mend;
