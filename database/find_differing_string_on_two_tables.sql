-- Where missing on table 1, missing on table 2 or both disagree
 SELECT lov.*, sg.*, DECODE(value_description, country_name, 0, 1) has_trouble
FROM 
 (select lov.value_description, lov.value
 from list_of_values@sep lov, custom_list cl, custom_level_list cll
 where cl.list_name = 'Country'
 and cll.custom_list_id = cl.custom_list_id
 and lov.list_of_values_id = cll.list_of_values_id) lov
FULL JOIN 
 (select salesgroup, code, country_name
 from salesgroup_country@sep) sg ON lov.value=sg.code
ORDER BY 6 DESC, 1

-- Just both disagree (where string differs):
 SELECT lov.*, sg.*, DECODE(value_description, country_name, 0, 1) has_trouble
FROM 
 (select lov.value_description, lov.value
 from list_of_values@sep lov, custom_list cl, custom_level_list cll
 where cl.list_name = 'Country'
 and cll.custom_list_id = cl.custom_list_id
 and lov.list_of_values_id = cll.list_of_values_id) lov
LEFT JOIN 
 (select salesgroup, code, country_name
 from salesgroup_country@sep) sg ON lov.value=sg.code
WHERE DECODE(value_description, country_name, 0, 1) = 1 AND (value_description is NOT NULL AND country_name IS NOT NULL)
ORDER BY 6 DESC, 1
