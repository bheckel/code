proc sql;
  connect to odbc as myconn (user=bheckel password=xxxyP@ss dsn=jasper readbuff=7000);
    create table work.t as select * from connection to myconn
    (

      select * from medispan.medndc LIMIT 5;

    );
  disconnect from myconn;
quit;
