with v as (
	select 'abc' account_name, 5645818 account_id from dual union all
	select 'abc' account_name, 5645818 account_id from dual union all
	select 'def' account_name, 456 account_id from dual union all
	select 'ghi' account_name, 5645818 account_id from dual
) 
select *
from v;

---

with v as (
          select date '2000-01-01' d, 10 amt from dual
union all select date '2000-01-02',   11     from dual
union all select date '2000-01-03',   30     from dual
union all select date '2000-01-03',   30     from dual
union all select date '2000-01-04',   10     from dual
union all select date '2000-01-05',   14     from dual
)
select *
from v;

---

insert into SALESGROUP_SUBSIDIARY ( SALESGROUP_SUBSIDIARY_ID, SALESGROUP, SUBSIDIARY_NAME, ADMINISTERING_COUNTRY_CD, STATUS, REVSTATE, SUBSIDIARY ) 
  select uid_salesgroup_subsidiary.nextval, s.SALESGROUP, s.SUBSIDIARY_NAME, s.ADMINISTERING_COUNTRY_CD, s.STATUS, s.REVSTATE, o.SUBSIDIARYINC
    from SALESGROUP_SUBSIDIARY s, ( with v as ( select 'INCAU' SUBSIDIARYINC, 'SASA' SUBSIDIARY, 'SAS In' SUBSIDIARY_NAME from dual 
                                                union all
                                                select 'INCA2' SUBSIDIARYINC, 'SAS2' SUBSIDIARY, 'SAS In' SUBSIDIARY_NAME from dual ) 
                                    select * from v ) o
   where s.subsidiary = o.subsidiary
;
