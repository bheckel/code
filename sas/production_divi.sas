
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: Macro
 *  INPUT:            Dataset and mapping dataset
 *  PROCESSING:       Lookup inspection lot
 *  OUTPUT:           Updated dataset including inspection lot
 *******************************************************************************
 */
%macro production_divi(divi, mapping);
  /* Updates existing &divi dataset with inspection lot number to later map
   * with indiv analytical dataset on key: batch, matl, procord, gsk/insplot 
   */
  data &mapping;
    length zeroInsp_lot $50;
    set &mapping;
    /* Must force a leading zero */
    zeroInsp_lot = '0'||compress(Insp_lot);
  run;

  proc sql;
    create table tmpLookupInspLot as
    select d.Batch, d.Material, d. Process_order, m.zeroInsp_lot
    from &mapping m JOIN &divi d ON m.Batch=d.Batch and
                                    m.Material=d.Material and
                                    m.SAP_ProcessOrder=d.Process_order
    ;
  quit;

  proc sql;
    create table &divi as
    select d.*, l.zeroInsp_lot
    from &divi d LEFT JOIN tmpLookupInspLot l ON d.Batch=l.Batch and
                                                 d.Material=l.Material and
                                                 d.Process_order=l.Process_order
    ;
  quit;

  /* Reorder */
  data &divi;
    retain Product Batch Material Process_order Inspection_Lot;
    set &divi(drop=Inspection_Lot rename=(zeroInsp_lot=Inspection_Lot));
  run;
%mend production_divi;
