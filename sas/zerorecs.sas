options NOcenter ls=150;

 /* Check for lowered GDM record counts prior to DP run
  *
  * c:/PROGRA~1/SASINS~1/SAS/V8/sas.exe -sysin './zerorecs.sas' -log './zerorecs.log' -print './zerorecs.lst'
  */

%macro zerorecs;
  %let PGM=%str(U:\gsk\zerorecs.sas);

  /* ~~~~~~~~~~~~~~~~ Overall count ~~~~~~~~~~~~~~~~ */
  libname GDM oracle user=gdm_dist_r password=slice45read path=ukprd613 schema=gdm_dist;
  proc sql;
    select count(*) into :CNT
    from GDM.vw_lift_rpt_results_nl
    where site_name='Zebulon'
    ;
  quit;
  /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

  /* ~~~~~~~~~~~~~~~~ Batch count ~~~~~~~~~~~~~~~~ */
  libname l 'u:\gsk';
  proc sql;
    create table l.zerorecs(genmax=7) as
      select count(distinct mrp_batch_id) as cb, prod_brand_name
      from GDM.vw_lift_rpt_results_nl
      where site_name='Zebulon'
      group by prod_brand_name
      order by cb desc
    ;
  quit;

  proc sort data=l.zerorecs(gennum=0) out=g0; by prod_brand_name; run;
  proc sort data=l.zerorecs(gennum=-1) out=g1; by prod_brand_name; run;
  proc sort data=l.zerorecs(gennum=-2) out=g2; by prod_brand_name; run;
  proc sort data=l.zerorecs(gennum=-3) out=g3; by prod_brand_name; run;
  proc sort data=l.zerorecs(gennum=-4) out=g4; by prod_brand_name; run;
  proc sort data=l.zerorecs(gennum=-5) out=g5; by prod_brand_name; run;
  proc sort data=l.zerorecs(gennum=-6) out=g6; by prod_brand_name; run;

  data all;
    merge g0(rename=(cb=cb0)) g1(rename=(cb=cb1)) g2(rename=(cb=cb2)) g3(rename=(cb=cb3)) g4(rename=(cb=cb4)) g5(rename=(cb=cb5)) g6(rename=(cb=cb6));
    by prod_brand_name;
    batchchange = abs((cb0-cb1)-(cb1-cb2)-(cb2-cb3)-(cb3-cb4)-(cb4-cb5)-(cb5-cb6));
  run;
  proc sort data=all; by DESCENDING batchchange; run;

/***    proc export data=l.zerorecs OUTFILE="u:\gsk\zerorecs.csv" DBMS=CSV REPLACE; run;***/
ods listing file='u:/gsk/zerorecs.txt';
  proc print data=_LAST_(obs=max) width=minimum;
    var prod_brand_name cb0 cb1 cb2 cb3 cb4 cb5 cb6 batchchange;
  run;
ods listing;
  /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

  /* ~~~~~~~~~~~~~~ Check ~~~~~~~~~~~~~~~~~~~~~~~~ */
  %if &CNT lt 1000000 %then %do;
    %put NOTE: abnormal DP run expected!;


    filename MAILTHIS email ('bheckel@gmail.com' 'rsh86800@gsk.com')
             subject="GDM has a low record count &SYSDAY &SYSDATE"
             attach=('u:\gsk\zerorecs.txt'
                     'u:\gsk\zerorecs_scheduler.png'
                     'z:\datapost\cfg\DataPost_Results.xml'
                    )
             ;

    %let CNTFMTD=%sysfunc(putn(&cnt, COMMA9.));

    data _null_;
      file MAILTHIS;
      put "a low GDM record count exists according to &PGM";
      put;
      put "select count(*) from gdm_dist.vw_lift_rpt_results_nl where site_name='Zebulon'";
      put;
      put "count is &CNTFMTD";
      put;
    run;

/***    proc datasets library=l; delete zerorecs; quit;***/
  %end;
  %else;
    %put NOTE: normal run expected;
  /* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
%mend;
%zerorecs;
