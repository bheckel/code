
libname mylib "\\ashq\root\dept\roion\cloud_data\sas\prod\risk_err";

options nolabel;
proc sql ;
  select modate format=datetime. as last_modified
    from dictionary.tables
   where libname = "MYLIB"
     and memname = upper("RPT_OPP_ERR_ESP_20230523");
quit;
