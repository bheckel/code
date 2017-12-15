options mprint mautosource sasautos=('/Drugs/Macros', sasautos) ps=150 ls=max nocenter sgen;

/* Given a list, determine if we're already running */

data potential_new_clids;
  infile cards;
  input clid :8.;
  cards;
445
449
2
615
924
  ;
run;


%dbpassword;
%odbc_start(lib=work, ds=existing_clids, db=db6);
  select distinct clientid as clid from analytics.tmm_enrollmentperf;
%odbc_end;


proc sql;
  select a.clid into :CLIDS separated by ','
  from potential_new_clids a left join existing_clids b on a.clid=b.clid
  where b.clid is null
  ;
quit;
%put &CLIDS;


libname func '/Drugs/FunctionalData';

data chain ind;
  set func.clients_shortname_lookup;
  if independent eq 'N' and clientid in(&CLIDS) then output chain;
  else if independent eq 'Y' and clientid in(&CLIDS) then output ind;
run;
title "new chain";proc print data=chain width=minimum heading=H;run;title;
title "new ind";proc print data=ind width=minimum heading=H;run;title;



%macro m;
  filename f '/Drugs/HealthPlans/UnitedHealthcare/Medicare/Tasks/20160606/Output/UHC_add_20160606_17.csv';
  data us;
    infile f dlm='|' dsd missover;;
    input a :$40.
          b :$40.
          ppid :$40.
    ;
    if ppid ne '';
  run;
  /***title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;***/

  proc sql NOprint;
    select distinct quote(trim(ppid), "'") into :ppids separated by ',' from us
    ;
  quit;

  %put &=ppids;

  %dbpassword;
  proc sql;
    connect to odbc as myconn (user=&user. password=&jasperpassword. dsn='db6' readbuff=7000);

    create table us2 as select * from connection to myconn (

      select distinct atebpatientid from patient.atebpatient where clientid=17 and pharmacypatientid in ( &ppids )
      ;
    );

    disconnect from myconn;
  quit;
  %put !!!&SQLRC &SQLOBS;
  /***title "&SYSDSN";proc print data=us2(obs=10) width=minimum heading=H;run;title;***/

  proc sql;
    connect to odbc as myconn (user=&usr_tableau password=&psw_tableau. dsn='db3' readbuff=7000);

    create table them as select * from connection to myconn (

    select distinct ia.atebpatientid
    from pmap.interventionalert as ia
         join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
         join client.store as st on ap.storeid = st.storeid
         join client.chain as ch on ch.chainid=st.chainid
    where ia.reasonforalert in ('Time My Meds - Priority Patient Enrollment - nUitedHealthcare') and ia.lastmodified > '2016-06-05' and ch.clientid=17;

    );

    disconnect from myconn;
  quit;
  %put !!!&SQLRC &SQLOBS;


  proc sql;
    create table nopmap as 
    select * from us2 left join them on us2.atebpatientid=them.atebpatientid
    where them.atebpatientid is null
    ;
  quit;
  title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;
%mend;
%m;
