--INNER JOIN (INNER keyword is optional)

-- implicit
select d.name, l.regional_group
from department d, location l
where d.location_id=l.location_id;

-- explicit
select d.name, l.regional_group
from department d INNER JOIN location l on d.location_id=l.location_id;


--OUTER JOIN (OUTER keyword is optional)

-- implicit
select d.name, l.regional_group
from department d, location l
where d.location_id=l.location_id (+);

-- explicit
select d.name, l.regional_group
from department d LEFT OUTER JOIN location l on d.location_id=l.location_id;

