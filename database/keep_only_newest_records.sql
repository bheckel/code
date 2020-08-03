
--Modified: 24-Mar-2020 (Bob Heckel)
-- Self join to keep just the greater date of the pair
with v as (  
  select o.opportunity_id, o.account_name_id, o.opportunity_name, o.salesgroup, oe.opportunity_employee_id, oe.territory_lov_id, oe.employee_id, oe.role_lov_id, oe.owner_type,e.first_name, e.last_name, e.jobtitle, ate.account_team_employee_id, ate.account_team_id, ate.function_lov_id, ate.actual_updated
   from opportunity_base o, opportunity_employee_base oe, account_team_employee ate, employee_base e
  where o.opportunity_id = oe.opportunity_id
    and oe.employee_id = ate.employee_id
    and ate.employee_id = e.employee_id
     ...
    and o.status NOT IN ('X','Y','XW','YL')
)
select *
  from v
 where exists ( select 1
                 from v v2
                 where v.actual_updated > v2.actual_updated )
order by 1, 2;

-- same, slightly lower cost
-- Analytic function to keep just the greater date of the pair
with v as (  
  select o.opportunity_id, o.account_name_id, o.opportunity_name, o.salesgroup, o.status as milestone, oe.opportunity_employee_id, oe.territory_lov_id, oe.employee_id, oe.role_lov_id, oe.owner_type,e.first_name, e.last_name, e.jobtitle, ate.account_team_employee_id, ate.account_team_id, ate.function_lov_id, ate.actual_updated,
         row_number() over (partition by o.opportunity_id order by o.opportunity_id, ate.actual_updated desc) rn
    from opportunity_base o, opportunity_employee_base oe, account_team_employee ate, employee_base e, account_name an
   where o.opportunity_id=oe.opportunity_id
     and oe.employee_id =ate.employee_id
     and ate.employee_id = e.employee_id
     ...
     and o.status NOT IN ('X','Y','XW','YL')
)
select *
  from v
 where rn = 1
 order by 1, 2;
