
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: Utility macro
 *  INPUT:            Dataset to prepend leading zero, new dataset name
 *  PROCESSING:       Prepend a leading zero
 *  OUTPUT:           None
 *******************************************************************************
 */
%macro add_leading_zero(ds, outname);
  /* Must force a leading zero for later merges */
  data &outname(rename=(SAP_ProcessOrder=Process_order));
    length zeroInsp_lot $50;
    set &ds;

    /* If the XLS' Insp_lot col wasn't originally saved as Numeric, we get this: */
    if Insp_lot =: '8.9E+11' then do;
      call symput('UNEXPECTEDERR', '8.9E+11');
      put "ERROR: must reformat lookup spreadsheet &ds column A to Numeric to avoid exponent representation";
      put _all_;
    end;

    /* E.g. 40000406074 needs it but 890000014201 doesn't */
    if length(Insp_Lot) eq 11 then
      zeroInsp_lot = '0'||compress(Insp_lot);
    else
      zeroInsp_lot = Insp_lot;
  run;
%mend;
