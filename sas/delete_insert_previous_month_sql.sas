
options ls=180 ps=max; libname l '~/tmp';

proc sql;
  connect to postgres as myconn (user=&user password=&password database=taebMART server='db-06.twa.taeb.com' readbuff=7000);

  create table l.prior as select * from connection to myconn (
    select * 
    from public.hppatientstarpdc
    where measurementenddt in('2018-04-30') /*and taebpatientid=1709524*/
    ;
  );

  create table l.curr as select * from connection to myconn (
    select * 
    from public.hppatientstarpdc
    where measurementenddt in('2018-05-31') /*and taebpatientid=1709524*/
    ;
  );

  disconnect from myconn;
quit;
%put !!!&SQLRC &SQLOBS;

data l.curr; set l.curr(drop=pdcscoreprevious); run;

proc sql;
  create table curr_with_pdcscoreprevious as
  select a.taebpatientid, a.measurementid, a.healthplanid, a.measurementstartdt, a.measurementenddt, a.pdcscore, a.targeted, a.clientid, a.pmapstoreid, b.pdcscore as pdcscoreprevious
  from l.curr a left join l.prior b on a.taebpatientid=b.taebpatientid and a.measurementid=b.measurementid
  ;
quit;  

data l.curr_with_pdcscoreprevious;
  retain taebpatientid measurementid healthplanid measurementstartdt measurementenddt pdcscore targeted clientid pmapstoreid pdcscoreprevious;
  set curr_with_pdcscoreprevious;
run;

proc export outfile='/tmp/copy.csv' data=l.curr_with_pdcscoreprevious dbms=dlm replace;
  delimiter=',';
  putnames=no;
run;


proc sql;
  connect to postgres as myconn (user=&user password=&password database=taebMART server='db-06.twa.taeb.com' readbuff=7000);
    EXECUTE ( delete from public.hppatientstarpdc where measurementenddt in('2018-05-31') ) BY myconn;
  disconnect from myconn;
quit;


data _null_;
  rc=system('psql -h db-06.twa.taeb.com taebMART -c "\COPY public.hppatientstarpdc(taebpatientid, measurementid, healthplanid, measurementstartdt, measurementenddt, pdcscore, targeted, clientid, pmapstoreid, pdcscoreprevious) FROM ''/tmp/copy.csv'' WITH (FORMAT CSV, DELIMITER '','');"');
  if rc ne 0 then put 'ERROR: INSERT failure' rc=;
run;
