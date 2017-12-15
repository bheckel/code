
 /* The problem is that occasionally LIMS data will have 2 consecutive Analysts
  * instead of a single line e.g. abc1234/def5678.  So we look for consecutive Analyst
  * lines and concatenate them.
  */
data lookupAnalyst(keep= mfg_batch gsk_identifier study storage_condition time_point analyst);
  retain hold;
  set base_&meth;
  set base_&meth(firstobs=2 keep=nm tbl rename=(nm=next_nm tbl=next_tbl));

  if tbl eq 'Analyst (Patron ID)';

  if tbl eq next_tbl then do;
    hold = upcase(nm);
    return;
  end;
  else do;
    if hold eq '' then
      analyst = trim(upcase(nm));
    else
      analyst = trim(hold)||'/'||trim(upcase(nm));

    output;

    hold = '';
  end;
run;
