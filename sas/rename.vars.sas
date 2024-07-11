options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: rename.sas
  *
  *  Summary: Demo of renaming variables.  Compare with using AS in SQL
  *
  *  Created: 21-May-2003 (Bob Heckel)
  * Modified: 05-Jul-2024 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

 /* Best - one swoop */
data d9(drop=long_test_name rename=(long_test_name2=long_test_name));
  set d8;

  if long_test_name eq 'Cascade Impaction - Individual Stages - FP (mcg/blister)' and replicate_id IN ('2','7','12','17') then do;
    long_test_name2 = 'Cascade Impaction - Stage 1-2 - FP (mcg/blister)';
  end;
run;



 /*                    reverse assignment! */
data finished (rename= oldvar=newvar);
  merge tmp tmpsum;
  by cause;
run;

 /* or */
data finished (keep= cause count  rename=(UPPERCASEVAR=uppercasevar));
  merge tmp tmpsum;
  by cause;
run;

 /* or multiple renames */
data finished (keep= cause count rename= (o1=n1 o2=n2));
  merge tmp tmpsum;
  by cause;
run;

 /* or as a statement */
data MIPatients(drop= Field2 Field3 Field4 Field5);
  set Patients;
  /*       old      new   */
  rename Field1=ID_Number
         Field6=Sex;
    
  label Field1='ID_Number'
        Field6='Sex' ;
run;

/***/

data forecast.kmc_renewal_forecast_alloc(drop=acct_id);
  set forecast.kmc_renewal_forecast_alloc;
  acct_id2 = input(acct_id, ?? 8.);
  rename acct_id2=acct_id;
run;
