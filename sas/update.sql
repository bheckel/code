--delete a method from pec
select * from pks_extraction_control where meth_spec_nm like 'ATM02102%';
delete from pks_extraction_control where meth_spec_nm like 'ATM02102%';

select STABILITY_LOWER_SPEC_LIMIT from pks_extraction_control where meth_spec_nm like 'AM0779%' and meth_var_nm='AbacavirContent';
update pks_extraction_control set STABILITY_LOWER_SPEC_LIMIT='90.0' where meth_spec_nm like 'AM0779%' and meth_var_nm='AbacavirContent';

select STABILITY_UPPER_SPEC_LIMIT from pks_extraction_control where meth_spec_nm like 'AM0779%' and meth_var_nm='AbacavirContent';
update pks_extraction_control set STABILITY_UPPER_SPEC_LIMIT='110.0' where meth_spec_nm like 'AM0779%' and meth_var_nm='AbacavirContent';

select stability_spec_txt_a from pks_extraction_control where meth_spec_nm like 'AM0779%' and meth_var_nm='AbacavirContent';
update pks_extraction_control set stability_spec_txt_a='90.0-110.0 % Label Claim' where meth_spec_nm like 'AM0779%' and meth_var_nm='AbacavirContent';

select mfg_spec_txt_b from pks_extraction_control where meth_spec_nm like 'APPEAR%' and prod_nm like 'Zia%';
update pks_extraction_control set mfg_spec_txt_b='' where meth_spec_nm like 'APPEAR%' and prod_nm like 'Zia%';

-- before
select meth_spec_nm, pks_extraction_cntrl_notes_txt from pks_extraction_control where pks_extraction_cntrl_notes_txt like '%CU HPLC%';
-- after
select meth_spec_nm, replace(pks_extraction_cntrl_notes_txt, 'CU HPLC','Content Uniformity') from pks_extraction_control where pks_extraction_cntrl_notes_txt like '%CU HPLC%';
-- run
update pks_extraction_control set pks_extraction_cntrl_notes_txt=REPLACE(pks_extraction_cntrl_notes_txt,'CU HPLC','Content Uniformity') where pks_extraction_cntrl_notes_txt like '%CU HPLC%';

select meth_spec_nm, pks_extraction_cntrl_notes_txt from pks_extraction_control where pks_extraction_cntrl_notes_txt like '%Assay HPLC%';
select meth_spec_nm, replace(pks_extraction_cntrl_notes_txt, 'Assay HPLC','Assay') from pks_extraction_control where pks_extraction_cntrl_notes_txt like '%Assay HPLC%';
update pks_extraction_control set pks_extraction_cntrl_notes_txt=REPLACE(pks_extraction_cntrl_notes_txt,'Assay HPLC','Assay') where pks_extraction_cntrl_notes_txt like '%Assay HPLC%';

select meth_spec_nm, pks_extraction_cntrl_notes_txt from pks_extraction_control where pks_extraction_cntrl_notes_txt like '%DISS HPLC%';
select meth_spec_nm, replace(pks_extraction_cntrl_notes_txt, 'Diss HPLC','Dissolution') from pks_extraction_control where pks_extraction_cntrl_notes_txt like '%DISS HPLC%';
update pks_extraction_control set pks_extraction_cntrl_notes_txt=REPLACE(pks_extraction_cntrl_notes_txt,'DISS HPLC','Dissolution') where pks_extraction_cntrl_notes_txt like '%DISS HPLC%';

select meth_spec_nm, pks_extraction_cntrl_notes_txt from pks_extraction_control where pks_extraction_cntrl_notes_txt like '%DRUG RELEASE UV%';
select meth_spec_nm, replace(pks_extraction_cntrl_notes_txt, 'DRUG RELEASE UV','Drug Release') from pks_extraction_control where pks_extraction_cntrl_notes_txt like '%DRUG RELEASE UV%';
update pks_extraction_control set pks_extraction_cntrl_notes_txt=REPLACE(pks_extraction_cntrl_notes_txt,'DRUG RELEASE UV','Drug Release') where pks_extraction_cntrl_notes_txt like '%DRUG RELEASE UV%';

select meth_spec_nm, pks_extraction_cntrl_notes_txt from pks_extraction_control where pks_extraction_cntrl_notes_txt like '%Content Uniformity HPLC%';
update pks_extraction_control set pks_extraction_cntrl_notes_txt=REPLACE(pks_extraction_cntrl_notes_txt,'Content Uniformity HPLC','Content Uniformity') where pks_extraction_cntrl_notes_txt like '%Content Uniformity HPLC%';

select meth_spec_nm, pks_extraction_cntrl_notes_txt from pks_extraction_control where pks_extraction_cntrl_notes_txt like '%ASSAY Content Uniformity%';
update pks_extraction_control set pks_extraction_cntrl_notes_txt=REPLACE(pks_extraction_cntrl_notes_txt,'ASSAY Content Uniformity','Content Uniformity') where pks_extraction_cntrl_notes_txt like '%ASSAY Content Uniformity%';

select meth_spec_nm, pks_extraction_cntrl_notes_txt from pks_extraction_control where pks_extraction_cntrl_notes_txt like '%HPLC Related Imp.';
update pks_extraction_control set pks_extraction_cntrl_notes_txt=REPLACE(pks_extraction_cntrl_notes_txt,'HPLC Related Imp.','Impurities') where pks_extraction_cntrl_notes_txt like '%HPLC Related Imp.';

select meth_spec_nm, pks_extraction_cntrl_notes_txt from pks_extraction_control where pks_extraction_cntrl_notes_txt like '%Dissolution UV%';
update pks_extraction_control set pks_extraction_cntrl_notes_txt=REPLACE(pks_extraction_cntrl_notes_txt,'Dissolution UV','Dissolution') where pks_extraction_cntrl_notes_txt like '%Dissolution UV%';

select meth_spec_nm, pks_extraction_cntrl_notes_txt from pks_extraction_control where pks_extraction_cntrl_notes_txt like '%Impurities HPLC%';
update pks_extraction_control set pks_extraction_cntrl_notes_txt=REPLACE(pks_extraction_cntrl_notes_txt,'Impurities HPLC','Impurities') where pks_extraction_cntrl_notes_txt like '%Impurities HPLC%';

select meth_spec_nm, pks_extraction_cntrl_notes_txt from pks_extraction_control where pks_extraction_cntrl_notes_txt like '%Content per Dose HPLC%';
update pks_extraction_control set pks_extraction_cntrl_notes_txt=REPLACE(pks_extraction_cntrl_notes_txt,'Content per Dose HPLC','Content per Dose') where pks_extraction_cntrl_notes_txt like '%Content per Dose HPLC%';

select meth_spec_nm, pks_extraction_cntrl_notes_txt from pks_extraction_control where pks_extraction_cntrl_notes_txt like '%CU by TPW%';
update pks_extraction_control set pks_extraction_cntrl_notes_txt=REPLACE(pks_extraction_cntrl_notes_txt,'CU by TPW','Content Uniformity') where pks_extraction_cntrl_notes_txt like '%CU by TPW%';

select meth_spec_nm, pks_extraction_cntrl_notes_txt from pks_extraction_control where pks_extraction_cntrl_notes_txt like '%MAN Content Uniformity%';
update pks_extraction_control set pks_extraction_cntrl_notes_txt=REPLACE(pks_extraction_cntrl_notes_txt,'MAN Content Uniformity','Content Uniformity') where pks_extraction_cntrl_notes_txt like '%MAN Content Uniformity%';

select meth_spec_nm, pks_extraction_cntrl_notes_txt from pks_extraction_control where pks_extraction_cntrl_notes_txt like '%GEN%';
update pks_extraction_control set pks_extraction_cntrl_notes_txt=REPLACE(pks_extraction_cntrl_notes_txt,'GEN','Gen') where pks_extraction_cntrl_notes_txt like '%GEN%';

select meth_spec_nm, STABILITY_SPEC_TXT_A from pks_extraction_control where STABILITY_SPEC_TXT_A like '%NMT%';
update pks_extraction_control set STABILITY_SPEC_TXT_A=REPLACE(STABILITY_SPEC_TXT_A,'NMT','Not More Than') where STABILITY_SPEC_TXT_A like '%NMT%';

select meth_spec_nm, pks_lab_tst_desc from pks_extraction_control where meth_var_nm like 'FinalDisso%';
update pks_extraction_control set pks_lab_tst_desc='Final Dissolution Result' where meth_var_nm like 'FinalDisso%';

select prod_nm, meth_spec_nm, pks_stage, pks_lab_tst_desc from pks_extraction_control where pks_stage like '%4th%' and pks_lab_tst_desc like '%2nd%';
update pks_extraction_control set pks_lab_tst_desc=REPLACE(pks_lab_tst_desc,'2nd','4th') where pks_stage like '%4th%' and pks_lab_tst_desc like '%2nd%';

select prod_nm, meth_spec_nm, pks_var_nm from pks_extraction_control where upper(meth_var_nm) like '%RSD%' and upper(pks_var_nm) like 'PEAK%';
update pks_extraction_control set pks_var_nm = '' where upper(meth_var_nm) like '%RSD%' and upper(pks_var_nm) like 'PEAK%';

--Change 'AM0999 - Assay' to 'AM0999 - Impurities' for non FOOCONTENT meth_var_nm's
select prod_nm, meth_spec_nm, meth_var_nm, pks_extraction_cntrl_notes_txt from pks_extraction_control where upper(meth_spec_nm) like '%ASS%' and upper(meth_var_nm) like 'ABACA%';
update pks_extraction_control set pks_extraction_cntrl_notes_txt=REPLACE(pks_extraction_cntrl_notes_txt,'Assay','Impurities') where upper(meth_spec_nm) like '%ASS%' and upper(meth_var_nm) like 'ABACA%';

select prod_nm, meth_spec_nm, meth_var_nm, pks_extraction_cntrl_notes_txt from pks_extraction_control where upper(meth_spec_nm) like '%ASS%' and upper(meth_var_nm) like 'LAMOTRIGINERE%';
update pks_extraction_control set pks_extraction_cntrl_notes_txt=REPLACE(pks_extraction_cntrl_notes_txt,'Assay','Impurities') where upper(meth_spec_nm) like '%ASS%' and upper(meth_var_nm) like 'LAMOTRIGINERE%';

select meth_var_nm, pks_lab_tst_desc, prod_nm, meth_spec_nm from pks_extraction_control where meth_var_nm like 'Upper%' and pks_lab_tst_desc like 'Individual Content Uniformity - Min%';
update pks_extraction_control set pks_lab_tst_desc='Individual Content Uniformity - Max %' where meth_var_nm like 'Upper%' and pks_lab_tst_desc like 'Individual Content Uniformity - Min%';

select meth_var_nm, pks_lab_tst_desc, prod_nm, meth_spec_nm from pks_extraction_control where meth_var_nm like 'TotalI%' and pks_lab_tst_desc like 'Individual Any Other Impurity';
update pks_extraction_control set pks_lab_tst_desc='Individual Total Impurity' where meth_var_nm like 'TotalI%' and pks_lab_tst_desc like 'Individual Any Other Impurity';

select count(*) from pks_extraction_control where meth_spec_nm like 'AM0952%' and pks_stage like 'Mg%';
update pks_extraction_control set pks_stage='Weight' where meth_spec_nm like 'AM0952%' and pks_stage like 'Mg%';

--change an existing lab test description
select meth_spec_nm,meth_var_nm,pks_lab_tst_desc,pks_format from pks_extraction_control where upper(pks_lab_tst_desc) like '%FINAL DISSOLUT%';
update pks_extraction_control set pks_format='0' where upper(pks_lab_tst_desc) like '%FINAL DISSOLUT%';

select meth_spec_nm,pks_lab_tst_desc from pks_extraction_control where upper(pks_lab_tst_desc) = 'CONTENT UNIFORMITY - RSD %';
update pks_extraction_control set pks_lab_tst_desc='Individual RSD %' where upper(pks_lab_tst_desc) = 'CONTENT UNIFORMITY - RSD %';

select meth_spec_nm, meth_var_nm, pks_extraction_macro, prod_nm from pks_extraction_control where meth_spec_nm like '%DISS%' and upper(pks_extraction_macro) = 'SRNVLIM' and (upper(meth_var_nm) like 'MIN%' or upper(meth_var_nm) like 'MAX%');
delete from pks_extraction_control where meth_spec_nm like '%DISS%' and upper(pks_extraction_macro) = 'SRNVLIM' and (upper(meth_var_nm) like 'MIN%' or upper(meth_var_nm) like 'MAX%');

select meth_spec_nm, pks_lab_tst_desc from pks_extraction_control where meth_var_nm like 'GR%';
update pks_extraction_control set pks_lab_tst_desc='Final Dissolution Result' where meth_var_nm like 'FinalDisso%';

update tst_rslt_summary set LAB_TST_DESC=replace(LAB_TST_DESC, 'Individual', 'Mean') where LAB_TST_DESC like '%Individual Dose%'

update tst_rslt_summary set LAB_TST_DESC=replace(LAB_TST_DESC, 'Individual', 'Mean') where LAB_TST_DESC like 'Individual Label Claim Num%'
update stage_translation set LAB_TST_DESC=replace(LAB_TST_DESC, 'Individual', 'Mean') where LAB_TST_DESC like 'Individual Label Claim Num%'

update pks_extraction_control set pks_format='99' where upper(pks_extraction_macro) = 'SRCVLIM' and prod_nm not like '%Diskus%' and mfg_spec_txt_a is not null and meth_var_nm not like 'FinalD%';

select * from user_role where user_nm like '%Heckel%'
update user_role set user_role=5 where user_nm like '%Heckel%'

select *
from tst_rslt_summary
where samp_id=198888 and meth_spec_nm like 'AM08%' and meth_peak_nm like '%MAX'

delete
from tst_rslt_summary
where samp_id=198888 and meth_spec_nm like 'AM08%' and meth_peak_nm like '%MAX'

select *
from pks_extraction_control
where meth_spec_nm = 'AM0880PARTICULATEMATTER' and meth_var_nm like '%Max'

delete
from pks_extraction_control
where meth_spec_nm = 'AM0880PARTICULATEMATTER' and meth_var_nm like '%Max'

delete
from pks_extraction_control
where meth_spec_nm like 'AM0837%'

-- 2 step b/c that's how the changes evolved during debugging
update pks_extraction_control set mfg_spec_txt_a='x'
update pks_extraction_control set stability_spec_txt_a='x'
update pks_extraction_control set mfg_spec_txt_a='' where column_nm is null
update pks_extraction_control set stability_spec_txt_a='' where column_nm is null


select prod_nm
from pks_extraction_control
where (upper(substr(prod_nm,1,6)) not in ('ADVAIR','COMBIV','IMITRE','RETROV','WELLBU','ZANTAC','ZIAGEN','ZOFRAN','ONDANS','SAL/FP','RELENZ') or upper(substr(prod_nm,1,9))='IMITREX T') 
and upper(prod_nm) ^='N/A'
order by prod_nm

delete
from pks_extraction_control
where (upper(substr(prod_nm,1,6)) not in ('ADVAIR','COMBIV','IMITRE','RETROV','WELLBU','ZANTAC','ZIAGEN','ZOFRAN','ONDANS','SAL/FP','RELENZ') or upper(substr(prod_nm,1,9))='IMITREX T') 
and upper(prod_nm) ^='N/A'




  /* vim: set tw=999 wrap : */ 

