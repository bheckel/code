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
