options sasautos=(SASAUTOS '/Drugs/Macros') ls=140 ps=max mprint mprintnest NOcenter validvarname=any;%dbpassword;
proc sql;
  connect to odbc as myconn (user=&user. password=&password. dsn='db8' readbuff=7000);
  /* connect to postgres as myconn (user=&user password=&password database=taeb server='db-103.twa.taeb.com' readbuff=7000); */
  create table t as select * from connection to myconn (
    select taebpatientid from patient.taebpatient limit 5;
  );
  disconnect from myconn;
quit;
%put !!!&SQLRC &SQLOBS;
