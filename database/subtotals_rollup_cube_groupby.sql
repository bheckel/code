
-- Use Oracle's ROLLUP, CUBE & SETS to group and subtotal more complicated queries
-- Adapted: 17-Dec-2021 (Bob Heckel-https://livesql.oracle.com/apex/livesql/s/evs32p79qszgvjfinqlh1iftw)
-- Performance - take a single trip to the database

/* Useless */
with v as (
          select 'blue' COLOR, 'cube' SHAPE from dual
union all select 'blue', 'cylinder' from dual
union all select 'green', 'cube' from dual
union all select 'red', 'cylinder' from dual
union all select 'red', 'rectangular cuboid' from dual
union all select 'yellow', 'rectangular cuboid' from dual
)
select color, shape, count(*) 
from v  
group  by color, shape
order by 1
/*
COLOR	SHAPE	COUNT(*)
blue	cube	1
blue	cylinder	1
green	cube	1
red	cylinder	1
red	rectangular cuboid	1
yellow	rectangular cuboid	1
*/

/* Add a grand total record for color instead of unioning two queries */
with v as (
          select 'blue' COLOR, 'cube' SHAPE from dual
union all select 'blue', 'cylinder' from dual
union all select 'green', 'cube' from dual
union all select 'red', 'cylinder' from dual
union all select 'red', 'rectangular cuboid' from dual
union all select 'yellow', 'rectangular cuboid' from dual
)
select color, count(*) from v
group  by ROLLUP(color)
order by 1
/*
COLOR	COUNT(*)
blue	  2
green	  1
red	    2
yellow	1
(null) 	6
*/

/* Rollup calculates the subtotals for the columns in it, working from right to
 * left. So this gives the number of rows for each color and the grand total.
 */
with v as (
          select 'blue' COLOR, 'cube' SHAPE from dual
union all select 'blue', 'cylinder' from dual
union all select 'green', 'cube' from dual
union all select 'red', 'cylinder' from dual
union all select 'red', 'rectangular cuboid' from dual
union all select 'yellow', 'rectangular cuboid' from dual
)
select color, shape, count(*) 
from v  
group  by ROLLUP(color, shape)
order by 1
/*
COLOR	SHAPE	COUNT(*)
blue	cube	    1
blue	cylinder	1
blue	 - 	      2
green	cube	     1
green	 - 	       1
red	cylinder	          1
red	rectangular cuboid	1
red	 - 	                2
yellow	rectangular cuboid	1
yellow	 - 	                1
 - 	 - 	6
*/

with v as (
          select 'blue' COLOR, 'cube' SHAPE from dual
union all select 'blue', 'cylinder' from dual
union all select 'green', 'cube' from dual
union all select 'red', 'cylinder' from dual
union all select 'red', 'rectangular cuboid' from dual
union all select 'yellow', 'rectangular cuboid' from dual
)
select color, shape, count(*)
from v
group  by ROLLUP(color), shape
order by 2,1
/*
COLOR	SHAPE	COUNT(*)
blue	cube	1
green	cube	1
 -  	cube	2
blue cylinder	1
red  cylinder	1
 -   cylinder	2
red   	rectangular cuboid	1
yellow	rectangular cuboid	1
 -    	rectangular cuboid	2
*/


/* Subtotal each color then subtotal each shape, then grand total */
with v as (
          select 'blue' COLOR, 'cube' SHAPE from dual
union all select 'blue', 'cylinder' from dual
union all select 'green', 'cube' from dual
union all select 'red', 'cylinder' from dual
union all select 'red', 'rectangular cuboid' from dual
union all select 'yellow', 'rectangular cuboid' from dual
)
select color, shape, count(*) 
from v
group  by CUBE(color, shape)
order by 1
/*
COLOR	SHAPE	COUNT(*)
blue	cube	    1             <--same as ROLLUP
blue	cylinder	1             <--same as ROLLUP
blue	 - 	      2             <--same as ROLLUP
green	cube	 1                <--same as ROLLUP
green	 - 	   1                <--same as ROLLUP
red	cylinder            1     <--same as ROLLUP
red	rectangular cuboid	1     <--same as ROLLUP
red	 - 	                2     <--same as ROLLUP
yellow	rectangular cuboid	1 <--same as ROLLUP
yellow	 - 	                1 <--same as ROLLUP
 - 	cube	              2
 - 	cylinder	          2
 - 	rectangular cuboid	2
 - 	 - 	6                     <--same as ROLLUP
*/


with v as (
          select 'blue' COLOR, 'cube' SHAPE from dual
union all select 'blue', 'cylinder' from dual
union all select 'green', 'cube' from dual
union all select 'red', 'cylinder' from dual
union all select 'red', 'rectangular cuboid' from dual
union all select 'yellow', 'rectangular cuboid' from dual
)
select color, shape, count(*) 
from v
group  by GROUPING SETS(color, shape)
--group  by GROUPING SETS(color, shape, () )  -- want grand total of 6 too
order by 1,2
/*
COLOR	SHAPE	COUNT(*)
blue	 - 	  2
green	 - 	  1
red	   -    2
yellow -  	1
 - 	cube	              2
 - 	cylinder	          2
 - 	rectangular cuboid	2
*/

