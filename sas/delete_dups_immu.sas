%macro delete_dups_immu;
  *****************************************************************************;
  *                         PROGRAM HEADER                                    *;
  *---------------------------------------------------------------------------*;
  *                                                                           *;
  *       PROGRAM NAME: delete_dups_immu.sas                                  *;
  *                                                                           *;
  *       DEVELOPED BY: Bob Heckel                                            *;
  *                                                                           *;
  *       SPONSOR:                                                            *;
  *                                                                           *;
  *       PURPOSE: To delete any duplicate immunization tasks                 *;
  *                                                                           *;
  *                                                                           *;
  *       SINGLE USE OR MULTIPLE USE? (SU OR MU) SU                           *;
  *---------------------------------------------------------------------------*;
  *       PROGRAM ASSUMPTIONS OR RESTRICTIONS: NONE                           *;
  *---------------------------------------------------------------------------*;
  *       DESCRIPTION OF OUTPUT:  CSVs 		                                    *;
  *****************************************************************************;
  *                     HISTORY OF CHANGE                                     *;
  *-------------+---------+--------------+------------------------------------*;
  *     DATE    | VERSION | NAME         | Description                        *;
  *-------------+---------+--------------+------------------------------------*;
  *  16-Sep-16  |    1.0  | Bob Heckel   | Initial                            *;
  *-------------+---------+--------------+------------------------------------*;
  options mprintnest=yes mlogic=no symbolgen=no sasautos=(SASAUTOS '/Drugs/Macros')
    fmtsearch=(myfmtlib) compress=yes reuse=yes;
  %dbpassword;
  %put NOTE: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;
  %let _start=%sysfunc(datetime());
  %put NOTE: %sysfunc(getoption(SYSIN)) started: %sysfunc(putn(%sysfunc(datetime()),DATETIME.));
  %put NOTE: ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;
  title;
  footnote;

  %odbc_start(lib=work,ds=del_&clid,db=atbleau)

    select ch.clientid, st.clientstoreid, ap.pharmacypatientid, ac.code, ac.name, '' as x1, '' as x2, 1 as x3, '' as x4, 'Delete' as x5, '' as x6, '' as x7
    from pmap.interventionalert as ia
         join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
         join client.store as st on ap.storeid=st.storeid
         join client.chain as ch on ch.chainid=st.chainid 
         join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
    where ch.clientid=&clid and alertstatusid=1
          and ia.actioncodeid in(select actioncodeid from pmap.actioncode where name like 'Immunization Opportunity%') 
    group by ia.atebpatientid, ch.clientid, st.clientstoreid, ap.pharmacypatientid, ia.atebpatientid, ac.code, ac.name
    having count(*)>1 order by ch.clientid
    ;

  %odbc_end;

  data _null_;
    if 0 then set del_&clid nobs=count;
    call symput('OBSCNT', strip(count));
    stop;
  run;


  %if "&OBSCNT" ne "0" %then %do;
    %odbc_start(lib=work,ds=addback_&clid,db=atbleau)

      select ch.clientid, st.clientstoreid, ap.pharmacypatientid, ac.code, ac.name, '' as x1, '' as x2, 0 as x3, to_char(date('now'),'YYYYMMDD') as x4, 'AddOrUpdate' as x5, '' as x6, '' as x7, 'EXPIRE='||to_char(date('now')+30,'YYYYMMDD') as x8,
             case when ac.actioncodeid=20106 then 'IMM_FAMILY=AV_OTHER'
                  when ac.actioncodeid=20107 then 'IMM_FAMILY=AV_HPV'
                  when ac.actioncodeid=20108 then 'IMM_FAMILY=AV_TETANUS'
                  when ac.actioncodeid=20109 then 'IMM_FAMILY=AV_HEPATITIS'
                  when ac.actioncodeid=20110 then 'IMM_FAMILY=AV_MENINGOCOCCAL'
                  when ac.actioncodeid=20111 then 'IMM_FAMILY=AV_PREVNAR'
                  when ac.actioncodeid=20112 then 'IMM_FAMILY=AV_ZOSTERSHINGLES'
                  when ac.actioncodeid=20113 then 'IMM_FAMILY=AV_PNEUM'
                  when ac.actioncodeid=20114 then 'IMM_FAMILY=AV_INFLUENZA'
             end as x9
      from pmap.interventionalert as ia
           join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
           join client.store as st on ap.storeid=st.storeid
           join client.chain as ch on ch.chainid=st.chainid 
           join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
      where ch.clientid=&clid and alertstatusid=1
            and ia.actioncodeid in(select actioncodeid from pmap.actioncode where name like 'Immunization Opportunity%') 
      group by ia.atebpatientid, ch.clientid, st.clientstoreid, ap.pharmacypatientid, ia.atebpatientid, ac.code, ac.name, ac.actioncodeid
      having count(*)>1 order by ch.clientid
      ;

    %odbc_end;

    %put WARNING: &OBSCNT duplicate tasks found;
    %put DEBUG: &path.&sp_name./&jobtype./&daten_exec./Output/imm_del_&daten_exec._&clid..csv;


    /*********** Remove duplicate tasks (PMAP removes both, we can't make it leave just one) *************/
    proc export outfile="&path.&sp_name./&jobtype./&daten_exec./Output/imm_del_&daten_exec._&clid..csv" data=del_&clid dbms=dlm replace;
      delimiter='|';
      putnames=no;
    run;

    data _null_;
      rc1=system("chmod 777 &path.&sp_name./&jobtype./&daten_exec./Output/imm_del_&daten_exec._&clid..csv");
      rc2=system("cp -p     &path.&sp_name./&jobtype./&daten_exec./Output/imm_del_&daten_exec._&clid..csv /mnt/nfs/dropboxes/tmm/alert");

      if (rc1 ne 0) or (rc2 ne 0) then
        do;
          put 'ERR' 'OR: dropbox transfer failure: ' rc1= rc2=;
          sysuserid=symget('SYSUSERID');
          sendfile="&path.&sp_name./&jobtype./&daten_exec./Output/imm_del_&daten_exec._&clid..csv";
          droploc='/mnt/nfs/dropboxes/tmm/alert';
          put sysuserid= sendfile= droploc=;
          /* We don't want to add back anything later if we weren't able to remove the dups here, so abort */
          abort abend 008;
        end;
    run;


    /********* Wait 30 seconds for PMAP to handle the import before proceeding **********/
    data _null_;
      x=sleep(30000);
    run;


    /*********** Add single tasks back *************/
    proc export outfile="&path.&sp_name./&jobtype./&daten_exec./Output/imm_addback_&daten_exec._&clid..csv" data=addback_&clid dbms=dlm replace;
      delimiter='|';
      putnames=no;
    run;

    data _null_;
      rc1=system("chmod 777 &path.&sp_name./&jobtype./&daten_exec./Output/imm_addback_&daten_exec._&clid..csv");
      rc2=system("cp -p     &path.&sp_name./&jobtype./&daten_exec./Output/imm_addback_&daten_exec._&clid..csv /mnt/nfs/dropboxes/tmm/alert");

      if (rc1 ne 0) or (rc2 ne 0) then
        do;
          put 'ERR' 'OR: dropbox transfer failure: ' rc1= rc2=;
          sysuserid=symget('SYSUSERID');
          sendfile="&path.&sp_name./&jobtype./&daten_exec./Output/imm_del_&daten_exec._&clid..csv";
          droploc='/mnt/nfs/dropboxes/tmm/alert';
          put sysuserid= sendfile= droploc=;
        end;
    run;


    /********* Wait 30 seconds for PMAP to handle the import before finishing **********/
    data _null_;
      x=sleep(30000);
    run;

  %end;  /* dups exist */
  %else %do;
    %put NOTE: &OBSCNT duplicate tasks found;
  %end;  /* dups do not exist */
%mend delete_dups_immu;
