SELECT /*+ INLINE */ DISTINCT ataa.account_id,
      COUNT(DISTINCT decode(th.parent_territory_lov_id, NULL, ataa.assign_territory_lov_id, NULL)) OVER(
        PARTITION BY ataa.account_id
      ) AS total_nonjmp_territories,
      COUNT(DISTINCT decode(th.parent_territory_lov_id, NULL, ate.employee_id, NULL)) OVER(
        PARTITION BY ataa.account_id
      ) AS total_nonjmp_tsr_owners,
      COUNT(DISTINCT decode(th.parent_territory_lov_id, NULL, NULL, th.sub_territory_lov_id)) OVER(
        PARTITION BY ataa.account_id
      ) AS total_jmp_territories,
      COUNT(DISTINCT decode(th.parent_territory_lov_id, NULL, NULL, ate.employee_id)) OVER(
        PARTITION BY ataa.account_id
      ) AS total_jmp_tsr_owners,
      COUNT(ataa.account_site_id) OVER(
        PARTITION BY ataa.account_id
      ) AS total_sites
FROM account_team_assign_all   ataa,
      account_team_employee     ate,
      territory_hierarchy       th
WHERE ataa.account_team_id = ate.account_team_id
  AND ate.function_lov_id = 2750
  AND ataa.assign_territory_lov_id = th.sub_territory_lov_id(+)
  AND th.parent_territory_lov_id(+) = 5566230

-- Visualized
select distinct COUNT(DISTINCT decode(th.parent_territory_lov_id, NULL, ataa.assign_territory_lov_id, NULL)) OVER( PARTITION BY ataa.account_id ) AS total_nonjmp_territories,
       COUNT(DISTINCT decode(th.parent_territory_lov_id, NULL, NULL, th.sub_territory_lov_id)) OVER( PARTITION BY ataa.account_id )  AS total_jmp_territories 
	FROM account_team_assign_all   ataa,
       account_team_employee     ate,
       territory_hierarchy       th
 WHERE ataa.account_team_id = ate.account_team_id
   AND ate.function_lov_id = 2750
   AND ataa.assign_territory_lov_id = th.sub_territory_lov_id (+)
   AND th.parent_territory_lov_id (+) = 5566230
