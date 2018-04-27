
with val as (
values ('1003033101'),	('1003048109'),	('1003109422')
)
select column1 as npi, 
       count(*),
       count(distinct cardholderid) as distinct_count,
       sum(case when h.atebpatientid is null then 1 else 0 end) as no_match,
       sum(case when h.atebpatientid is not null then 1 else 0 end) as match
from val v
left join healthplan_mdf_uhc h on h.npi=v.column1 and h.importsourceid in (14167,14171,15339)
group by 1
order by 1
;



with binpcn as (
select column1 as bin, column2 as pcn
from (
values ('610455','MPDBP')
,('610455','ELMSBB')
,('610455','MHCP')
,('015574','MNPROD1')
,('017142','MNPROD1')
,('018315','MNM')
,('004336','MEDDMCDMN')
,('004336','MCAIDMN')
,('015574','ASPROD1')
,('015574','PWPROD1')
,('012353','6190000')
,('600428','6180000')
,('003858','DE')
,('003858','MA')
) a
)
, pats as (
select pp.atebpatientid, rxfd.bin, rxfd.pcn, count(*)
from pmap.patientparticipation pp
join pmap.pmapcampaign pc on pc.pmapcampaignid = pp.pmapcampaignid and pc.pmapfeatureid = 1
join pmap.medsyncresponse msr on msr.atebpatientid = pp.atebpatientid
join patient.rxfilldetail rxfd on rxfd.patientrxid = msr.patientrxid
where pp.clientid = 19 and msr.clientid = 19 and rxfd.clientid = 19
and pp.patientstatusid = 3
and msr.programstatusid = 1
and row(rxfd.bin, rxfd.pcn) in
(select * from binpcn)
group by 1,2,3
)
select c.name as client_name, cs.storeid, cs.clientstoreid, cs.city as store_city, cs.stateprov as store_stateprov,
ap.pharmacypatientid
  , a.atebpatientid , a.bin, a.pcn
  , pn.firstname, pn.lastname
  , pd.dateofbirth, pd.patientgender
  , pcon.phonenum
  , pa.stateprov as patient_stateprov
  , pa.city as patient_city
  , coalesce(pp.statusmodifieddate,pp.lastmodified)::date as statusdate
from pats a

join pmap.patientparticipation pp on pp.atebpatientid = a.atebpatientid
join pmap.pmapcampaign pc on pc.pmapcampaignid = pp.pmapcampaignid and pc.pmapfeatureid = 1

join patient.atebpatient ap on ap.atebpatientid = a.atebpatientid
join client.client c on c.clientid = ap.clientid
join client.store cs on cs.storeid = ap.storeid
join patient.patientname pn on pn.atebpatientid = ap.atebpatientid
join patient.patientdemographic pd on pd.atebpatientid = ap.atebpatientid
join patient.patientcontact pcon on pcon.atebpatientid = ap.atebpatientid
join patient.patientaddress pa on pa.atebpatientid = ap.atebpatientid

where pp.clientid = 19 and ap.clientid = 19 and pn.clientid = 19 and pd.clientid = 19 and pcon.clientid = 19 and
pa.clientid = 19



with actions as (
    select apa.auditatebpatientactionid, apa.atebpatientid, apa.created, pua.pmapuserid, pu.loginname, pua.actiontypeid, a.actiontypegroupname
    , a.name as actiontype
    , row_number() over (partition by apa.atebpatientid order by apa.atebpatientid, apa.created desc, apa.auditatebpatientactionid desc)
    from pmap.auditatebpatientaction apa
    join pmap.auditpmapuseraction pua on pua.auditpmapuseractionid = apa.auditpmapuseractionid and pua.clientid = apa.clientid
    join pmap.pmapuser pu on pu.pmapuserid = pua.pmapuserid
    join pmap.actiontype a on a.actiontypeid = pua.actiontypeid
    where a.actiontypeid = 39 and apa.clientid = 2000000 and apa.created::date >= date('now')-interval '1 day'
  ) , userauth as (
    select pu.pmapuserid, pu.loginname, pr.pmaproleid, pr.name as pmaprole
      , coalesce(s.num_store,0) as num_store, coalesce(ch.num_chain,0) as num_chain, coalesce(cl.num_client,0) as num_client
      , s.store, ch.chain, cl.client
      from pmap.pmapuser pu
      join pmap.pmapuserrole pur on pur.pmapuserid = pu.pmapuserid
      join pmap.pmaprole pr on pr.pmaproleid = pur.pmaproleid
      left join (
        select pmapuserid, count(*) as num_store, array_agg(distinct cs.clientstoreid) as store
        from pmap.pmapuserstore pus
        join client.store cs on cs.storeid = pus.storeid
        group by 1
      ) s on s.pmapuserid = pu.pmapuserid
      left join (
        select pmapuserid, count(*) as num_chain, array_agg(distinct ch.name) as chain
        from pmap.pmapuserchain puc
        join client.chain ch on ch.chainid = puc.chainid
        group by 1
      ) ch on ch.pmapuserid = pu.pmapuserid
      left join (
        select pmapuserid, count(*) as num_client, array_agg(distinct cl.name) as client
        from pmap.pmapuserclient puc
        join client.client cl on cl.clientid = puc.clientid
        group by 1
      ) cl on cl.pmapuserid = pu.pmapuserid
  )
  select coalesce(pp.statusmodifieddate,pp.lastmodified)::date as statusdate, cs.clientstoreid, ap.pharmacypatientid
    , current_timestamp::timestamp as current_timestamp, a.pmapuserid, a.loginname, a.actiontypeid, a.actiontypegroupname, a.actiontype
    , u.pmaproleid, u.pmaprole, u.num_store, u.num_chain, u.num_client, pp.reasontext, pn.firstname, pn.lastname, pd.dateofbirth
  from pmap.patientparticipation pp
     join pmap.pmapcampaign pc on pc.pmapcampaignid = pp.pmapcampaignid and pc.pmapfeatureid = 1
     join patient.atebpatient ap on ap.atebpatientid = pp.atebpatientid and ap.clientid = pp.clientid
     join patient.patientname pn on pn.atebpatientid = pp.atebpatientid and pn.clientid = pp.clientid
     join patient.patientdemographic pd on pd.atebpatientid = pp.atebpatientid and pd.clientid = pp.clientid
     join client.store cs on cs.storeid = pp.nextfillstoreid
     left join actions a on a.atebpatientid = pp.atebpatientid and a.row_number = 1
     left join userauth u on u.pmapuserid = a.pmapuserid
     where pp.clientid = 2000000
     and coalesce(pp.statusmodifieddate,pp.lastmodified)::date >= date('now')-interval '1 day'
     and pp.patientstatusid = 5
     ;
