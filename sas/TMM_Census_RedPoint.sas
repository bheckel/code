%macro tmm_census;
  *****************************************************************************;
  *                         PROGRAM HEADER                                    *;
  *---------------------------------------------------------------------------*;
  *                                                                           *;
  *       PROGRAM NAME: TMM_Census_RedPoint.sas.sas                           *;
  *                                                                           *;
  *       DEVELOPED BY: Bob Heckel                                            *;
  *                                                                           *;
  *       SPONSOR:                                                            *;
  *                                                                           *;
  *       PURPOSE: To create eligibility lists for RedPoint clients           *;
  *                                                                           *;
  *       SINGLE USE OR MULTIPLE USE? (SU OR MU) SU                           *;
  *---------------------------------------------------------------------------*;
  *       PROGRAM ASSUMPTIONS OR RESTRICTIONS: NONE                           *;
  *---------------------------------------------------------------------------*;
  *       DESCRIPTION OF OUTPUT:  Elibility list                              *;
  *****************************************************************************;
  *                     HISTORY OF CHANGE                                     *;
  *-------------+---------+--------------+------------------------------------*;
  *     DATE    | VERSION | NAME         | Description                        *;
  *-------------+---------+--------------+------------------------------------*;
  *  15-Aug-16  |    1.0  | Bob Heckel   | Initial                            *;
  *-------------+---------+--------------+------------------------------------*;
  options sasautos=(SASAUTOS '/Drugs/Macros' '.') ls=max ps=max mprint mprintnest NOcenter validvarname=any;

  %let path=/Drugs/TMMEligibility;
  %let sp_name=BBP;
  %let jobtype=Imports;
  %let daten_exec=20160914;
  %let clid=1021;
  %let storelist=%str('1','5','7','25','35');
  %let daysback=120;
  %let minage=18;

  libname TMM "&path./&sp_name./&jobtype./&daten_exec./Data";
  libname BUILDS '/Drugs/FunctionalData';


  /* Formulary meds */
  proc sql;
    select distinct gpi into :formulary_gpis separated by ','
    from BUILDS.medlist
    ;
  quit;


  %if not %sysfunc(exist(TMM.sdfarchive)) %then %do;
    %dbpassword;
    proc sql;
      connect to odbc as myconn (user=&user password=&jasperpassword dsn='dbx' readbuff=7000);

      create table TMM.sdfarchive as select * from connection to myconn (

        select clientid, clientstoreid, pharmacypatientid, filldate, gpi, patientdateofbirth,
               concat(trim(leading '0' from clientstoreid::text),pharmacypatientid::text) as upid
        from sdfarchive
        where clientid=&clid
              and trim(leading '0' from clientstoreid::text) in ( &storelist )
              and substring(gpi,1,10)::bigint in ( &formulary_gpis )
              and date_part('YEAR'::text, age(patientdateofbirth::timestamp with time zone)) >= &minage
              and filldate>=(date('now')-&daysback)
        ;

      );

      disconnect from myconn;
    quit;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;    
    %put !!!&SQLRC &SQLOBS;
  %end;


  proc sql;
    create table cnts as
    select distinct upid, count(distinct gpi) as nRx
    from TMM.sdfarchive
    group by upid
    ;
  quit;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;  


  %if not %sysfunc(exist(TMM.stores)) %then %do;
    %dbpassword;
    proc sql;
      connect to odbc as myconn (user=&usr_tableau password=&psw_tableau dsn='dby' readbuff=7000);

      create table TMM.stores as select * from connection to myconn (

        /* e.g.  0013         18244      */
        select a.storeid, a.client_storeid
        from amc.stores a join client.store b on a.chainid=b.chainid and a.id=b.amcstoreid
        where a.clients_fkid=&clid
        ;

      );

      disconnect from myconn;
    quit;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;    
    %put !!!&SQLRC &SQLOBS;
  %end;


  %build_long_in_list(ds=TMM.sdfarchive, var=pharmacypatientid, type=char);


  %if not %sysfunc(exist(TMM.atebpatient)) %then %do;
    %dbpassword;
    proc sql;
      connect to odbc as myconn (user=&user password=&jasperpassword dsn='db6' readbuff=7000);

      create table TMM.atebpatient as select * from connection to myconn (

        /* e.g.          18244                                  */
        select clientid, storeid, pharmacypatientid, atebpatientid
        from patient.atebpatient
        where clientid = &clid and pharmacypatientid in ( %long_in_list )
        ;

      );

      disconnect from myconn;
    quit;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;    
    %put !!!&SQLRC &SQLOBS;
  %end;
/***proc compare base=tmm.atebpatient1 compare=tmm.atebpatient briefsummary;run;***/


  /* Get client's store number (to build upid) */
  proc sql;
    create table atebpatient2 as
    select a.*, b.storeid as storenum
    /* e.g.                                                18244             */
    from TMM.atebpatient a left join TMM.stores b on a.storeid=b.client_storeid
    ;
  quit;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;  


  proc sql;
    create table atebpatient3 as
    /* e.g.                           0013                              */
    select atebpatientid, cats(%rml0(storenum),pharmacypatientid) as upid /*, put(input(storenum,4.),z4.) as storenumz*/
    from atebpatient2
    ;
  quit;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;  


  proc sql;
    create table TMM.fnl as
    /*select b.atebpatientid, b.storenumz, nRx, today() as dt format=YYMMDDD10., a.upid as ua, b.upid as ub*/
    select b.atebpatientid, "&clid" as clid, nRx, today() as dt format=YYMMDDD10.
    from cnts a left join atebpatient3 b on a.upid=b.upid
    where nRx >= 3
    ;
  quit;
title "&SYSDSN";proc print data=_LAST_(obs=max) width=minimum heading=H;run;title;  


  proc export outfile="&path./&sp_name./&jobtype./&daten_exec./Output/&sp_name._TMM_candidates_fdw.csv" data=TMM.fnl dbms=dlm replace;
    delimiter='|';
    putnames=no;
  run;

  /* chmod 777 /Drugs/TMMEligibility/BBP/Imports/20160914/Output/BBP_TMM_candidates_fdw.csv */
  /* cp -p /Drugs/TMMEligibility/BBP/Imports/20160914/Output/BBP_TMM_candidates_fdw.csv /mnt/nfs/home/janitor/dataproc/tmm/pending/ */
/***  %submitel;***/
%mend tmm_census;
%tmm_census;
