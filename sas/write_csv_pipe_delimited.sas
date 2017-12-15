
options ls=180 ps=max; libname l '/Drugs/TMMEligibility/Publix/Imports/20160114/Data' access=readonly;

filename F "/Drugs/TMMEligibility/Publix/Imports/20160114/Output/PUPTMM_candidates_fdw_0.csv";

data f;
  format senddate YYMMDD10.;
  infile F DLM='|' DSD MISSOVER FIRSTOBS=1;
  input atebpatientid  :8.
        clientid       :8.
        nrx            :8.
        senddate       :YYMMDD10.
        ;
run;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;


proc sql;
  create table t as
  select * 
  from l.fnl
  ;
quit;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;


proc sql;
  create table t2 as
  select a.*, b.storeid
  from f a left join t b on a.clientid=b.clientid and a.atebpatientid=b.atebpatientid
  where a.atebpatientid is not null
  order by atebpatientid
  ;
quit;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;


 /* 31-Aug-16 see proc_export.sas */
ods path templat (update) sashelp.tmplmst (read);
proc template;
  define tagset
    tagsets.csvnoq / store=templat;
    parent=tagsets.csv;
    define event quotes;
    end;
  end;
run;

ODS listing close;
ods tagsets.csvnoq file="PUPTMM_candidates_fdw_0_NEW.csv" options(delimiter='|' table_headers="no");
proc print data=t2 NOobs label; run;
ODS tagsets.csvnoq close;

