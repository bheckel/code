CREATE TABLE zorion32822_missing as
select orion_contact_id from zorion32822@eds
MINUS
select contact_id from contact_base c 
where c.contact_id in (select orion_contact_id from zorion32822@eds);

-- same

SELECT a.*
FROM zorion32822 a LEFT JOIN contact_base b ON a.orion_contact_id=b.contact_id
WHERE b.contact_id IS NULL
