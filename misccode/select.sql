
-- Remember to never use SELECT * and write out the field names

-- Specify maximum records returned (like obs= in SAS)
SELECT * FROM funds LIMIT 10;

SELECT * FROM funds ORDER BY transdt DESC;

SELECT * FROM country ORDER BY statecode DESC LIMIT 10;
