options NOsource;
 /*---------------------------------------------------------------------------
  *     Name: case.sql.sas
  *
  *  Summary: Demo of the CASE/SELECT function - proc sql and datastep 
  *           approaches.
  *
  *           There is no else-if, case expressions evaluate to the <result> of
  *           the first true <condition>
  *          
  *           CASE  WHEN <condition> THEN <result>
  *                [WHEN <condition> THEN <result>
  *                 ...]
  *                [ELSE <result>]
  *           END
  *
  *  Created: Thu 02 Dec 2010 10:49:31 (Bob Heckel)
  * Modified: Tue 03 Oct 2017 08:56:08 (Bob Heckel)
  *---------------------------------------------------------------------------
  */
options source NOcenter;

proc sql;
  create table stages as
  select upid, (case when nrx ge 3 then 1
                    when nrx eq 2 and isstar=1 then 2
                    else 3
                end) as stage
  from fnl0_4_a
  ;
quit;  




proc sql;
  select count(case when pharmacypatientid eq '' then . else 1 end) as notfound,
         count(case when pharmacypatientid ne '' then . else 1 end) as found,
         count(case when pharmacypatientid ne '' then . else 1 end) / count(case when pharmacypatientid eq '' then . else 1 end) as pctnotfound
  from l.Publix_pharmacydata
quit;



data temp;
  input id x y ;
  cards;
1 25 30
1 28 30
1 40 25
2 23 54
2 34 54
2 35 56
  ;
run;

 /* Count number of distinct y values when x is less than 30: */
proc sql;
  select count(distinct y) as unique_y,
  count(distinct case when x < 30 then y else . end) as unique_criteria
  from temp;
quit;
title "&SYSDSN";proc print data=_LAST_(obs=10) width=minimum heading=H;run;title;



 /* Dataset only has Y and blank, want Y & N */
proc sql NOprint;
  create table l2.chronic as
  select a.*, case when b.chronic='Y' then 'Y' else 'N' end as chronic
  from l2.rxtotal a left join l.medispan3 b  on a.ndc=b.ndc_upc_hri
  ;
quit;



proc sql;
  select region, case product
                   when 'Boot'   then 'bootlike'
                   when 'Sandal' then 'sandallike'
                   else               'UNK'
                 end as etype
  from SASHELP.shoes
  where region like 'Africa%' and monotonic()<40
  ;
quit;


 /* Same using datastep */
data t(keep= region etype);
  set SASHELP.shoes(obs=39);
  if region eq: 'Africa';
  select;
    when (product eq 'Boot') etype='bootlike';
    when (product eq 'Sandal') etype='sandallike';
    otherwise etype='UNK';
  end;
run;
proc print data=_LAST_(obs=max) width=minimum NOobs; run;


proc sql;
  select region,
         sum(sales) as sales format=DOLLAR16.,
         sum(case when Product='Boot' then sales else 0 end) format=DOLLAR16.,
         sum(case when Product='Boot' then sales else 0 end) / sum(sales) as boot_sales_ratio format=PERCENT10.2
  from SASHELP.shoes
  group by region;
quit;
