
options mprint mautosource sasautos=('/Drugs/Macros', sasautos) mprint mprintnest nocenter sgen set=SAS_HADOOP_JAR_PATH="/sas/sashome/SAS_HADOOP_JAR_PATH"; %dbpassword;

%macro m(clid=, projected_build_date=);
 /* delete from analytics.build where clientid in(2,4); delete from analytics.buildconfig where clientid in(2,4); */
  /* %put select * from analytics.tmm_client_build_config(_clientid:=&clid); */
  /* %put update analytics.build set projectedimport=&projected_build_date where clientid=&clid; */

  proc sql;
    connect to postgres as myconn(user=&user password=&password dsn="db6dev" readbuff=7000);

    execute (
      select * from analytics.tmm_client_build_config(_clientid:=&clid);
    ) by myconn;

    execute (
      update analytics.build set builddate=&projected_build_date where clientid=&clid;
    ) by myconn;

    disconnect from myconn;
  quit;
%mend;

data _null_;
  set FUNCDATA.tmm_targeted_list_refresh(keep= clid projected_build_date obs=2);
  str = cats('%m(clid=', clid, ', projected_build_date=', "'", put(projected_build_date,YYMMDD10.), "'", ');');
  /* put str=; */
  call execute(str);
run;  
