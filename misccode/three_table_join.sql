
select *
from
    tableA a
        inner join
    tableB b
        on a.common=b.common
        inner join 
    tableC c
        on b.common=c.common



-- parens are optional
select *
from (links_material_genealogy g join links_material l on g.prod_matl_nbr=l.matl_nbr) join samp s on g.prod_matl_nbr=s.matl_nbr 
-- 1  ^^^^^^^^^^^^^^^^^^^^^^^^^^      ^^^^^^^^^^^^^^^^                    
-- 2  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^       ^^^^^^
where s.prod_nm like 'Ven%'
