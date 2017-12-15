options mprintnest mautosource sasautos=('/Drugs/Macros', sasautos) ps=max ls=max nocenter sgen set=SAS_HADOOP_JAR_PATH="/sas/sashome/SAS_HADOOP_JAR_PATH"; 

 /* https://cwiki.apache.org/confluence/display/Hive/Tutorial */

proc sql;
  connect to hadoop (server='hwnode-02.hdp.taeb.com' schema=patient user=hive password=pw);
    create table t as select created length=30 from connection to hadoop (
      !!!Hive SQL HQL goes here
      select to_date(created) as created2 from patient.atebpatient where  clientid = 4 and pharmacypatientid rlike 'FOO.*'
    );
  disconnect from hadoop;
quit;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;
proc contents; run;


proc sql;
  connect to hadoop (server='hwnode-02.hdp.taeb.com' schema=patient user=hive password=pw);
    create table t as select * from connection to hadoop (
      show tables '.*patient.*'
    );
  disconnect from hadoop;
quit;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;
proc contents; run;



filename pscript1 "/users/lputhenv/Pigscript1.sas" ;
data _null_; 
  file pscript1 ;
  put "LEDG2 = LOAD '/datalake/LLEDGER.csv' using PigStorage(',') AS (contract:chararray, customer:chararray, fiscal_date:chararray, 
  ...
  project:chararray, reinsurance:chararray, source_sys:chararray,
  account:chararray, 
  amount:float) ;" ;

  put "LEDG3 = FILTER LEDG2 BY customer != '8100000' ;" ;
  put "STORE LEDG3 INTO '/datalake  /LEDGER_FILTERED.csv' using PigStorage(',');" ;
run; 
proc hadoop options="/sas/hadoop/cfg-site.xml" username="user" password="password" verbose;
  PIG code=pscript1;
run; 


