
select ch.clientid, st.clientstoreid, ap.pharmacypatientid, ac.code, ac.name, '' as x1, '' as x2, 0 as x3, to_char(date('now'),'YYYYMMDD') as x4, 'AddOrUpdate' as x5, '' as x6, '' as x7, 'EXPIRE='||to_char(date('now')+30,'YYYYMMDD') as x8,
       case when ac.actioncodeid=20109 then 'IMM_FAMILY=AV_HEPATITIS'
            when ac.actioncodeid=20114 then 'IMM_FAMILY=AV_INFLUENZA'
       end as x9
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid 
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
where alertstatusid=1 and ia.actioncodeid in(select actioncodeid from pmap.actioncode where name like 'Immunization Opportunity%') 
group by ia.atebpatientid, ch.clientid, st.clientstoreid, ap.pharmacypatientid, ia.atebpatientid, ac.code, ac.name, ac.actioncodeid
having count(*)>1 order by ch.clientid;
