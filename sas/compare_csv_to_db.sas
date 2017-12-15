options source mprint mprintnest symbolgen=no sasautos=(SASAUTOS 'e:/Macros') fmtsearch=(myfmtlib) validvarname=any ps=max ls=160;

filename f 'E:\Users\Bob.Heckel\Data Validation_2015 01 18.csv';

data csv;
  format filldate_csv YYMMDD10.;
  infile f DLM='|' DSD MISSOVER  LRECL=2600 FIRSTOBS=2;
  input storeid_csv x1 $ x2 $ x3 $ filldate_csv :MMDDYY10. pharmacypatientid_csv rxnbr_csv rxnbr2_csv x4 $;
run;

data csv2;
  length all_csv $200;
  set csv;
  if storeid_csv ne .;
  all_csv=strip(storeid_csv)||' '||strip(pharmacypatientid_csv)||' '||strip(rxnbr2_csv)||' '||strip(put(filldate_csv,YYMMDD10.));
run;




%dbpassword;

proc sql;
  connect to odbc as myconn (user=&user. password=&password. dsn='db5' readbuff=7000);

  create table db5 as select * from connection to myconn (

    select trim(leading '0' from storeid) as storeid_db5, pharmacypatientid as pharmacypatientid_db5, rxnbr as rxnbr_db5, filldate as filldate_db5
    from rxfilldata_parent
    where trim(leading '0' from storeid) in('34','83','202','604','7212') and filldate >= date('2014-11-01') and filldate <= date('2015-11-01')

    ;

  );

  disconnect from myconn;
quit;

data db52;
  length all_db5 $200;
  set db5;
  all_db5=strip(storeid_db5)||' '||strip(pharmacypatientid_db5)||' '||strip(rxnbr_db5)||' '||strip(put(filldate_db5,YYMMDD10.));
run;



proc sql;                                                                                                                               
  create table on_db5_not_csv as                                                                                                        
  select a.storeid_db5 as storeid, a.pharmacypatientid_db5 as pharmacypatientid, a.rxnbr_db5 as rxnbr, a.filldate_db5 as filldate       
  from db52 a left join csv2 b on a.all_db5=b.all_csv                                                                                   
  where b.all_csv is null                                                                                                               
  ;                                                                                                                                     
quit;     
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run; 
proc sql;                                                                                                                               
  create table on_db5_not_csv_summary1 as                                                                                               
  select storeid, count(*)                                                                                                              
  from on_db5_not_csv                                                                                                                   
  group by storeid                                                                                                                      
  ;                                                                                                                                     
quit;                                                                                                                                   
proc sql;                                                                                                                               
  create table on_db5_not_csv_summary2 as                                                                                               
  select storeid, put(filldate,YYMMD.) as fillmo, count(*)                                                                              
  from on_db5_not_csv                                                                                                                   
  group by storeid, fillmo                                                                                                              
  ;                                                                                                                                     
quit;         
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run; 


                                                                                                                                        
proc sql;                                                                                                                               
  create table on_csv_not_db5 as                                                                                                        
  select a.storeid_csv as storeid, a.pharmacypatientid_csv as pharmacypatientid, a.rxnbr_csv as rxnbr, a.filldate_csv as filldate       
  from csv2 a left join db52 b on a.all_csv=b.all_db5                                                                                   
  where b.all_db5 is null                                                                                                               
  ;                                                                                                                                     
quit; 
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run; 
proc sql;                                                                                                                               
  create table on_csv_not_db5_summary1 as                                                                                               
  select storeid, count(*) as diffcount                                                                                                            
  from on_csv_not_db5                                                                                                                   
  group by storeid                                                                                                                      
  ;                                                                                                                                     
quit;                                                                                                                                
proc sql;                                                                                                                               
  create table on_csv_not_db5_summary2 as                                                                                               
  select storeid, put(filldate,YYMMD.) as fillmo, count(*) as diffcount                                                                           
  from on_csv_not_db5                                                                                                                   
  group by storeid, fillmo                                                                                                              
  ;                                                                                                                                     
quit;    
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run; 


title; footnote; ODS listing close;
ODS csvall FILE='E:\Users\Bob.Heckel\on_db5_not_csv.csv'; 
proc print data=on_db5_not_csv NOobs label; run;

ODS csvall FILE='E:\Users\Bob.Heckel\on_db5_not_csv_summary1.csv'; 
proc print data=on_db5_not_csv_summary1 NOobs label; run;
ODS csvall FILE='E:\Users\Bob.Heckel\on_db5_not_csv_summary2.csv'; 
proc print data=on_db5_not_csv_summary2 NOobs label; run;


ODS csvall FILE='E:\Users\Bob.Heckel\on_csv_not_db5.csv'; 
proc print data=on_csv_not_db5 NOobs label; run;

ODS csvall FILE='E:\Users\Bob.Heckel\on_csv_not_db5_summary1.csv'; 
proc print data=on_csv_not_db5_summary1 NOobs label; run;
ODS csvall FILE='E:\Users\Bob.Heckel\on_csv_not_db5_summary2.csv'; 
proc print data=on_csv_not_db5_summary2 NOobs label; run;
ODS csvall CLOSE;
