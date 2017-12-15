libname BPMS oledb provider=sqloledb.1 
        properties=("Persist Security Info"=True "Integrated Security"=SSPI 
        "Data Source"="wnetbpms1\production"
        "Initial Catalog"="BPMS") schema=dbo ignore_read_only_columns=yes
        access=readonly
        readbuff=100000
        direct_exe=delete
 /***         bulkload=yes ***/
        ;

libname SAND oledb provider=sqloledb.1 
        properties=("Persist Security Info"=True "Integrated Security"=SSPI 
        "Data Source"="wnetbpms1\production"
        "Initial Catalog"="sandbox") schema=rheckel ignore_read_only_columns=yes
        access=readonly
        readbuff=100000
        direct_exe=delete
 /***         bulkload=yes ***/
        ;

libname W23PSQL1 oledb provider=sqloledb.1 
        properties=("Persist Security Info"=True "Integrated Security"=SSPI
        "Data Source"="W23PSQL01\PRODUCTION" "Initial Catalog"=bpms_XX)
        access=readonly
        readbuff=100000
        direct_exe=delete
 /***         bulkload=yes ***/
        ;
