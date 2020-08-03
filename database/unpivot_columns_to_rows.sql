create table brick_counts (
  shape varchar2(10),
  red   integer,
  green integer,
  blue  integer
);

insert into brick_counts values ( 'cube', 2, 4, 1 );
insert into brick_counts values ( 'pyramid', 1, 2, 1 );

commit;

/* Removes the columns in this list from the output. And adds two new ones.
 * These show the values from the removed columns and the name of the column each
 * value is from.
*/

/*
SHAPE     COLOUR   COLOUR_COUNT   
cube      BLUE                  1 
cube      GREEN                 4 
cube      RED                   2 
pyramid   BLUE                  1 
pyramid   GREEN                 2 
pyramid   RED                   1
*/

/* Manual - reads table 3x! */
select shape, 'RED' colour, red colour_count
from   brick_counts 
union  all 
select shape, 'GREEN' colour, green colour_count  
from   brick_counts 
union  all 
select shape, 'BLUE' colour, blue colour_count 
from   brick_counts 
order  by shape, colour;

/* Better */
select * from brick_counts 
unpivot ( 
  colour_count for colour in ( 
    red, green, blue 
  ) 
) 
order by shape, colour;

