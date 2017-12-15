
proc sql;
  connect to odbc as myconn (user=&user password=&jasperpassword dsn=jasper);
  select * from connection to myconn(
  select count(*) from myschema.htients
  ;
  )
quit;
