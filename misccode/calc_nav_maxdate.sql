-- Calculate the current total asset value of a fund (returns a scalar).
-- I use a 0 as number of shares when entering a current NAV.
-- This uses that 0 as a way of telling what is the most current price per sh.

-- Massive example of using subselects.

--               Number of shares  *  Most recent non-zero price per share.
--               _________________    ___________________________________________________________________
select distinct (select sum(shares)
                 from transacts
                 where fundid = 21
                 group by fundid
                 )                 * (select distinct pricepershare
                                      from transacts
                                      where (fundid = 21) and (trandt = (select max(trandt)
                                                                         from transacts
                                                                         where shares = 0 and fundid = 21
                                                                         )
                                                               )
                                     ) as currentval
from transacts
;
