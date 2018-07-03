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
