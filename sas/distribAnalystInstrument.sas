
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process LIMS data
 *  DESIGN COMPONENT: Utility macro
 *  INPUT:            Method on which to distribute Analyst and Instrument
 *  PROCESSING:       Lookup analyst and instrument and distribute across
 *                    results
 *  OUTPUT:           Modified input dataset
 *******************************************************************************
 */
%macro distribAnalystInstrument(meth);
  data lookupInstrument(keep= mfg_batch gsk_identifier study storage_condition time_point instrument);
    set base_&meth;

    if tbl in('Instrument Name');

    length instrument $40;
    if tbl eq 'Instrument Name' then do;
      instrument = nm;
    end;
  run;

  data lookupAnalyst(keep= mfg_batch gsk_identifier study storage_condition time_point analyst);
    set base_&meth;

    if tbl in('Analyst (Patron ID)');

    length analyst $40;
    if tbl eq 'Analyst (Patron ID)' then do;
      analyst = upcase(nm);
    end;
  run;

  proc sql; create index ai1 on lookupInstrument(mfg_batch,gsk_identifier,study,storage_condition,time_point); quit;
  proc sql; create index ai2 on lookupAnalyst(mfg_batch,gsk_identifier,study,storage_condition,time_point); quit;
  data lookupIA;
    merge lookupInstrument lookupAnalyst;
    by mfg_batch gsk_identifier study storage_condition time_point;
  run;

  proc sql;
    create table base_&meth as
    select b.*, l.analyst, l.instrument
    from base_&meth b LEFT JOIN lookupIA l ON b.mfg_batch=l.mfg_batch and
                                              b.gsk_identifier=l.gsk_identifier and
                                              b.study=l.study and
                                              b.storage_condition=l.storage_condition and
                                              b.time_point=l.time_point
                                              ;
  quit;

  data base_&meth(drop= tbl nm);
    set base_&meth;
  run;
%mend distribAnalystInstrument;
