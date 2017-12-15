
/* We may already have a mfg_batch in base_&meth so two steps are required to
 * avoid overwriting the original value (if any) 
 */
%macro mapTSRtoBatch(meth, map);
  /* Obtain mfg_batch for TSRs where we don't already have mfg_batch */
  proc sql;
    create table base_&meth as
    select *, m.batch_lookupTSR as blt
    from base_&meth b LEFT JOIN &map m ON b.study=m.tsrnum
    ;
  quit;

  data base_&meth(drop= tsrnum blt batch_lookupTSR);
    set base_&meth;
    if mfg_batch eq '' then
      mfg_batch = blt;
  run;
%mend;
