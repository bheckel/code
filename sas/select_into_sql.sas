options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: select_into_sql.sas
  *
  *  Summary: Extract a list from a dataset variable.
  *
  *           Data gathered can be used after the datastep completes.
  *
  *           Also called SELECT INTO.  Resembles call symput.
  *
  *           See also count_num_obs.sas for filling a single mvar.
  *           or split_into_region_datasets.sas for THRU
  *
  * select count(distinct uid), min(dt), max(dt) into :IGNORE, :MINDT, :MAXDT
  *
  *  Created: Fri 06 Jun 2008 13:52:42 (Bob Heckel)
  * Modified: Mon 26 Mar 2018 14:57:09 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source mprint mlogic sgen;

proc sql noprint;
  connect to postgres as myconn(user=&user password=&password dsn="db6" readbuff=7000);

    select clientid into :clids separated by ',' from connection to myconn(
      select distinct clientid from dshbrd.dashboardclients;
    );
  disconnect from myconn;
quit;



 /* Single quoted comma separated list into a macrovar */
proc sql NOprint;
  connect to postgres as myconn(user=&user password=&password dsn="db8" readbuff=7000);

    select
      gpi10s
      into
        :gpi10 separated by ','
    from connection to myconn(
      select ''''||gd.gpidrugid||'''' as gpi10
      from campaign.atebcampaigngpidrug acgd
           join campaign.atebcampaign ac using (atebcampaignid)
           join campaign.gpidrug gd using (gpidrugid)
       where atebcampaignid not in (8,9,10)
       ;
    );

  disconnect from myconn;
quit;
%put _user_;



proc sql NOprint;
  connect to postgres as myconn(user=&user password=&password dsn="db6dev" readbuff=7000);

    select
      buildid, importpath, nextbuild
      into
        :buildid TRIMMED,
        :el_file TRIMMED,
        :nextbuild TRIMMED
    from connection to myconn(
      select buildid, importpath, builddate+importdelay as nextbuild
      from analytics.build
      where clientid = 953
      ;
    );

  disconnect from myconn;
quit;
%put &SYSMACRONAME; %put _user_;


endsas;
data one;
  U1=1;
  U2=2;
  X=3;
  U3=4;
  Z=5;
run;

%let LIB=WORK;
%let DSN=one;
%let PREFIX=U;

 /* Build individual macrovariables */
proc sql PRINT;
  select count(*) into :NV
  from dictionary.columns
  where libname="&LIB" and name like "&PREFIX%"
  ;
/***  select distinct(name) into :VAR1-:VAR%TRIM(%LEFT(&NV))***/
  /* same */
  select distinct(name) into :VAR1 thru :VAR%TRIM(%LEFT(&NV))
  from dictionary.columns
  where libname="&LIB" and name like "&PREFIX%"
  ;
quit;



 /* Unrelated example */

 /* Build single list of vars into one macrovariable */
proc sql PRINT;
  select distinct(name) into :VARLIST separated by '||'
  from dictionary.columns
  where libname eq "&LIB" and memname eq "%upcase(&DSN)" 
        and name like "&PREFIX%"
        ;
quit;


%put _all_;



data tmp;
  input froms $ tos $  dist;
  cards;
AL         AL         0.000
AL         TN         3.059
AL         CA       129.396
AL         GU       130.184
AK         AK         0.000
AK         MT        45.695
  ;
run;
proc print data=_LAST_; run;

data tmp2;
  input revstate $;
  cards;
AL
CA
CA
MT
  ;
run;


 /* Comma delimited separated CSV (revstate is char, leave out quote(... for
  * numerics.
  */
proc sql NOPRINT;
  select distinct quote(trim(revstate)) into :quotedcommadel separated by ', '
  from tmp2
  ;
quit;
%put !!!&quotedcommadel;


proc sql NOPRINT;
  select distinct revstate into :REVS separated by ' '
  from tmp2
  ;
quit;

%macro Loop;
  %let i=1;
  %let listelem=%scan(&REVS, &i);
  %do %while(%length(&listelem));
    %put !!! &i;
    data tmp&i;
      set tmp;
      if tos eq "&listelem";
    run;
    proc print data=_LAST_; run;
    %let i=%eval(&i+1);
    %let listelem=%scan(&REVS, &i);
  %end;
%mend;
%Loop


proc sql NOPRINT;
  select froms, tos, dist into :ITEM1, :ITEM2, :ITEM3
  from tmp
  ;
quit;
%put !!!ITEM1 &ITEM1;
%put !!!ITEM2 &ITEM2;
%put !!!ITEM3 &ITEM3;
 /* Save these macrovars in a permanent dataset */
proc sql NOPRINT;
  create table savedmvars as
  select name, value
  from SASHELP.vmacro
  where scope='GLOBAL' and name in('ITEM1','ITEM2')
  order by 1
  ;
quit;
title 'savedmvars'; proc print data=_LAST_(obs=max); run;


 /* Count groups using an INTO range */
proc sql NOPRINT;
  select trim(left(put(count (distinct froms),8.))) into :C1 - :C3
  from tmp
  group by tos
  ;
quit;
%put !!!C1 &C1;
%put !!!C2 &C2;
%put !!!C3 &C3;


proc sql NOPRINT;
  select name into :V1-:V999999
  from dictionary.columns
  where libname eq 'SASHELP'
  ;
quit;
%put &V1;
%put &V9;



proc sql NOPRINT;
  select distinct product, cats(product,stores) into :PROD separated by ',',
                                                     :PRODPLUS separated by ','
  from SASHELP.shoes (obs=10)
  order by product
  ;
quit;

%put !!!prod: %bquote(&PROD);
%put !!!prodplus: %bquote(&PRODPLUS);



 /* E.g. if need list for SAS and a list for SQL */
proc sql NOPRINT;
  /* DISTINCT is distributive */
  select distinct product, product into :PROD separated by ' ',
                                        :PRODPLUS separated by ','
  from SASHELP.shoes (obs=10)
  ;
quit;


endsas;
select batch_nbr, matl_nbr into :batches separated by "','", :materials separated by "','"
