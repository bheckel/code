options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: VA_validation_dataset_build.sas
  *
  *  Summary: Build dataset that will be used for validation during the VA
  *           prescriber load process.
  *
  *  Created: Wed 03 Aug 2005 10:06:49 (RH)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

libname L 'X:/BPMS/VA/Data/Providers/SAS';

data L.prescriber_validation (drop=ignore medicaid_prescriber_id_numeric);
  infile 'X:/BPMS/VA/Docs/pharmacy_list.csv' DLM=',' DSD MISSOVER FIRSTOBS=2;
  length medicaid_prescriber_id $9;
  input ignore $  medicaid_prescriber_id_numeric;
  /* Convert to char for later comparision with char var state_license */
  medicaid_prescriber_id = put(medicaid_prescriber_id_numeric, Z9.);
  ;
run;
