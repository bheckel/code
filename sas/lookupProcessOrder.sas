
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: Macro
 *  INPUT:            Dataset requiring process order, lookup dataset and
 *                    keys
 *  PROCESSING:       Lookup process order
 *  OUTPUT:           Original dataset plus process order
 *******************************************************************************
 */
%macro lookupProcessOrder(needsPO, mappingds, key1, key2, key3);
  /* We do not yet have PO in needsPO so this join is sufficient */
  proc sql;
    create table &needsPO as
    select a.*, b.Process_order, b.SAP_Start_Date, b.SAP_End_Date
    from &needsPO a LEFT JOIN &mappingds b ON a.&key1=b.&key1 and
                                              a.&key2=b.&key2 and
                                              a.&key3=b.&key3
    ;
  quit;

  proc sql;
    select distinct '!!!For UTC process order map verification: ',  mfg_batch format=$10., material format=$15., gsk_identifier format=$15., Process_order format=$15.
    from &needsPO
    where Process_order ne '' and material ne ''
    ;
  quit;
%mend;
