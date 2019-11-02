options sasautos=(SASAUTOS '/Drugs/Macros') ls=140 ps=max mprint mprintnest NOcenter validvarname=any;%dbpassword;
proc sql;
  connect to odbc as myconn (user=&user. password=&password. dsn='db1' readbuff=7000);
  /* connect to postgres as myconn (user=&user password=&password database=mydb server='db-1.taeb.com' readbuff=7000); */
  create table t as select * from connection to myconn (
    select patientid from patient.patient limit 5;
  );
  disconnect from myconn;
quit;
%put !!!&SQLRC &SQLOBS;
