-- Make only the 100th row (of 100 rows) NULL
 select nullif(level,100)
   from dual
connect by level <= 100;

---

select level x, 
       case ceil( level / 25 )
         when 1 then 'blue'
         when 2 then 'green'
         when 3 then 'yellow'
         when 4 then 'red'
       end colour
from   dual
connect by level <= 10
/*
         X COLOUR
---------- ------
         1 blue  
         2 blue  
         3 blue  
         4 blue  
         5 blue  
         6 blue  
         7 blue  
         8 blue  
         9 blue  
        10 blue 
*/        

---

-- Want two columns with 10 of each number from 1 to 10. I.e. 1K rows.
select t.*
  from ( select level x, level y from dual connect by level <= 100 ) t,
       ( select level from dual connect by level <= 10 );
