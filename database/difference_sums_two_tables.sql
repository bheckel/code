with t as(
  select invoice,sum(round(lbdamt)) lbdamt
  from mkc_revenue@atlas_test_rw
  where   source_db='SALESFORCE'
   and lbddate > '31DEC2023'
   and invoice_type != 'CM'
  group by invoice
), p as (
  select invoice,round(lbdamt) lbdamt
  from mkc_revenue 
  where   source_db='SALESFORCE'
  and lbddate > '31DEC2023'
     and invoice_type != 'CM'
), dif as (
select t.invoice, t.lbdamt t_lbdamt, p.lbdamt p_lbdamt
  from t, p 
 where t.invoice = p.invoice(+)
   and t.lbdamt != p.lbdamt
)
select invoice, t_lbdamt-p_lbdamt diff
  from dif
 order by 1
;
