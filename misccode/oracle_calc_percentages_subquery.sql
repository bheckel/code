
-- Calculate percentage selected vs. not selected
select avg(pct) from
(
  select matl_nbr, sel/tot pct from
  (
    select aa.matl_nbr, bb.cb sel, aa.ca, bb.cb+aa.ca tot from
    (select matl_nbr, count(*) ca
    from RETAIN.FNSH_PROD 
    where prod_act_ind = 'Y' AND deleted_ind = 'N' and prod_sel = 'N'
    group by matl_nbr) aa
    join
    (select matl_nbr, count(*) cb
    from RETAIN.FNSH_PROD 
    where prod_act_ind = 'Y' AND deleted_ind = 'N' and prod_sel = 'Y'
    group by matl_nbr) bb
    on aa.matl_nbr=bb.matl_nbr
  )
)


-- Same but need criteria from a lookup table
select avg(pct) from
(
  select matl_nbr, sel/tot pct from
  (
    select aa.matl_nbr, bb.cb sel, aa.ca, bb.cb+aa.ca tot from

    (select a.matl_nbr, count(*) ca
    from RETAIN.FNSH_PROD a join RETAIN.MATERIAL b on a.matl_nbr=b.matl_nbr
    where prod_act_ind = 'Y' AND deleted_ind = 'N' and prod_sel = 'N' and prod_class != 6
    group by prod_desc, a.matl_nbr) aa

    join

    (select a.matl_nbr, count(*) cb
    from RETAIN.FNSH_PROD a join retain.material b on A.matl_nbr=b.matl_nbr
    where prod_act_ind = 'Y' AND deleted_ind = 'N' and prod_sel = 'Y' and prod_class != 6
    group by prod_desc, a.matl_nbr) bb

    on aa.matl_nbr=bb.matl_nbr
  )
)
