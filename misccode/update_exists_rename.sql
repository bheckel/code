
-- Use self-join to change all 'Viay' to 'Viay (Analytics Platform)' where it's not already set to 'Viay'
update INITIATIVE i1
set corporate_initiative = 'Viay (Analytics Platform)' 
where corporate_initiative = 'Viay' 
  and not exists (select 1
                  from INITIATIVE i2
                  where i1.reference_id=i2.reference_id and i2.corporate_initiative='Viay (Analytics Platform)');

