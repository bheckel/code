
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: LIMS parsing Macro
 *  INPUT:            Dataset requiring inspection lot, lookup dataset and
 *                    keys
 *  PROCESSING:       Lookup material
 *  OUTPUT:           Original dataset plus material code
 *******************************************************************************
 */                                                                                                                                                                                 /*}}}*/
%macro lookupMatlCode(needsMatl, mappingds, key1, key2, key3, key4);
  proc sql;
    create table &needsMatl as
    select a.*, b.Material
    from &needsMatl a LEFT JOIN &mappingds b ON a.&key1=b.&key3 and
                                                a.&key2=b.&key4
    ;
  quit;

  proc sql;
    select distinct '!!!For UTC mfg_batch to material map verification: ',  mfg_batch, material
    from &needsMatl
    where material ne ''
    ;
  quit;
%mend;
