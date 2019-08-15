-- see also explain_plan.sql

with inds as (    
    select substr(    
             index_name, instr(index_name, '_') + 1,     
             instr(index_name, '_', 1, 2) - instr(index_name, '_') - 1    
           ) col, leaf_blocks,    
           index_type    
    from   user_indexes    
)    
  select * from inds    
  pivot (     
    sum(leaf_blocks)     
    for index_type in ('NORMAL' btree, 'BITMAP' bitmap)    
  )
