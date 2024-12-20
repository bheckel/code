--  Created: 05-Aug-2020 (Bob Heckel)
-- Modified: 11-Dec-2024 (Bob Heckel)

---

   sum(kr.lbdamt) over(partition by kr.invoice, kr.newren) as invoice_total,
   sum(decode(kr.NEWREN, 'N', kr.lbdamt, 0)) over(partition by kr.INVOICE, kr.newren) as invoice_total_new,
   sum(decode(kr.NEWREN, 'N', 0, kr.lbdamt)) over(partition by kr.INVOICE, kr.newren) as invoice_total_renewal,

---

SELECT
  (SUM(CASE WHEN saleid IS NULL THEN 1 ELSE 0 END)) AS null_count,
  COUNT(CASE WHEN saleid = '.' THEN 1 END) AS x_count,
  (SUM(CASE WHEN saleid = '.' THEN 1 ELSE 0 END)) AS x_count_same
FROM kmc_allocated;

---

select count(*),
       count( distinct job_id ) jobs,
       count( distinct department_id ) depts,
       /* count( case when job_id = 'SA_REP' then 1 end ) sa_rep, */
       -- same
       sum( case when job_id = 'SA_REP' then 1 end ) sa_rep,
       count( case when department_id = 80 then 1 end ) dept_80,
       count( case when job_id = 'SA_REP' and department_id = 80 then 1 end ) sa_rep_dept_80
from   employees;

---

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
