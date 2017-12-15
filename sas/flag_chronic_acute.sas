     %if %sysfunc(exist(data.medispanchronic)) %then %do;
           %put data.medispanchronic exists;
     %end;
     %else %do;
       proc sql;
             connect to odbc as myconn (user=&user. password=&password. dsn='asper' readbuff=7000);

                       create table data.medispanchronic as select * from connection to myconn (

          select distinct genericproductidentifier as gpi, outcomecode, roleoftherapycode, 'Y' as chronic
          from medispan.indgind
          where roleoftherapycode=1 and outcomecode not in (1,6)
          order by genericproductidentifier, outcomecode, roleoftherapycode
          ;

          );

             disconnect from myconn;
       quit;
     %end;


     proc sql;
           create table rxtotal_chronic_acute as
           select a.*, substr(b.gpi, 1,10) as gpi10, b.gpi,
                case when b.gpi in (select gpi from data.medispanchronic) then 1 else 0 end as chronic,
                1-(case when b.gpi in (select gpi from data.medispanchronic) then 1 else 0 end) as acute
           from rxfill as a left join data.medispan as b
           on a.ndc=b.ndc_upc_hri;
     quit;

