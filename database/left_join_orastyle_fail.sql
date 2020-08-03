-- http://philip.greenspun.com/sql/views.html

select users.user_id, users.email, classified_ads.posted
from users, classified_ads
where users.user_id = classified_ads.user_id(+)
and users.email like 'db%'
and classified_ads.posted > '1999-01-01'
order by users.email, posted;

       USER_ID EMAIL			                 POSTED
    ---------- ------------------------- ----------
         35102 db44@aol.com 		        1999-12-23
         40134 db@spindelvision.com 	  1999-02-04
         16979 dbdors@ev1.net		        2000-10-03
         16979 dbdors@ev1.net		        2000-10-26
        235920 dbendo@mindspring.com	  2000-08-03
        258161 dbouchar@bell.mma.edu	  2000-10-26
         39921 dbp@agora.rdrop.com		  1999-06-03
         39921 dbp@agora.rdrop.com		  1999-11-05

    8 rows selected.

-- Hey! This completely wrecked our outer join! All of the rows where the user
-- had not posted any ads have now disappeared. Why? They didn't meet the and
-- classified_ads.posted > '1999-01-01' constraint. The outer join added NULLs
-- to every column in the report where there was no corresponding row in the
-- classified_ads table. The new constraint is comparing NULL to January 1,
-- 1999 and the answer is... NULL. That's three-valued logic for you. Any
-- computation involving a NULL turns out NULL. Each WHERE clause constraint
-- must evaluate to true for a row to be kept in the result set of the SELECT.
-- What's the solution? A "view on the fly". Instead of OUTER JOINing the users
-- table to the classified_ads, we will OUTER JOIN users to a view of
-- classified_ads that contains only those ads posted since January 1, 1999:

select users.user_id, users.email, ad_view.posted
from 
  users, 
  (select * 
   from classified_ads
   where posted > '1999-01-01') ad_view
where users.user_id = ad_view.user_id(+)
and users.email like 'db%'
order by users.email, ad_view.posted;

       USER_ID EMAIL			                      POSTED
    ---------- ------------------------------ ----------
         71668 db-designs@emeraldnet.net
        112295 db1@sisna.com
        137640 db25@umail.umd.edu
         35102 db44@aol.com 		              1999-12-23
         59279 db4rs@aol.com
         95190 db@astro.com.au
         17474 db@hotmail.com
        248220 db@indianhospitality.com
         40134 db@spindelvision.com 	        1999-02-04
        144420 db_chang@yahoo.com
         15020 dbaaru@mindspring.com
    ...
    174 rows selected.

