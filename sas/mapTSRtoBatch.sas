
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process data
 *  DESIGN COMPONENT: Macro
 *  INPUT:            Method to map, mapping dataset
 *  PROCESSING:       Map TSR number to batch number
 *  OUTPUT:           Original dataset plus TSR number
 *******************************************************************************
 */
%macro mapTSRtoBatch(meth, map);
  /* Obtain mfg_batch for TSRs where we don't already have mfg_batch */

  %abendIfDSNotExist(&map);

  proc sql;
    create table base_&meth as
    select *, m.batch_lookupTSR as blt
    from base_&meth b LEFT JOIN &map m ON b.study=m.tsrnum
    ;
  quit;

  data base_&meth(drop= tsrnum batch_lookupTSR);
    set base_&meth;
    if mfg_batch eq '' then do;
      mfg_batch = blt;
    end;
  run;

  proc sql;
    select distinct '!!!For UTC TSR to mfg_batch map verification: ', study 'TSR', blt 'mfg_batch'
    from base_&meth
    where study like 'T0%'
    ;
  quit;

  data base_&meth;
    set base_&meth(drop=blt);
  run;
%mend;
