options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: insert_subtotals.sas
  *
  *  Summary: Insert subtotals into existing dataset
  *
  *  Created: Mon 23 Jan 2012 14:14:19 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

/* Add Total grouping per requirements IT01132 */
proc sort data=ci_ind&stren;
  by SampId SampName SampCreateTS SpecName Name Market device RowIx;
run;
data ci_ind&stren;
  set ci_ind&stren;
  by SampId SampName SampCreateTS SpecName Name Market device RowIx;

  /* result is char */
  numres = input(result, F8.);

  if first.device then do;
    subtotal = 0;
  end;

  if test in('CASCADE IMPACTION -  SUM-FPM', 'CASCADE IMPACTION -  SUM-TP0', 'CASCADE IMPACTION -  SUM-67&F') then do;
    subtotal+numres;
  end;

  output;

  if last.device then do;
    test = 'CASCADE IMPACTION - TOTAL';
    result = subtotal;
    output;
  end;
run;


endsas;

/* This may be necessary first if there are no existing DEVICEs to disambiguate
   the groupings:
   */
  data ci;
    set ci;

    /* Create an arbitrary devicenumber (like Serevent already has) so that stage Tot works */
    if lims_id4 eq 'TP0' then do;
      dev+1;
    end;
  run;
