
select distinct prod_nm, meth_spec_nm,pks_extraction_cntrl_notes_txt, substr(pks_extraction_cntrl_notes_txt,instr(pks_extraction_cntrl_notes_txt,'-')) f 
from pks_extraction_control 
where prod_nm in ('Advair HFA','Advair Diskus','Ventolin HFA','Relenza Rotadisk') 
order by f, prod_nm
