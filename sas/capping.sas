options obs=50000;
options sasautos=(SASAUTOS '/Drugs/Macros') ls=140 ps=max mprint mprintnest validvarname=any;
%let numcap=500;
libname l '/sasdata/Personnel/bob/TMM/Delhaize';
libname data '/Drugs/TMMEligibility/Delhaize/Imports/20170914/Data';

data fnl0_4;
  set l.fnl0_4;
  upid=cats(%rml0(storeid), pharmacypatientid);
run;
/* title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title; */

proc sql;
  create table dbg1 as
  select distinct storeid, count(*)
  from fnl0_4
  where nrx ge 3
  group by storeid
  /* having count(*) ge 500 */
  order by 1
  ;
quit;
title "3+ only";proc print data=_LAST_ width=minimum heading=H;run;title;

data dbg1a;
  set dbg1;
  if _TEMG001 > &numcap then Count=500; else Count=_TEMG001;
  drop _TEMG001;
  rename storeid = 'Store ID'n;
run;


proc sql NOprint;
  create table star_ndcs as
  select distinct ndc
  from FUNCDATA.pqa_medlist
  where diabetes=1 or rasa=1 or statin=1
  ;
quit;

 /* 153 stores */
  /* 72 stage A stores (normally) capped */

proc sql;
  create table star_patients as
  select distinct cats(%rml0(a.storeid), a.pharmacypatientid) as upid
  from data.rxfilldata a left join star_ndcs b on a.ndc=b.ndc
  where b.ndc is not null
  ;
quit;

%build_long_in_list(ds=star_patients, var=upid, type=char);

proc sql;
  create table fnl0_4_stars as
  select *, 1 as isstarpat
  from fnl0_4 
  where upid in ( %long_in_list )
  ;
quit;

proc sql;
  create table fnl0_4_withsp as
  select a.*, b.isstarpat
  from fnl0_4 a left join fnl0_4_stars b on a.upid=b.upid
  ;
quit;
/* title "&SYSDSN";proc print data=_LAST_(where=(upid='1010061108')) width=minimum heading=H;run;title; */
/* title "&SYSDSN";proc print data=_LAST_(where=(upid='1010143477')) width=minimum heading=H;run;title; */
/* title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title; */

proc sql;
  create table stages as
  select upid, storeid, nrx, (case 
                                when nrx ge 3 then 1
                                when nrx eq 2 and isstarpat=1 then 2
                                else 3
                              end) as stage
  from fnl0_4_withsp
  ;
quit;  
/* title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title; */

proc sql;
  create table dbg2 as
  select distinct storeid, stage, count(*)
  from stages
  group by storeid, stage
  order by 1, 2
  ;
quit;
title "uncapped";proc print data=_LAST_ width=minimum heading=H;run;title;

proc sort data=stages; by storeid stage DESCENDING nrx; run;

data fnl1;
  set stages;
  retain seq;
  by storeid stage DESCENDING nrx;

  if first.storeid then do;
    seq=1;
    output;
  end;
  else do;
    seq=seq+1;

    if seq<=&numcap. then
      output;
  end;

  drop seq;
run;

proc sql;
  create table dbg3 as
  select distinct storeid as 'Store ID'n, stage as Stage, count(*) as Count
  from fnl1
  group by storeid, stage
  order by 1, 2
  ;

  create table dbg4 as
  select distinct storeid as 'Store ID'n, count(*) as Count
  from fnl1
  group by storeid
  order by 1, 2
  ;
quit;
title "capped";proc print data=_LAST_ width=minimum heading=H;run;title;


ods excel file="/sasdata/Personnel/bob/TMM/Delhaize/Delhaize_ReCapping_Summary.xlsx";
  ods excel options(sheet_name="Original Capping by Store");
  proc print data=dbg1a NOobs; run;
  ods excel options(sheet_name="New Capping By Store");
  proc print data=dbg4 NOobs; run;
  ods excel options(sheet_name="New Capping By Stage");
  proc print data=dbg3 NOobs; run;
ods excel close;
