-- 2007-04-05 Oracle at least
-- Replace the string starting after the dash
-- E.g.
-- "ATM02104 - Cascade Impaction" 
-- becomes
-- "ATM02104 - Cas. Impaction HPLC"

update pks_extraction_control
set pks_extraction_cntrl_notes_txt=REPLACE(pks_extraction_cntrl_notes_txt, substr(pks_extraction_cntrl_notes_txt,instr(pks_extraction_cntrl_notes_txt,'-')), '- Cas. Impaction HPLC')
where meth_spec_nm in ('ATM02003FULLCASCADEHPLC','ATM02065FULLCASCADEHPLC','ATM02104CASCADEHPLC')
