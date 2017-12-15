
%macro m;
  /* Match pharmacypatientid records that Publix encrypted with their salt 'salty' by encrypting our
   * pharmacypatientid using their salt then comparing.
   */

  filename f '/Drugs/RFD/2016/11/AN.5706/Publix_pharmacydata.csv';

  data publix;
    format enroll_date exit_date YYMMDDN8.;
    infile f dlm=',' firstobs=2;
    input patient_num :$40. enroll_date :YYMMDD8. rx_count :8. exit_date :YYMMDD8.;
  run;

/***  %if not %sysfunc(exist(l.rxf)) %then %do;***/
    proc sql;
      connect to postgres as myconn (database=reporting authdomain=Postdb5Auth server='db-05.twa.taeb.com' readbuff=7000);

      create table rxf as select * from connection to myconn (

      select pharmacypatientid, encode(digest(pharmacypatientid||'salty','sha1'), 'hex') as patient_num2, filldate
      from rxfilldata_parent
      where clientid in(118)
      and filldate >= '2013-01-01'

      );
    quit;
/***  %end;***/

  libname l '/Drugs/RFD/2016/11/AN.5706/';

  proc sql;
    create table l.Publix_pharmacydata as
    select distinct a.*, b.pharmacypatientid
    from publix a left join rxf b on a.patient_num=b.patient_num2
    ;
  quit;
%mend;
%m;
