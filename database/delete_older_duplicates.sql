
 with errs as (       
    SELECT risk_id
    FROM risk_employee
    group by risk_id
    having count(1)>1
  )
  select r.risk_employee_id, row_number() OVER (partition by r.risk_id order by r.actual_updated) as rownbr
  from risk_employee r, errs e
  where r.risk_id=e.risk_id;

---

-- Keep only the youngest duplicate by account_id and custom_area_property_id
DELETE
  FROM account_flex_field af1
 WHERE af1.account_flex_field_id IN
   (SELECT af3.account_flex_field_id
      FROM (SELECT row_number() OVER (PARTITION BY af2.account_id, af2.custom_area_property_id ORDER BY af2.updated desc) rownumber, af2.account_flex_field_id
              FROM account_flex_field af2) af3
     WHERE rownumber != 1)

