/* Convert rows to columns */
/* See also sum_salary_by_job-matrix.sql */

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
    sum (weight) for colour in ( 
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
  for colour in ( 
    'red' as red,  
    'blue' as blue
  ) 
);

