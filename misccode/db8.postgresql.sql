
-- Last update lag
select * from pg_last_xact_replay_timestamp();

select * from pg_stat_activity where usename='bheckel'
select pg_cancel_backend(17720)

-- \i ~/bob/tmp/.vimxfer

$ while true; do psql -U tableau -h db-03.twa.ateb.com ateb -c "select count(*) from pmap.interventionalert as ia join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid join client.store as st on ap.storeid=st.storeid join client.chain as ch on ch.chainid=st.chainid join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid where alertstatusid=1 and ia.actioncodeid in(select actioncodeid from pmap.actioncode where name like 'Immunization Opportunity%') and ch.clientid=2;"; sleep 60; done

select * from pmap.interventionalert where clientid=22 and reasonforalert='Humana - Medicare Advantage' and atebpatientid='24736677' order by created desc

-- trace a winndixie patient activity in pmap
select pp.clientid, pharmacypatientid, st.storeid, st.clientstoreid, pp.patientstatusid, ps.name, pc.pmapfeatureid, pp.atebpatientid, coalesce(pp.statusmodifieddate,pp.lastmodified) as modified
from pmap.archivepatientparticipation as pp
     join patient.atebpatient ap on pp.atebpatientid=ap.atebpatientid
     join client.store as st on st.storeid=ap.storeid
     join pmap.pmapcampaign as pc on pc.pmapcampaignid=pp.pmapcampaignid
     join pmap.patientstatus as ps on pp.patientstatusid=ps.patientstatusid
where pharmacypatientid in('HAYDCH1','GIOVJO1')
order by modified desc;

select ap.atebpatientid, pp.clientid, st.storeid, st.clientstoreid, ps.patientstatusid, date_part('year',age(dateofbirth))
from pmap.patientparticipation as pp
     join patient.atebpatient ap on pp.atebpatientid=ap.atebpatientid
     join client.store as st on st.storeid=ap.storeid
     join pmap.pmapcampaign as pc on pc.pmapcampaignid=pp.pmapcampaignid
     join patient.patientdemographic as pd on pp.atebpatientid=pd.atebpatientid
     join pmap.patientstatus as ps on pp.patientstatusid=ps.patientstatusid
where pp.clientid=654 
      and  pc.pmapfeatureid=1
      and  ap.atebpatientid in(40469384,41167048,41189949,41198508,41200426,40462625,40471844,40468756,41168035,41168206,41170122,41196782,41170136,50504945,68348874,47332762,47844580,73725061,60900640,60436461,70124910,70594910,72082953,51034800,59979634,61896710,71040693)
order by ps.patientstatusid;

-- Count all HPs by clientid
select ch.clientid, ia.reasonforalert, count(*) 
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid
where ia.actioncodeid=20018 and alertstatusid=1
group by ch.clientid, ia.reasonforalert
order by ch.clientid, ia.reasonforalert

-- Counts of Priority active tasks by clientid
select ch.clientid, ia.reasonforalert, ia.alertstatusid, al.name, count(*) 
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid
     join pmap.alertstatus as al on al.alertstatusid=ia.alertstatusid
where ch.clientid=1020 and ia.actioncodeid=20018 --and alertstatusid=3
group by ch.clientid, ia.reasonforalert, ia.alertstatusid, al.name
order by ch.clientid, ia.reasonforalert, ia.alertstatusid

-- https://wiki.ateb.com/display/MYX/Camel+Route+-+Time+My+Meds+%28TMM%29+Alerts
-- All active Immunization tasks in PMAP
select ch.clientid, st.displayname, st.clientstoreid, ap.pharmacypatientid, ac.code, ac.name, ia.reasonforalert, ac.actioncodeid
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid 
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
where alertstatusid=1 and ia.actioncodeid in(select actioncodeid from pmap.actioncode where name like 'Immunization Opportunity%') and ch.clientid=690 and st.clientstoreid='0811';

-- Want patients with two or more Immu tasks
select atebpatientid, reasonforalert
from pmap.interventionalert
where atebpatientid in (select ap.atebpatientid
                        from pmap.interventionalert as ia
                             join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
                             join client.store as st on ap.storeid=st.storeid
                             join client.chain as ch on ch.chainid=st.chainid
                        where ch.clientid=434 and ia.actioncodeid in(select distinct actioncodeid from pmap.actioncode where name ilike '%immu%') and ia.alertstatusid=1
                        group by ap.atebpatientid
                        having count(*)>1)
     and actioncodeid in(select distinct actioncodeid from pmap.actioncode where name ilike '%immu%')


-- Want all imm priorities
SELECT distinct ia.actioncodeid, reasonforalert, ac.name, ac.code, ia.priority
FROM pmap.interventionalert ia join pmap.actioncode ac on ia.actioncodeid=ac.actioncodeid
where ia.actioncodeid in(select distinct actioncodeid from pmap.actioncode where name ilike '%immuni%')
      and ia.reasonforalert ilike '%zation opp%' and ia.alertstatusid=1


-- Want patients with auto completed task:
select ia.atebpatientid, ch.clientid, ia.reasonforalert, ia.alertstatusid, al.name 
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid
     join pmap.alertstatus as al on al.alertstatusid=ia.alertstatusid
where ch.clientid=1020 and ia.actioncodeid=20018 and ia.alertstatusid=10

-- Want counts of Priority active tasks by store.  Are caps being honored?  
select ch.clientid, st.clientstoreid, ap.storeid, count(*) 
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid
where ia.reasonforalert in ('Time My Meds - Priority Patient Enrollment - UnitedHealthcare') and alertstatusid=1
group by ch.clientid, st.clientstoreid, ap.storeid
order by ch.clientid, st.clientstoreid, ap.storeid
;

-- Find a patient with an active UHC HP task
select ap.atebpatientid, ch.clientid, st.clientstoreid, ap.storeid
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid
where ia.reasonforalert in ('Time My Meds - Priority Patient Enrollment - UnitedHealthcare') and alertstatusid=1 and ch.clientid=137
order by ap.atebpatientid, ch.clientid, st.clientstoreid, ap.storeid
;

-- Are deletions removing Enrolled, Opt-Out or Un-enrolled patients?
select ch.clientid, st.clientstoreid, ap.pharmacypatientid as externalpatientid, ia.reasonforalert, ia.atebpatientid, date(ia.lastmodified) as dateadded
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid
where ia.reasonforalert in ('Time My Meds - Priority Patient Enrollment - UnitedHealthcare') and alertstatusid=1 and ia.atebpatientid in(select atebpatientid from pmap.patientparticipation where  patientstatusid in (3,4,5));

select * from pmap.patientparticipation where atebpatientid=42236438;

-- Are dropbox files making it to PMAP?
select ch.clientid, st.clientstoreid, ap.pharmacypatientid as externalpatientid, 'TMM_ENROLL_PRI' as tasktype, ia.reasonforalert, ia.atebpatientid, date(ia.lastmodified) as dateadded
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid
where ia.reasonforalert in ('Time My Meds - Priority Patient Enrollment - UnitedHealthcare') and ia.lastmodified > '2016-06-05' and ch.clientid=636;

-- Have clientid want chainid "Big D's Discount Drugs" is 647
SELECT chainid,clientid,name,version,created,lastmodified FROM "client"."chain" where clientid=137;
-- Find storeid (Ateb) is 16868 and clientstoreid is 3990 (Freds)
SELECT storeid,chainid,name,displayname,openflag,storestatusid,obcstoreid,amcstoreid,clientstoreid,ncpdpid,npi,address1,address2,city,stateprov,postalcode,latitude,longitude,phonenum,faxnum,version,created,lastmodified FROM "client"."store" where chainid=647;

-- Have clientstoreid want storeid detail CANONICAL
select a.name, c.chain, a.city, a.status, a.id, a.storeid, a.chainid, a.clients_fkid, a.client_storeid, NULL as x, b.displayname, b.openflag, b.storeid, b.obcstoreid, b.amcstoreid, b.clientstoreid
from amc.stores a 
     join client.store b on a.chainid=b.chainid and a.id=b.amcstoreid
     join amc.chains c on a.chainid=c.id
where a.clients_fkid=8  and a.storeid='509' --a.storeid::integer=509
order by a.chainid, a.storeid;

-- Have storeid want clientstoreid
select a.name, a.city, a.status, a.id, a.storeid, a.chainid, a.clients_fkid, a.client_storeid, NULL as x, b.displayname, b.openflag, b.storeid, b.obcstoreid, b.amcstoreid, b.clientstoreid
from amc.stores a join client.store b on a.chainid=b.chainid and a.id=b.amcstoreid
where a.clients_fkid=118 and a.storeid='4' -- id the store uses, not ateb, often w/o leading zeros
order by a.chainid, a.storeid;

-- Have clientid want store details CANONICAL
select * --distinct ch.clientid, st.storeid, st.clientstoreid
from client.store as st join client.chain as ch on st.chainid=ch.chainid
where ch.clientid=1000362

-- Have storeid atebpatientid want clientstoreid
select  distinct ch.clientid, st.storeid, st.clientstoreid
from client.store as st join client.chain as ch on st.chainid=ch.chainid
where st.storeid in ( select distinct storeid
                      from patient.atebpatient 
                      where atebpatientid in(83902247,83902259)
                    )

-- Have client want all atebpatientid for a store
select distinct ap.atebpatientid, ch.clientid, st.storeid, st.clientstoreid
from client.store as st join client.chain as ch on st.chainid=ch.chainid
     join patient.atebpatient ap on ap.storeid=st.storeid
where ap.clientid=1059 and st.clientstoreid='0779'
;

/* e.g.  0013         18244      */
select a.storeid, a.client_storeid
from amc.stores a join client.store b on a.chainid=b.chainid and a.id=b.amcstoreid
where a.clients_fkid=1021 ;

-- duplicate rxnum - warning: large clients may only be able to run the subquery
select distinct  a.storeid, a.rxnum, a.atebpatientid
from patient.patientrx as a, 
     (select clientid, storeid, rxnum, count(distinct atebpatientid) from patient.patientrx where clientid=7 group by 1, 2, 3 having count(atebpatientid) > 1) as b
where a.storeid=b.storeid and a.rxnum=b.rxnum;

-- Count active TMM patients for a client
select b.clientid, c.clientstoreid, a.patientstatusid, count(distinct b.atebpatientid) 
from pmap.patientparticipation a
     join patient.atebpatient as b on a.atebpatientid=b.atebpatientid
     join client.store as c on b.storeid=c.storeid
where a.patientstatusid in (3,4,5) and a.clientid=17
and a.created>'2017-11-15'
group by b.clientid, c.clientstoreid, a.patientstatusid
order by 1, 2, 3;

--- List active TMM patients for a client DEPRECATED
select distinct atebpatientid from pmap.patientparticipation where clientid=685 and patientstatusid in(3);

-- Has a patient enrolled?
select * from pmap.archivepatientparticipation where clientid=137 and atebpatientid=1877220

--- List active/optout/unenrolled TMM patients for a store
select c.clientstoreid, b.pharmacypatientid, b.atebpatientid
from pmap.patientparticipation a join  patient.atebpatient as b on a.atebpatientid=b.atebpatientid
join client.store as c on b.storeid=c.storeid
where a.patientstatusid in (3,4,5) and a.clientid=12 and c.clientstoreid='026';

-- Error check for enrolled patients with tasks (should be 0)
select c.clientstoreid, b.pharmacypatientid, b.atebpatientid
from pmap.patientparticipation a join  patient.atebpatient as b on a.atebpatientid=b.atebpatientid
     join client.store as c on b.storeid=c.storeid
where a.patientstatusid in (3,4,5) and b.atebpatientid in( select distinct ia.atebpatientid
                                                           from pmap.interventionalert as ia join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
                                                           join client.store as st on ap.storeid = st.storeid
                                                           where ia.actioncodeid=20018 and alertstatusid=1);

-- TMM synced meds status (green recycle icon to left of Rx col in PMAP)
select a.clientid , a.atebpatientid, trim(leading '0' from clientstoreid) as storeid, d.pharmacypatientid,  a.created, b.name as medicationstatus, c.rxnum
from pmap.medsyncresponse as a, pmap.medicationstatus as b, patient.patientrx as c, patient.atebpatient as d, client.store as e
where a.clientid in(685)
  and a.programstatusid=b.medicationstatusid
  and a.patientrxid=c.patientrxid
  and a.atebpatientid=d.atebpatientid
  and d.storeid=e.storeid
  and b.name='Active'
  and d.pharmacypatientid='MORIA'
order by a.created;

-- How many TMM enrollees (partial, enrolled, optout, unenroll) for a store?
select pp.clientid, st.storeid, st.clientstoreid, count(distinct pp.atebpatientid) as TotalEnrolledLstx, pp.patientstatusid
from pmap.archivepatientparticipation as pp
     join patient.atebpatient ap on pp.atebpatientid=ap.atebpatientid
     join client.store as st on st.storeid=ap.storeid
     join pmap.pmapcampaign as pc on pc.pmapcampaignid=pp.pmapcampaignid
where pp.clientid=137 and st.clientstoreid='3648'
      and  pc.pmapfeatureid=1
      and  pp.patientstatusid in(3,4,5)
      and  coalesce(pp.statusmodifieddate::date,pp.lastmodified)::date>=(date('2016-09-03'))
group by pp.clientid, st.storeid, st.clientstoreid, pp.patientstatusid
;

-- Has sync started?
select * from pmap.archivemedsyncresponse where atebpatientid=1877220

-- 25-Apr-17 tbl possibly deprecated.  Did eligibility targeted csv work to flip the tile title to "Targeted"?
select * from pmap.eligibilitybatch where clientid=919 and created>'2016-07-12' --?? and finalpatientstatusid=1

-- Trace a campaign patient                                                                                   _________________
SELECT id,campaigngroupid,rxnbr,ndc,campaignrefill,dayssupply,campaigndatarecid,storeuid,numrefillsauthorized,campaignpatientid,drugname,created,lastmodified,gpi,generic_indicator,groupid 
FROM "amc"."campaignrefills" where campaigngroupid=1067 and upper(drugname) like '%SALSA%'
--     __
SELECT id,campaigngroupid,storeuid,patientnamefirst,patientnamelast,patientphonenbr,patientaltphone,patientdob,patientaddress1,patientaddress2,patientcity,patientstateprov,patientpostalcode,patientgroup,declinecount,userkey,impressiontimestamp,receivedtimestamp,campaigndatarecid,campaignreferralid,campaignrefillid,firstimpressionts,optedoutdate,patientemail,patientgender,callback,siteid,callstatus,drugname,ndc,rxnbr,lastfilldate,excluded,pkgfileid,numcallattempts,excludedwithincl,callbacknolaterthan,lastcallattempt,version,referralcallnum,scriptstatus,scriptid,sendtocallcenter,dayssupply,numrefillsauthorized,numrefillsremaining,lastsolddate,numrefills,pscreferralid,callcentercomments,commentfileid,notes,numprestartrefills,expireddate,created,lastmodified,preferredcalltime,programcallsmade,autofillprogram,originalfilldate,quantitydispensed,externalpatientid,chrpatienthash,tracked,refillnumber,ateboptedoutdate,userpath,responses,origid,finalstatus,ntt,updated_since_rpt_archive,masked_patientkey,masked_patient_phone_number,masked_rx_number,schedule_call,dueday,excluded_reason,campaigndrugid,copaycardusesremaining,copaycardnumber,cplpatienthash,optedoutsource,status,gpi,generic_indicator,copay_status,crm_status,paymenttype,rfr_excluded_reasons,control_timestamp,control_source,activation_timestamp,rx_origin,original_storeid,rx_date_written,paidamount,copayamount,cardholderid,memberid,rx_status,preferred_language,inbin_date,prescribernamelast,prescribernamefirst,enrolled_timestamp,bin,pcn,groupid,ltc_code,autofilltype,medsyncdate,patientcontactmethod,prescriberfaxnbr,atebpatientid,filltype 
FROM "amc"."campaignpatients" where id=418058328
-- confirm in db5: select * from rxfilldata_parent where clientid=137 and medicationname='SALSALATE 500 MG    TAB GOLD'

-- Duplicate HP tasks
select ch.clientid, st.clientstoreid, ia.atebpatientid
from pmap.interventionalert as ia join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid join client.store as st on ap.storeid=st.storeid join client.chain as ch on ch.chainid=st.chainid 
where alertstatusid=1 and ia.reasonforalert like '%Priority Patient%' 
group by ch.clientid, st.clientstoreid, ap.pharmacypatientid, ia.atebpatientid 
having count(*)>1 order by ch.clientid;
-- 20018 is "TMM Priority Enrollment"
select ch.clientid, st.clientstoreid, ia.atebpatientid, ac.name, ac.code
from pmap.interventionalert as ia
join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
join client.store as st on ap.storeid=st.storeid
join client.chain as ch on ch.chainid=st.chainid 
join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
where alertstatusid=1 and ia.actioncodeid=20018 group by ch.clientid, st.clientstoreid, ap.pharmacypatientid, ia.atebpatientid, ac.name, ac.code having count(*)>1 order by ch.clientid;

-- All active HP tasks in PMAP
select ch.clientid, st.displayname, st.clientstoreid, ap.pharmacypatientid, ac.code, ac.name, ia.reasonforalert, ac.actioncodeid
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid 
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
where alertstatusid=1 and ia.actioncodeid in(select actioncodeid from pmap.actioncode where name = 'TMM Priority Enrollment') and ch.clientid=685;

-- Specific HP tasks for a patient
select ch.clientid, st.displayname, st.clientstoreid, ap.pharmacypatientid, ac.code, ac.name, ia.reasonforalert, ac.actioncodeid
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid 
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
where alertstatusid=1 and ia.actioncodeid in(select actioncodeid from pmap.actioncode where name = 'TMM Priority Enrollment') and ch.clientid=12 and ap.pharmacypatientid='12042';

-- Count active HP patients for specific client
select distinct ch.clientid, ia.reasonforalert, count(*)
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid
where ch.clientid=665 and alertstatusid=1 and ia.actioncodeid=20018
group by ch.clientid, ia.reasonforalert;

-- 60+ age check
select age(dateofbirth) as age, dateofbirth, count(*) as count
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
     join patient.patientdemographic as pd on ia.atebpatientid=pd.atebpatientid
where alertstatusid=1 and ia.actioncodeid in(20112) and ch.clientid=8
group by age, dateofbirth
order by age;

-- alertstatusid
select * from pmap.alertstatus

-- trace an imm task patient
select ch.*, st.*, ap.*, ac.*, ac.name, alertstatusid
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid 
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
     join patient.patientdemographic as pd on ia.atebpatientid=pd.atebpatientid
where ia.actioncodeid in(20112) and ch.clientid=8 and pharmacypatientid='1201098';

-- 1. Immunization dups fix 
-- \f '|' \a \t \o /Drugs/Personnel/bob/dup_addback_20160914.csv
-- https://wiki.ateb.com/display/MYX/Camel+Route+-+Time+My+Meds+%28TMM%29+Alerts to edit IMM_FAMILY=
---select ch.clientid, st.clientstoreid, ap.pharmacypatientid, ac.code, 'EDITWakefern - Immunization Opportunity - Tdap' as x0, '' as x1, '' as x2, 0 as x3, to_char(date('now'),'YYYYMMDD') as x4, 'AddOrUpdate' as x5, '' as x6, '' as x7, 'EXPIRE='||to_char(date('now')+30,'YYYYMMDD') as x8,
   select ch.clientid, st.clientstoreid, ap.pharmacypatientid, ac.code, ac.name, '' as x1, '' as x2, 0 as x3, to_char(date('now'),'YYYYMMDD') as x4, 'AddOrUpdate' as x5, '' as x6, '' as x7, 'EXPIRE='||to_char(date('now')+30,'YYYYMMDD') as x8,
       case when ac.actioncodeid=20106 then 'IMM_FAMILY=AV_OTHER'
            when ac.actioncodeid=20107 then 'IMM_FAMILY=AV_HPV'
            when ac.actioncodeid=20108 then 'IMM_FAMILY=AV_TETANUS'
            when ac.actioncodeid=20109 then 'IMM_FAMILY=AV_HEPATITIS'
            when ac.actioncodeid=20110 then 'IMM_FAMILY=AV_MENINGOCOCCAL'
            when ac.actioncodeid=20111 then 'IMM_FAMILY=AV_PREVNAR'
            when ac.actioncodeid=20112 then 'IMM_FAMILY=AV_ZOSTERSHINGLES'
            when ac.actioncodeid=20113 then 'IMM_FAMILY=AV_PNEUM'
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

-- 2. Immunization dups fix
-- \f '|' \a \t \o /Drugs/Personnel/bob/dup_del_20160914.csv
--   8|013|1234567|IMMOPP_FLU|Immunization Opportunity - Influenza|||1||Delete||
---select clientid, clientstoreid, pharmacypatientid, 'IMMOPP_ZOSTER' as code, 'Wakefern - Immunization Opportunity - Zoster / Shingles' as name, '' as x1, '' as x2, 0 as x3, '' as x4, 'Delete' as x5, '' as x6, '' as x7
select ch.clientid, st.clientstoreid, ap.pharmacypatientid, ac.code, ac.name, '' as x1, '' as x2, 1 as x3, '' as x4, 'Delete' as x5, '' as x6, '' as x7
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid 
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
where alertstatusid=1 and ia.actioncodeid in(select actioncodeid from pmap.actioncode where name like 'Immunization Opportunity%') 
group by ia.atebpatientid, ch.clientid, st.clientstoreid, ap.pharmacypatientid, ia.atebpatientid, ac.code, ac.name
having count(*)>1 order by ch.clientid;
-- or delete all imm tasks for a client:
select distinct ch.clientid, st.clientstoreid, ap.pharmacypatientid, ac.code, ac.name, '' as rxnum, '' as rxid, 1 as priority, '' as earlieststartdt, 'Delete' as operation, '' as campaignid, '' as status
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid 
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
     join patient.patientdemographic as pd on ia.atebpatientid=pd.atebpatientid
where alertstatusid=1 and ia.actioncodeid in(select distinct actioncodeid from pmap.actioncode where name like 'Immunization Opportunity%') and ch.clientid=1059;

-- 3. Immunization fix dups
-- chmod 777 /Drugs/Personnel/bob/dup_del_20160914.csv && cp -p /Drugs/Personnel/bob/dup_del_20160914.csv /mnt/nfs/dropboxes/tmm/alert
-- chmod 777 /Drugs/Personnel/bob/dup_addback_20160914.csv && cp -p /Drugs/Personnel/bob/dup_addback_20160914.csv /mnt/nfs/dropboxes/tmm/alert

-- Immunization remove under 60 year olds
--  \f '|' \a \t \o /Drugs/Immunizations/Wakefern/Imports/20161012/Output/imm_del_zost_under60_201612.csv
-- 8|0801|9948624|IMMOPP_ZOSTER|Immunization Opportunity - Zoster / Shingles|||1||Delete||
---select distinct ch.clientid, st.clientstoreid, ap.pharmacypatientid, ac.code, ac.name, '' as rxnum, '' as rxid, 1 as priority, '' as earlieststartdt, 'Delete' as operation, '' as campaignid, '' as status, date_part('year',age(dateofbirth)) as age
select distinct ch.clientid, st.clientstoreid, ap.pharmacypatientid, ac.code, ac.name, '' as rxnum, '' as rxid, 1 as priority, '' as earlieststartdt, 'Delete' as operation, '' as campaignid, '' as status
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid 
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
     join patient.patientdemographic as pd on ia.atebpatientid=pd.atebpatientid
where alertstatusid=1 and ia.actioncodeid in(20112) and ch.clientid=8 and date_part('year',age(dateofbirth))<60;
---where alertstatusid=1 and ia.actioncodeid in(20112) and ch.clientid=8 and dateofbirth>'1956-10-12';

-- Delete specific patient's HP or Imm task
-- \f '|' \a \t \o /Drugs/Personnel/bob/del_deceased_20161011.csv
select distinct ch.clientid, st.clientstoreid, ap.pharmacypatientid, ac.code, ac.name, '' as rxnum, '' as rxid, 1 as priority, '' as earlieststartdt, 'Delete' as operation, '' as campaignid, '' as status,
       case when sp.sponsorid=2 then 'SPONSOR=FREDS_SILVERS'
            when sp.sponsorid=3 then 'SPONSOR=WEIS_SILVERS'
            when sp.sponsorid=4 then 'SPONSOR=MEIJER_SILVERS'
            when sp.sponsorid=6 then 'SPONSOR=SHRIVERS_SILVERS'
            when sp.sponsorid=8 then 'SPONSOR=SHRIVERS_CIGNA'
            when sp.sponsorid=10 then 'SPONSOR=SHRIVERS_HUMANA'
            when sp.sponsorid=11 then 'SPONSOR=GE_SILVERS'
            when sp.sponsorid=14 then 'SPONSOR=OWENS_SILVERS'
            when sp.sponsorid=15 then 'SPONSOR=OWENS_WELLCARE'
            when sp.sponsorid=16 then 'SPONSOR=OWENS_CIGNA'
            when sp.sponsorid=17 then 'SPONSOR=OWENS_COVENTRY'
            when sp.sponsorid=18 then 'SPONSOR=OWENS_HUMANA'
            when sp.sponsorid=20 then 'SPONSOR=UHC'
            when sp.sponsorid=21 then 'SPONSOR=PUBLIX_OPTUM'
            when sp.sponsorid=22 then 'SPONSOR=PUBLIX_EXPRESS'
            when sp.sponsorid=23 then 'SPONSOR=PUBLIX_PRIME'
            when sp.sponsorid=24 then 'SPONSOR=PUBLIX_SILVERS'
            when sp.sponsorid=25 then 'SPONSOR=PUBLIX_WELLCARE'
            when sp.sponsorid=26 then 'SPONSOR=AHOLD_SILVERS'
            when sp.sponsorid=27 then 'SPONSOR=AHOLD_UHC'
            when sp.sponsorid=28 then 'SPONSOR=DELHAIZE_AARP'
            when sp.sponsorid=29 then 'SPONSOR=DELHAIZE_UHC'
            when sp.sponsorid=30 then 'SPONSOR=DELHAIZE_MARTINS'
            when sp.sponsorid=31 then 'SPONSOR=GE_ANTHEM'
            when sp.sponsorid=32 then 'SPONSOR=GE_CIGNA'
            when sp.sponsorid=33 then 'SPONSOR=FREDS_DIAB'
            when sp.sponsorid=42 then 'SPONSOR=PUBLIX_HUMANA'
       else ''
       end as sponsor
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid 
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
     join patient.patientdemographic as pd on ia.atebpatientid=pd.atebpatientid
     join pmap.sponsor as sp on ia.sponsorid=sp.sponsorid
where alertstatusid=1 and ch.clientid=12 and ap.atebpatientid=41834173;

-- Confirm ages
select age(dateofbirth) as age, dateofbirth, count(*) as count
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid 
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
     join patient.patientdemographic as pd on ia.atebpatientid=pd.atebpatientid
where alertstatusid=1 and ia.actioncodeid in(20112) and ch.clientid=8 
group by age, dateofbirth
order by age
;

-- All actioncodeids
select distinct name, actioncodeid from pmap.actioncode where name like 'Immunization Opportunity%' ;
select distinct actioncodeid, name, code from pmap.actioncode order by 3

-- Analytics' generated tasks
select distinct actioncodeid, name, code
from pmap.actioncode 
where code ilike 'IMMOPP_%' or code ilike 'IMEDICARE%' or code ilike 'NOSTATIN%' or code ilike 'TMM_ENROLL_PRI%'
order by 3

-- Patient detail for active Immunization PMAP tasks
select ch.clientid, st.clientstoreid, ap.pharmacypatientid, ac.code, ac.name, ia.reasonforalert
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid 
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
     join patient.patientdemographic as pd on ia.atebpatientid=pd.atebpatientid
where alertstatusid=1 and ia.actioncodeid in(select actioncodeid from pmap.actioncode where name like 'Immunization Opportunity%') and ch.clientid=8 ;

-- Immunization sponsor codes
SELECT distinct b.sponsorid,b.code
FROM pmap.interventionalert a join pmap.sponsor b on a.sponsorid=b.sponsorid
where a.actioncodeid in(select actioncodeid from pmap.actioncode where name like 'Immunization Opportunity%');

-- HP sponsor codes
SELECT distinct b.sponsorid,b.code
FROM pmap.interventionalert a join pmap.sponsor b on a.sponsorid=b.sponsorid
where a.actioncodeid in(select actioncodeid from pmap.actioncode where name like '%Priority%');

-- TODO s/b left join ac and sp??
select ch.clientid, st.clientstoreid, ap.pharmacypatientid, ac.code, ac.name, '' as x1, '' as x2, 1 as x3, '' as x4, 'Delete' as x5, '' as x6, '' as x7, '' as x8,
       case when ac.actioncodeid=20106 then 'IMM_FAMILY=AV_OTHER'
            when ac.actioncodeid=20107 then 'IMM_FAMILY=AV_HPV'
            when ac.actioncodeid=20108 then 'IMM_FAMILY=AV_TETANUS'
            when ac.actioncodeid=20109 then 'IMM_FAMILY=AV_HEPATITIS'
            when ac.actioncodeid=20110 then 'IMM_FAMILY=AV_MENINGOCOCCAL'
            when ac.actioncodeid=20111 then 'IMM_FAMILY=AV_PREVNAR'
            when ac.actioncodeid=20112 then 'IMM_FAMILY=AV_ZOSTERSHINGLES'
            when ac.actioncodeid=20113 then 'IMM_FAMILY=AV_PNEUM'
            when ac.actioncodeid=20114 then 'IMM_FAMILY=AV_INFLUENZA'
       else ''
       end as x9,
       case when sp.sponsorid=34 then 'SPONSOR=GE_ZOST'
            when sp.sponsorid=37 then 'SPONSOR=GE_FLU'
            when sp.sponsorid=38 then 'SPONSOR=GE_PNEUMO'
            when sp.sponsorid=39 then 'SPONSOR=WF_PNEUMO'
            when sp.sponsorid=40 then 'SPONSOR=WF_ZOST'
            when sp.sponsorid=41 then 'SPONSOR=WF_FLU'
       else ''
       end as x10
  from pmap.interventionalert as ia
       join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
       join client.store as st on ap.storeid=st.storeid
       join client.chain as ch on ch.chainid=st.chainid 
       join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
       join pmap.sponsor as sp on ia.sponsorid=sp.sponsorid
  where ch.clientid=&clid and alertstatusid=1
        and ia.actioncodeid in(select actioncodeid from pmap.actioncode where name like 'Immunization Opportunity%') ;

select ch.clientid, st.clientstoreid, ap.pharmacypatientid, ac.code, ac.name, '' as x1, '' as x2, 1 as x3, '' as x4, 'Delete' as x5, '' as x6,
       case when sp.sponsorid=34 then 'SPONSOR=GE_ZOST'
            when sp.sponsorid=37 then 'SPONSOR=GE_FLU'
            when sp.sponsorid=38 then 'SPONSOR=GE_PNEUMO'
            when sp.sponsorid=39 then 'SPONSOR=WF_PNEUMO'
            when sp.sponsorid=40 then 'SPONSOR=WF_ZOST'
            when sp.sponsorid=41 then 'SPONSOR=WF_FLU'
            else ''
       end as sponsorcode
  from pmap.interventionalert as ia
       join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
       join client.store as st on ap.storeid=st.storeid
       join client.chain as ch on ch.chainid=st.chainid 
       left join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
       left join pmap.sponsor as sp on ia.sponsorid=sp.sponsorid
  where ch.clientid=&clid and alertstatusid=1
        and ia.actioncodeid in(select actioncodeid from pmap.actioncode where name like 'Immunization Opportunity%') 
  ;

-- Count all Priority HP 20018 or Imm 20106-20114 tasks
select ch.clientid, ia.reasonforalert, count(*) 
from pmap.interventionalert as ia 
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid 
     join client.store as st on ap.storeid=st.storeid 
     join client.chain as ch on ch.chainid=st.chainid 
-- TOGGLE
---where alertstatusid=1 and ia.actioncodeid in (select actioncodeid from pmap.actioncode where name like 'Immunization Opportunity%')
where alertstatusid=1 and ia.actioncodeid in (20018)
group by ch.clientid, ia.reasonforalert
order by ch.clientid;

-- Want Priority Tasks actioncodes
select distinct actioncodeid from pmap.actioncode where code = 'TMM_ENROLL_PRI' order by 1
select distinct code, name, actioncodeid from pmap.actioncode order by 1;

-- Verify imm tasks were accepted by pmap
select ch.clientid, ia.reasonforalert, ia.expirationdate, count(*) 
from pmap.interventionalert as ia 
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid 
     join client.store as st on ap.storeid=st.storeid 
     join client.chain as ch on ch.chainid=st.chainid 
where alertstatusid=1 and ia.actioncodeid in (select actioncodeid from pmap.actioncode where name like 'Immunization Opportunity%')
group by ch.clientid, ia.reasonforalert,ia.expirationdate
order by ch.clientid,ia.expirationdate;

-- PMAP H M L prioritized tasks for a store (remove alertstatusid for history)
select ch.clientid, st.clientstoreid, ia.reasonforalert, ia.actioncodeid, ia.atebpatientid, ac.name, ac.priority
from pmap.interventionalert as ia join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
join client.store as st on ap.storeid=st.storeid
join client.chain as ch on ch.chainid=st.chainid 
join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
where alertstatusid=1 and ch.clientid=8 and st.clientstoreid='0105' and ac.actioncodeid>=20106 and ac.actioncodeid<=20114
order by ch.clientid, ac.priority;

-- PMAP Priority tasks for a patient
select ch.clientid, st.clientstoreid, ia.reasonforalert, count(*)
from pmap.interventionalert as ia join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid join client.store as st on ap.storeid=st.storeid join client.chain as ch on ch.chainid=st.chainid
where alertstatusid=1 and ia.atebpatientid=55703175 group by ch.clientid, st.clientstoreid, ia.reasonforalert;

-- View a dup priority task
select st.clientstoreid, ap.*, ia.*
from pmap.interventionalert as ia 
  join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
  join client.store as st on ap.storeid = st.storeid
where ia.reasonforalert in ('Freds Humana Priority Enrollment')  
  and ap.pharmacypatientid='1146MARICL1';

select * from mdfarchive where pharmacypatientid='*******' and clientid=329 and clientstoreid='8121'

-- Delete all UHC HP tasks:
-- \f '|' \a \t \o /Drugs/Personnel/bob/deleteallUHC.csv
select distinct ch.clientid, st.clientstoreid, ap.pharmacypatientid, ac.code, ac.name, '' as rxnum, '' as rxid, 1 as priority, '' as earlieststartdt, 'Delete' as operation, '' as campaignid, '' as status, 'SPONSOR=UHC' as interventionalert
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid 
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
     join pmap.sponsor as sp on ia.sponsorid=sp.sponsorid
where alertstatusid=1 and ia.actioncodeid in(20018) and sp.sponsorid=20;
-- chmod 777 /Drugs/Personnel/bob/deleteallUHC.csv
-- cp -p /Drugs/Personnel/bob/deleteallUHC.csv /mnt/nfs/dropboxes/tmm/alert
-- ls -lt /mnt/nfs/dropboxes/tmm/alert/rejected/|head
-- ls -lt /mnt/nfs/dropboxes/tmm/alert/archive/20170210|head

-- medispan ndc to gpi
select 	dr.name, brand_name_code, substring(gpi from 1 for 8) as gpi8, substring(gpi from 1 for 10) as gpi10, dr.gpi, ndc.ndc_upc_hri as ndc, strength, strength_units
from medispan.drug_name as dr, medispan.ndc as ndc
where dr.drug_descriptor_id=ndc.drug_descriptor_id and ndc.ndc_upc_hri in('00173069500','00173069502');

SELECT distinct sponsorid, reasonforalert
FROM pmap.interventionalert 
where sponsorid is not null and reasonforalert != 'Patient is deceased'
order by sponsorid;

-- Remove missing HP expire date records (with sponsorid) AN-5357
-- \f '|' \a \t \o /Drugs/Personnel/bob/noexpire2_del_20160930.csv
-- 2|0004|30455|IMMOPP_FLU|Immunization Opportunity - Influenza|||1||Delete|||SPONSOR=GE_FLU
-- compare with sponsor-less 118|0399|35574401|TMM_ENROLL_PRI|TMM Priority Patient Enrollment|||1||Delete||
select distinct ch.clientid, st.clientstoreid, ap.pharmacypatientid, ac.code, ac.name, '' as rxnum, '' as rxid, 1 as priority, '' as earlieststartdt, 'Delete' as operation, '' as campaignid, '' as status,
       case when sp.sponsorid=2 then 'SPONSOR=FREDS_SILVERS'
            when sp.sponsorid=3 then 'SPONSOR=WEIS_SILVERS'
            when sp.sponsorid=4 then 'SPONSOR=MEIJER_SILVERS'
            when sp.sponsorid=6 then 'SPONSOR=SHRIVERS_SILVERS'
            when sp.sponsorid=8 then 'SPONSOR=SHRIVERS_CIGNA'
            when sp.sponsorid=10 then 'SPONSOR=SHRIVERS_HUMANA'
            when sp.sponsorid=11 then 'SPONSOR=GE_SILVERS'
            when sp.sponsorid=14 then 'SPONSOR=OWENS_SILVERS'
            when sp.sponsorid=15 then 'SPONSOR=OWENS_WELLCARE'
            when sp.sponsorid=16 then 'SPONSOR=OWENS_CIGNA'
            when sp.sponsorid=17 then 'SPONSOR=OWENS_COVENTRY'
            when sp.sponsorid=18 then 'SPONSOR=OWENS_HUMANA'
            when sp.sponsorid=20 then 'SPONSOR=UHC'
            when sp.sponsorid=21 then 'SPONSOR=PUBLIX_OPTUM'
            when sp.sponsorid=22 then 'SPONSOR=PUBLIX_EXPRESS'
            when sp.sponsorid=23 then 'SPONSOR=PUBLIX_PRIME'
            when sp.sponsorid=24 then 'SPONSOR=PUBLIX_SILVERS'
            when sp.sponsorid=25 then 'SPONSOR=PUBLIX_WELLCARE'
            when sp.sponsorid=26 then 'SPONSOR=AHOLD_SILVERS'
            when sp.sponsorid=27 then 'SPONSOR=AHOLD_UHC'
            when sp.sponsorid=28 then 'SPONSOR=DELHAIZE_AARP'
            when sp.sponsorid=29 then 'SPONSOR=DELHAIZE_UHC'
            when sp.sponsorid=30 then 'SPONSOR=DELHAIZE_MARTINS'
            when sp.sponsorid=31 then 'SPONSOR=GE_ANTHEM'
            when sp.sponsorid=32 then 'SPONSOR=GE_CIGNA'
            when sp.sponsorid=33 then 'SPONSOR=FREDS_DIAB'
            when sp.sponsorid=42 then 'SPONSOR=PUBLIX_HUMANA'
       else ''
       end as sponsor
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
     join pmap.sponsor as sp on ia.sponsorid=sp.sponsorid
where expirationdate is null and ac.actioncodeid=20018 and alertstatusid=1;

-- Monitor weirdness 04-Oct-16
SELECT *
FROM pmap.interventionalert ia
INNER JOIN pmap.alertstatus as1 ON ia.alertstatusid = as1.alertstatusid
INNER JOIN pmap.actioncode ac ON ac.actioncodeid = ia.actioncodeid
WHERE ac.code = 'APT_ZOST' and ia.alertstatusid=1 and clientid != 95 and ia.created>'2016-10-03'
order by ia.created desc;

-- Deceased patients
select distinct ap.atebpatientid, concat(st.clientstoreid::text,ap.pharmacypatientid::text) as uniqueid
from patient.patientdemographic pd
     join patient.atebpatient ap on pd.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid
where pd.knowledgeofdeath is not null;

-- Find a patient date of birth using only name
select *
from patient.atebpatient ap 
     join patient.patientdemographic pd on ap.atebpatientid=pd.atebpatientid
     join patient.patientname pn on pn.atebpatientid=ap.atebpatientid
     join client.store as st on st.storeid=ap.storeid
where clientspecifiedfirstname='GAIL' and clientspecifiedlastname='LANDFELD' and ap.clientid=2;

-- alternative table to short name ds', used by Task Alert Processor
select shortname from client.client where clientid=95;

select cg.rptrequirements, cg.id,
       sum(case when postedtimestamp between '1JUL2016' and '31JUL2016' then 1 else 0 end),				
       sum(case when postedtimestamp between '1AUG2016' and '31AUG2016' then 1 else 0 end),				
       sum(case when postedtimestamp between '1SEP2016' and '30SEP2016' then 1 else 0 end)
from amc.campaignrefills cr join amc.campaigngroups cg on cr.campaigngroupid=cg.id
where cr.excluded is null and postedtimestamp>='1JUL2016'				
and cr.campaigngroupid in (
1087, 1088, 1089, 1090, 1091, 1092, 1093, 1094, 1095, 1096, 1097, 1098, 1099, 1100, 1101, 1102, 1103, 1104, 1105, 1106, 1107, 1108, 1109, 1110, 1111, 1112, 1113, 1114, 1115, 1116, 1117, 1118, 1119, 1120, 1121, 1122, 1123, 1124, 1125, 1126, 1127, 1128, 1129, 1130, 1131, 1132, 1133, 1134, 1135, 1136, 1137, 1138, 1139, 1140, 1141, 1142, 1143, 1144, 1145, 1146, 1147, 1148, 1149, 1150, 1151, 1152, 1153, 1154, 1155, 1156, 1157, 1158, 1159, 1160, 1161, 1162, 1163
)
and cr.storeuid not in (
12700, 12705, 12708, 12711, 12717, 12719, 12722, 12726, 12737, 12739, 12740, 12741, 12742, 12745, 12746, 12752, 12761, 12763, 12774, 12780, 12781, 12782, 12784, 12785, 12789, 12791, 12792, 12793, 12798, 12814, 12817, 12819, 12821, 12825, 12828, 12955, 16872
)
group by 1,2
order by 1;

-- Compare same patient in store switch
select ch.clientid, st.displayname, st.clientstoreid, ap.pharmacypatientid, ac.code, ac.name, ia.reasonforalert, ac.actioncodeid, pp.patientstatusid
from pmap.interventionalert as ia
join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
join client.store as st on ap.storeid=st.storeid
join client.chain as ch on ch.chainid=st.chainid
join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
join pmap.patientparticipation as pp on pp.atebpatientid=ia.atebpatientid
where ia.actioncodeid in(select actioncodeid from pmap.actioncode where name = 'TMM Priority Enrollment') and ch.clientid=20 and ap.pharmacypatientid in('120686','10690888');

select clientid from client.client where shortname = 'CLI_1568556876';
select * from client.client where clientid in(445, 449, 589, 605, 606, 615, 623, 648, 654, 662, 663, 668, 683, 684, 689, 691, 699, 702, 754, 755, 756, 757, 758, 760, 761, 762, 768, 829, 834, 879, 884, 902, 909, 924, 931, 941, 952, 963, 964, 965, 970, 1008, 1010, 1011, 1012);

SELECT campaigngroupid, impressiontimestamp,drugname,rxnbr,lastfilldate,numrefillsremaining,storeuid,finalstatus,userpath,patientnamefirst,patientnamelast,patientphonenbr,patientaltphone,patientdob,patientaddress1,patientaddress2,patientcity,patientstateprov,patientpostalcode,clientid,campaigndatarecid,created
FROM amc.campaignimpressions
where impressiontimestamp>='2016-10-01' and impressiontimestamp<='2016-10-02' and campaigngroupid = 681 --in(681,1230)

-- View PMAP "Prescriptions" column.
select * from patient.patientrx where atebpatientid=79993935;
-- Then select * from rxfilldata_201607 where clientid=8 and rxnbr='6164291'; for the actual medicationname from the mdf

-- Determine width of clientstoreid / or list all stores for a client
select distinct clientstoreid from client.store as st join client.chain as ch on ch.chainid=st.chainid where ch.clientid=2 order by 1;

-- Imm PMAP tile data
select count(*) from pmap.immunization_extra where vaccinefamily='AV_INFLUENZA' and source='PatientReported';

-- Rx numbers for a patient
select *
from patient.patientrx 
where atebpatientid=44599634
order by created desc;

-- TMM eligible targeted patient counts by clientstoreid
select st.clientstoreid, count(distinct pp.atebpatientid) as npats
from pmap.patientparticipation as pp, patient.atebpatient as ap, client.store as st
where ap.storeid=st.storeid and ap.atebpatientid=pp.atebpatientid and pp.clientid=137 and pp.patientstatusid=1
group by 1;

-- Is immunization enabled in PMAP for this client/store?
select clientid, cl.code, csl.*, clientstoreid from client.storelabel csl join client.clientchainstore ccs on ccs.storeid = csl.storeid  join client.label cl on cl.labelid = csl.labelid where clientid=8 order by clientstoreid;

select cl.code, csl.*
from client.storelabel csl                                                                                                                                                       
join client.clientchainstore ccs on  ccs.storeid = csl.storeid and ccs.clientid = (select clientid from client.client where shortname = 'AtebDemo') join client.label cl on cl.labelid = csl.labelid;

-- Deleted imm tasks for a store
select distinct ch.clientid, st.clientstoreid, ap.pharmacypatientid, ac.code, ac.name, '' as rxnum, '' as rxid, 1 as priority, '' as earlieststartdt, 'Delete' as operation, '' as campaignid, '' as status
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid 
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
where alertstatusid=2 and ia.actioncodeid in(select distinct actioncodeid from pmap.actioncode where name like 'Immunization Opportunity%')
and st.clientstoreid in('0058')
and ch.clientid=2;

-- Deleted HP tasks
select distinct ch.clientid, st.clientstoreid, ap.pharmacypatientid, ac.code, ac.name, '' as rxnum, '' as rxid, 1 as priority, '' as earlieststartdt, 'Delete' as operation, '' as campaignid, '' as status, sp.sponsorid
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid 
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
     join pmap.sponsor as sp on ia.sponsorid=sp.sponsorid
where alertstatusid=2 and ia.actioncodeid in(20018)
and ch.clientid=137 and sp.sponsorid=43;

-- Want campaign name groupname
SELECT * FROM amc.campaigngroups WHERE description like '%eis%' and campaigntype = 'TMM'

-- Check all HP health plans
select ch.clientid, ia.reasonforalert, count(*) 
from pmap.interventionalert as ia 
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid 
     join client.store as st on ap.storeid=st.storeid 
     join client.chain as ch on ch.chainid=st.chainid 
where alertstatusid=1 and ia.actioncodeid in (20018)
group by ch.clientid, ia.reasonforalert
order by ia.reasonforalert;

-- Trace a priority task patient
select st.clientstoreid, ap.*, ia.*
from pmap.interventionalert as ia 
  join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
  join client.store as st on ap.storeid = st.storeid
where ia.reasonforalert in ('Freds Humana Priority Enrollment')  
  and ap.pharmacypatientid='6022SORROZ1';


with ia as (
select *, row_number() over (partition by ia.interventionalertid order by ia.lastmodified desc)
from pmap.archiveinterventionalert ia
where ia.clientid = 8
and ia.storeid = 10195
and ia.lastmodified <= '2017-04-20'
)
   , prep as ( SELECT ia.interventionalertid,
    ia.statuschangedate,
    ia.clientid,
    ia.storeid,
    st.clientstoreid,
    st.name AS storename,
    ia.atebpatientid,
    ia.earliestdate,
    ia.expirationdate,
    ia.created AS alertcreated,
    ia.lastmodified AS alertlastmodified,
    COALESCE(pp.priority, 0) + COALESCE(cacc.priority, ac.priority, 0) + COALESCE(pmap.gettimelypriority(ac.maxtimelypriority, ia.earliestdate, ac.timelyincrement::numeric, ac.timelyreset), 0) + COALESCE(pc.priority, s.priority, 0) + ia.priority AS totalpriority,
    COALESCE(pp.priority, 0) AS patientpriority,
    COALESCE(cacc.priority, ac.priority, 0) AS taskpriority,
    COALESCE(pmap.gettimelypriority(ac.maxtimelypriority, ia.earliestdate, ac.timelyincrement::numeric, ac.timelyreset), 0) AS timelypriority,
    COALESCE(cs.priority, pc.priority, s.priority, 0) AS sponsorpriority,
    ia.priority AS itempriority,
    ia.pmapcampaignid,
    ia.pmapuserid AS createdbyid,
    ia.updatedbyid,
    ia.reasonforalert,
    ia.patientrxid,
    ac.actioncodeid,
    ac.name AS actionname,
    ac.code AS actioncode,
    s.code AS sponsorcode,
    s.name AS sponsorname,
    ac.pmapscreenid,
    ast.code AS status
   FROM ia
     JOIN pmap.alertstatus ast ON ast.alertstatusid = ia.alertstatusid
     JOIN pmap.actioncode ac ON ac.actioncodeid = ia.actioncodeid
     JOIN client.client c ON c.clientid = ia.clientid
     JOIN client.store st ON st.storeid = ia.storeid
     LEFT JOIN pmap.pmapcampaign pc ON pc.pmapcampaignid = ia.pmapcampaignid
     LEFT JOIN pmap.patientpriority pp ON pp.clientid = ia.clientid AND pp.atebpatientid = ia.atebpatientid
     LEFT JOIN pmap.clientactioncodecampaign cacc ON cacc.clientid = ia.clientid AND cacc.actioncodeid = ia.actioncodeid AND cacc.pmapcampaignid = ia.pmapcampaignid
     LEFT JOIN pmap.sponsor s ON s.sponsorid = ia.sponsorid
     LEFT JOIN pmap.clientsponsor cs ON cs.sponsorid = ia.sponsorid AND cs.clientid = c.clientid
     --where ia.row_number = 1
     )
     select * from prep where totalpriority > 40 /*and status = 'ACTIVE'*/ and alertlastmodified >= '2017-04-10'::date
     order by interventionalertid, alertlastmodified
;

-- find all patients with active imm task:
select distinct ap.atebpatientid
  from pmap.interventionalert as ia
       join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
       join client.store as st on ap.storeid=st.storeid
       join client.chain as ch on ch.chainid=st.chainid
  where ch.clientid=2 and alertstatusid =1 and ia.actioncodeid = 20112;


-- NOSTATIN
select ap.atebpatientid, statuschangedate, ia.created, ia.lastmodified, ia.reasonforalert, ia.priority, st.storeid, st.clientstoreid, ac.code, ia.alertstatusid, asi.name
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
     join pmap.alertstatus as asi on asi.alertstatusid=ia.alertstatusid
where ia.alertstatusid !=1 and ch.clientid=8 and ac.actioncodeid = 20133;


-- Want specific task and demographic patient info have PMAP "i" icon taskid
select ap.atebpatientid, statuschangedate, ia.created, ia.lastmodified, ia.reasonforalert, ia.priority, st.storeid, st.clientstoreid, ac.code, ia.alertstatusid, asi.name, dateofbirth, age(dateofbirth) as age, interventionalertid
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
     join pmap.alertstatus as asi on asi.alertstatusid=ia.alertstatusid
     join patient.patientdemographic as pd on ia.atebpatientid=pd.atebpatientid
where interventionalertid=26450689;

-- Want active tasks gap statin tasks CANONICAL
select ap.pharmacypatientid, ap.atebpatientid, st.clientstoreid, pd.dateofbirth, date_part('year',age(dateofbirth)) as age2, pnm.lastname, pnm.firstname, asi.code, ac.name, ia.reasonforalert, pn.note
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
     join pmap.alertstatus as asi on asi.alertstatusid=ia.alertstatusid
     join patient.patientdemographic as pd on ia.atebpatientid=pd.atebpatientid
     join patient.patientname as pnm on pnm.atebpatientid=ia.atebpatientid
     left join pmap.patientnote as pn on pn.atebpatientid=ap.atebpatientid
where ch.clientid=8 and ac.actioncodeid=20133  and asi.code = 'ACTIVE'
order by age2, clientstoreid;

-- Want all active gap statin tasks outside legal age range
select ap.pharmacypatientid, ap.atebpatientid, st.clientstoreid, pd.dateofbirth, date_part('year',age(dateofbirth)) as age2, pnm.lastname, pnm.firstname, asi.code, pn.note
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
     join pmap.alertstatus as asi on asi.alertstatusid=ia.alertstatusid
     join patient.patientdemographic as pd on ia.atebpatientid=pd.atebpatientid
     join patient.patientname as pnm on pnm.atebpatientid=ia.atebpatientid
     left join pmap.patientnote as pn on pn.atebpatientid=ap.atebpatientid
where ch.clientid=8 and ac.actioncodeid=20133  and asi.code = 'ACTIVE' and ( date_part('year',age(dateofbirth))<40 and date_part('year',age(dateofbirth))<75 )
order by age2, clientstoreid;

-- Delete all gap
select distinct ch.clientid, st.clientstoreid, ap.pharmacypatientid, ac.code, ac.name, '' as rxnum, '' as rxid, '' as priority, '' as earlieststartdt, 'Delete' as operation, '' as campaignid, '' as status, '' as expire
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
where alertstatusid=1 and ia.actioncodeid in(20133);

-- Have atebpatientid want pharmacypatientid canonical
select pharmacypatientid, st.clientstoreid
from patient.atebpatient ap
     join client.store as st on ap.storeid=st.storeid 
     join client.chain as ch on ch.chainid=st.chainid    
where atebpatientid =59838276;

-- Have clientstoreid want all patients in that store
select ch.clientid, st.displayname, st.clientstoreid, ap.pharmacypatientid, ap.atebpatientid
from patient.atebpatient as ap
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid 
where ch.clientid=95 and st.clientstoreid = '001';

-- Want TMM targeted list file prefix name e.g. TMM-CLI_MCK0070(clientid=1000005)-RFD-20170602.xlsx
SELECT groupname FROM amc.campaigngroups where description ilike '%brant%'

-- Compare cgid
select name, short_name FROM amc.clients where id=970
select id, groupname, description from amc.campaigngroups where description ilike '%rein%'

-- Have store name want store details
select a.*, b.clientid from client.store a join client.chain b on a.chainid=b.chainid where displayname like '%CLI_1134470016%';

-- Open stores per PMAP
select st.displayname as storename2, st.openflag, st.clientstoreid, st.ncpdpid, st.npi, st.city, st.stateprov
from client.store as st join client.chain as ch on st.chainid=ch.chainid
where ch.clientid=17 and openflag=true;

-- Importsourceid
select a.*, b.name
from public.importsource a join importtype b on a.importtypeid=b.importtypeid
where clientid= '1020' order by created desc limit 20; 

--- Which immu tasks exist by clientid
SELECT distinct ia.clientid, ia.actioncodeid, reasonforalert, ac.name, ac.code
FROM pmap.interventionalert ia join pmap.actioncode ac on ia.actioncodeid=ac.actioncodeid
where ia.actioncodeid in(select distinct actioncodeid from pmap.actioncode where name ilike '%immuni%')
      and ia.reasonforalert ilike '%zation opp%' and ia.alertstatusid=1
order by ia.clientid

-- Have rxnum want ndc for a patient
select a.rxnum, b.ndc
from patient.patientrx a join patient.rxdetail_extra b on a.patientrxid=b.patientrxid
where atebpatientid=22510462

-- Want recently closed campaigns
select id, description, groupname, enddate from amc.campaigngroups where campaigntype = 'RRC' and enddate > current_date-90 order by 4, 3;

-- Want count of imm tasks
select ch.clientid, ac.code, count(*) as count
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid 
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
where alertstatusid=1 and ia.actioncodeid in(select actioncodeid from pmap.actioncode where code like 'IMMOPP_%') and ch.clientid=1059
group by ch.clientid, ac.code
order by 1, 2
;

-- Have client want task counts of all Analytics tasks CANONICAL
select ch.clientid, ac.code, ia.reasonforalert, count(*) as count
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid 
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
where alertstatusid=1 and ia.actioncodeid in( select distinct actioncodeid
                                              from pmap.actioncode 
                                              where code ilike 'IMMOPP_%' or code ilike 'IMEDICARE%' or code ilike 'NOSTATIN%' or code ilike 'TMM_ENROLL_PRI%' or code ='TMM_PLANMEDNOTENROLL'
) and ch.clientid=1059
group by ch.clientid, ia.reasonforalert, ac.code
order by 1, 2
;

-- Have patient, want task full details CANONICAL
select ch.clientid, st.displayname, st.clientstoreid, ap.pharmacypatientid, ac.code, ac.name, ac.actioncodeid, ia.*
from pmap.interventionalert as ia
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid
     join client.store as st on ap.storeid=st.storeid
     join client.chain as ch on ch.chainid=st.chainid 
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid
where alertstatusid=1 and ia.actioncodeid in( select distinct actioncodeid
                                              from pmap.actioncode 
                                              where code ilike 'TMM_ENROLL_PRI%'
) and ch.clientid=7 and ap.pharmacypatientid='11159958'
order by 3, 4
;

-- Have patient want MDF details.  Compare alternative with db5 rxfilldata_parent version.
select a.clientid, a.ndc, a.medicationname, c.atebpatientid, c.patientrxid, c.rxnum, b.rxstatus, b.filldate, coalesce(b.solddate,b.filldate)+b.dayssupply as duedate
from patient.rxdetail as a
     join patient.rxfilldetail b on a.patientrxid=b.patientrxid
     join patient.patientrx c on a.patientrxid=c.patientrxid
where c.clientid=7 and rxstatus != 14 and coalesce(b.solddate, b.filldate) + 180 >= current_date and c.atebpatientid=86969770
order by 8;

-- Have birthdate dob want atebpatientid pharmacypatientid
select a.patientdemographicid, a.atebpatientid, a.dateofbirth, a.knowledgeofdeath, b.lastname, d.clientstoreid
from patient.patientdemographic a join patient.patientname b on a.atebpatientid=b.atebpatientid
     join patient.atebpatient c on a.atebpatientid=c.atebpatientid
     join client.store as d on c.storeid=d.storeid
     join client.chain as e on d.chainid=e.chainid
where a.clientid=17 and a.dateofbirth='1959-04-21' and a.knowledgeofdeath is null

-- Want all actioncodeid
select distinct actioncodeid,name from pmap.actioncode order by 1;

-- Trace a store's Gap patients:
select ch.clientid, st.clientstoreid, ap.pharmacypatientid, ac.code, ia.reasonforalert
from pmap.interventionalert as ia                                                               
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid                        
     join client.store as st on ap.storeid=st.storeid                                           
     join client.chain as ch on ch.chainid=st.chainid                                           
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid                              
where alertstatusid=1 and ia.actioncodeid in( select distinct actioncodeid                      
                                              from pmap.actioncode                              
                                              where code ilike 'NOSTATIN'
) and ch.clientid=8 and st.clientstoreid='0106'                                                                             
order by 1, 2  , 3                                                                                 
;

-- Trace a store's SEG priority patient
select ch.clientid, st.clientstoreid, ap.pharmacypatientid, ac.code, ia.reasonforalert, pp.patientstatusid, ia.interventionalertid, statuschangedate, ia.alertstatusid
from pmap.interventionalert as ia                                                               
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid                        
     join client.store as st on ap.storeid=st.storeid                                           
     join client.chain as ch on ch.chainid=st.chainid                                           
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid                              
     join pmap.patientparticipation as pp on pp.atebpatientid=ap.atebpatientid
where ia.actioncodeid in( select distinct actioncodeid                      
                                              from pmap.actioncode                              
                                              where code ilike 'TMM_ENROLL_PRI')
      and ch.clientid=17 and ia.reasonforalert ilike '%manatee%'
      and ap.pharmacypatientid='10132570'
order by 2, 4, 8 desc, 9
;

select ch.clientid, st.clientstoreid, ac.code, count(*) as count
from pmap.interventionalert as ia                                                               
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid                        
     join client.store as st on ap.storeid=st.storeid                                           
     join client.chain as ch on ch.chainid=st.chainid                                           
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid                              
where alertstatusid=1 and ia.actioncodeid in( select distinct actioncodeid                      
                                              from pmap.actioncode                              
                                              where code = 'TMM_ENROLL_PRI') and ch.clientid=17 and ia.reasonforalert ilike '%manatee%'
group by ch.clientid, st.clientstoreid, ac.code
order by 1, 2  , 3                                                                                 
;

-- GPIs in Freds RFR campaign
select distinct cg.id, cg.groupname, cg.description, cg.campaigntype, cg.rptrequirements, cg.status, cr.gpi
from amc.campaigngroups as cg, amc.campaignrefills as cr          
where cg.id=cr.campaigngroupid          
  and cg.status='RUNNING'         
  and cg.groupname like 'FPG%'        
  and cg.id in(328,329,330,334,335,385,413,417,420,421,422,424,1065,1066,1067,1068,1069,1070,1071,1072,1073,1074,1075,1076,1077,1078,1079,1080,1085)
  and pickeduptimestamp > '2016-05-01'
order by cg.id
;

-- Total OBC calls made by store for a campaign
select clients.short_name, stores.storeid,
       sum(case when cp.status='ACTIVE' then 1 else 0 end) as active_count,
       count(cor.*) as call_count
from amc.campaignPatients as cp
      inner join amc.campaignGroups as cg on cg.id = cp.campaignGroupId and cg.groupname='FPGSngl'
      inner join amc.stores on stores.id = cp.storeuid
      inner join amc.clients on clients.id = stores.clients_fkid
      left outer join amc.campaignOBCResults as cor on cor.campaignPatientId = cp.id and cor.campaignGroupId = cg.id
group by short_name, storeid
order by short_name; 

-- Active RFR eval campaigns:
select id, lower(rptrequirements) rr from amc.campaigngroups where campaigntype='RRC' and upper(description) like '%AHOLD%' and status='RUNNING' and rrc=true and enddate is null order by rr;

-- Have campaign name want cgid
select * from amc.campaigngroups where campaigntype='RRC' and upper(description) like '%AHOLD%' and description ilike '%gaba%';

-- Verify no enrolled patients with task:
select ch.clientid, st.clientstoreid, ap.pharmacypatientid, ac.code, ia.reasonforalert, pp.patientstatusid, ia.interventionalertid, statuschangedate, ia.alertstatusid
from pmap.interventionalert as ia                                                               
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid                        
     join client.store as st on ap.storeid=st.storeid                                           
     join client.chain as ch on ch.chainid=st.chainid                                           
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid                              
     join pmap.patientparticipation as pp on pp.atebpatientid=ap.atebpatientid
where ia.actioncodeid in( select distinct actioncodeid                      
                                              from pmap.actioncode                              
                                              where code = 'TMM_ENROLL_PRI')
      and ch.clientid=8 and (ia.reasonforalert = 'Standard' or a.reasonforalert = 'Performance Network')
      and pp.patientstatusid in(3,4,5)
      and ia.alertstatusid=1
order by 2, 4, 8 desc, 9
;

-- Have patient want health plan and enrollment info
select distinct ch.clientid, st.clientstoreid, ap.pharmacypatientid, ap.atebpatientid, ia.reasonforalert, pp.patientstatusid,
                    sum(case when pp.patientstatusid = 3 then 1 else 0 end) as enrolled,
                    sum(case when pp.patientstatusid = 4 then 1 else 0 end) as optout,
                    sum(case when pp.patientstatusid = 5 then 1 else 0 end) as unenrolled,
                    ia.lastmodified
from pmap.interventionalert as ia                                                               
     join patient.atebpatient as ap on ia.atebpatientid=ap.atebpatientid                        
     join client.store as st on ap.storeid=st.storeid                                           
     join client.chain as ch on ch.chainid=st.chainid                                           
     join pmap.actioncode as ac on ac.actioncodeid=ia.actioncodeid                              
     join pmap.patientparticipation as pp on pp.atebpatientid=ap.atebpatientid
where ia.actioncodeid in( select distinct actioncodeid from pmap.actioncode where code ilike 'TMM_ENROLL_PRI' )
      and ia.reasonforalert in (
                                'Ahold SilverScript',
                                'Ahold United Healthcare',
                                'Brilinta Sponsored Program',
                                'Cigna Healthspring',
                                'Delhaize UHC Advantage',
                                'Freds Diabetic Patients Priority Enrollments',
                                'Freds Humana Priority Enrollment',
                                'Freds SilverScript',
                                'Giant Eagle Aetna or Coventry',
                                'Giant Eagle Anthem',
                                'Giant Eagle Cigna',
                                'Giant Eagle Envision',
                                'Giant Eagle Humana',
                                'Giant Eagle Magellan',
                                'Giant Eagle SilverScript',
                                'Humana',
                                'Meijer SilverScript',
                                'Owens Cigna/Healthspring',
                                'Owens Coventry',
                                'Owens Humana',
                                'Owens SilverScript',
                                'Owens Wellcare',
                                'Publix Caremark SilverScript',
                                'Publix Express Scripts',
                                'Publix Humana',
                                'Publix Optum',
                                'Publix Prime Therapeutics',
                                'Publix Wellcare',
                                'Shrivers Cigna/Healthspring',
                                'Shrivers Humana',
                                'Shrivers SilverScript',
                                'Silverscript',
                                'Time My Meds - Priority Patient Enrollment - UnitedHealthcare',
                                'Weis SilverScript'
                                )
      and ch.clientid=1059 and ap.pharmacypatientid='1475977'
      and pp.patientstatusid in(3, 4, 5)
      /* and coalesce(pp.statusmodifieddate::date, pp.lastmodified::date)>='2017-09-18' */
      /* and coalesce(pp.statusmodifieddate::date, pp.lastmodified::date)<='2017-09-28' */
group by ch.clientid, st.clientstoreid, ap.pharmacypatientid, ap.atebpatientid, ia.reasonforalert, pp.patientstatusid,ia.lastmodified
order by 6, 1, 2, 3
;
