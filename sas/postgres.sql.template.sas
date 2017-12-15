options sasautos=(SASAUTOS '/Drugs/Macros' '.') ls=180 ps=max mprintnest validvarname=any;
%dbpassword;
proc sql;
  connect to odbc as myconn (user=&user. password=&password. dsn='dbN' readbuff=7000);
/***  connect to postgres as myconn (database=reporting authdomain=Postdb5Auth server='db-0N.twa.taeb.com' readbuff=7000);***/

  create table l.dsout as select * from connection to myconn (

    select masked_patientkey
    from public.mydb
    where ndc in('00006496300','00006496341','54868570300','68258890801','68258890800')
    ;

  );
  disconnect from myconn;
quit;
