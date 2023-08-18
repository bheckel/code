
insert into SALESGROUP_SUBSIDIARY ( SALESGROUP_SUBSIDIARY_ID, SALESGROUP, SUBSIDIARY_NAME, ADMINISTERING_COUNTRY_CD, STATUS, REVSTATE, SUBSIDIARY ) 
  select uid_salesgroup_subsidiary.nextval, s.SALESGROUP, s.SUBSIDIARY_NAME, s.ADMINISTERING_COUNTRY_CD, s.STATUS, s.REVSTATE, o.SUBSIDIARYINC
    from SALESGROUP_SUBSIDIARY s, ( with v as ( select 'INCAU' SUBSIDIARYINC, 'SASA' SUBSIDIARY, 'SAS In' SUBSIDIARY_NAME from dual 
                                                union all
                                                select 'INCAU' SUBSIDIARYINC, 'SASA' SUBSIDIARY, 'SAS In' SUBSIDIARY_NAME from dual ) 
                                    select * from v ) o
   where s.subsidiary = o.subsidiary
;
