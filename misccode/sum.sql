select (round((tot_count_with_primary / total_count), 4) * 100) percent_contacts_w_primary,
       (round(((tot_count_with_primary - (tot_existing_addresses + tot_existing_emails)) / tot_count_with_primary), 4) * 100) percent_missing_contact_method,
       v.*
  from (select count(1) total_count,
               sum(decode(b.primary_contact_method, null, 0, 1)) tot_count_with_primary,
               sum(case
                     when b.primary_contact_method like '% Mail' then
                      (select 1
                         from contact_address ca
                        where ca.contact_id = b.contact_id
                          and ca.primary_address = 1)
                     else
                      0
                   end) tot_existing_addresses,
               sum(case
                     when b.primary_contact_method like '%Email' then
                      (select 1
                         from contact_email ce
                        where ce.contact_id = b.contact_id
                          and ce.primary_email = 1)
                     else
                      0
                   end) tot_existing_emails
          from contact b) v;

---

-- Sum 3 stages together by device
select indvl_tst_rslt_device,sum(indvl_tst_rslt_val_num) from indvl_tst_rslt 
where samp_id=214577 and indvl_meth_stage_nm in('THROAT','PRESEPARATOR','0')
group by indvl_tst_rslt_device

---

SELECT EMPLOYEE_ID, SUM(HOURS) HRTOT_ALIAS
FROM TIME_TRANSACTS 
WHERE TIME BETWEEN TO_DATE('7/10/2001', 'mm/dd/yyyy') 
               AND TO_DATE('7/24/2001', 'mm/dd/yyyy')
GROUP BY EMPLOYEE_ID; --mandatory if using SUM
