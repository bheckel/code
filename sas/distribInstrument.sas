
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process LIMS data
 *  DESIGN COMPONENT: Macro
 *  INPUT:            Method on which to distribute Instrument
 *  PROCESSING:       Modify dataset to distribute the INT condition
 *  OUTPUT:           Modified input dataset
 *******************************************************************************
 */
%macro distribInstrument(meth);
  data lookupInstrument(keep= mfg_batch gsk_identifier study storage_condition time_point instrument);
    set base_&meth;

    if tbl in('Instrument Name');

    length instrument $40;
    if tbl eq 'Instrument Name' then do;
      instrument = nm;
    end;
  run;

  proc sql;
    create table base_&meth as
    select *
    from base_&meth b LEFT JOIN lookupInstrument l ON b.mfg_batch=l.mfg_batch and
                                              b.gsk_identifier=l.gsk_identifier and
                                              b.study=l.study and
                                              b.storage_condition=l.storage_condition and
                                              b.time_point=l.time_point
                                              ;
  quit;

  data base_&meth(drop= tbl nm);
    set base_&meth;
  run;
%mend distribInstrument;
