-- Adapted: 18-Sep-2020 (Bob Heckel--Oracle DevGym) 

/*
LOGGED_DATE        LOGGED_PRICE
------------------ ------------
01-SEP-14 00:00:00          7.5
02-SEP-14 00:00:00         7.61
03-SEP-14 00:00:00         7.72
04-SEP-14 00:00:00         7.89  <--group
05-SEP-14 00:00:00         7.89  <--group
06-SEP-14 00:00:00         7.83
07-SEP-14 00:00:00         7.55
08-SEP-14 00:00:00         7.55
09-SEP-14 00:00:00         7.72
10-SEP-14 00:00:00         7.89  <--newgroup, this requirement is why we can't simply use:  dense_rank() over ( order by logged_price)
11-SEP-14 00:00:00         7.61
12-SEP-14 00:00:00         7.61
13-SEP-14 00:00:00         7.61
14-SEP-14 00:00:00         7.72
*/
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   select logged_date
        , logged_price
        , last_value(period_start IGNORE NULLS) over (
             order by logged_date
             rows between unbounded preceding and current row
          ) period_group
     from (
      select logged_date
           , logged_price
           -- those dates that have same price as the previous date get null
           , case lag(logged_price) over (order by logged_date)
                when logged_price then null         -- we've already saw the analytic give us a 7.89 in the previous iteration so make this one a null
                                  else logged_date  -- we've not seen this 7.89 yet
             end period_start
        from plch_gas_price_log
     );
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 /*
 LOGGED_DATE        LOGGED_PRICE PERIOD_GROUP      
 ------------------ ------------ ------------------
 01-SEP-14 00:00:00          7.5 01-SEP-14 00:00:00
 02-SEP-14 00:00:00         7.61 02-SEP-14 00:00:00
 03-SEP-14 00:00:00         7.72 03-SEP-14 00:00:00
 04-SEP-14 00:00:00         7.89 04-SEP-14 00:00:00  <--group
 05-SEP-14 00:00:00         7.89 04-SEP-14 00:00:00  <--group
 06-SEP-14 00:00:00         7.83 06-SEP-14 00:00:00
 07-SEP-14 00:00:00         7.55 07-SEP-14 00:00:00
 08-SEP-14 00:00:00         7.55 07-SEP-14 00:00:00
 09-SEP-14 00:00:00         7.72 09-SEP-14 00:00:00
 10-SEP-14 00:00:00         7.89 10-SEP-14 00:00:00  <--newgroup
 11-SEP-14 00:00:00         7.61 11-SEP-14 00:00:00
 12-SEP-14 00:00:00         7.61 11-SEP-14 00:00:00
 13-SEP-14 00:00:00         7.61 11-SEP-14 00:00:00
 14-SEP-14 00:00:00         7.72 14-SEP-14 00:00:00
 */

select logged_date
     , logged_price
     , dense_rank() over (
          order by period_group
       ) logged_group_id
  from (
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   select logged_date
        , logged_price
        , last_value(period_start IGNORE NULLS) over (
             order by logged_date
             rows between unbounded preceding and current row
          ) period_group
     from (
      select logged_date
           , logged_price
           , case lag(logged_price) over (order by logged_date)
                when logged_price then null
                                  else logged_date
             end period_start
        from plch_gas_price_log
     )
    --~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  )
 order by logged_date;
 /*
 LOGGED_DATE        LOGGED_PRICE LOGGED_GROUP_ID
 ------------------ ------------ ---------------
 01-SEP-14 00:00:00          7.5               1
 02-SEP-14 00:00:00         7.61               2
 03-SEP-14 00:00:00         7.72               3
 04-SEP-14 00:00:00         7.89               4  <--group
 05-SEP-14 00:00:00         7.89               4  <--group
 06-SEP-14 00:00:00         7.83               5
 07-SEP-14 00:00:00         7.55               6
 08-SEP-14 00:00:00         7.55               6
 09-SEP-14 00:00:00         7.72               7
 10-SEP-14 00:00:00         7.89               8  <--newgroup
 11-SEP-14 00:00:00         7.61               9
 12-SEP-14 00:00:00         7.61               9
 13-SEP-14 00:00:00         7.61               9
 14-SEP-14 00:00:00         7.72              10
*/

-- Better, no IGNORE NULL hacking:
select logged_date
     , logged_price
     , sum(period_start) over (
          order by logged_date
          rows between unbounded preceding and current row
       ) logged_group_id
  from (
   select logged_date
        , logged_price
        , case lag(logged_price) over (order by logged_date)
             when logged_price then 0
                               else 1
          end period_start
     from plch_gas_price_log
  )
 order by logged_date;

-- Worse, inefficient multiple table accesses
select logged_date
     , logged_price
     , (
          select count(*)
            from plch_gas_price_log g2
            join plch_gas_price_log g3
                 on g3.logged_date = g2.logged_date - 1
           where g3.logged_price != g2.logged_price
             and g2.logged_date <= g1.logged_date
       ) + 1 logged_group_id
  from plch_gas_price_log g1
 order by logged_date;
