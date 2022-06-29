-- Determine which lovs in a list have no description by padding the null column
with v as (
  select to_number(COLUMN_VALUE) id FROM xmltable(('"' || replace('536013,536014,536015) || '"'))
), v2 as (
  select v.id, c.list_description
    from v, custom_query_lov_view c
   where v.id=c.list_of_values_id(+)
)
select * 
  from v2
 where list_description is null;
