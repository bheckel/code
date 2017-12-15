
/* Can't use PROC EXPORT - requirements specify custom headers */
data _null_;
  set &OUTPUTFILE;
  file "&DPPATH\&OUTPUTDIR\&OUTPUTFILE..csv" DLM=',' lrecl=32676;
  if _N_ eq 1 then do;
    put 'Index,Product,Material-Batch Number,Manufacture Date,Test Method Description,' @;
    put 'Numeric Result,Numeric Results (units),Device,Impactor #,Character Result,Method Number,' @;
    put 'LIFT Data Status,Test Date,Analyst,Blend Number,Blend Nbr Manufacture Date,' @;
    put 'Blend Nbr Description (MDPI ONLY),Fill Number,Fill Nbr Manufacture Date,Fill Nbr Description (MDPI ONLY),' @;
    put 'Assembled Number,Assembled Nbr Manufacture Date,Assembled Nbr Description (MDPI ONLY)';
  end;
  put (_ALL_)(+0);
run;
