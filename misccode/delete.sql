-- To be sure, first toggle the DELETE
--select *
delete 
from transacts
where trandt = '1/1/2003';


-- Remove all records
delete
from foo


-- Oracle - remove one of two duplicates - first find unique identifier:

select rowid
from pks_extraction_control
where meth_spec_nm='AM0735CUHPLC' and meth_var_nm='PEAKINFO';

-- then remove one of them
delete
from pks_extraction_control
where rowid='AAB5QNACDAAARalAAo';

-- don't forget to 
COMMIT;

