%macro rfd;
   /* "Count all patients between 18-80 years old who are actively on both Metformin and Victoza but have been active for less than 90 days." */

  %let y=2016;
  %let m=05;
  %let j=AN-3803;

	%let d=%sysfunc(dcreate(&y, /Drugs/RFD));
	%let d=%sysfunc(dcreate(&m, /Drugs/RFD/&y));
	%let d=%sysfunc(dcreate(&j, /Drugs/RFD/&y/&m));
	%let d=%sysfunc(dcreate(Datasets, /Drugs/RFD/&y/&m/&j));
	%let d=%sysfunc(dcreate(Reports, /Drugs/RFD/&y/&m/&j));
	%let d=%sysfunc(dcreate(Code, /Drugs/RFD/&y/&m/&j));

  %let RFDPATH=/Drugs/RFD/&y/&m/&j;
  %let RFDNUM=%sysfunc(prxchange(s/(.*)\/(.*)$/$2/, 1, &RFDPATH));

  %dbpassword;

  %let client=hopko;
  libname TMMBUILD '/Drugs/MTMEligibility/hopko/PHTasks/20160514/Data' access=readonly;

  options ls=180 ps=max; libname l "&RFDPATH/Datasets";

  %if not %sysfunc(exist(l.metndc)) %then %do;
    proc sql;
      connect to odbc as myconn (user=&user. password=&jasperpassword. dsn='db6' readbuff=7000);

      create table l.metndc as select * from connection to myconn (

        select a.*, b.drugname
        from medispan.medndc a join medispan.medname b on a.drugdescriptoridentifier=b.drugdescriptoridentifier
        where genericproductidentifier like '2725005000%'
        ;

      );

      create table l.vicndc as select * from connection to myconn (

        select a.*, b.drugname
        from medispan.medndc a join medispan.medname b on a.drugdescriptoridentifier=b.drugdescriptoridentifier
        where genericproductidentifier like '2717005000%'
        ;

      );

      disconnect from myconn;
    quit;

    %put !!!&SQLRC &SQLOBS;
    title "metndc";proc freq data=l.metndc; table drugname;run;title;    
    title "vicndc";proc freq data=l.vicndc; table drugname;run;title;    
  %end;

  %build_long_in_list(ds=l.metndc, var=ndcupchri, type=char);
  %let metndcs=%long_in_list;

  %build_long_in_list(ds=l.vicndc, var=ndcupchri, type=char);
  %let vicndcs=%long_in_list;


  /* Only selected prescriptionstatus = 3 (picked up) to avoid cancelled */
  %if not %sysfunc(exist(l.oldusers_&client)) %then %do;
    proc sql;
      create table l.oldusers_&client as
      select *, cats(storeid,pharmacypatientid) as sidppid
      from TMMBUILD.rxfilldata
      where (prescriptionstatus in(3)) and (age>=18 and age<=80) and (filldate<date()-90)
      ;
    quit;     
  %end;

  %if not %sysfunc(exist(l.newusers_&client)) %then %do;
    proc sql;
      create table l.newusers_&client as
      select *, cats(storeid,pharmacypatientid) as sidppid
      from TMMBUILD.rxfilldata
      where (prescriptionstatus in(3)) and (age>=18 and age<=80) and (filldate>=date()-90)
      ;
    quit;     
  %end;


  %if not %sysfunc(exist(l.oldbothmeds_&client)) %then %do;
    /* Both-And Metformin and Victoza */
    proc sql;
      create table l.oldbothmeds_&client as
      select distinct a.sidppid, a.ndc, b.ndc as ndc2, a.filldate
      from l.oldusers_&client a, l.oldusers_&client b
      where (a.sidppid=b.sidppid)
        and (a.ndc in( &metndcs ) and (b.ndc in( &vicndcs )))
      ;
    quit;     
  %end;

  %if not %sysfunc(exist(l.newbothmeds_&client)) %then %do;
    /* Both-And Metformin and Victoza */
    proc sql;
      create table l.newbothmeds_&client as
      select distinct a.sidppid, a.ndc, b.ndc as ndc2, a.filldate
      from l.newusers_&client a, l.newusers_&client b
      where (a.sidppid=b.sidppid)
        and (a.ndc in( &metndcs ) and (b.ndc in( &vicndcs )))
      ;
    quit;     
  %end;

  %if not %sysfunc(exist(l.final_&client)) %then %do;
    /* "Count all patients between 18-80 years old who are actively on both
     * Metformin and Victoza BUT HAVE BEEN ACTIVE FOR LESS THAN 90 DAYS"
     *
     * HPTask datasets used go back only 6 months.  Therefore a patient may
     * have used Met+Vic currently, i.e. the 90 day criteria) but also >6
     * months ago
     */
    proc sql;
      create table l.final_&client as
      select a.sidppid, a.ndc, a.ndc2, a.filldate
      from l.newbothmeds_&client a left join l.oldbothmeds_&client b  on a.sidppid=b.sidppid
      where b.sidppid is null
      ;
    quit;     
  %end;


  proc sql;
    create table counts as
    select "&client" as client, count(distinct sidppid) as count
    from l.final_&client
    ;
  quit;

  ods excel file="&RFDPATH/Reports/&RFDNUM._Counts_&client..xlsx" style=mystyle2 options(sheet_name="&RFDNUM" sheet_interval="none" absolute_column_width="20");
  %report_writer(type=excel,
                 ds=counts,
                 title='Count all patients between 18-80 years old who are actively on both Metformin and Victoza but have been active for less than 90 days',
                 nvars=2,
                 vars=%str(client,count),
                 vartypes=%str(char,num),
                 labels=%str(Client,Count)
                );
%mend rfd;
%rfd;
