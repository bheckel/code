options noreplace fullstimer;

 /* SQL Server passthrough query */
proc sql;
  connect to oledb(provider=sqloledb.1 properties=("Persist Security Info"=True 
  "Integrated Security"=SSPI "Data Source"="WNETBPMS1\production"                                   
  "Initial Catalog"="SANDBOX") schema=dbo ignore_read_only_columns=yes);
  
  create table foo as select * from connection to oledb (
    select top 100000 * 
    from lu_prescriber
  );

  disconnect from oledb;
quit;

 /* Compare the much slower non-passthrough approach */
endsas;
libname BPMS oledb provider=sqloledb.1 
        properties=("Persist Security Info"=True "Integrated Security"=SSPI 
        "Data Source"="wnetbpms1\production"
        "Initial Catalog"="SANDBOX") schema=dbo ignore_read_only_columns=yes;  

data foo;
  set BPMS.lu_prescriber;
  if _N_ lt 100000;
run;

