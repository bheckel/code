 /* proc export or ODS is better unless you don't want to use their default header lines */
data _null_;
  set l.ods_0002e_advair;
  file 't.csv' DSD;
  if _n_ eq 1 then put 'Product,Material-Batch Number,Manufacture Date';
  put (_all_)(+0);
 run;

 /* More vars than SAS will allow on one line */
data _null_;
/***  set _allado;***/
  set l.ods_0002e_advair;
  file "t.csv" DLM=',' lrecl=32676;
  if _n_ eq 1 then do;
put 'Index,Product,Material-Batch Number,Manufacture Date,Test Method Description,' @;
put 'Numeric Result,Numeric Results (units),Device,Impactor #,Character Result,Method Number,' @;
put 'LIFT Data Status,Test Date,Analyst,Blend Number,Blend Nbr Manufacture Date,' @;
put 'Blend Nbr Description (MDPI ONLY),Fill Number,FILL_MFG_DATE,Fill Nbr Description (MDPI ONLY),' @;
put 'Assembled Number,Assembled Nbr Manufacture Date,Assembled Nbr Description (MDPI ONLY)';
end;
  put (_all_)(+0);
run;
