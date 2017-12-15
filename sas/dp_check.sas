options ls=180;

***%let B=1ZM8244;
***%let B=1ZM8239;
***%let B=1ZM8243;
***%let B=1ZM0538;
***%let B=1ZM0228;
%let B=0ZM0167;
***%let B=1ZM8756;
***%let B=1ZM0412;
***%let DS=l.ods_0101e_sd l.ods_0102e_sd;  /* Meth */
***%let DS=l.ods_0103e_sd l.ods_0104e_sd;  /* Lami */
***%let DS=l.ods_0105e_sd l.ods_0106e_sd;  /* Valt */
%let DS=l.ods_0105e_sd;  /* Valt */
***%let DS=l.ods_0107e_sd l.ods_0108e_sd;  /* Bupro */
***%let DS=l.ods_0109e_sd l.ods_0110e_sd;  /* Well */
***%let DS=l.ods_0111e_sd l.ods_0112e_sd;  /* Zyb */

data t;
  set &DS;
  ***res=result+0.0;
  ***res=result;
  res=input(result, ?? COMMA9.);
run;
proc sql NOprint;
  select distinct method_id format=$14., lift_test_description format=$45., component format=$20., test_result_type_desc format=$25., material_description format=$35.,
         unit format=$4., min(res), max(res)
  from t
  group by method_id, lift_test_description, component, test_result_type_desc
  ;
quit;

title "&B";
proc sql;
  select method_id format=$15., lift_test_description format=$45., component format=$45., test_result_type_desc format=$15., res
  from t
  where batch_number="&B"
  ;
quit;


endsas;
title;
proc sql;
  select component format=$45., test_result_type_desc format=$15., batch_number, res
  from t
  where lift_test_description like "Particle Size%" and component like '12%'
  ;
quit;
