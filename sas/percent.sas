options nosource;
 /*---------------------------------------------------------------------------
  *     Name: percent.sas
  *
  *  Summary: Calculate subtotal percentages
  *
  *  Created: Mon 04 Aug 2014 14:43:04 (Bob Heckel)
  * Modified: Fri 23 Feb 2018 14:03:36 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source;

data qc_status;
  patientstateprov='NC';
  output;
  patientstateprov='NJ';
  output;
  patientstateprov='Nx';
  output;
run;

%let statelist=%str('AL','AK','AS','AZ','AR','CA','CO','CT','DE','DC','FM','FL','GA','GU','HI','ID','IL','IN','IA','KS','KY','LA','ME','MH','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','MP','OH','OK','OR','PW','PA','PR','RI','SC','SD','TN','TX','UT','VT','VI','VA','WA','WV','WI','WY', 'AB','BC','MB','NB','NL','NS','NT','NU','ON','PE','QC','SK','YT');
 /* Zero obs if there are fewer than 95% clean data */
proc sql;
  create table _err_patientstate as
  select distinct (select count(*) from qc_status where patientstateprov not in( &statelist )) / (select count(*) from qc_status) as pct, '_err_patientstate' as ds
  from qc_status
  having pct gt 0.05
  ;
quit;
title "_err_patientstate";proc print data=_err_patientstate width=minimum heading=H;run;title;

data error_count;
  length ds $40;
  set _err:;
  clid=&clid;
run;
title "&SYSDSN";proc print data=error_count width=minimum heading=H;run;title;  

%let dsid=%sysfunc(open(work.error_count)); %let cntobs=%sysfunc(attrn(&dsid, NLOBS)); %let dsid=%sysfunc(close(&dsid));

%if &cntobs gt 0 %then %do;
  %put ERROR: Activation QC fail;
  data _NULL_; to='bob.heckel@taeb.com'; file DUMMY email filevar=to subject="Error during qc_tmm_activation execution &clid" attach=("/Drugs/TMMEligibility/&clientfolder./Imports/ClientQC_&Cname"); run;
  proc datasets library=work; delete error_count _err:; run; quit;
  data _NULL_; abort abend 008; run;
%end;
%else %do;
  %put NOTE: Activation QC clean;
%end;



data pay;
  input dept $ name $ salary @@;
  datalines;
bedding Watlee 18000    bedding Ives 16000
bedding Parker 9000     bedding George 8000
bedding Joiner 8000     carpet Keller 20000
carpet Ray 12000        carpet Jones 9000
gifts Johnston 8000     gifts Matthew 19000
kitchen White 8000      kitchen Banks 14000
kitchen Marks 9000      kitchen Cannon 15000
tv Jones 9000           tv Smith 1000
tv Rogers 15000         tv Morse 15000
xray Jones 1000
  ;
run;
proc print data=_LAST_(obs=max) width=minimum; run;

proc means noprint;
  class dept;
  var salary;
  output out=stats sum=s_sal;
run;
/* title 'class dept, var salary'; proc print data=_LAST_(obs=max) width=minimum; run; title; */

/*
Obs    dept       _TYPE_    _FREQ_     s_sal

 1                   0        19      214000
 2     bedding       1         5       59000
 3     carpet        1         3       41000
 ...
*/
data _null_;
  set stats;
  if _n_=1 then 
    call symput('s_tot', s_sal);
  else
    call symput('s_'||dept, s_sal);
run;

%put _user_;

data final;
  set pay;
  pctofdept=(salary/symget('s_'||dept))*100;
  pctoftot=(salary/&s_tot)*100;
run;
/* title 'datastep'; proc print data=_LAST_(obs=max) width=minimum; run; */


 /* Compare */
title 'proc sql';
proc sql;
  select a.*,
         a.salary/a.totdeptsal as pctofdept,
         b.salary/b.totsal as pctoftot
  from (select *, sum(salary) as totdeptsal from pay group by dept) as a JOIN (select name, salary, sum(salary) as totsal from pay) as b ON a.name=b.name
  ;
quit;


 /* Compare */
title 'proc freq';
proc freq data=pay; run;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;



 /* Two-step */

proc sql;
  create table report1_nRx as 
  select nRx, count(distinct cats(storeid,pharmacypatientid)) as UPID
  from data.fnl
  group by nRx
  order by nRx;
quit;
/*
Obs    nRx    UPID

  1      3     110
  2      4      74
  3      5      50
  4      6      35
  5      7      24
  6      8      15
  7      9      17
  8     10      13
  9     11       4
 10     12       6
 11     13       1
 12     14       1
 13     15       2
 14     17       1
*/

title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;  

proc sql;
  create table t as 
  select a.*, b.*, a.UPID/b.tot as pct format=PERCENT8.2
  from report1_nRx a join (select nRx, sum(upid) as tot from report1_nRx) b on a.nRx=b.nRx
  ;
quit;
title "&SYSDSN";proc print data=_LAST_ width=minimum heading=H;run;title;  
/*
Obs    nRx    UPID    tot     pct

  1      3     110    353    31.16%
  2      4      74    353    20.96%
  3      5      50    353    14.16%
  4      6      35    353     9.92%
  5      7      24    353     6.80%
  6      8      15    353     4.25%
  7      9      17    353     4.82%
  8     10      13    353     3.68%
  9     11       4    353     1.13%
 10     12       6    353     1.70%
 11     13       1    353     0.28%
 12     14       1    353     0.28%
 13     15       2    353     0.57%
 14     17       1    353     0.28%
*/
