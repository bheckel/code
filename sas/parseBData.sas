
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
%macro parseBData(dsets, outname);
  data &outname;
    length strength granulator market $40;
    set &dsets;

    if index(Product, '500') then
      strength = '500 mg';
    else if index(Product, '1000') then
      strength = '1000 mg';

    if index(upcase(Product), 'FIELDER') then
      granulator = 'Fielder';
    else if index(upcase(Product), 'LODIGE') then
      granulator = 'Lodige';

    Vendor = Drug_Substance_Vendor;

    /* We want 'CANADA' anywhere or 'CAN' at end of string e.g. "Valtrex Caplets 500 mg Can" */
    if (index(upcase(Product), 'CANADA')) or (reverse(upcase(left(trim(Product)))) eq: 'NAC ') then
      market = 'Canada';
    else if scan(Product, 2, '-') eq 'Canada' then
      market = 'Canada';
    else
      market = 'USA';

    keep Batch strength granulator market Material Vendor Process_Order InspectionLot;
    rename Batch=mfg_batch InspectionLot=gsk_identifier;
  run;
%mend;
