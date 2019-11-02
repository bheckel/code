/* Convert rows to columns */
/* See also sum_salary_by_job-matrix.sql */
/* Modified: 02-Oct-2019 (Bob Heckel) */

-- Quarter's rows to columns (long to wide)
/*         _flip_
QUARTER	PROD_CATEGORY	           COUNT(*)
JAN	    Electronics	                 6398
APR	    Electronics	                 8709
JUL	    Electronics	                10283
OCT	    Electronics	                10771
JAN	    Hardware	                    944
APR	    Hardware	                    696
JUL	    Hardware	                    740
OCT	    Hardware	                    708
JAN	    Peripherals and Accessories	17923
APR	    Peripherals and Accessories	12627
JUL	    Peripherals and Accessories	14254
OCT	    Peripherals and Accessories	14047
*/
select prod_category,jan,apr,jul,oct
from (
  select to_char(trunc(s.time_id,'Q'),'MON') quarter, prod_category
  from sh.sales s, sh.products p
  where s.prod_id = p.prod_id and s.time_Id >= date '2000-01-01'
)
PIVOT ( count(*) FOR quarter IN ( 'JAN' as jan,'APR' as apr,'JUL' as jul,'OCT' as oct ) )
/*
PROD_CATEGORY	              JAN	   APR	   JUL	   OCT
Electronics	                 6398	8709	  10283	   10771
Hardware	                    944  696	    740	     708
Peripherals and Accessories	17923	12627	14254	14047
*/

-- Columns to rows unpivot
...( quantity FOR quarter IN (JAN,APR,JUL,OCT) )

---


create table bricks (
  brick_id integer,
  colour   varchar2(10),
  weight   integer
);

insert into bricks values ( 1, 'blue', 1 );
insert into bricks values ( 2, 'blue', 2 );
insert into bricks values ( 3, 'red', 1 );
insert into bricks values ( 4, 'red', 2 );
insert into bricks values ( 5, 'red', 3 );
insert into bricks values ( 6, 'green', 1 );

commit;


/* Wrong */
/*
RED   GREEN   BLUE   
    1       1      1 
    6       6      6 
    3       3      3
*/
select sum(weight) red, sum(weight) green, sum(weight) blue 
from   bricks 
group  by colour;


/* Manual 1 */
/*
RED   GREEN   BLUE   
  6       1      3 
*/
select sum(case when colour='red' then weight end) red, 
       sum(case when colour='green' then weight end) green, 
       sum(case when colour='blue' then weight end) blue 
from   bricks;

/* Manual 2 */
/*
RED   GREEN   BLUE   
  6       1      3 
*/
select sum(decode(colour, 'red', weight)) red,
       sum(decode(colour, 'green', weight)) green,
       sum(decode(colour, 'blue', weight)) blue
from bricks


/* CTE required to avoid the implicit grouping by brick_id (it's not in the pivot clause), exclude it from the input table */
/*
RED   GREEN   BLUE   
  6       1      3 
*/
with rws as ( 
  select colour, weight  
  from   bricks 
) 
  select * from rws 
  pivot ( 
    sum (weight) FOR colour IN ( 
      -- The values from the IN list, in quotes, become the headings of the new columns
      'red' as red,  
      'blue' as blue,  
      'green' as green 
    ) 
  );

/*
RED_TOTAL   RED_GREATEST   RED_MEAN   BLUE_TOTAL   BLUE_GREATEST   BLUE_MEAN   
        6              3          2            3               2         1.5
*/
with rws as ( 
  select colour, weight  
  from   bricks 
) 
select * from bricks
pivot ( 
  sum (weight) total,
  max (weight) greatest,
  avg (weight) mean
  FOR colour IN ( 
    'red' as red,  
    'blue' as blue
  ) 
);


---

/*
COLOUR	SHAPE	WEIGHT
red	    cube	  1
red	    cuboid	1
red	    pyramid	2
blue	  cube	  3
blue	  cuboid	5
blue	  pyramid	8
*/
create table bricks (
  colour varchar2(10),
  shape  varchar2(10),
  weight integer
);

insert into bricks values ( 'red', 'cube', 1 );
insert into bricks values ( 'red', 'cuboid', 1 );
insert into bricks values ( 'red', 'pyramid', 2 );
insert into bricks values ( 'blue', 'cube', 3 );
insert into bricks values ( 'blue', 'cuboid', 5 );
insert into bricks values ( 'blue', 'pyramid', 8 );
commit;

/*
COLOUR	SHAPE	WEIGHT	TOTAL_WEIGHT
red			cube		1			4
blue		cube		3			4
blue		cuboid	5			6
red			cuboid	1			6
blue		pyramid	8			10
red			pyramid	2			10
*/
select colour, shape, weight, sum ( weight ) over ( partition by shape ) total_weight  
from   bricks  

/* Pivot the rows by shape, showing the total weight for each colour as columns. Also filter the results, so the output only includes shapes with a total weight greater than five. */
/*
SHAPE	RED_TOT_WEIGHT	BLUE_TOT_WEIGHT
cuboid	1							5
pyramid	2							8
*/
with weights as (  
  select colour, shape, weight, sum (weight) over (partition by shape) total_weight 
  from   bricks 
), rws as ( 
  select colour, shape, weight 
  from   weights 
  where  total_weight > 5 
) 
  select *
  from rws 
  PIVOT ( 
    sum(weight) tot_weight FOR colour IN ('red' red, 'blue' blue) 
  ) 
  order  by shape;
