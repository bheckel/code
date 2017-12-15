options NOreplace;

libname LOC 'd:/temp';

libname W2301 oledb provider=sqloledb.1 
        properties=("Persist Security Info"=True "Integrated Security"=SSPI 
        "Data Source"="w23psql01\production"
        "Initial Catalog"="bpms_va") schema=dbo
        ignore_read_only_columns=yes access=readonly;

data LOC.claims_pharm_va20050808;
  set W2301.claims_pharmacy;
run;
