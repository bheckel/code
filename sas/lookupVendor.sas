
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: Macro
 *  INPUT:            Dataset requiring vendor, lookup dataset and keys
 *  PROCESSING:       Lookup vendor
 *  OUTPUT:           Original dataset plus vendor
 *******************************************************************************
 */
%macro lookupVendor(needsVend, mappingds, key1, key2, key3, key4);
  proc sql;
    create table &needsVend as
    select a.*, b.Vendor
    from &needsVend a LEFT JOIN &mappingds b ON a.&key1=b.&key1 and
                                                a.&key2=b.&key2 and
                                                a.&key3=b.&key3 and
                                                a.&key4=b.&key4
    ;
  quit;

  proc sql;
    select distinct '!!!For UTC vendor map verification: ',  mfg_batch 'batch' format=$10., Vendor format=$40.
    from &needsVend
    where Vendor ne ''
    ;
  quit;
%mend;
