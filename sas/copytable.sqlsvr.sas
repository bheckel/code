 /* Use Enterprise Manager or rightclick Object Browser (select db, Tables,
  * Claims_Pharmacy, click Tools, Generate SQL Script, Preview, Copy) to
  * generate the CREATE TABLE statements, create a new empty table in Analyzer
  * (change dbo to rheckel, be sure to 'use sandbox') then run this.
  *
  * May be faster to just use this after CREATEing the empty table:
  * 
  * INSERT INTO rheckel.clp 
  * SELECT * 
  * FROM [w23psql02\production].bpms_il.dbo.claims_pharmacy
  */

libname SAND oledb provider=sqloledb.1 
        properties=("Persist Security Info"=True "Integrated Security"=SSPI 
        "Data Source"="wnetbpms1\production"
        "Initial Catalog"="SANDBOX") schema=rheckel 
        ignore_read_only_columns=yes;  

libname W2301 oledb provider=sqloledb.1 
        properties=("Persist Security Info"=True "Integrated Security"=SSPI 
        "Data Source"="w23psql01\production"
        "Initial Catalog"="bpms_va") schema=dbo
        ignore_read_only_columns=yes access=readonly;

data tmp;
  set W2301.claims_pharmacy(obs=50);
run;

proc datasets;
  append base=SAND.vaclptmp data=tmp;
quit;
