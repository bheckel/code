--Created: 03-Jan-2023 (Bob Heckel)

with jan as (  
  select sum(constamt) tot1 ,  extract(year from report_date) yr
    from MKC_REVENUE
   where extract(year from report_date)>=kmc.get_first_reporting_year
   group by  extract(year from report_date)
), dec as (
  select sum(constamt) tot2 ,  extract(year from report_date) yr
    from MKC_REVENUE_02jan23--31dec22
   WHERE extract(year from report_date)>=kmc.get_first_reporting_year
   group by  extract(year from report_date)
)
select jan.yr, to_char(tot1,'9,999,999,999pr') jan, to_char(tot2,'9,999,999,999pr') dec, to_char(tot1-tot2,'9,999,999,999pr') diff 
  from jan, dec where jan.yr=dec.yr
 order by 1;
