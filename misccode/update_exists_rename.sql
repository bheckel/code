-- Change 'Viay' to 'Viay (Analytics Platform)'
update INITIATIVE rf1
set corporate_initiative = 'Viay (Analytics Platform)' 
where corporate_initiative = 'Viay' 
and not exists (select 1
                from INITIATIVE rf2
                where rf1.reference_id=rf2.reference_id and rf2.corporate_initiative='Viay (Analytics Platform)');
