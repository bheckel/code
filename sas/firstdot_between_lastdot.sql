/* Kirk Paul Lafler */

proc sql;
create table first_bygroup_rows as
select rating,
title,
'FirstRow' as ByGroup
from movies M1
where title =
(select min(title)
from movies M2
where M1.title = M2.title)
order by rating, title;

create table last_bygroup_rows as
select rating,
title,
'LastRow' as ByGroup
from movies M1
where title =
(select max(title)
from movies M2
where M1.title = M2.title)
order by rating, title;

create table between_bygroup_rows as
select rating,
title,
min(title) as Min_Title,
max(title) as Max_Title,
'BetweenRow' as ByGroup
from movies
group by rating
having CALCULATED min_Title NOT =
CALCULATED max_Title AND
CALCULATED min_Title NOT =
Title AND
CALCULATED max_Title NOT = Title
order by rating, title;

/***********************************************************/
/** ROUTINE.....: CONCATENATE-FIRST-BETWEEN-LAST **/
/** PURPOSE.....: Concatenate the results from the first **/
/** (min) row, between rows, and last (max) **/
/** row within each by-group, and print. **/
/***********************************************************/
create table first_between_last_rows as
select rating, title, bygroup
from first_bygroup_rows
UNION ALL
select rating, title, bygroup
from between_bygroup_rows
UNION ALL
select rating, title, bygroup
from last_bygroup_rows;
select * from first_between_last_rows;
quit;
