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



proc sql;
  connect to odbc as myconn (user=&user  password=&password  dsn=db6 readbuff=7000);
    execute (
      create temp table tmp_ndcs (ndc varchar(50));
      insert into tmp_ndcs select a.ndcupchri
                           from ((medispan.medndc a LEFT JOIN medispan.medprc b on a.ndcupchri=b.ndcupchri)
                                left join medispan.medgpr c on a.genericproductpackagingcode=c.genericproductpackagingcode)
                                left join medispan.medname d on a.drugdescriptoridentifier=d.drugdescriptoridentifier
                           where genericproductidentifier like '4420990270%'
                           ;
    ) by myconn;

    create table t as select * from connection to myconn (
      select * from tmp_ndcs limit 5;
    );
  disconnect from myconn;
quit;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;
