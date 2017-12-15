
/*******************************************************************************
 *                       MODULE HEADER
 *------------------------------------------------------------------------------
 *  REQUIREMENT(S):   Process LIMS data
 *  DESIGN COMPONENT: Macro
 *  INPUT:            Method on which to distribute Dissolution
 *  PROCESSING:       Distribute dissolution across results
 *  OUTPUT:           Modified input dataset
 *******************************************************************************
 */
%macro distribDisso(meth);
  /* Disso requires several more elements distributed than the usual Instrument and/or Analyst */

  data lookupLevel(keep= mfg_batch gsk_identifier study storage_condition time_point test_level disso_loop create_date);
    set base_&meth;

    if tbl in('Stage Evaluated');

    length test_level $40;
    if tbl eq 'Stage Evaluated' then do;
      test_level = upcase(nm);
    end;
  run;

  data lookupInstrument(keep= mfg_batch gsk_identifier study storage_condition time_point instrument disso_loop create_date);
    set base_&meth;

    if tbl in('Instrument Name');

    length instrument $40;
    if tbl eq 'Instrument Name' then do;
      instrument = nm;
    end;
  run;

  data lookupMultidose(keep= mfg_batch gsk_identifier study storage_condition time_point disso_multidose_instr disso_loop create_date);
    set base_&meth;

    if tbl in('Multidose #');

    length disso_multidose_instr __tmp $40;
    if tbl eq 'Multidose #' then do;
      disso_multidose_instr = upcase(nm);
      /* Standardize 6 to MD-6 etc */
      if not index(disso_multidose_instr, 'MD') then
        do;
          __tmp = trim(left(disso_multidose_instr));
          if __tmp not in('N/A', 'NA') then
            disso_multidose_instr = 'MD-' || left(trim(__tmp));
        end;
        drop __tmp;
    end;
  run;

  data lookupBath(keep= mfg_batch gsk_identifier study storage_condition time_point disso_bath disso_loop create_date);
    set base_&meth;

    if tbl in('Dissolution Bath Asset #');

    length disso_bath $40;
    if tbl eq 'Dissolution Bath Asset #' then do;
      disso_bath = upcase(nm);
    end;
  run;

  proc sql; create index dd0 on lookupLevel(mfg_batch,gsk_identifier,study,storage_condition,time_point,create_date,disso_loop); quit;
  proc sql; create index dd1 on lookupInstrument(mfg_batch,gsk_identifier,study,storage_condition,time_point,create_date,disso_loop); quit;
  proc sql; create index dd2 on lookupMultidose(mfg_batch,gsk_identifier,study,storage_condition,time_point,create_date,disso_loop); quit;
  proc sql; create index dd3 on lookupBath(mfg_batch,gsk_identifier,study,storage_condition,time_point,create_date,disso_loop); quit;
  data lookupAllDissoDistribs;
    merge lookupLevel lookupInstrument lookupMultidose lookupBath;
    by mfg_batch gsk_identifier study storage_condition time_point create_date disso_loop;
  run;

  proc sql;
    create table base_&meth as
    select b.*, l.test_level, l.instrument, l.disso_multidose_instr, l.disso_bath
    from base_&meth b LEFT JOIN lookupAllDissoDistribs l ON b.mfg_batch=l.mfg_batch and
                                                            b.gsk_identifier=l.gsk_identifier and
                                                            b.study=l.study and
                                                            b.storage_condition=l.storage_condition and
                                                            b.time_point=l.time_point 
                                                            ;
  quit;

  data base_&meth(drop= tbl nm);
    format create_date DATE9.;
    set base_&meth;
    if tbl ne 'Percent Released Table' then
      delete;
  run;

  proc sort data=base_&meth NODUPKEY;
    by mfg_batch gsk_identifier study storage_condition time_point test test_date vessel1 vessel2 vessel3 vessel4 vessel5 vessel6;
  run;
%mend distribDisso;
