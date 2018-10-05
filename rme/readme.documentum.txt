
select * from delta_document ENABLE (RETURN_TOP 3)

select * from delta_document where object_name='IT00921'

SELECT r_folder_path
FROM dm_folder
WHERE r_object_id in(SELECT i_folder_id
                     FROM dm_document
                     WHERE object_name='IT00789')


select distinct r_folder_path from dm_folder

SELECT object_name, doc_control_user, title
FROM delta_document
SEARCH DOCUMENT CONTAINS '"LIMS"' OR '"Laboratory Information Management System"'
WHERE object_name like 'IT0%'
ORDER BY doc_control_user, object_name

SELECT object_name, doc_control_user, title
FROM delta_document
SEARCH DOCUMENT CONTAINS '"LINKS"' OR '"Knowledge System"'
WHERE object_name like 'IT0%'
ORDER BY doc_control_user, object_name

---

http://zebdelta.sgk.com:8080/da

Control click File
Control click About Documentum
Click DQL Editor

SELECT object_name, doc_control_user, title
FROM delta_document
SEARCH DOCUMENT CONTAINS '"corrections"'
WHERE object_name like 'QC%'
ORDER BY doc_control_user, object_name

SELECT object_name, doc_control_user, title
FROM delta_document
SEARCH DOCUMENT CONTAINS '"LINKS"' OR '"Knowledge System"'
WHERE object_name like 'IT0%'
ORDER BY doc_control_user, object_name

SELECT object_name, doc_control_user, title
FROM delta_document
SEARCH DOCUMENT CONTAINS '"Flovent Diskus"'
WHERE object_name like 'PS%'
ORDER BY doc_control_user, object_name

SELECT object_name, r_version_label, title
FROM delta_document (all)
WHERE object_name in('IT01889')
ORDER BY doc_control_user, object_name
