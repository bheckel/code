 -- Created: 11-Aug-2021 (Bob Heckel)

 --  set serveroutput on
 declare
 --  create or replace procedure rion52833 is
   cnt number := 0;
   rowcnt number := 0;
   cursor c1 is
     select sdm_business_key, invoice_number, tor_ind_sr, tor_ind_f, kmc_exclusion_reason_id 
       from KMC_REVENUE_FULL
      where sdm_business_key in(
    '2955550100000182522862007',
    '2955549100000182522860007',
    '2955500100000182522828007')
   ;
begin
  for r in c1 loop
    if (r.tor_ind_sr + r.tor_ind_f) != 0 then
      if r.kmc_exclusion_reason_id = -99 then
        cnt := cnt + 1;
        DBMS_OUTPUT.put_line(r.sdm_business_key || ' ' || r.tor_ind_sr || ' ' || r.tor_ind_f || ' ');
        update KMC_REVENUE_FULL 
           set tor_ind_sr=0, tor_ind_f=0, kmc_exclusion_reason_id=10, kmc_exclusion_reason_date=sysdate
         where sdm_business_key = r.sdm_business_key;
        rowcnt := rowcnt + sql%rowcount;
        commit;
      end if;
    end if;
  end loop;
  
  e_mail_message('replies-disabled@s.com',
                 'bob.heckel@s.com',
                 'rion52833',
                 'updated ' || rowcnt || ' of ' || cnt);
end;
