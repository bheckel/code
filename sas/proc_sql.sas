options nosource;
 /*---------------------------------------------------------------------------
  *     Name: proc_sql.sas
  *
  *  Summary: Demo of proc sql
  *
  *           See also:
  *           except_set_operator.sas
  *           proc_sql_generic_connect.sas 
  *           sql_inline_view_find_max_count.sas
  *           sql_remerging_summary_statistics_back.sas
  *           sql_set_operations.sas
  *           varexist.sas
  *
  *           Adjust print width via:  select foovar format=$5. from ...
  *
  *           Practical Problem-Solving http://support.sas.com/documentation/cdl/en/sqlproc/62086/HTML/default/viewer.htm#a002536887.htm
  *
  *  Created: Sun 23 Feb 2003 12:45:12 (Bob Heckel)
  * Modified: Wed 21 Dec 2016 09:59:33 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
 /* proc sql default is to use labels instead of ds varnames */
 /*                   _______                                */
options source ls=256 NOlabel;

 /* Create empty ds for proc append */
proc sql;
  create table tosoftdelete2 as 
  select &clid. as clientid,
     clientstoreid format $20. length  20, 
     atebpatientid,
     today() as startdate format date9.,
     today()+8 as enddate format date9.,
     1000000 as ranking,
     '2' as criteria,
     1 as softdeleteflag
  from ccecallrequest(obs=0)
/***  where atebpatientid in ( %long_in_list )***/
  ;
quit;



 /*~~~~~~~~~~~~~~~~~~~~~~~ SAS ~~~~~~~~~~~~~~~~~~~~~~~*/

data bringin;
  input job_id $  distcode $  foo;
  cards;
a123 ral 5
b345 dur 6
c678 nj  7
  ;
run;

data jobcost;
  input job_id $  distcode $  foo  bar;
  cards;
a123 ral 5 1
b345 dur 6 2
b345 dur 7 3
c678 nj  7 2
d901 huh 8 2
  ;
run;

proc sql;
  /* "Mixed" SAS+SQL */
  create table work.job_w_om(rename=(bar=baz)) as
    select a.job_id label='Job Number', b.distcode label='OM Number'
    from work.bringin(drop=foo) as a left join work.jobcost as b on a.job_id=b.job_id;
quit;
proc print; run;


proc sql NOPRINT;
  select job_id into :JOB_IDS 
  from bringin
  ;
quit;
%put &JOB_IDS;
%put automatic variable SQLOBS counts variables: &SQLOBS;


proc sql NOPRINT;
  /* quote() adds doublequotes around each. */
  select distinct quote(job_id) into :wantemall separated by ', '
  from bringin
  ;
quit;
%put &wantemall;

proc sql NOPRINT;
  select catt('NUM',name) into :NUMflagnames separated by ' '
  from dictionary.columns
  where memname eq "&dsin" and upcase(name) like '%_FLAG'

  ;
quit;

title 'IN(wantemall)';
proc sql;
  select *
  from jobcost
  where job_id in(&wantemall)
  ;
quit;
title;


proc sql NOPRINT;
  select max(foo), max(bar) into :maxf, :maxb
  from jobcost
  ;
quit;
%put &maxf and &maxb;


proc sql NOPRINT;
  /* format= relies on e.g. ls=180 */
  select max(foo) format=DOLLAR8.2 into :max
  from jobcost
  ;
quit;
%put &max;



 /* Emulate the SAS datastep's _N_ (or OBS) to determine the current row
  * number.  Similar to data step's  ...SET FOO(OBS=2);...  or Oracle's
  * ...ROWNUM<3...
  */
title 'monotonic';
proc sql;
  select monotonic() as ObsNumber, *
  from jobcost
  where monotonic() le 2;
  ;
quit;
title;



proc sql;                       
  create table one (
    name   char(200),
    CONSTRAINT prim_key  primary key(name)
  );
quit;

proc sql;
  insert into one values('Bob');
  insert into one values('Bobagainnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn');
quit;

 /* proc print will complain if we have chars > 124  This gets around that
  * limitation.
  */
proc sql flow=20;
  select *
  from one
  ;
quit;


title 'Aggregate Group By';
proc sql;
  /***   select *, sum(foo) as foosum ***/
  /*                                            column modifiers     */
  /*                                         ______         _______  */
  select distcode, sum(foo)/100 as foosumdiv label='My Sum' format=PERCENT. 
  from jobcost
  group by distcode
  ;
quit;


title 'Using LIKE wildcarding (and debugging SQL)';
***proc sql ;
***proc sql INOBS=5;  /* like obs= for non-sql */
***proc sql NOEXEC;  /* syntax check */
proc sql FEEDBACK;  /* debugging gives Log "NOTE: Statement transforms to:" and expands "SELECT *" etc. */
 /* Toggle this to 1-dry-run or 2-"DROP" fields by seeing all the vars that will be selected by "*" */
/***VALIDATE***/
  select * 
  from sashelp.shoes(drop=sales)
  where region like 'A%a'
  ;

  %put !!! automatic proc sql mvar &SQLOBS;
  %put !!! automatic proc sql mvar (0 is no error, 4 warning, 8 error stop, 12 SAS Institute compile bug, 16 SQL runtime, 24 Env runtime, 28 SAS Institute runtime bug) &SQLRC;

  reset NOFEEDBACK;

  select * 
  from sashelp.shoes
  where region like 'B%'
  ;

quit;


 /* Complex, hard to do this join in SAS */

proc sql;
  create table t3 as
  select frds, specname, meth_spec_nm
  from L.t1 LEFT JOIN L.t2 on substr(t1.frds,4,6)=upcase(substr(t2.prod_nm,1,6)) 
                              and specname=meth_spec_nm
  ;
quit;



 /* Rename field / varname */
proc sql;
  select *
  from sashelp.shoes(rename=(region=myyr subsidiary=mysub))
  ;
quit;



 /* Prepending a string literal */
proc sql;
  select distinct 'literal ', region, product
  from sashelp.shoes
  ;
quit;



 /* Using hardcoded literals in SELECT plus WHERE negation (!= doesn't work) */
proc sql;
  select distinct 'literal ' as hardcodedfieldname, region 'reggy' format=$5., product
  from sashelp.shoes
  /* all 3 are the same */
/***    where region ^= 'Africa'***/
/***  where region not = 'Africa'***/
  where region ne 'Africa'
  ;
quit;



 /* Aggregate calculations */
proc sql;
  select min(&var) as min, (min(&var)*.10)+min(&var) as minref, max(&var) as max, (max(&var)*.10)+max(&var) as maxref into :MIN, :MINREF, :MAX, :MAXREF
  from l.ip21_0002t_line8filler
  ;
quit;



 /* Modify on the fly */
proc sql;
  CREATE TABLE work.July_XYZ_Co_Claims AS
    SELECT input(bill_date,MMDDYY10.) AS bill_date, account_no, claim_id, claim_line_item, dx_code AS diagnosis, line_item_charge AS claim_line_item_amount
    FROM work.July_2010_Claims
    ORDER BY input(bill_date,MMDDYY10.) DESC, account_no, claim_id, claim_line_item
    ;
quit;



 /* SAS functions + SQL mixed mode */
proc sql;
  select specname, datepart(max(sampcreatets)) as maxs format=MMDDYYD8., max(resstrval) as maxr
  from foo
  ;
quit;



 /* Nexus 6 Cylon */
proc sql;
  select * 
  from sashelp.shoes(where=(region='Africa'))
  ;
quit;



 /* Should be impossible - char to num conversion on the fly: */
proc sql;
  create table t as
  select long_product_name, avg(input(recorded_text, 8.)) as avgrectxt
  from L.ols_0016t_advairdiskus
  where mrp_batch_id='ZP1715'
  group by long_product_name, material_description, alt_batch_number
  ;
quit;



 /*~~~~~~~~~~~~~~~~~~~~~~~ SAS/Access ~~~~~~~~~~~~~~~~~~~~~~~*/

 /* Libname approach */
%let usr=pks;
%let pw=ev123dba;
%let db=sdev581;
%let sch=dm_dist;
libname ORA oracle user=&usr password=&pw path=&db schema=&sch;
data t;
  set ORA.vw_lift_rpt_results_nl(obs=5);
run;


 /* Pass through */
%let EXTRACTSTRING=
select foo 
from bar
;
proc sql feedback;
  CONNECT TO ORACLE(USER=&USERNAME ORAPW=&PASSWORD PATH=&DATABASE);
    CREATE TABLE &OUTPUTFILE.&i AS SELECT * FROM CONNECTION TO ORACLE (
      %bquote(&EXTRACTSTRING)
    );
  DISCONNECT FROM ORACLE;
quit;


 /* Multiple table creation */
PROC SQL;
  CONNECT TO ORACLE(USER=&DbId ORAPW=&DbPsw BUFFSIZE=5000 PATH="&DbServerName");

    CREATE TABLE PKS_SUM AS SELECT * FROM CONNECTION TO ORACLE (
      select distinct METH_SPEC_NM
      from pks_extraction_control 
      where Column_Nm is null or 
      Column_Nm in (&prods)
    );

    CREATE TABLE PKS_IND AS SELECT * FROM CONNECTION TO ORACLE (
      select distinct METH_SPEC_NM
      from pks_extraction_control 
      where Column_Nm is not null and 
      Column_Nm not in (&prods)
    );

  DISCONNECT FROM ORACLE;
QUIT;



proc sql;
   create table on_csv_not_db5 as
   select storeid_csv as storeid, pharmacypatientid_csv as pharmacypatientid, sumflag, cntdb5
   from csv3 a left join db52 b on a.storeid_csv=input(b.storeid_db5, 8.) and a.pharmacypatientid_csv=input(b.pharmacypatientid_db5, 8.)
   ;
quit;


 /* When you use Ave_Height in a calculation, you need to precede it with the
  * keyword CALCULATED, so that PROC SQL doesn’t look for the variable in one
  * of the input data sets
  */
proc sql;
  select Subj, Height, Weight, mean(Height) as Ave_Height, 100*Height/CALCULATED Ave_Height as Percent_Height
  from learn.health
  ;
quit;

