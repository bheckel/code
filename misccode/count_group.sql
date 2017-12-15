
select distinct t.samp_id, count(distinct meth_spec_nm) c
from tst_rslt_summary t join samp s on t.samp_id=s.samp_id
where prod_nm like 'Rel%'
group by t.samp_id
having count(distinct meth_spec_nm) > 1
order by c desc
