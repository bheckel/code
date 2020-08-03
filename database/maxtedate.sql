
set linesize 180;
set pagesize 9999;
column material_description format a45

SELECT material_description, TO_CHAR(min(test_execution_date), 'DD-MON-YY'), TO_CHAR(max(test_execution_date), 'DD-MON-YY')
FROM ods_dist.vw_zeb_combined_qcresults_nl
   -- in prod
where upper(material_description) like '%ADVAIR DISKUS%'
   OR upper(material_description) like '%BUPROPION%'
   OR upper(material_description) like '%LAMICTAL%'
   OR upper(material_description) like '%METHYLCELLULOSE%'
   OR upper(material_description) like '%SEREVENT%'
   OR upper(material_description) like '%VALTREX%'
   OR upper(material_description) like '%WELLBUTRIN%'
   OR upper(material_description) like '%ZYBAN%'
   -- in DEMO
   OR upper(material_description) like '%ADVAIR HFA%'
   OR upper(material_description) like '%ALBUTEROL%'
   OR upper(material_description) like '%AVANDAMET%'
   OR upper(material_description) like '%AVANDARYL%'
   OR upper(material_description) like '%LOTRONEX%'
   OR upper(material_description) like '%LOVAZA%'
   OR upper(material_description) like '%RELENZA%'
   OR upper(material_description) like '%RETROVIR%'
   OR upper(material_description) like '%ROSIGLITAZONE%'
   OR upper(material_description) like '%TRIZIVIR%'
   OR upper(material_description) like '%ALBUTEROL%'
   OR upper(material_description) like '%VENTOLIN HFA%'
   OR upper(material_description) like '%ZOFRAN%'
   OR upper(material_description) like '%ZOVIRAX%'
GROUP BY material_description
ORDER BY material_description
;
quit;
