
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: Macro
 *  INPUT:            Dataset requiring process order, lookup dataset and keys
 *  PROCESSING:       None
 *  OUTPUT:           Updated dataset with process order
 *******************************************************************************
 */
%macro updateProcessOrder(needsPO, mappingds, key1, key2);
  /* We may already have a PO in dataset needsPO so two steps are required to avoid 
   * overwriting any original value
   */
  proc sql;
    create table &needsPO as
    select a.*, b.Process_Order as po2
    from &needsPO a LEFT JOIN &mappingds b ON a.%upcase(&key1)=b.%upcase(Batch) and
                                              a.%upcase(&key2)=b.%upcase(Material)
    ;
  quit;

  data &needsPO(drop=po2);
    set &needsPO;
    if Process_Order eq '' then
      Process_Order = po2;
  run;
%mend;
