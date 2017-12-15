
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: Macro
 *  INPUT:            Dataset requiring inspection lot and lookup dataset
 *  PROCESSING:       Lookup inspection lot
 *  OUTPUT:           Original dataset plus inspection lot
 *******************************************************************************
 */
%macro lookupInspLot(needsIL, mapping);
  /* Based on SAP process order, updates needsIL dataset with inspection lot
   * number to later map on key: batch, matl, procord, gsk/insplot 
   */
  proc sql;
    create table tmp as
    select b.Batch, b.Material, b.Process_order, a.zeroInsp_lot as InspectionLot
    from &mapping a JOIN &needsIL b ON a.Batch=b.Batch and
                                       a.Material=b.Material and
                                       a.Process_order=b.Process_order
    ;
  quit;


  proc sql;
    create table &needsIL as
    select a.*, b.InspectionLot
    from &needsIL a LEFT JOIN tmp b ON a.Batch=b.Batch and
                                       a.Material=b.Material and
                                       a.Process_order=b.Process_order
    ;
  quit;

  /* Reorder */
  data &needsIL;
    retain Product Batch Material Process_order;
    set &needsIL;
    put "!!!For UTC-IL Map: " Batch= Material= Process_order= InspectionLot=;
  run;
%mend;
